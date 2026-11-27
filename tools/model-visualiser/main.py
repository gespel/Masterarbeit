import argparse
import json
import math
import networkx as nx
from matplotlib import pyplot as plt

def main():
    arg = argparse.ArgumentParser()
    arg.add_argument("model_json_path")

    args = arg.parse_args()

    with open(args.model_json_path) as f:
        model = json.load(f)
        G = nx.Graph()

        layers = model["model_def"]["layers"]

        for layer_index in range(0, len(layers)):
            for input_node_index in range(0, layers[layer_index][0]):
                G.add_node(f"{layer_index}_{input_node_index}")

            if layer_index == len(layers) - 1:
                for output_layer_index in range(0, layers[-1][1]):
                    G.add_node(f"{layer_index + 1}_{output_layer_index}")

        for node in G.nodes:
            layer = int(node.split("_")[0])
            id = int(node.split("_")[1])

            if layer < len(layers):
                num_next_layer_nodes = layers[layer][1]

                for next_layer_node_index in range(0, num_next_layer_nodes):
                    weight = model["model_def"]["weights"][layer][next_layer_node_index * model["model_def"]["layers"][layer][0] + id]
                    red = 0
                    blue = 0
                    if weight > 0:
                        blue = weight / 32768
                    elif weight < 0:
                        red = -weight /32768
                
                    G.add_edge(f"{layer}_{id}", f"{layer + 1}_{next_layer_node_index}", color=(red, 0.0, blue, abs(weight / 32768)))
        for node in G.nodes:
            G.nodes[node]["layer"] = int(node.split("_")[0])

        pos = nx.multipartite_layout(G, subset_key="layer")
        edge_colors = [G.edges[e]["color"] for e in G.edges]
        nx.draw(G, pos, node_size=50, width=0.2, edge_color=edge_colors)
        plt.savefig("model.pdf")
        plt.show()

if __name__ == "__main__":
    main()
