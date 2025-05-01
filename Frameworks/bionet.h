#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

typedef struct ByteArray {
  uint8_t *data;
  uintptr_t len;
} ByteArray;

struct ByteArray bionet(const uint8_t *data_ptr, uintptr_t data_len);
