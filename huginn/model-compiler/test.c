#include "model.h"
#include <stdio.h>

int main() {
    int16_t input[10]  = {1 << 8, 2 << 8, 3 << 8, 4 << 8, 5 << 8, 6 << 8, 7 << 8, 8 << 8, 9 << 8, 10 << 8};
    int16_t output[1] = {0};

    neural_network(input, output);

    printf("Output: %d\n", *output);

    return 0;
}
