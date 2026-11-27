import json

LAYER_FUNCTION = """static void layer(const int16_t *in, const int16_t *w, const int16_t *b, int16_t *out, int rows, int cols, int relu) {
    for (int r = 0; r < rows; r++) {
        int64_t acc = 0;
        for (int c = 0; c < cols; c++)
            acc += (int32_t)w[r * cols + c] * (int32_t)in[c];
        acc >>= NN_SHIFT;
        acc += b[r];
        if (relu && acc < 0)
            acc = 0;
        if (acc > INT16_MAX)
            acc = INT16_MAX;
        if (acc < INT16_MIN)
            acc = INT16_MIN;
        out[r] = (int16_t)acc;
    }
}
"""
FRAC_BITS = 15
Q_SCALE = 1 << FRAC_BITS
Q_MIN, Q_MAX = -(1 << 15), (1 << 15) - 1


class ModelCompiler:
    def __init__(self) -> None:
        pass

    def compile_mlp(self, model_json: dict) -> str:
        out = ""
        defines = f"#include <stdint.h>\n\n#define NN_SHIFT {FRAC_BITS}\n"
        weight_defs = ""
        bias_defs = ""
        values_defs = ""

        #print("Compiling the model...")
        i = 0
        weights = model_json["model_def"]["weights"]
        for layer_weights in weights:
            # check if the parameter is a weight or bias

            #print(f"Layer: {name}, Weight shape: {weight.shape}")
            defines += f"#define NN_H{i} {model_json["model_def"]["layers"][i][0]}\n"

            weight_defs += f"    static const int16_t w{i+1}[NN_H{i} * NN_H{i+1}] = {{"
            for j in range(len(layer_weights)):
                weight_defs += f"{layer_weights[j]}, "
            weight_defs = weight_defs[:-2]
            weight_defs += "};\n"

            bias_defs += f"    static const int16_t b{i+1}[NN_H{i+1}] = {{"
            for j in range(len(model_json["model_def"]["biases"][i])):
                bias_defs += f"{model_json["model_def"]["biases"][i][j]}, "
            bias_defs = bias_defs[:-2]
            bias_defs += "};\n"

            if i != 0:
                values_defs += f"    int16_t v{i}[NN_H{i}];\n"

            i += 1
        defines += f"#define NN_H{i} {model_json["model_def"]["layers"][-1][1]}\n"
        
        out += f"{defines}\n"
        out += f"{LAYER_FUNCTION}\n"
        out += f"static void neural_network(const int16_t *input, int16_t *output) {{\n"
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

def main():
    import argparse

    arg = argparse.ArgumentParser()
    arg.add_argument("--model_path", type=str, required=True, help="Path to the model file")

    args = arg.parse_args()

    with open(args.model_path, "r") as f:
        model_json = json.load(f)
        model_compiler = ModelCompiler()
        c_code = model_compiler.compile_mlp(model_json)
        print(c_code)