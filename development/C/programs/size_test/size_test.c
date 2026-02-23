#include <stdint.h>

uint64_t size_test() {
    int n = 32;
    uint8_t list[32];

    for (int i = 0; i < n; i++) {
        list[i] = (uint8_t)(i);
    }

    uint8_t  a = list[0];
    uint8_t  b = list[1];
    uint16_t c = *(uint16_t*)&list[0];
    uint16_t d = *(uint16_t*)&list[2];
    uint32_t e = *(uint32_t*)&list[0];
    uint32_t f = *(uint32_t*)&list[4];
    uint64_t g = *(uint64_t*)&list[0];
    uint64_t h = *(uint64_t*)&list[8];

    return (uint64_t)a + b + c + d + e + f + g + h;
}
