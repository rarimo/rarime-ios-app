#ifndef WITNESSCALC_REGISTERIDENTITY_1_256_3_4_336_232_1_1480_5_296_H
#define WITNESSCALC_REGISTERIDENTITY_1_256_3_4_336_232_1_1480_5_296_H


#ifdef __cplusplus
extern "C" {
#endif

#define WITNESSCALC_OK                  0x0
#define WITNESSCALC_ERROR               0x1
#define WITNESSCALC_ERROR_SHORT_BUFFER  0x2

/**
 *
 * @return error code:
 *         WITNESSCALC_OK - in case of success.
 *         WITNESSCALC_ERROR - in case of an error.
 *
 * On success wtns_buffer is filled with witness data and
 * wtns_size contains the number bytes copied to wtns_buffer.
 *
 * If wtns_buffer is too small then the function returns WITNESSCALC_ERROR_SHORT_BUFFER
 * and the minimum size for wtns_buffer in wtns_size.
 *
 */

int
witnesscalc_registerIdentity_1_256_3_4_336_232_1_1480_5_296(
    const char *circuit_buffer,  unsigned long  circuit_size,
    const char *json_buffer,     unsigned long  json_size,
    char       *wtns_buffer,     unsigned long *wtns_size,
    char       *error_msg,       unsigned long  error_msg_maxsize);

#ifdef __cplusplus
}
#endif


#endif // WITNESSCALC_REGISTERIDENTITY_1_256_3_4_336_232_1_1480_5_296_H