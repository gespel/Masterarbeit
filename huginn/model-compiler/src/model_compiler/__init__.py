import torch

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
        # Convert a float32 value to int8 using a simple scaling factor
        scale = 127.0  # Scale factor for int8 range
        return int(max(min(value * scale, 127), -128))

    def compile(self, model: torch.nn.Module) -> str:
        out = ""
        defines = ""
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

                print(f"Layer: {name}, Weight shape: {weight.shape}")
                defines += f"#define NN_H{i} {weight.shape[1]}\n"
                weight_defs += f"int8_t w{i+1}[NN_H{i} * NN_H{i+1}] = {{"

                for j in range(weight.numel()):
                    weight_defs += f"{self.f32_to_int8(weight.view(-1)[j].item())}, "
                weight_defs = weight_defs[:-2]
                weight_defs += "};\n\n"

                bias_defs += f"int32_t b{i}[NN_H{i+1}];\n"
                values_defs += f"int8_t v{i}[NN_H{i}];\n"
                for j in range(weight.numel()):
                    print(f"Value at index {j}: {weight.view(-1)[j].item()}")
                i += 1
        defines += f"#define NN_H{i} {model.layers[len(model.layers)-1].out_features}\n"
        values_defs += f"int8_t v{i}[NN_H{i}];\n"

        out = f"{defines}\n{weight_defs}\n{bias_defs}\n{values_defs}"
        return out

def main() -> None:
    m = TestNetwork()
    compiler = ModelCompiler()
    print(compiler.compile(m))

if __name__ == "__main__":
    main()
