/*
Unit Tests for num_format Odin Bindings

Run with: odin test . -out:test.exe
*/

package num_format

import num_format "."
import "core:fmt"
import "core:math"
import "core:strconv"
import "core:testing"

@(test)
test_num_format_f64_simple :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(3.14159)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "3.14159", "Expected correct output")
}

@(test)
test_num_format_f32_simple :: proc(t: ^testing.T) {
	str, ok := num_format.format_f32_to_string(f32(2.71828))
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "2.71828", "Expected correct output")
}

@(test)
test_num_format_f64_nan :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(math.nan_f64())
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "NaN", "Expected NaN representation")
}

@(test)
test_num_format_f64_positive_infinity :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(math.inf_f64(1))
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "inf", "Expected positive infinity representation")
}

@(test)
test_num_format_f64_negative_infinity :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(math.inf_f64(-1))
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "-inf", "Expected negative infinity representation")
}

@(test)
test_num_format_f64_zero :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(0.0)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "0.0", "Expected zero representation")
}

@(test)
test_num_format_f64_negative_zero :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(-0.0)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "-0.0", "Expected negative zero representation")
}

@(test)
test_num_format_f64_roundtrip :: proc(t: ^testing.T) {
	original := 1234.5678
	str, ok := num_format.format_f64_to_string(original)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")

	if parsed, parse_ok := strconv.parse_f64(str); parse_ok {
		testing.expect(t, parsed == original, "Expected perfect round-trip")
	} else {
		testing.fail_now(t, "Failed to parse formatted string")
	}
}

@(test)
test_num_format_f64_buffer_stack :: proc(t: ^testing.T) {
	buf: [num_format.BUFFER_SIZE]u8
	str, ok := num_format.format_f64_buffer(3.14, buf[:])

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "3.14", "Expected correct output")
}

@(test)
test_num_format_f64_buffer_too_small :: proc(t: ^testing.T) {
	small_buf: [2]u8
	_, ok := num_format.format_f64_buffer(123456.789, small_buf[:])

	testing.expect(t, !ok, "Expected error for small buffer")
}

@(test)
test_num_format_f64_large_value :: proc(t: ^testing.T) {
	value := 123456789.0
	str, ok := num_format.format_f64_to_string(value)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "123456789.0", "Expected correct large number")
}

@(test)
test_num_format_f64_small_value :: proc(t: ^testing.T) {
	value := 1e-10
	str, ok := num_format.format_f64_to_string(value)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, len(str) > 0, "Expected non-empty output")

	// Verify it parses correctly
	if parsed, parse_ok := strconv.parse_f64(str); parse_ok {
		// Allow small floating point error
		error := math.abs(parsed - value)
		tolerance := value * 1e-14
		testing.expect(t, error < tolerance, "Expected accurate formatting")
	}
}

@(test)
test_num_format_finite_f64 :: proc(t: ^testing.T) {
	value := 123.456
	str, ok := num_format.format_finite_f64_to_string(value)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")
	testing.expect(t, str == "123.456", "Expected correct output")
}

@(test)
test_num_format_f64_sequence :: proc(t: ^testing.T) {
	values := []f64{0.0, 1.0, -1.0, 0.5, -0.5, 100.0, 1e10, 1e-10}

	for value in values {
		str, ok := num_format.format_f64_to_string(value)
		defer delete(str)

		testing.expect(t, ok, fmt.tprintf("Format failed for value: %f", value))
		testing.expect(t, len(str) > 0, fmt.tprintf("Empty output for value: %f", value))

		// Verify output fits in buffer size
		testing.expect(t, len(str) <= num_format.BUFFER_SIZE, fmt.tprintf("Output too large for value: %f", value))
	}
}

@(test)
test_num_format_f32_sequence :: proc(t: ^testing.T) {
	values := []f32{0.0, 1.0, -1.0, 0.5, -0.5, 100.0, 1e6, 1e-6}

	for value in values {
		str, ok := num_format.format_f32_to_string(value)
		defer delete(str)

		testing.expect(t, ok, fmt.tprintf("Format failed for f32: %f", value))
		testing.expect(t, len(str) > 0, fmt.tprintf("Empty output for f32: %f", value))
	}
}

@(test)
test_num_format_f64_utf8_valid :: proc(t: ^testing.T) {
	str, ok := num_format.format_f64_to_string(3.14159)
	defer delete(str)

	testing.expect(t, ok, "Expected successful formatting")

	// All num_format output should be ASCII (subset of UTF-8)
	for i in 0 ..< len(str) {
		testing.expect(t, str[i] < 128, "Expected ASCII output")
	}
}

@(test)
test_num_format_math_constants :: proc(t: ^testing.T) {
	// Test π
	pi_str, pi_ok := num_format.format_f64_to_string(math.PI)
	defer delete(pi_str)
	testing.expect(t, pi_ok, "Expected π formatting success")

	// Test e
	e_str, e_ok := num_format.format_f64_to_string(math.E)
	defer delete(e_str)
	testing.expect(t, e_ok, "Expected e formatting success")

	// Verify they're different
	testing.expect(t, pi_str != e_str, "Expected different outputs for π and e")
}

@(test)
test_num_format_f64_boundary_values :: proc(t: ^testing.T) {
	// Test very large number
	large_str, large_ok := num_format.format_f64_to_string(f64(1e300))
	defer delete(large_str)
	testing.expect(t, large_ok, "Expected large number formatting")

	// Test very small positive number
	small_str, small_ok := num_format.format_f64_to_string(f64(1e-300))
	defer delete(small_str)
	testing.expect(t, small_ok, "Expected small number formatting")

	// Test MIN_POSITIVE
	min_str, min_ok := num_format.format_f64_to_string(f64(math.F64_MIN))
	defer delete(min_str)
	testing.expect(t, min_ok, "Expected MIN_POSITIVE formatting")

	// Test MAX
	max_str, max_ok := num_format.format_f64_to_string(f64(math.F64_MAX))
	defer delete(max_str)
	testing.expect(t, max_ok, "Expected MAX formatting")
}

/* itoa function tests */

@(test)
test_itoa_i64_simple :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i64(i64(12345), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "12345", "Expected correct i64 output")
}

@(test)
test_itoa_i64_negative :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i64(i64(-67890), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "-67890", "Expected correct negative i64 output")
}

@(test)
test_itoa_i64_zero :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i64(i64(0), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "0", "Expected zero representation")
}

@(test)
test_itoa_i64_max :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i64(i64(9223372036854775807), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "9223372036854775807", "Expected i64::MAX")
}

@(test)
test_itoa_i64_min :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i64(i64(-9223372036854775808), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "-9223372036854775808", "Expected i64::MIN")
}

@(test)
test_itoa_u64_simple :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_u64(u64(98765), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "98765", "Expected correct u64 output")
}

@(test)
test_itoa_u64_zero :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_u64(u64(0), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "0", "Expected zero representation")
}

@(test)
test_itoa_u64_max :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_u64(u64(18446744073709551615), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "18446744073709551615", "Expected u64::MAX")
}

@(test)
test_itoa_i32_simple :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i32(i32(54321), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "54321", "Expected correct i32 output")
}

@(test)
test_itoa_i32_negative :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i32(i32(-12345), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "-12345", "Expected correct negative i32 output")
}

@(test)
test_itoa_i32_zero :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i32(i32(0), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "0", "Expected zero representation")
}

@(test)
test_itoa_i32_max :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i32(i32(2147483647), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "2147483647", "Expected i32::MAX")
}

@(test)
test_itoa_i32_min :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_i32(i32(-2147483648), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "-2147483648", "Expected i32::MIN")
}

@(test)
test_itoa_u32_simple :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_u32(u32(11111), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "11111", "Expected correct u32 output")
}

@(test)
test_itoa_u32_zero :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_u32(u32(0), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "0", "Expected zero representation")
}

@(test)
test_itoa_u32_max :: proc(t: ^testing.T) {
	buf: [40]u8
	len := num_format.itoa_u32(u32(4294967295), raw_data(buf[:]), 40)

	testing.expect(t, len > 0, "Expected successful formatting")
	testing.expect(t, string(buf[:len]) == "4294967295", "Expected u32::MAX")
}
