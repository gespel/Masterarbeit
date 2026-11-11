import torch

LAYER_FUNCTION = """static void layer(const int16_t *in, const int16_t *w, const int16_t *b, int16_t *out, int rows, int cols, int relu) {
    for (int r = 0; r < rows; r++) {
        int32_t acc = 0;
        for (int c = 0; c < cols; c++)
            acc += (int32_t)w[r * cols + c] * (int32_t)in[c];
        acc >>= NN_SHIFT;
        acc += b[r];
        if (relu && acc < 0)
            acc = 0;
        if (acc > 127)
            acc = 127;
        if (acc < -128)
            acc = -128;
        out[r] = (int8_t)acc;
    }
}
"""


class TestNetwork(torch.nn.Module):
    def __init__(self):
        super().__init__()

        self.layers = torch.nn.Sequential(
            torch.nn.Linear(10, 16),
            torch.nn.ReLU(),
            torch.nn.Linear(16, 16),
            torch.nn.ReLU(),
            torch.nn.Linear(16, 8),
            torch.nn.ReLU(),
            torch.nn.Linear(8, 1)
        )

    def forward(self, x):
        return self.layers(x)

class ModelCompiler:
    def __init__(self) -> None:
        pass

    def f32_to_int8(self, value: float) -> int:
        scale = 128.0  # Scale factor for int8 range
        return round(max(min(value * scale, 127), -128))
    
    def f32_to_int16(self, value: float) -> int:
        scale = 32767
        return round(max(min(value * scale, 32766), -32767))

    def f32_to_int32(self, value: float) -> int:
        scale = 2147483647.0  # Scale factor for int32 range
        return round(max(min(value * scale, 2147483647), -2147483648))

    def compile(self, model: torch.nn.Module) -> str:
        out = ""
        defines = "#include <stdint.h>\n\n#define NN_SHIFT 7\n"
        weight_defs = ""
        bias_defs = ""
        values_defs = ""

        print("Compiling the model...")
        i = 0

        for name, param in model.named_modules():
            # check if the parameter is a weight or bias
            if isinstance(param, torch.nn.Linear):
                weight = param.weight
                bias = param.bias

                #print(f"Layer: {name}, Weight shape: {weight.shape}")
                defines += f"#define NN_H{i} {weight.shape[1]}\n"

                weight_defs += f"    static const int16_t w{i+1}[NN_H{i} * NN_H{i+1}] = {{"
                for j in range(weight.numel()):
                    weight_defs += f"{self.f32_to_int16(weight.view(-1)[j].item())}, "
                weight_defs = weight_defs[:-2]
                weight_defs += "};\n"

                bias_defs += f"    static const int16_t b{i+1}[NN_H{i+1}] = {{"
                for j in range(bias.numel()):
                    bias_defs += f"{self.f32_to_int16(bias.view(-1)[j].item())}, "
                bias_defs = bias_defs[:-2]
                bias_defs += "};\n"

                if i != 0:
                    values_defs += f"    static int16_t v{i}[NN_H{i}] = {{0}};\n"

                i += 1
        defines += f"#define NN_H{i} {model.layers[len(model.layers)-1].out_features}\n"
        
        out += f"{defines}\n"
        out += f"{LAYER_FUNCTION}\n"
        out += f"void neural_network(int16_t* input, int16_t* output) {{\n"
        out += f"{weight_defs}\n{bias_defs}\n{values_defs}\n"

        for k in range(i):
            if k == i-1:
                out += f"    layer(v{k}, w{k+1}, b{k+1}, output, NN_H{k+1}, NN_H{k}, 1);\n"
                out = out[:-4] + "0);\n\n"
            elif k == 0:
                out += f"    layer(input, w{k+1}, b{k+1}, v{k+1}, NN_H{k+1}, NN_H{k}, 1);\n"
            else:
                out += f"    layer(v{k}, w{k+1}, b{k+1}, v{k+1}, NN_H{k+1}, NN_H{k}, 1);\n"

        out += "}\n"
        return out

def main() -> None:
    m = TestNetwork()
    compiler = ModelCompiler()
    text = compiler.compile(m)

    with open("model.h", "w") as f:
        f.write(text)

if __name__ == "__main__":
    main()
