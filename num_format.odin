/*
num_format C FFI Bindings for Odin

Fast floating-point to string conversion via the num_format Rust library.

Example usage:
    import num_format "."

    buf := make([dynamic]u8, num_format.BUFFER_SIZE)
    defer delete(buf)

    len := num_format.format_f64(3.14159, raw_data(buf), len(buf))
    if len > 0 {
        str := string(buf[:len])
        fmt.println(str)
    }

Memory requirements:
    - Minimum buffer size: BUFFER_SIZE (24 bytes)
    - No heap allocation (stack-based formatting)
    - UTF-8 encoded output (no null terminator)

Library requirements:
    - Link against: num_format_ffi library
    - Include path: path to num_format.h
    - Platforms: Windows, Linux, macOS
*/

package num_format

import "core:c"

/* Constants */

/// Recommended buffer size for all floating-point numbers
BUFFER_SIZE :: 24

/* FFI Function Declarations */

//  cargo rustc -q -- --print=native-static-libs
//  +add linker folder path for our extra libraries so "system" can pick it up
foreign import num_format {"system:num_format_ffi.lib", "system:kernel32.lib", "system:ntdll.lib", "system:userenv.lib", "system:ws2_32.lib", "system:dbghelp.lib"}

@(default_calling_convention = "c", link_prefix = "zmij_")
foreign num_format {
	/// Format f64 floating point to UTF-8 string
	///
	/// Formats a double-precision floating point number as a UTF-8 string.
	/// Handles special cases: NaN → "NaN", +∞ → "inf", -∞ → "-inf"
	///
	/// Arguments:
	///     value   - The f64 value to format
	///     buf     - Output buffer (must be valid and writable)
	///     buf_len - Size of output buffer in bytes
	///
	/// Returns:
	///     Number of bytes written, or 0 if buffer too small/invalid
	///
	/// Example:
	///     buf := make([dynamic]u8, num_format.BUFFER_SIZE)
	///     defer delete(buf)
	///     len := num_format.format_f64(3.14, raw_data(buf), len(buf))
	///     if len > 0 {
	///         str := string(buf[:len])
	///     }
	format_f64 :: proc(value: f64, buf: [^]u8, buf_len: c.uint) -> c.uint ---

	/// Format f32 floating point to UTF-8 string
	///
	/// Formats a single-precision floating point number as a UTF-8 string.
	/// Handles special cases: NaN → "NaN", +∞ → "inf", -∞ → "-inf"
	///
	/// Arguments:
	///     value   - The f32 value to format
	///     buf     - Output buffer (must be valid and writable)
	///     buf_len - Size of output buffer in bytes
	///
	/// Returns:
	///     Number of bytes written, or 0 if buffer too small/invalid
	format_f32 :: proc(value: f32, buf: [^]u8, buf_len: c.uint) -> c.uint ---

	/// Format finite f64 (optimized, no NaN/inf checks)
	///
	/// Optimized variant that skips checks for NaN and infinity.
	/// Only call this if you've verified the value is finite.
	///
	/// WARNING: Undefined behavior if value is NaN or infinity.
	/// Always verify finiteness before calling.
	///
	/// Arguments:
	///     value   - The finite f64 value to format
	///     buf     - Output buffer (must be valid and writable)
	///     buf_len - Size of output buffer in bytes
	///
	/// Returns:
	///     Number of bytes written, or 0 if buffer too small/invalid
	format_finite_f64 :: proc(value: f64, buf: [^]u8, buf_len: c.uint) -> c.uint ---

	/// Format finite f32 (optimized, no NaN/inf checks)
	///
	/// Optimized variant that skips checks for NaN and infinity.
	/// Only call this if you've verified the value is finite.
	///
	/// WARNING: Undefined behavior if value is NaN or infinity.
	/// Always verify finiteness before calling.
	///
	/// Arguments:
	///     value   - The finite f32 value to format
	///     buf     - Output buffer (must be valid and writable)
	///     buf_len - Size of output buffer in bytes
	///
	/// Returns:
	///     Number of bytes written, or 0 if buffer too small/invalid
	format_finite_f32 :: proc(value: f32, buf: [^]u8, buf_len: c.uint) -> c.uint ---
}

/* itoa FFI declarations */

@(default_calling_convention = "c", link_prefix = "rust_")
foreign num_format {
	/// Format i64 integer to UTF-8 string
	///
	/// Arguments:
	///     value   - The i64 value to format
	///     buf     - Output buffer (must be valid and writable)
	///     buf_len - Size of output buffer in bytes (must be >= 40)
	///
	/// Returns:
	///     Number of bytes written, or 0 if buffer too small/invalid
	itoa_i64 :: proc(value: i64, buf: [^]u8, buf_len: c.uint) -> c.uint ---

	/// Format u64 integer to UTF-8 string
	itoa_u64 :: proc(value: u64, buf: [^]u8, buf_len: c.uint) -> c.uint ---

	/// Format i32 integer to UTF-8 string
	itoa_i32 :: proc(value: i32, buf: [^]u8, buf_len: c.uint) -> c.uint ---

	/// Format u32 integer to UTF-8 string
	itoa_u32 :: proc(value: u32, buf: [^]u8, buf_len: c.uint) -> c.uint ---
}

/* Helper Procedures */

/// Format f64 and return as Odin string
///
/// Allocator: Uses provided allocator (default: context.allocator)
/// Returns: formatted string (must be deleted by caller)
///
/// Example:
///     str := num_format.format_f64_to_string(3.14159) or_else "error"
///     defer delete(str)
///     fmt.println(str)
format_f64_to_string :: proc(value: f64, allocator := context.allocator) -> (string, bool) {
	buf := make([dynamic]u8, BUFFER_SIZE, allocator)
	defer delete(buf)

	len := format_f64(value, raw_data(buf), BUFFER_SIZE)
	if len == 0 {
		return "", false
	}

	result := make([dynamic]u8, len, allocator)
	copy(result[:], buf[:len])

	return string(result[:]), true
}

/// Format f32 and return as Odin string
///
/// Allocator: Uses provided allocator (default: context.allocator)
/// Returns: formatted string (must be deleted by caller)
format_f32_to_string :: proc(value: f32, allocator := context.allocator) -> (string, bool) {
	buf := make([dynamic]u8, BUFFER_SIZE, allocator)
	defer delete(buf)

	len := format_f32(value, raw_data(buf), BUFFER_SIZE)
	if len == 0 {
		return "", false
	}

	result := make([dynamic]u8, len, allocator)
	copy(result[:], buf[:len])

	return string(result[:]), true
}

/// Format finite f64 and return as Odin string (optimized)
///
/// Only call after verifying value is finite.
/// Allocator: Uses provided allocator (default: context.allocator)
/// Returns: formatted string (must be deleted by caller)
format_finite_f64_to_string :: proc(value: f64, allocator := context.allocator) -> (string, bool) {
	buf := make([dynamic]u8, BUFFER_SIZE, allocator)
	defer delete(buf)

	len := format_finite_f64(value, raw_data(buf), BUFFER_SIZE)
	if len == 0 {
		return "", false
	}

	result := make([dynamic]u8, len, allocator)
	copy(result[:], buf[:len])

	return string(result[:]), true
}

/// Format finite f32 and return as Odin string (optimized)
///
/// Only call after verifying value is finite.
/// Allocator: Uses provided allocator (default: context.allocator)
/// Returns: formatted string (must be deleted by caller)
format_finite_f32_to_string :: proc(value: f32, allocator := context.allocator) -> (string, bool) {
	buf := make([dynamic]u8, BUFFER_SIZE, allocator)
	defer delete(buf)

	len := format_finite_f32(value, raw_data(buf), BUFFER_SIZE)
	if len == 0 {
		return "", false
	}

	result := make([dynamic]u8, len, allocator)
	copy(result[:], buf[:len])

	return string(result[:]), true
}

/// Format f64 into provided buffer
///
/// Buffer: Caller must provide valid buffer
/// Returns: (string, success)
///
/// Example:
///     buf := make([dynamic]u8, num_format.BUFFER_SIZE)
///     defer delete(buf)
///     str, ok := num_format.format_f64_buffer(3.14, buf[:])
///     if ok {
///         fmt.println(str)
///     }
format_f64_buffer :: proc(value: f64, buffer: []u8) -> (string, bool) {
	len := format_f64(value, raw_data(buffer), c.uint(len(buffer)))
	if len == 0 {
		return "", false
	}

	return string(buffer[:len]), true
}

/// Format f32 into provided buffer
format_f32_buffer :: proc(value: f32, buffer: []u8) -> (string, bool) {
	len := format_f32(value, raw_data(buffer), c.uint(len(buffer)))
	if len == 0 {
		return "", false
	}

	return string(buffer[:len]), true
}

/// Format finite f64 into provided buffer (optimized)
format_finite_f64_buffer :: proc(value: f64, buffer: []u8) -> (string, bool) {
	len := format_finite_f64(value, raw_data(buffer), c.uint(len(buffer)))
	if len == 0 {
		return "", false
	}

	return string(buffer[:len]), true
}

/// Format finite f32 into provided buffer (optimized)
format_finite_f32_buffer :: proc(value: f32, buffer: []u8) -> (string, bool) {
	len := format_finite_f32(value, raw_data(buffer), c.uint(len(buffer)))
	if len == 0 {
		return "", false
	}

	return string(buffer[:len]), true
}
