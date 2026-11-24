import argparse
import json
import torch
import uuid
import namer

FRAC_BITS = 15
Q_SCALE = 1 << FRAC_BITS
Q_MIN, Q_MAX = -(1 << 15), (1 << 15) - 1

class TestModel(torch.nn.Module):
    def __init__(self):
        super().__init__()

        self.layers = torch.nn.Sequential(
            torch.nn.Linear(4, 4),
            torch.nn.ReLU(),
            torch.nn.Linear(4, 2),
            torch.nn.ReLU(),
            torch.nn.Linear(2, 1)
        )

    def forward(self, x):
        return self.layers(x)


class ModelSerializer:
    def __init__(self):
        print("ModelSerializer initialized!")
        self.model_string = ""

    def f32_to_int8(self, value: float) -> int:
        scale = 128.0
        return round(max(min(value * scale, 127), -128))
    
    def f32_to_int16(self, value: float) -> int:
        return round(max(min(value * Q_SCALE, Q_MAX), Q_MIN))

    def f32_to_int32(self, value: float) -> int:
        scale = 2147483647.0
        return round(max(min(value * scale, 2147483647), -2147483648))

    def _serialize_torch_neural_network(self, model) -> str:
        out = {}
        print("Starting serializing a pytorch model...")
        out["type"] = "torch_neural_network"
        out["name"] = namer.generate(category='__all__', separator='_')
        print(model)
        out["model_def"] = {}
        
        model_def = out["model_def"]
        model_def["layers"] = []
        model_def["weights"] = []
        model_def["biases"] = []
        
        model_layers = model_def["layers"]
        model_weights = model_def["weights"]
        model_biases = model_def["biases"]

        for name, param in model.named_modules():
            if isinstance(param, torch.nn.Linear):
                print(f"Found Linear layer. {name}")
                model_layers.append((param.in_features, param.out_features))
                layers_weights = []
                layers_biases = []
                for weight_index in range(0, param.weight.numel()):
                    layers_weights.append(self.f32_to_int16(param.weight.view(-1)[weight_index].item()))
                    #print(param.weight.view(-1)[weight_index].item())
                for bias_index in range(0, param.bias.numel()):
                    layers_biases.append(self.f32_to_int16(param.bias.view(-1)[bias_index].item()))
                model_weights.append(layers_weights)
                model_biases.append(layers_biases)

            elif isinstance(param, torch.nn.ReLU):
                print(f"Found ReLU activation function. {name}")
        
        if list(model.named_modules())[-1][1].out_features == 1:
            model_def["model_type"] = "binary_classification"
        return json.dumps(out, indent=4)

    def serialize(self, model) -> str:
        out = ""
        if isinstance(model, torch.nn.Module):
            out = self._serialize_torch_neural_network(model)

        self.model_string = out
        print(out)
        return out

    def write_to_file(self, name: str):
        with open(name, "w") as f:
            f.write(self.model_string)

if __name__ == "__main__":
    model_serializer = ModelSerializer()

    model = TestModel()

    model_serializer.serialize(model)
    model_serializer.write_to_file("test_model.json")
