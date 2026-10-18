#include <dpaintrin.h>
#include <doca_dpa_dev.h>

__dpa_global__ void hello(void) {
	DOCA_DPA_DEV_LOG_INFO("Hello from DPA\n");
}

#define MAX_PRIME 10000
#define CALCULATION_ITERS 10

__dpa_global__ void calc_primes() {
	DOCA_DPA_DEV_LOG_INFO("Calculating primes up to %d with %d iterations\n", MAX_PRIME, CALCULATION_ITERS);
	uint32_t primes[MAX_PRIME];
	int num_primes = 0;
	uint64_t start_time = __dpa_thread_time();
	uint64_t start_cycles = __dpa_thread_cycles();
	for (int iter = 0; iter < CALCULATION_ITERS; iter++) {
		for (int num = 2; num <= MAX_PRIME; num++) {
			int is_prime = 1;
			for (int i = 2; i * i <= num; i++) {
				if (num % i == 0) {
					is_prime = 0;
					break;
				}
			}
			if (is_prime) {
				primes[num_primes++] = num;
				//DOCA_DPA_DEV_LOG_INFO("Prime: %d\n", num);
			}
		}
		if (iter == CALCULATION_ITERS - 1) {
			//DOCA_DPA_DEV_LOG_INFO("Iteration %d done, found %d primes\n", iter + 1, num_primes);
			break;
		}
		num_primes = 0;  // Reset for the next iteration
	}
	uint64_t end_time = __dpa_thread_time();
	uint64_t end_cycles = __dpa_thread_cycles();
	DOCA_DPA_DEV_LOG_INFO("Last calculated prime: %d\n", primes[num_primes - 1]);
	DOCA_DPA_DEV_LOG_INFO("Prime calculation took %lu ms\n", (end_time - start_time) / 1000);
	//DOCA_DPA_DEV_LOG_INFO("Prime calculation took %lu cycles\n", end_cycles - start_cycles);
	DOCA_DPA_DEV_LOG_INFO("Calculated processor frequency: %lu MHz\n", (end_cycles - start_cycles) / (end_time - start_time));
}

/*
 * Small quantized MLP (16 -> 32 -> 16 -> 2), int8 weights/activations,
 * int32 accumulators. The DPA has no FPU, so everything is integer math.
 * Weights are pseudo-random (no trained model yet) - this is a compute benchmark.
 */
#define NN_IN      16
#define NN_H1      32
#define NN_H2      16
#define NN_OUT     2
#define NN_SHIFT   7      /* requantization: acc >> NN_SHIFT */
#define NN_ITERS   10000  /* number of inferences to time */

static uint32_t xorshift32(uint32_t *s) {
	uint32_t x = *s;
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 5;
	return *s = x;
}

static void fill_rand(int8_t *buf, int n, uint32_t *seed) {
	for (int i = 0; i < n; i++)
		buf[i] = (int8_t)(xorshift32(seed) & 0xFF);
}

/* out = act(W * in + b); W is [rows][cols], row-major */
static void dense(const int8_t *in, const int8_t *w, const int32_t *b, int8_t *out, int rows, int cols, int relu) {
	for (int r = 0; r < rows; r++) {
		int32_t acc = b[r];
		for (int c = 0; c < cols; c++)
			acc += (int32_t)w[r * cols + c] * (int32_t)in[c];
		acc >>= NN_SHIFT;
		if (relu && acc < 0)
			acc = 0;
		if (acc > 127)
			acc = 127;
		if (acc < -128)
			acc = -128;
		out[r] = (int8_t)acc;
	}
}

__dpa_global__ void small_neural_network(void) {
	DOCA_DPA_DEV_LOG_INFO("Running small neural network\n");
	for(int i = 0; i < 1000; i++) {

		int8_t w1[NN_H1 * NN_IN], w2[NN_H2 * NN_H1], w3[NN_OUT * NN_H2];
		int32_t b1[NN_H1] = {0}, b2[NN_H2] = {0}, b3[NN_OUT] = {0};
		int8_t x[NN_IN], h1[NN_H1], h2[NN_H2], y[NN_OUT];
		uint32_t seed = 0x12345678;

		fill_rand(w1, sizeof(w1), &seed);
		fill_rand(w2, sizeof(w2), &seed);
		fill_rand(w3, sizeof(w3), &seed);

		uint64_t class_count[NN_OUT] = {0};
		uint64_t start_time = __dpa_thread_time();
		uint64_t start_cycles = __dpa_thread_cycles();

		for (int it = 0; it < NN_ITERS; it++) {
			fill_rand(x, NN_IN, &seed);  /* new input sample each iteration */
			dense(x, w1, b1, h1, NN_H1, NN_IN, 1);
			dense(h1, w2, b2, h2, NN_H2, NN_H1, 1);
			dense(h2, w3, b3, y, NN_OUT, NN_H2, 0);
			class_count[y[1] > y[0]]++;  /* argmax */
		}

		uint64_t end_cycles = __dpa_thread_cycles();
		uint64_t end_time = __dpa_thread_time();
		uint64_t time = end_time - start_time;
		uint64_t cycles = end_cycles - start_cycles;

		/* logging the result keeps the compiler from optimizing the loop away */
		DOCA_DPA_DEV_LOG_INFO("NN: %d inferences, class0=%lu class1=%lu\n", NN_ITERS, class_count[0], class_count[1]);
		DOCA_DPA_DEV_LOG_INFO("NN: %lu ms time, %lu cycles, %lu cycles/inference\n", time/1000, cycles, cycles / NN_ITERS);
	}
}