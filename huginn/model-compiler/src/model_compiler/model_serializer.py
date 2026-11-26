import argparse
import json
import torch
import uuid
import math
import namer
from sklearn.ensemble import RandomForestClassifier

FRAC_BITS = 15
Q_SCALE = 1 << FRAC_BITS
Q_MIN, Q_MAX = -(1 << 15), (1 << 15) - 1

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

    def _serialize_random_forest(self, model: RandomForestClassifier) -> str:
        out = {}
        out["type"] = "scikit_random_forest"
        out["name"] = namer.generate(category='__all__', separator='_')
        out["model_def"] = {}
        model_def = out["model_def"]
        model_def["n_estimators"] = model.n_estimators
        model_def["n_features"] = int(model.n_features_in_)
        model_def["max_depth"] = model.max_depth
        model_def["estimators"] = []

        print("Starting serializing a scikit-learn random forest...")
        for estimator in model.estimators_:
            estimator_def = {}
            estimator_def["depth"] = estimator.get_depth()
            estimator_def["n_leaves"] = int(estimator.get_n_leaves())

            decision_tree = estimator.tree_
            estimator_def["tree"] = {}
            tree_def = estimator_def["tree"]
            tree_def["n_nodes"] = decision_tree.node_count
            tree_def["children_left"] = decision_tree.children_left.tolist()
            tree_def["children_right"] = decision_tree.children_right.tolist()
            tree_def["feature"] = decision_tree.feature.tolist()
            tree_def["threshold"] = [math.floor(threshold) for threshold in decision_tree.threshold.tolist()]
            tree_def["value"] = [[1 if v > 0.5 else 0 for v in value[0]] for value in decision_tree.value.tolist()]

            model_def["estimators"].append(estimator_def)

        return json.dumps(out, indent=4)

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
                    weight = param.weight.view(-1)[weight_index].item()
                    if isinstance(weight, float):
                        layers_weights.append(self.f32_to_int16(weight))
                    else:
                        layers_weights.append(weight)
                    #print(param.weight.view(-1)[weight_index].item())
                for bias_index in range(0, param.bias.numel()):
                    bias = param.bias.view(-1)[bias_index].item()
                    if isinstance(bias, float):
                        layers_biases.append(self.f32_to_int16(bias))
                    else:
                        layers_biases.append(bias)
                model_weights.append(layers_weights)
                model_biases.append(layers_biases)

            elif isinstance(param, torch.nn.ReLU):
                print(f"Found ReLU activation function. {name}")
        
        if list(model.named_modules())[-1][1].out_features == 1:
            model_def["model_type"] = "binary_classification"
        elif list(model.named_modules())[-1][1].out_features == list(model.named_modules())[-1][1].in_features:
            model_def["model_type"] = "autoencoder"
        return json.dumps(out, indent=4)

    def serialize(self, model) -> str:
        out = ""
        if isinstance(model, torch.nn.Module):
            out = self._serialize_torch_neural_network(model)
        elif isinstance(model, RandomForestClassifier):
            out = self._serialize_random_forest(model)

        self.model_string = out
        print(out)
        return out

    def write_to_file(self, name: str):
        with open(name, "w") as f:
            f.write(self.model_string)

class TestNetwork(torch.nn.Module):
    def __init__(self):
        super().__init__()

        self.layers = torch.nn.Sequential(
            torch.nn.Linear(8, 4),
            torch.nn.ReLU(),
            torch.nn.Linear(4, 2),
            torch.nn.ReLU(),
            torch.nn.Linear(2, 4),
            torch.nn.ReLU(),
            torch.nn.Linear(4, 8)
        )

    def forward(self, x):
        return self.layers(x)


def main():
    rf = RandomForestClassifier(n_estimators=1, max_depth=8)
    rf.fit([[1, 2], [2, 3], [4, 5], [1, 1], [2, 2]], [1, 1, 1, 0, 0])

    tn = TestNetwork()
    
    ms = ModelSerializer()
    
    ms.serialize(tn)

    #print(rf.predict([[3, 3]]))
