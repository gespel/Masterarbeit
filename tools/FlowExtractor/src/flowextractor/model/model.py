import torch
import numpy
import pandas
import tqdm
import argparse
import ipaddress
import time
from torch.utils.data import DataLoader
from flowextractor.tools.telegram import TelegramBot

# Feature order and integer arithmetic must match extract_features() in huginn/device/kernel.c.
FEATURE_COLUMNS = ["Number of Packets", "Source Port", "Destination Port", "Average Packet Size", "Minimum Packet Size", "Maximum Packet Size", "Total Bytes", "IAT Min", "IAT Max", "IAT Mean"]
LOG_SCALED_COLUMNS = ["Total Bytes", "IAT Min", "IAT Max", "IAT Mean"]

# Q0.7 fixed point as in huginn/model-compiler (NN_SHIFT 7): the int8 value q stands for q / 128.
Q_SHIFT = 7
Q_SCALE = 1 << Q_SHIFT
Q_MIN, Q_MAX = -128, 127
# kernel.c classifies a flow as malicious if out[0] > 64.
DEVICE_THRESHOLD_Q = 64
U32_MAX = 0xFFFFFFFF


def q_lin(v):
    """Saturates to 0..127 like q_lin() in kernel.c."""
    return numpy.minimum(v, 127)


def q_log2(v):
    """Like q_log2() in kernel.c: 4 steps per power of two (bit length plus the two bits after the leading one)."""
    v = numpy.asarray(v, dtype=numpy.int64)
    msb = numpy.zeros_like(v)
    for k in range(1, 32):
        msb += (v >> k) > 0
    frac = ((v << (32 - msb)) & U32_MAX) >> 30
    return numpy.where(v <= 1, 0, msb * 4 + frac)


def _u32(values):
    """Raw CSV values as the uint32 counters of struct flow; inf/NaN (e.g. IATs of single-packet flows) become 0."""
    v = numpy.nan_to_num(numpy.asarray(values, dtype=numpy.float64), nan=0.0, posinf=0.0, neginf=0.0)
    return numpy.clip(v, 0, U32_MAX).astype(numpy.int64)


def device_features(df):
    """Computes the int8 model inputs (0..127) exactly like extract_features() in kernel.c from the raw CSV columns."""
    n = _u32(df["Number of Packets"])
    src_port = _u32(df["Source Port"])
    dst_port = _u32(df["Destination Port"])

    # parse_five_tuple() orders the tuple by IP (then port), so "Source Port" on the device is the port of the lower IP.
    if "Source IP" in df.columns and "Destination IP" in df.columns:
        src_ip = numpy.array([int(ipaddress.IPv4Address(ip)) for ip in df["Source IP"]], dtype=numpy.int64)
        dst_ip = numpy.array([int(ipaddress.IPv4Address(ip)) for ip in df["Destination IP"]], dtype=numpy.int64)
        swap = (src_ip > dst_ip) | ((src_ip == dst_ip) & (src_port > dst_port))
        src_port, dst_port = numpy.where(swap, dst_port, src_port), numpy.where(swap, src_port, dst_port)

    total_bytes = _u32(df["Total Bytes"])
    pkt_min = numpy.minimum(_u32(df["Minimum Packet Size"]), 0xFFFF)
    pkt_max = numpy.minimum(_u32(df["Maximum Packet Size"]), 0xFFFF)

    # The device measures IATs in µs (__dpa_thread_time runs at 1 MHz); the CSV holds seconds.
    iat_min = _u32(numpy.rint(df["IAT Min"].to_numpy(dtype=numpy.float64) * 1e6))
    iat_max = _u32(numpy.rint(df["IAT Max"].to_numpy(dtype=numpy.float64) * 1e6))
    # The device computes iat_sum / (n - 1) on integer µs (floor). The CSV mean is a float in seconds whose round trip
    # can land just below an integer µs value (499999.9999 instead of 500000), hence the small tolerance before flooring.
    iat_mean = _u32(numpy.floor(df["IAT Mean"].to_numpy(dtype=numpy.float64) * 1e6 + 1e-3))

    return numpy.stack([
        q_lin(n),
        q_lin(src_port >> 9),
        q_lin(dst_port >> 9),
        q_lin((total_bytes // numpy.maximum(n, 1)) >> 4),
        q_lin(pkt_min >> 4),
        q_lin(pkt_max >> 4),
        q_log2(total_bytes),
        q_log2(iat_min),
        q_log2(iat_max),
        q_log2(iat_mean),
    ], axis=1).astype(numpy.int64)


def normalize_training_data(df):
    """Model inputs as the real values of the device's Q0.7 int8 features (q / 128), plus label columns."""
    features = pandas.DataFrame(device_features(df) / Q_SCALE, columns=FEATURE_COLUMNS, index=df.index)
    return pandas.concat([features, df[["Label", "Attack Type"]]], axis=1)


def _ste(x, q):
    """Straight-through estimator: forward pass uses q, backward pass uses the gradient of x."""
    return x + (q - x).detach()


def _fake_q07(t):
    """Rounds to the int8 Q0.7 grid like ModelCompiler.f32_to_int8."""
    return _ste(t, torch.clamp(torch.round(t * Q_SCALE), Q_MIN, Q_MAX) / Q_SCALE)


class Q07Linear(torch.nn.Linear):
    """Computes like layer() in model.h: int8 Q0.7 weights and bias, acc >>= 7 (floor), bias added after the shift."""

    def forward(self, x):
        acc = torch.nn.functional.linear(x, _fake_q07(self.weight))
        acc = _ste(acc, torch.floor(acc * Q_SCALE) / Q_SCALE)
        return acc + _fake_q07(self.bias)


class Q07ReLU(torch.nn.Module):
    """ReLU plus the saturation at 127 of layer() in model.h."""

    def forward(self, x):
        return torch.clamp(x, 0, Q_MAX / Q_SCALE)


class AttackDetectionNet(torch.nn.Module):
    def __init__(self):
        super().__init__()
        self.layers = torch.nn.Sequential(
            Q07Linear(10, 16),
            Q07ReLU(),
            Q07Linear(16, 16),
            Q07ReLU(),
            Q07Linear(16, 8),
            Q07ReLU(),
            Q07Linear(8, 1)
        )
        self.clip_parameters()

    def forward(self, x):
        # Shifted by the device threshold: logit > 0 corresponds to out[0] > 64 in kernel.c.
        return self.layers(x) - DEVICE_THRESHOLD_Q / Q_SCALE

    @torch.no_grad()
    def clip_parameters(self):
        """Keeps the float weights inside the int8 Q0.7 range so they cannot drift beyond what the device can represent."""
        for p in self.parameters():
            p.clamp_(Q_MIN / Q_SCALE, Q_MAX / Q_SCALE)

    def fit(self, training_data, epochs=200, learning_rate=0.001, batch_size=32, telegram_bot: TelegramBot = None):
        # The fake-quant forward pass relies on exact float32 sums; no reduced-precision matmuls.
        torch.backends.cuda.matmul.allow_tf32 = False
        torch.set_float32_matmul_precision("highest")
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
                loss = loss_fn(y_pred, y.unsqueeze(1))
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


def _export_int8(t):
    """Same conversion as ModelCompiler.f32_to_int8 (round half to even after clamping)."""
    return numpy.rint(numpy.clip(t.detach().cpu().numpy().astype(numpy.float64) * Q_SCALE, Q_MIN, Q_MAX)).astype(numpy.int64)


def dpa_inference(model, x):
    """Bit-exact integer reference of neural_network() in model.h. x: (N, 10) ints 0..127, returns out[0] per flow."""
    a = numpy.asarray(x, dtype=numpy.int64)
    linears = [layer for layer in model.layers if isinstance(layer, torch.nn.Linear)]
    for i, layer in enumerate(linears):
        acc = (a @ _export_int8(layer.weight).T) >> Q_SHIFT
        acc = acc + _export_int8(layer.bias)
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

        x = torch.tensor(training_data[FEATURE_COLUMNS].to_numpy(), dtype=torch.float32)
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

        # Metrics come from the integer reference, i.e. from what the DPA will compute.
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
