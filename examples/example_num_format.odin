/*
num_format Odin Binding Examples

Demonstrates how to use the num_format FFI bindings from Odin code.

Build instructions:
    1. Build the Rust library:
       cd src
       cargo build --release

    2. Build Odin example:
       odin build . -out:example.exe

    3. Run:
       ./example.exe

Required:
    - Odin compiler installed
    - rust-ffi library built (see src/)
    - Library path configured in num_format.odin
*/

package main

import num_format ".."
import "core:c"
import "core:fmt"
import "core:math"
import "core:strconv"

main :: proc() {
	fmt.println("=== num_format Odin Binding Examples ===\n")

	// Example 1: Basic f64 formatting
	fmt.println("Example 1: Basic f64 formatting")
	{
		buf := make([dynamic]u8, num_format.BUFFER_SIZE)
		defer delete(buf)

		value := 3.14159
		len := num_format.format_f64(value, raw_data(buf), c.uint(cap(buf)))

		if len > 0 {
			str := string(buf[:len])
			fmt.printf("  format_f64(%.5f) = %q\n", value, str)
		} else {
			fmt.println("  Error: buffer too small")
		}
	}
	fmt.println()

	// Example 2: Basic f32 formatting
	fmt.println("Example 2: Basic f32 formatting")
	{
		buf := make([dynamic]u8, num_format.BUFFER_SIZE)
		defer delete(buf)

		value := f32(2.71828)
		len := num_format.format_f32(value, raw_data(buf), c.uint(cap(buf)))

		if len > 0 {
			str := string(buf[:len])
			fmt.printf("  format_f32(%f) = %q\n", value, str)
		}
	}
	fmt.println()

	// Example 3: Using helper function (allocates string)
	fmt.println("Example 3: Helper function (with allocation)")
	{
		values := []f64{0.0, 1.0, -1.0, 3.14159, 1e10, 1e-10}

		for value in values {
			if str, ok := num_format.format_f64_to_string(value); ok {
				defer delete(str)
				fmt.printf("  %f → %q\n", value, str)
			}
		}
	}
	fmt.println()

	// Example 4: Special values
	fmt.println("Example 4: Special values (NaN, infinity)")
	{
		special_values := []f64{math.nan_f64(), math.inf_f64(1), math.inf_f64(-1)}

		for value in special_values {
			if str, ok := num_format.format_f64_to_string(value); ok {
				defer delete(str)
				fmt.printf("  %f → %q\n", value, str)
			}
		}
	}
	fmt.println()

	// Example 5: Using provided buffer (stack allocation)
	fmt.println("Example 5: Stack-allocated buffer")
	{
		buf: [num_format.BUFFER_SIZE]u8

		value := 42.5
		if str, ok := num_format.format_f64_buffer(value, buf[:]); ok {
			fmt.printf("  format_f64_buffer(%f) = %q\n", value, str)
		}
	}
	fmt.println()

	// Example 6: Optimized finite formatting
	fmt.println("Example 6: Optimized finite formatting")
	{
		buf := make([dynamic]u8, num_format.BUFFER_SIZE)
		defer delete(buf)

		value := 123.456

		// Use optimized path (no NaN/inf checks)
		len := num_format.format_finite_f64(value, raw_data(buf), c.uint(cap(buf)))

		if len > 0 {
			str := string(buf[:len])
			fmt.printf("  format_finite_f64(%f) = %q (optimized)\n", value, str)
		}
	}
	fmt.println()

	// Example 7: Error handling
	fmt.println("Example 7: Error handling (buffer too small)")
	{
		small_buf := make([dynamic]u8, 2)
		defer delete(small_buf)

		value := 123456.789
		len := num_format.format_f64(value, raw_data(small_buf), c.uint(cap(small_buf)))

		if len == 0 {
			fmt.println("  ✓ Correctly returned 0 for undersized buffer")
		} else {
			fmt.println("  ✗ Unexpected success")
		}
	}
	fmt.println()

	// Example 8: Batch formatting
	fmt.println("Example 8: Batch processing multiple values")
	{
		values := []f64{0.0, 1.234, -56.789, 100.0, 1e20, 1e-20}

		formatted := make([dynamic]string)
		defer {
			for s in formatted {
				delete(s)
			}
			delete(formatted)
		}

		for value in values {
			if str, ok := num_format.format_f64_to_string(value); ok {
				append(&formatted, str)
			}
		}

		fmt.println("  Input values → Formatted strings:")
		for idx := 0; idx < len(values); idx += 1 {
			fmt.printf("    %e → %q\n", values[idx], formatted[idx])
		}
	}
	fmt.println()

	// Example 9: Round-trip test
	fmt.println("Example 9: Round-trip formatting")
	{
		original := 3.14159265358979
		if str, ok := num_format.format_f64_to_string(original); ok {
			defer delete(str)
			if parsed, parse_ok := strconv.parse_f64(str); parse_ok {
				fmt.printf("  Original:  %.15f\n", original)
				fmt.printf("  Formatted: %q\n", str)
				fmt.printf("  Parsed:    %.15f\n", parsed)
				fmt.printf("  Match:     %v\n", original == parsed)
			}
		}
	}
	fmt.println()

	// Example 10: Comparing f32 vs f64
	fmt.println("Example 10: f32 vs f64 formatting difference")
	{
		value_f64 := 0.1
		value_f32 := f32(0.1)

		if str64, ok64 := num_format.format_f64_to_string(value_f64); ok64 {
			defer delete(str64)
			if str32, ok32 := num_format.format_f32_to_string(value_f32); ok32 {
				defer delete(str32)
				fmt.printf("  f64(0.1) → %q\n", str64)
				fmt.printf("  f32(0.1) → %q\n", str32)
			}
		}
	}
	fmt.println()

	fmt.println("=== Examples Complete ===")
}
