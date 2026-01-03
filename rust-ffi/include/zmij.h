#ifndef ZMIJ_FFI_H
#define ZMIJ_FFI_H

#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Zmij C FFI Interface
 * 
 * Fast floating-point to decimal string conversion.
 * Wraps the zmij Rust crate for C interoperability.
 * 
 * All format functions write UTF-8 encoded decimal strings to the provided
 * buffer and return the number of bytes written. Returns 0 if the buffer
 * is too small or invalid.
 * 
 * Recommended buffer size: 24 bytes (sufficient for all f64 values)
 */

/** Maximum buffer size needed for any floating-point number */
#define ZMIJ_BUFFER_SIZE 24

/**
 * Format a double-precision floating point number as a UTF-8 string.
 * 
 * Handles special cases:
 * - NaN produces "NaN" (3 bytes)
 * - +infinity produces "inf" (3 bytes)
 * - -infinity produces "-inf" (4 bytes)
 * - Normal values: decimal representation with minimal digits
 * 
 * \param value The f64 value to format
 * \param buf Output buffer (must be valid and writable)
 * \param buf_len Length of output buffer in bytes
 * \return Number of bytes written, or 0 if buffer too small or invalid
 */
uint32_t zmij_format_f64(double value, uint8_t *buf, uint32_t buf_len);

/**
 * Format a single-precision floating point number as a UTF-8 string.
 * 
 * Handles special cases:
 * - NaN produces "NaN" (3 bytes)
 * - +infinity produces "inf" (3 bytes)
 * - -infinity produces "-inf" (4 bytes)
 * - Normal values: decimal representation with minimal digits
 * 
 * \param value The f32 value to format
 * \param buf Output buffer (must be valid and writable)
 * \param buf_len Length of output buffer in bytes
 * \return Number of bytes written, or 0 if buffer too small or invalid
 */
uint32_t zmij_format_f32(float value, uint8_t *buf, uint32_t buf_len);

/**
 * Format a finite double-precision floating point number as a UTF-8 string.
 * 
 * Optimized variant that assumes the input is finite. Skips checks for NaN
 * and infinity, resulting in better performance.
 * 
 * WARNING: Behavior is undefined if value is NaN or infinity.
 * Always verify that the value is finite before calling this function.
 * 
 * \param value The finite f64 value to format
 * \param buf Output buffer (must be valid and writable)
 * \param buf_len Length of output buffer in bytes
 * \return Number of bytes written, or 0 if buffer too small or invalid
 */
uint32_t zmij_format_finite_f64(double value, uint8_t *buf, uint32_t buf_len);

/**
 * Format a finite single-precision floating point number as a UTF-8 string.
 * 
 * Optimized variant that assumes the input is finite. Skips checks for NaN
 * and infinity, resulting in better performance.
 * 
 * WARNING: Behavior is undefined if value is NaN or infinity.
 * Always verify that the value is finite before calling this function.
 * 
 * \param value The finite f32 value to format
 * \param buf Output buffer (must be valid and writable)
 * \param buf_len Length of output buffer in bytes
 * \return Number of bytes written, or 0 if buffer too small or invalid
 */
uint32_t zmij_format_finite_f32(float value, uint8_t *buf, uint32_t buf_len);

/**
 * Helper macros for common usage patterns
 */

/** Check if a double-precision value is finite */
#define zmij_is_finite_f64(x) (isfinite(x))

/** Check if a single-precision value is finite */
#define zmij_is_finite_f32(x) (isfinite(x))

/** Safe formatting with pre-check */
#define zmij_format_f64_safe(value, buf, buf_len) \
    zmij_format_f64((value), (buf), (buf_len))

/** Safe formatting with pre-check for f32 */
#define zmij_format_f32_safe(value, buf, buf_len) \
    zmij_format_f32((value), (buf), (buf_len))

#ifdef __cplusplus
}
#endif

#endif /* ZMIJ_FFI_H */
