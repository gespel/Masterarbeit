import torch
import numpy
import pandas
import tqdm
import argparse
import ipaddress
import time
from torch.utils.data import DataLoader
from flowextractor.tools.telegram import TelegramBot

FEATURE_COLUMNS = ["Number of Packets", "Source Port", "Destination Port", "Average Packet Size", "Minimum Packet Size", "Maximum Packet Size", "Total Bytes", "IAT Min", "IAT Max", "IAT Mean"]
LOG_SCALED_COLUMNS = ["Total Bytes", "IAT Min", "IAT Max", "IAT Mean"]

Q_SHIFT = 15
Q_SCALE = 1 << Q_SHIFT
Q_MIN, Q_MAX = -(1 << 15), (1 << 15) - 1
DEVICE_THRESHOLD_Q = 1 << (Q_SHIFT - 1)
U32_MAX = 0xFFFFFFFF


def f_lin(v, shift):
    v = numpy.asarray(v, dtype=numpy.int64)
    return numpy.where(v > (Q_MAX >> shift), Q_MAX, v << shift)


def f_log2(v):
    v = numpy.asarray(v, dtype=numpy.int64)
    msb = numpy.zeros_like(v)
    for k in range(1, 32):
        msb += (v >> k) > 0
    frac = ((v << (32 - msb)) & U32_MAX) >> 22
    return numpy.where(v <= 1, 0, (msb << 10) | frac)


def _u32(values):
    v = numpy.nan_to_num(numpy.asarray(values, dtype=numpy.float64), nan=0.0, posinf=0.0, neginf=0.0)
    return numpy.clip(v, 0, U32_MAX).astype(numpy.int64)


def device_features(df):
    n = _u32(df["Number of Packets"])
    src_port = _u32(df["Source Port"])
    dst_port = _u32(df["Destination Port"])

    if "Source IP" in df.columns and "Destination IP" in df.columns:
        src_ip = numpy.array([int(ipaddress.IPv4Address(ip)) for ip in df["Source IP"]], dtype=numpy.int64)
        dst_ip = numpy.array([int(ipaddress.IPv4Address(ip)) for ip in df["Destination IP"]], dtype=numpy.int64)
        swap = (src_ip > dst_ip) | ((src_ip == dst_ip) & (src_port > dst_port))
        src_port, dst_port = numpy.where(swap, dst_port, src_port), numpy.where(swap, src_port, dst_port)

    total_bytes = _u32(df["Total Bytes"])
    pkt_min = numpy.minimum(_u32(df["Minimum Packet Size"]), 0xFFFF)
    pkt_max = numpy.minimum(_u32(df["Maximum Packet Size"]), 0xFFFF)

    iat_min = _u32(numpy.rint(df["IAT Min"].to_numpy(dtype=numpy.float64) * 1e6))
    iat_max = _u32(numpy.rint(df["IAT Max"].to_numpy(dtype=numpy.float64) * 1e6))
    iat_mean = _u32(numpy.floor(df["IAT Mean"].to_numpy(dtype=numpy.float64) * 1e6 + 1e-3))

    return numpy.stack([
        f_lin(n, 8),
        f_lin(src_port >> 1, 0),
        f_lin(dst_port >> 1, 0),
        f_lin(total_bytes // numpy.maximum(n, 1), 4),
        f_lin(pkt_min, 4),
        f_lin(pkt_max, 4),
        f_log2(total_bytes),
        f_log2(iat_min),
        f_log2(iat_max),
        f_log2(iat_mean),
    ], axis=1).astype(numpy.int64)


def normalize_training_data(df):
    features = pandas.DataFrame(device_features(df) / Q_SCALE, columns=FEATURE_COLUMNS, index=df.index)
    return pandas.concat([features, df[["Label", "Attack Type"]]], axis=1)


def _ste(x, q):
    return x + (q - x).detach()


def _fake_q(t):
    return _ste(t, torch.clamp(torch.round(t * Q_SCALE), Q_MIN, Q_MAX) / Q_SCALE)


class QLinear(torch.nn.Linear):

    def forward(self, x):
        acc = torch.nn.functional.linear(x, _fake_q(self.weight))
        acc = _ste(acc, torch.floor(acc * Q_SCALE) / Q_SCALE)
        return acc + _fake_q(self.bias)


class QReLU(torch.nn.Module):

    def forward(self, x):
        return torch.clamp(x, 0, Q_MAX / Q_SCALE)


class AttackDetectionNet(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.layers = torch.nn.Sequential(
            QLinear(10, 16),
            QReLU(),
            QLinear(16, 16),
            QReLU(),
            QLinear(16, 8),
            QReLU(),
            QLinear(8, 1)
        )
        self.double()
        self.clip_parameters()

    def forward(self, x):
        return self.layers(x.to(torch.float64)) - DEVICE_THRESHOLD_Q / Q_SCALE

    @torch.no_grad()
    def clip_parameters(self):
        for p in self.parameters():
            p.clamp_(Q_MIN / Q_SCALE, Q_MAX / Q_SCALE)

    def fit(self, training_data, epochs=200, learning_rate=0.001, batch_size=32, telegram_bot: TelegramBot = None):
        device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"Training on {device}.")
        self.to(device)
        self.train()
        optimizer = torch.optim.Adam(self.parameters(), lr=learning_rate)
        loss_fn = torch.nn.BCEWithLogitsLoss()
        dataloader = DataLoader(training_data, batch_size=batch_size, shuffle=True)
        for epoch in tqdm.tqdm(range(epochs), desc="Training Epochs"):
            total_loss = 0
            for x, y in tqdm.tqdm(dataloader, leave=False):
                x, y = x.to(device), y.to(device)
                optimizer.zero_grad()
                y_pred = self.forward(x)
                loss = loss_fn(y_pred, y.unsqueeze(1).to(y_pred.dtype))
                loss.backward()
                optimizer.step()
                self.clip_parameters()
                total_loss += loss.item()
            tqdm.tqdm.write(f"Epoch {epoch+1}/{epochs} completed. average loss: {total_loss/len(dataloader)}")
            if telegram_bot:
                if (epoch + 1) % 50 == 0:
                    telegram_bot.send_message(793377854, f"Epoch {epoch+1}/{epochs} completed. average loss: {total_loss/len(dataloader)}")
        self.to("cpu")
        self.eval()
        print("Training finished.")


def _export_int16(t):
    return numpy.rint(numpy.clip(t.detach().cpu().numpy().astype(numpy.float64) * Q_SCALE, Q_MIN, Q_MAX)).astype(numpy.int64)


def dpa_inference(model, x):
    a = numpy.asarray(x, dtype=numpy.int64)
    linears = [layer for layer in model.layers if isinstance(layer, torch.nn.Linear)]
    for i, layer in enumerate(linears):
        acc = (a @ _export_int16(layer.weight).T) >> Q_SHIFT
        acc = acc + _export_int16(layer.bias)
        if i < len(linears) - 1:
            acc = numpy.maximum(acc, 0)
        a = numpy.clip(acc, Q_MIN, Q_MAX)
    return a[:, 0]


def print_metrics(name, y_true, y_pred, telegram_bot: TelegramBot = None):
    TP = int(((y_true == 1) & (y_pred == 1)).sum())
    FP = int(((y_true == 0) & (y_pred == 1)).sum())
    TN = int(((y_true == 0) & (y_pred == 0)).sum())
    FN = int(((y_true == 1) & (y_pred == 0)).sum())
    overall = TP + FP + TN + FN
    print(f"-> {name} ({overall} samples)")
    if overall == 0:
        print("No validation data available.")
        return
    print(f"TP: {TP} ({TP/overall * 100:.2f} %), FP: {FP} ({FP/overall * 100:.2f} %), TN: {TN} ({TN/overall * 100:.2f} %), FN: {FN} ({FN/overall * 100:.2f} %)")
    precision = TP / (TP + FP) if TP + FP > 0 else None
    recall = TP / (TP + FN) if TP + FN > 0 else None
    print(f"Precision: {precision * 100:.2f} %" if precision is not None else "Precision: N/A (No positive predictions)")
    print(f"Recall: {recall * 100:.2f} %" if recall is not None else "Recall: N/A (No actual positives)")
    if not precision or not recall:
        print("F1 Score: N/A (Cannot compute F1 score)")
    else:
        print(f"F1 Score: {2 * precision * recall / (precision + recall) * 100:.2f} %")
        if telegram_bot:
            telegram_bot.send_message(793377854, f"Metrics for {name}:\nTP: {TP}, FP: {FP}, TN: {TN}, FN: {FN}\nPrecision: {precision * 100:.2f} %, Recall: {recall * 100:.2f} %, F1 Score: {2 * precision * recall / (precision + recall) * 100:.2f} %")


def main():
    tb = TelegramBot()

    argparser = argparse.ArgumentParser(description="Train a neural network for attack detection.")
    argparser.add_argument("--feature_csv", type=str, default="flow_vectors.csv", help="Path to the CSV file containing flow features.")
    argparser.add_argument("--batch_size", type=int, default=32, help="Batch size used during training.")
    argparser.add_argument("--epochs", type=int, default=20, help="Number of Epochs used for training")
    argparser.add_argument("--dry_run", action="store_true", help="If set, the script will train the model but will not save it.")
    argparser.add_argument("--seed", type=int, default=None, help="Random seed for reproducible training.")
    argparser.add_argument("--loop", action="store_true", help="If set, the script will run in a loop, retraining the model every hour.")
    args = argparser.parse_args()

    if args.seed is not None:
        torch.manual_seed(args.seed)
    while True:
        #tb.send_message(793377854, "Starting training of the attack detection model.")
        raw_data = pandas.read_csv(args.feature_csv)
        training_data = normalize_training_data(raw_data)
        print(training_data.info())
        tb.send_message(793377854, f"Training data loaded. {len(training_data)} samples available. Starting training now...")

        x = torch.tensor(training_data[FEATURE_COLUMNS].to_numpy(), dtype=torch.float64)
        y = torch.tensor((training_data["Label"] == "malicious").to_numpy(), dtype=torch.float32)
        #is_ssh = torch.tensor(((raw_data["Source Port"] == 22) | (raw_data["Destination Port"] == 22)).to_numpy())

        # chronological split: flows are appended to the csv in recording order
        split = int(len(x) * 0.8)
        X_train, X_test = x[:split], x[split:]
        y_train, y_test = y[:split], y[split:]
        #ssh_test = is_ssh[split:]
        print(f"Train: {len(y_train)} samples ({int(y_train.sum())} malicious), Test: {len(y_test)} samples ({int(y_test.sum())} malicious)")

        m = AttackDetectionNet()
        print(m)
        m.fit(list(zip(X_train, y_train)), batch_size=args.batch_size, epochs=args.epochs, telegram_bot=tb)

        if not args.dry_run:
            torch.save(m, f"{time.strftime('%Y%m%d-%H%M%S')}.pt")

        out_q = dpa_inference(m, numpy.rint(X_test.numpy() * Q_SCALE))
        y_pred = torch.from_numpy((out_q > DEVICE_THRESHOLD_Q).astype(numpy.int32))
        y_true = y_test.int()

        with torch.no_grad():
            y_pred_train_path = (m(X_test).squeeze(1) > 0).int()
        mismatches = int((y_pred != y_pred_train_path).sum())
        if mismatches:
            print(f"WARNING: fake-quant forward pass and DPA integer reference disagree on {mismatches} of {len(y_pred)} test flows.")

        print_metrics("All flows (DPA integer inference)", y_true, y_pred, telegram_bot=tb)
        #print_metrics("SSH flows only", y_true[ssh_test], y_pred[ssh_test], telegram_bot=tb)
        #print_metrics("Baseline: port 22 => malicious", y_true, ssh_test.int(), telegram_bot=tb)

        if not args.loop:
            break

        time.sleep(1800)


if __name__ == "__main__":
    main()
