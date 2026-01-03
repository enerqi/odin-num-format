use std::slice;

// ============================================================================
// Zmij C FFI Wrappers - Fast floating point to string conversion
// ============================================================================
// All functions write UTF-8 formatted output to the provided buffer
// and return the number of bytes written (0 if buffer too small)

// ============================================================================
// itoa C FFI Wrappers - Fast integer to string conversion
// ============================================================================
// All functions write UTF-8 formatted output to the provided buffer
// and return the number of bytes written (0 if buffer too small)

// Buffer size constants - itoa uses i128::MAX_STR_LEN internally (40 bytes)
const ITOA_BUFFER_SIZE: usize = 40; // i128::MAX_STR_LEN, covers all integer types

/// Format f64 floating point to string
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - buf_len should be >= 24 for guaranteed success
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn zmij_format_f64(value: f64, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < std::mem::size_of::<zmij::Buffer>() {
        return 0;
    }

    // Safety: buf is valid for at least 24 bytes (size of Buffer)
    unsafe {
        // Cast caller's buffer as Buffer (no need to initialize, Buffer fields are MaybeUninit)
        let buffer_ptr = buf as *mut zmij::Buffer;
        // std::ptr::write(buffer_ptr, zmij::Buffer::new()); // not needed, Buffer fields are MaybeUninit

        // Format directly into that memory
        let formatted = (*buffer_ptr).format(value);
        let bytes = formatted.as_bytes();

        // If format() returned a static string (NaN/inf), copy it into buf
        // Otherwise, the output is already in buf
        if bytes.as_ptr() != buf as *const u8 {
            let out = slice::from_raw_parts_mut(buf, buf_len);
            out[..bytes.len()].copy_from_slice(bytes);
        }

        bytes.len()
    }
}

/// Format f32 floating point to string
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - buf_len should be >= 24 for guaranteed success
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn zmij_format_f32(value: f32, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < std::mem::size_of::<zmij::Buffer>() {
        return 0;
    }

    // Safety: buf is valid for at least 24 bytes (size of Buffer)
    unsafe {
        // Cast caller's buffer as Buffer (no need to initialize, Buffer fields are MaybeUninit)
        let buffer_ptr = buf as *mut zmij::Buffer;
        // std::ptr::write(buffer_ptr, zmij::Buffer::new()); // not needed, Buffer fields are MaybeUninit

        // Format directly into that memory
        let formatted = (*buffer_ptr).format(value);
        let bytes = formatted.as_bytes();

        // If format() returned a static string (NaN/inf), copy it into buf
        // Otherwise, the output is already in buf
        if bytes.as_ptr() != buf as *const u8 {
            let out = slice::from_raw_parts_mut(buf, buf_len);
            out[..bytes.len()].copy_from_slice(bytes);
        }

        bytes.len()
    }
}

/// Format f64 assuming it is finite (no NaN/inf checks)
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - value must be a finite floating point number (not NaN or infinity)
/// - buf_len should be >= 24 for guaranteed success
///
/// # Undefined Behavior
/// Calling with non-finite values produces unspecified output
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn zmij_format_finite_f64(value: f64, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < std::mem::size_of::<zmij::Buffer>() {
        return 0;
    }

    // Safety: buf is valid for at least 24 bytes (size of Buffer)
    unsafe {
        // Cast caller's buffer as Buffer (no need to initialize, Buffer fields are MaybeUninit)
        let buffer_ptr = buf as *mut zmij::Buffer;
        // std::ptr::write(buffer_ptr, zmij::Buffer::new()); // not needed, Buffer fields are MaybeUninit

        // Format directly into that memory; output is now at buf[0..len]
        let formatted = (*buffer_ptr).format_finite(value);
        let bytes = formatted.as_bytes();

        bytes.len()
    }
}

/// Format f32 assuming it is finite (no NaN/inf checks)
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - value must be a finite floating point number (not NaN or infinity)
/// - buf_len should be >= 24 for guaranteed success
///
/// # Undefined Behavior
/// Calling with non-finite values produces unspecified output
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn zmij_format_finite_f32(value: f32, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < std::mem::size_of::<zmij::Buffer>() {
        return 0;
    }

    // Safety: buf is valid for at least 24 bytes (size of Buffer)
    unsafe {
        // Cast caller's buffer as Buffer (no need to initialize, Buffer fields are MaybeUninit)
        let buffer_ptr = buf as *mut zmij::Buffer;
        // std::ptr::write(buffer_ptr, zmij::Buffer::new()); // not needed, Buffer fields are MaybeUninit

        // Format directly into that memory; output is now at buf[0..len]
        let formatted = (*buffer_ptr).format_finite(value);
        let bytes = formatted.as_bytes();

        bytes.len()
    }
}

/// Format i64 integer to UTF-8 string
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - buf_len should be >= 40 for guaranteed success
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn rust_itoa_i64(value: i64, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < ITOA_BUFFER_SIZE {
        return 0;
    }

    unsafe {
        // Cast caller's buffer as itoa::Buffer
        let buffer_ptr = buf as *mut itoa::Buffer;
        // Format directly into that memory
        let formatted = (*buffer_ptr).format(value);
        let bytes = formatted.as_bytes();

        // Only copy if the byte slice is not the same memory as buf
        if bytes.as_ptr() != buf as *const u8 {
            // Use ptr::copy to handle potential overlap
            std::ptr::copy(bytes.as_ptr(), buf, bytes.len());
        }

        bytes.len()
    }
}

/// Format u64 integer to UTF-8 string
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - buf_len should be >= 40 for guaranteed success
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn rust_itoa_u64(value: u64, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < ITOA_BUFFER_SIZE {
        return 0;
    }

    unsafe {
        // Cast caller's buffer as itoa::Buffer
        let buffer_ptr = buf as *mut itoa::Buffer;
        // Format directly into that memory
        let formatted = (*buffer_ptr).format(value);
        let bytes = formatted.as_bytes();

        // Only copy if the byte slice is not the same memory as buf
        if bytes.as_ptr() != buf as *const u8 {
            // Use ptr::copy to handle potential overlap
            std::ptr::copy(bytes.as_ptr(), buf, bytes.len());
        }

        bytes.len()
    }
}

/// Format i32 integer to UTF-8 string
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - buf_len should be >= 40 for guaranteed success
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn rust_itoa_i32(value: i32, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < ITOA_BUFFER_SIZE {
        return 0;
    }

    unsafe {
        // Cast caller's buffer as itoa::Buffer
        let buffer_ptr = buf as *mut itoa::Buffer;
        // Format directly into that memory
        let formatted = (*buffer_ptr).format(value);
        let bytes = formatted.as_bytes();

        // Only copy if the byte slice is not the same memory as buf
        if bytes.as_ptr() != buf as *const u8 {
            // Use ptr::copy to handle potential overlap
            std::ptr::copy(bytes.as_ptr(), buf, bytes.len());
        }

        bytes.len()
    }
}

/// Format u32 integer to UTF-8 string
///
/// # Safety
/// - buf must be a valid mutable pointer to at least buf_len bytes
/// - buf_len should be >= 40 for guaranteed success
///
/// # Returns
/// Number of bytes written to buffer, or 0 if buffer was too small
#[unsafe(no_mangle)]
pub extern "C" fn rust_itoa_u32(value: u32, buf: *mut u8, buf_len: usize) -> usize {
    if buf.is_null() || buf_len < ITOA_BUFFER_SIZE {
        return 0;
    }

    unsafe {
        // Cast caller's buffer as itoa::Buffer
        let buffer_ptr = buf as *mut itoa::Buffer;
        // Format directly into that memory
        let formatted = (*buffer_ptr).format(value);
        let bytes = formatted.as_bytes();

        // Only copy if the byte slice is not the same memory as buf
        if bytes.as_ptr() != buf as *const u8 {
            // Use ptr::copy to handle potential overlap
            std::ptr::copy(bytes.as_ptr(), buf, bytes.len());
        }

        bytes.len()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::str;

    // ========================================================================
    // Test Helper Functions
    // ========================================================================

    fn format_f64_test(value: f64) -> String {
        let mut buf = [0u8; 24];
        let len = zmij_format_f64(value, buf.as_mut_ptr(), buf.len());
        assert!(len > 0, "zmij_format_f64 failed for value: {}", value);
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn format_f32_test(value: f32) -> String {
        let mut buf = [0u8; 24];
        let len = zmij_format_f32(value, buf.as_mut_ptr(), buf.len());
        assert!(len > 0, "zmij_format_f32 failed for value: {}", value);
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn format_finite_f64_test(value: f64) -> String {
        let mut buf = [0u8; 24];
        let len = zmij_format_finite_f64(value, buf.as_mut_ptr(), buf.len());
        assert!(
            len > 0,
            "zmij_format_finite_f64 failed for value: {}",
            value
        );
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn format_finite_f32_test(value: f32) -> String {
        let mut buf = [0u8; 24];
        let len = zmij_format_finite_f32(value, buf.as_mut_ptr(), buf.len());
        assert!(
            len > 0,
            "zmij_format_finite_f32 failed for value: {}",
            value
        );
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn itoa_i64_test(value: i64) -> String {
        let mut buf = [0u8; 40]; // i128::MAX_STR_LEN
        let len = rust_itoa_i64(value, buf.as_mut_ptr(), buf.len());
        assert!(len > 0, "rust_itoa_i64 failed for value: {}", value);
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn itoa_u64_test(value: u64) -> String {
        let mut buf = [0u8; 40]; // i128::MAX_STR_LEN
        let len = rust_itoa_u64(value, buf.as_mut_ptr(), buf.len());
        assert!(len > 0, "rust_itoa_u64 failed for value: {}", value);
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn itoa_i32_test(value: i32) -> String {
        let mut buf = [0u8; 40]; // i128::MAX_STR_LEN
        let len = rust_itoa_i32(value, buf.as_mut_ptr(), buf.len());
        assert!(len > 0, "rust_itoa_i32 failed for value: {}", value);
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    fn itoa_u32_test(value: u32) -> String {
        let mut buf = [0u8; 40]; // i128::MAX_STR_LEN
        let len = rust_itoa_u32(value, buf.as_mut_ptr(), buf.len());
        assert!(len > 0, "rust_itoa_u32 failed for value: {}", value);
        String::from_utf8_lossy(&buf[..len]).into_owned()
    }

    // ========================================================================
    // zmij_format_f64 Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_zero() {
        let result = format_f64_test(0.0);
        assert_eq!(result, "0.0");
    }

    #[test]
    fn test_zmij_format_f64_negative_zero() {
        let result = format_f64_test(-0.0);
        assert_eq!(result, "-0.0");
    }

    #[test]
    fn test_zmij_format_f64_simple_positive() {
        let result = format_f64_test(3.14159);
        assert_eq!(result, "3.14159");
    }

    #[test]
    fn test_zmij_format_f64_simple_negative() {
        let result = format_f64_test(-42.5);
        assert_eq!(result, "-42.5");
    }

    #[test]
    fn test_zmij_format_f64_large_integer() {
        let result = format_f64_test(123456789.0);
        assert_eq!(result, "123456789.0");
    }

    #[test]
    fn test_zmij_format_f64_very_small() {
        let result = format_f64_test(1e-10);
        // Should be in scientific notation
        assert!(!result.is_empty());
        let parsed: f64 = result.parse().expect("output should be parseable");
        assert!((parsed - 1e-10).abs() < 1e-20);
    }

    #[test]
    fn test_zmij_format_f64_very_large() {
        let result = format_f64_test(1e20);
        assert!(!result.is_empty());
        let parsed: f64 = result.parse().expect("output should be parseable");
        assert!((parsed - 1e20).abs() < 1e10);
    }

    #[test]
    fn test_zmij_format_f64_nan() {
        let result = format_f64_test(f64::NAN);
        assert_eq!(result, "NaN");
    }

    #[test]
    fn test_zmij_format_f64_positive_infinity() {
        let result = format_f64_test(f64::INFINITY);
        assert_eq!(result, "inf");
    }

    #[test]
    fn test_zmij_format_f64_negative_infinity() {
        let result = format_f64_test(f64::NEG_INFINITY);
        assert_eq!(result, "-inf");
    }

    #[test]
    fn test_zmij_format_f64_pi() {
        let result = format_f64_test(std::f64::consts::PI);
        // Just verify it's not empty and roughly correct
        assert!(!result.is_empty());
        let parsed: f64 = result.parse().expect("output should be parseable");
        assert!((parsed - std::f64::consts::PI).abs() < 1e-15);
    }

    #[test]
    fn test_zmij_format_f64_e() {
        let result = format_f64_test(std::f64::consts::E);
        assert!(!result.is_empty());
        let parsed: f64 = result.parse().expect("output should be parseable");
        assert!((parsed - std::f64::consts::E).abs() < 1e-15);
    }

    #[test]
    fn test_zmij_format_f64_one() {
        let result = format_f64_test(1.0);
        assert_eq!(result, "1.0");
    }

    #[test]
    fn test_zmij_format_f64_negative_one() {
        let result = format_f64_test(-1.0);
        assert_eq!(result, "-1.0");
    }

    #[test]
    fn test_zmij_format_f64_tenth() {
        let result = format_f64_test(0.1);
        assert_eq!(result, "0.1");
    }

    // ========================================================================
    // zmij_format_f32 Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f32_zero() {
        let result = format_f32_test(0.0f32);
        assert_eq!(result, "0.0");
    }

    #[test]
    fn test_zmij_format_f32_simple_positive() {
        let result = format_f32_test(3.14f32);
        assert_eq!(result, "3.14");
    }

    #[test]
    fn test_zmij_format_f32_simple_negative() {
        let result = format_f32_test(-42.5f32);
        assert_eq!(result, "-42.5");
    }

    #[test]
    fn test_zmij_format_f32_nan() {
        let result = format_f32_test(f32::NAN);
        assert_eq!(result, "NaN");
    }

    #[test]
    fn test_zmij_format_f32_positive_infinity() {
        let result = format_f32_test(f32::INFINITY);
        assert_eq!(result, "inf");
    }

    #[test]
    fn test_zmij_format_f32_negative_infinity() {
        let result = format_f32_test(f32::NEG_INFINITY);
        assert_eq!(result, "-inf");
    }

    #[test]
    fn test_zmij_format_f32_one() {
        let result = format_f32_test(1.0f32);
        assert_eq!(result, "1.0");
    }

    #[test]
    fn test_zmij_format_f32_large() {
        let result = format_f32_test(1e10f32);
        assert!(!result.is_empty());
        let parsed: f32 = result.parse().expect("output should be parseable");
        assert!((parsed - 1e10).abs() < 1e6);
    }

    // ========================================================================
    // zmij_format_finite_f64 Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_finite_f64_zero() {
        let result = format_finite_f64_test(0.0);
        assert_eq!(result, "0.0");
    }

    #[test]
    fn test_zmij_format_finite_f64_simple() {
        let result = format_finite_f64_test(123.456);
        assert_eq!(result, "123.456");
    }

    #[test]
    fn test_zmij_format_finite_f64_negative() {
        let result = format_finite_f64_test(-99.99);
        assert_eq!(result, "-99.99");
    }

    #[test]
    fn test_zmij_format_finite_f64_very_small() {
        let result = format_finite_f64_test(1.23e-50);
        assert!(!result.is_empty());
    }

    #[test]
    fn test_zmij_format_finite_f64_very_large() {
        let result = format_finite_f64_test(1.23e50);
        assert!(!result.is_empty());
    }

    // ========================================================================
    // zmij_format_finite_f32 Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_finite_f32_zero() {
        let result = format_finite_f32_test(0.0f32);
        assert_eq!(result, "0.0");
    }

    #[test]
    fn test_zmij_format_finite_f32_simple() {
        let result = format_finite_f32_test(45.67f32);
        assert_eq!(result, "45.67");
    }

    #[test]
    fn test_zmij_format_finite_f32_negative() {
        let result = format_finite_f32_test(-8.9f32);
        assert_eq!(result, "-8.9");
    }

    // ========================================================================
    // Buffer Size Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_buffer_too_small() {
        let value = 12345678.90123456;
        let mut buf = [0u8; 2]; // Way too small
        let len = zmij_format_f64(value, buf.as_mut_ptr(), buf.len());
        // Should return 0 indicating failure
        assert_eq!(len, 0, "Should return 0 for buffer too small");
    }

    #[test]
    fn test_zmij_format_f32_buffer_too_small() {
        let value = 12345.6f32;
        let mut buf = [0u8; 1];
        let len = zmij_format_f32(value, buf.as_mut_ptr(), buf.len());
        assert_eq!(len, 0, "Should return 0 for buffer too small");
    }

    #[test]
    fn test_zmij_format_f64_minimal_buffer() {
        // Try with a very small but non-zero buffer
        let value = 1.0;
        let mut buf = [0u8; 1];
        let len = zmij_format_f64(value, buf.as_mut_ptr(), buf.len());
        // "1" is 1 byte, so this might succeed
        assert!(len <= 1);
    }

    #[test]
    fn test_zmij_format_f64_null_buffer() {
        let value = 3.14;
        let len = zmij_format_f64(value, std::ptr::null_mut(), 24);
        assert_eq!(len, 0, "Should return 0 for null buffer");
    }

    #[test]
    fn test_zmij_format_f32_null_buffer() {
        let value = 3.14f32;
        let len = zmij_format_f32(value, std::ptr::null_mut(), 24);
        assert_eq!(len, 0, "Should return 0 for null buffer");
    }

    #[test]
    fn test_zmij_format_f64_zero_buffer_len() {
        let mut buf = [0u8; 24];
        let len = zmij_format_f64(42.0, buf.as_mut_ptr(), 0);
        assert_eq!(len, 0, "Should return 0 for zero buffer length");
    }

    #[test]
    fn test_zmij_format_finite_f64_null_buffer() {
        let len = zmij_format_finite_f64(1.23, std::ptr::null_mut(), 24);
        assert_eq!(len, 0, "Should return 0 for null buffer");
    }

    // ========================================================================
    // UTF-8 Validation Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_output_is_valid_utf8() {
        let mut buf = [0u8; 24];
        let len = zmij_format_f64(3.14159, buf.as_mut_ptr(), buf.len());
        let result = str::from_utf8(&buf[..len]);
        assert!(result.is_ok(), "Output should be valid UTF-8");
    }

    #[test]
    fn test_zmij_format_f32_output_is_valid_utf8() {
        let mut buf = [0u8; 24];
        let len = zmij_format_f32(2.71828f32, buf.as_mut_ptr(), buf.len());
        let result = str::from_utf8(&buf[..len]);
        assert!(result.is_ok(), "Output should be valid UTF-8");
    }

    #[test]
    fn test_zmij_format_finite_f64_output_is_valid_utf8() {
        let mut buf = [0u8; 24];
        let len = zmij_format_finite_f64(999.999, buf.as_mut_ptr(), buf.len());
        let result = str::from_utf8(&buf[..len]);
        assert!(result.is_ok(), "Output should be valid UTF-8");
    }

    // ========================================================================
    // Round-trip Tests (format and parse back)
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_roundtrip() {
        let original = 1234.5678;
        let result = format_f64_test(original);
        let parsed: f64 = result.parse().expect("Should parse back to f64");
        assert_eq!(parsed, original);
    }

    #[test]
    fn test_zmij_format_f32_roundtrip() {
        let original = 123.45f32;
        let result = format_f32_test(original);
        let parsed: f32 = result.parse().expect("Should parse back to f32");
        assert_eq!(parsed, original);
    }

    // ========================================================================
    // Edge Case Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_min_positive_normal() {
        let result = format_f64_test(f64::MIN_POSITIVE);
        assert!(!result.is_empty());
        assert!(result.len() <= 24);
    }

    #[test]
    fn test_zmij_format_f64_max() {
        let result = format_f64_test(f64::MAX);
        assert!(!result.is_empty());
        assert!(result.len() <= 24);
    }

    #[test]
    fn test_zmij_format_f32_min_positive_normal() {
        let result = format_f32_test(f32::MIN_POSITIVE);
        assert!(!result.is_empty());
    }

    #[test]
    fn test_zmij_format_f32_max() {
        let result = format_f32_test(f32::MAX);
        assert!(!result.is_empty());
    }

    // ========================================================================
    // Multiple Values Test
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_sequence() {
        let values = vec![0.0, 1.0, -1.0, 0.5, -0.5, 100.0, 1e10, 1e-10];
        for value in values {
            let result = format_f64_test(value);
            assert!(!result.is_empty(), "Format failed for {}", value);
            let parsed: f64 = result.parse().expect("Should be parseable");
            // Allow small floating point errors
            let error = (parsed - value).abs();
            let tolerance = value.abs() * 1e-14 + 1e-100;
            assert!(
                error < tolerance,
                "Round-trip error too large: {} -> {} (error: {})",
                value,
                parsed,
                error
            );
        }
    }

    #[test]
    fn test_zmij_format_f32_sequence() {
        let values = vec![0.0f32, 1.0, -1.0, 0.5, -0.5, 100.0, 1e6, 1e-6];
        for value in values {
            let result = format_f32_test(value);
            assert!(!result.is_empty(), "Format failed for {}", value);
            let parsed: f32 = result.parse().expect("Should be parseable");
            let error = (parsed - value).abs();
            // For zero, special case
            if value == 0.0 {
                assert_eq!(parsed, 0.0, "Zero should parse back to zero");
            } else {
                let tolerance = value.abs() * 1e-6 + 1e-100;
                assert!(
                    error < tolerance,
                    "Round-trip error too large: {} -> {} (error: {})",
                    value,
                    parsed,
                    error
                );
            }
        }
    }

    // ========================================================================
    // rust_itoa_i64 Tests
    // ========================================================================

    #[test]
    fn test_itoa_i64_zero() {
        let result = itoa_i64_test(0);
        assert_eq!(result, "0");
    }

    #[test]
    fn test_itoa_i64_positive() {
        let result = itoa_i64_test(42);
        assert_eq!(result, "42");
    }

    #[test]
    fn test_itoa_i64_negative() {
        let result = itoa_i64_test(-42);
        assert_eq!(result, "-42");
    }

    #[test]
    fn test_itoa_i64_large_positive() {
        let result = itoa_i64_test(9223372036854775807); // i64::MAX
        assert_eq!(result, "9223372036854775807");
    }

    #[test]
    fn test_itoa_i64_large_negative() {
        let result = itoa_i64_test(-9223372036854775808); // i64::MIN
        assert_eq!(result, "-9223372036854775808");
    }

    #[test]
    fn test_itoa_i64_roundtrip() {
        let values = vec![0, 1, -1, 42, -42, 1000000, -1000000];
        for value in values {
            let result = itoa_i64_test(value);
            let parsed: i64 = result.parse().expect("Should parse back to i64");
            assert_eq!(parsed, value);
        }
    }

    // ========================================================================
    // rust_itoa_u64 Tests
    // ========================================================================

    #[test]
    fn test_itoa_u64_zero() {
        let result = itoa_u64_test(0);
        assert_eq!(result, "0");
    }

    #[test]
    fn test_itoa_u64_positive() {
        let result = itoa_u64_test(42);
        assert_eq!(result, "42");
    }

    #[test]
    fn test_itoa_u64_max() {
        let result = itoa_u64_test(18446744073709551615); // u64::MAX
        assert_eq!(result, "18446744073709551615");
    }

    #[test]
    fn test_itoa_u64_roundtrip() {
        let values = vec![0, 1, 42, 1000000, 9999999999];
        for value in values {
            let result = itoa_u64_test(value);
            let parsed: u64 = result.parse().expect("Should parse back to u64");
            assert_eq!(parsed, value);
        }
    }

    // ========================================================================
    // rust_itoa_i32 Tests
    // ========================================================================

    #[test]
    fn test_itoa_i32_zero() {
        let result = itoa_i32_test(0);
        assert_eq!(result, "0");
    }

    #[test]
    fn test_itoa_i32_positive() {
        let result = itoa_i32_test(42);
        assert_eq!(result, "42");
    }

    #[test]
    fn test_itoa_i32_negative() {
        let result = itoa_i32_test(-42);
        assert_eq!(result, "-42");
    }

    #[test]
    fn test_itoa_i32_max() {
        let result = itoa_i32_test(2147483647); // i32::MAX
        assert_eq!(result, "2147483647");
    }

    #[test]
    fn test_itoa_i32_min() {
        let result = itoa_i32_test(-2147483648); // i32::MIN
        assert_eq!(result, "-2147483648");
    }

    // ========================================================================
    // rust_itoa_u32 Tests
    // ========================================================================

    #[test]
    fn test_itoa_u32_zero() {
        let result = itoa_u32_test(0);
        assert_eq!(result, "0");
    }

    #[test]
    fn test_itoa_u32_positive() {
        let result = itoa_u32_test(42);
        assert_eq!(result, "42");
    }

    #[test]
    fn test_itoa_u32_max() {
        let result = itoa_u32_test(4294967295); // u32::MAX
        assert_eq!(result, "4294967295");
    }

    // ========================================================================
    // itoa Buffer Validation Tests
    // ========================================================================

    #[test]
    fn test_itoa_i64_output_is_valid_utf8() {
        let mut buf = [0u8; 25];
        let len = rust_itoa_i64(42, buf.as_mut_ptr(), buf.len());
        let result = str::from_utf8(&buf[..len]);
        assert!(result.is_ok(), "Output should be valid UTF-8");
    }

    #[test]
    fn test_itoa_u64_output_is_valid_utf8() {
        let mut buf = [0u8; 25];
        let len = rust_itoa_u64(42, buf.as_mut_ptr(), buf.len());
        let result = str::from_utf8(&buf[..len]);
        assert!(result.is_ok(), "Output should be valid UTF-8");
    }

    #[test]
    fn test_itoa_i32_null_buffer() {
        let len = rust_itoa_i32(42, std::ptr::null_mut(), 25);
        assert_eq!(len, 0, "Should return 0 for null buffer");
    }

    #[test]
    fn test_itoa_u64_null_buffer() {
        let len = rust_itoa_u64(42, std::ptr::null_mut(), 25);
        assert_eq!(len, 0, "Should return 0 for null buffer");
    }

    #[test]
    fn test_itoa_i64_zero_buffer_len() {
        let mut buf = [0u8; 25];
        let len = rust_itoa_i64(42, buf.as_mut_ptr(), 0);
        assert_eq!(len, 0, "Should return 0 for zero buffer length");
    }

    #[test]
    fn test_itoa_u32_buffer_too_small() {
        let mut buf = [0u8; 1];
        let len = rust_itoa_u32(123456, buf.as_mut_ptr(), buf.len());
        // Should fail since buffer is way too small
        assert_eq!(len, 0, "Should return 0 for buffer too small");
    }

    #[test]
    fn test_itoa_i64_no_overflow() {
        // Test that function doesn't write beyond buffer bounds
        let mut buf = [0xAAu8; 50];
        let len = rust_itoa_i64(42, buf[5..45].as_mut_ptr(), 40);
        assert!(len > 0 && len <= 40);

        // Check guard bytes aren't overwritten
        assert_eq!(buf[0..5], [0xAA; 5], "Buffer before output was modified");
        assert!(
            buf[45..50].iter().all(|&b| b == 0xAA),
            "Buffer after output was modified"
        );
    }

    // ========================================================================
    // Integration with itoa_i64 (both wrappers)
    // ========================================================================

    #[test]
    fn test_library_contains_both_wrappers() {
        // Test that we can call both wrappers in the same test
        // This ensures the library properly exports both symbols

        // Test itoa
        let mut int_buf = [0u8; 40];
        let int_len = rust_itoa_i64(42, int_buf.as_mut_ptr(), int_buf.len());
        assert!(int_len > 0);

        // Test zmij
        let mut float_buf = [0u8; 24];
        let float_len = zmij_format_f64(3.14, float_buf.as_mut_ptr(), float_buf.len());
        assert!(float_len > 0);

        // Both should have produced output
        assert!(int_len > 0 && float_len > 0);
    }

    // ========================================================================
    // Length Validation Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_length_bounds() {
        let values = vec![0.0, 1.0, 3.14159, 1e20, 1e-20, f64::MAX];
        for value in values {
            let mut buf = [0u8; 24];
            let len = zmij_format_f64(value, buf.as_mut_ptr(), buf.len());
            assert!(
                len > 0 && len <= 24,
                "Length {} out of bounds for {}",
                len,
                value
            );
        }
    }

    #[test]
    fn test_zmij_format_finite_f32_length_bounds() {
        let values = vec![0.0f32, 1.0, -1.5, 1e20, 1e-20];
        for value in values {
            let mut buf = [0u8; 24];
            let len = zmij_format_finite_f32(value, buf.as_mut_ptr(), buf.len());
            assert!(
                len > 0 && len <= 24,
                "Length {} out of bounds for {}",
                len,
                value
            );
        }
    }

    // ========================================================================
    // No Buffer Corruption Tests
    // ========================================================================

    #[test]
    fn test_zmij_format_f64_no_overflow() {
        // Test that function doesn't write beyond buffer bounds
        // Buffer too small is rejected
        let mut buf = [0xAAu8; 30];
        let len = zmij_format_f64(3.14, buf[5..20].as_mut_ptr(), 15);
        assert_eq!(len, 0, "Should reject buffer smaller than 24 bytes");

        // With a proper 24-byte buffer, test no overflow
        let mut buf = [0xAAu8; 32];
        let len = zmij_format_f64(3.14, buf[4..28].as_mut_ptr(), 24);
        assert!(len > 0 && len <= 24);

        // Check guard bytes aren't overwritten
        assert_eq!(buf[0..4], [0xAA; 4], "Buffer before output was modified");
        assert!(
            buf[28..32].iter().all(|&b| b == 0xAA),
            "Buffer after output was modified"
        );
    }

    #[test]
    fn test_buffer_sizes_and_alignment() {
        println!("itoa::Buffer size: {}", std::mem::size_of::<itoa::Buffer>());
        println!("itoa::Buffer align: {}", std::mem::align_of::<itoa::Buffer>());
        println!("ITOA_BUFFER_SIZE constant: {}", ITOA_BUFFER_SIZE);
    }
}
