#include "model.h"
#include <stdio.h>

int main() {
    int8_t input[10]  = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int8_t output[1] = {0};

    neural_network(input, output);

    printf("Output: %d\n", *output);

    return 0;
}