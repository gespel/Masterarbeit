#include <doca_dpa_dev.h>

__dpa_global__ void hello(void) {
	DOCA_DPA_DEV_LOG_INFO("Hello from DPA\n");
}

__dpa_global__ void calc_primes(int max) {
	for (int num = 2; num <= max; num++) {
		int is_prime = 1;
		for (int i = 2; i * i <= num; i++) {
			if (num % i == 0) {
				is_prime = 0;
				break;
			}
		}
		/*if (is_prime) {
			DOCA_DPA_DEV_LOG_INFO("Prime: %d\n", num);
		}*/
	}
}