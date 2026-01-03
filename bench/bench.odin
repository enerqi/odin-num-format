package main

import num_format ".."
import "core:c"
import "core:fmt"
import "core:time"

buf_f64: [dynamic]u8
buf_f32: [dynamic]u8
buf_i64: [dynamic]u8
buf_u64: [dynamic]u8
buf_i32: [dynamic]u8
buf_u32: [dynamic]u8
COUNT_ITERATIONS :: 1_000_000
ITOA_BUFFER_SIZE :: 40

setup_f64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	buf_f64 = make([dynamic]u8, num_format.BUFFER_SIZE, allocator)
	return .Okay
}

teardown_f64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_f64 := f64(3.14159265358979323846)
	len := num_format.format_finite_f64(test_f64, raw_data(buf_f64), num_format.BUFFER_SIZE)
	if len > 0 {
		fmt.printf("Sample f64 output: %s\n", string(buf_f64[:len]))
	}
	delete(buf_f64)
	return .Okay
}

bench_f64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_f64 := f64(3.14159265358979323846)

	for i := 0; i < COUNT_ITERATIONS; i += 1 {
		_ = num_format.format_finite_f64(test_f64, raw_data(buf_f64), num_format.BUFFER_SIZE)
	}
	options.count = COUNT_ITERATIONS

	return .Okay
}

setup_f32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	buf_f32 = make([dynamic]u8, num_format.BUFFER_SIZE, allocator)
	return .Okay
}

teardown_f32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_f32 := f32(2.71828182845904523536)
	len := num_format.format_finite_f32(test_f32, raw_data(buf_f32), num_format.BUFFER_SIZE)
	if len > 0 {
		fmt.printf("Sample f32 output: %s\n", string(buf_f32[:len]))
	}
	delete(buf_f32)
	return .Okay
}

bench_f32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_f32 := f32(2.71828182845904523536)

	for i in 0 ..< COUNT_ITERATIONS {
		_ = num_format.format_finite_f32(test_f32, raw_data(buf_f32), num_format.BUFFER_SIZE)
	}
	options.count = COUNT_ITERATIONS

	return .Okay
}

// ============================================================================
// itoa benchmarks
// ============================================================================

setup_i64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	buf_i64 = make([dynamic]u8, ITOA_BUFFER_SIZE, allocator)
	return .Okay
}

teardown_i64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_i64 := i64(9223372036854775807) // i64::MAX
	len := num_format.itoa_i64(test_i64, raw_data(buf_i64), c.uint(ITOA_BUFFER_SIZE))
	if len > 0 {
		fmt.printf("Sample i64 output: %s\n", string(buf_i64[:len]))
	}
	delete(buf_i64)
	return .Okay
}

bench_i64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_i64 := i64(9223372036854775807) // i64::MAX

	for i := 0; i < COUNT_ITERATIONS; i += 1 {
		_ = num_format.itoa_i64(test_i64, raw_data(buf_i64), c.uint(ITOA_BUFFER_SIZE))
	}
	options.count = COUNT_ITERATIONS

	return .Okay
}

setup_u64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	buf_u64 = make([dynamic]u8, ITOA_BUFFER_SIZE, allocator)
	return .Okay
}

teardown_u64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_u64 := u64(18446744073709551615) // u64::MAX
	len := num_format.itoa_u64(test_u64, raw_data(buf_u64), c.uint(ITOA_BUFFER_SIZE))
	if len > 0 {
		fmt.printf("Sample u64 output: %s\n", string(buf_u64[:len]))
	}
	delete(buf_u64)
	return .Okay
}

bench_u64 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_u64 := u64(18446744073709551615) // u64::MAX

	for i in 0 ..< COUNT_ITERATIONS {
		_ = num_format.itoa_u64(test_u64, raw_data(buf_u64), c.uint(ITOA_BUFFER_SIZE))
	}
	options.count = COUNT_ITERATIONS

	return .Okay
}

setup_i32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	buf_i32 = make([dynamic]u8, ITOA_BUFFER_SIZE, allocator)
	return .Okay
}

teardown_i32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_i32 := i32(2147483647) // i32::MAX
	len := num_format.itoa_i32(test_i32, raw_data(buf_i32), c.uint(ITOA_BUFFER_SIZE))
	if len > 0 {
		fmt.printf("Sample i32 output: %s\n", string(buf_i32[:len]))
	}
	delete(buf_i32)
	return .Okay
}

bench_i32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_i32 := i32(2147483647) // i32::MAX

	for i in 0 ..< COUNT_ITERATIONS {
		_ = num_format.itoa_i32(test_i32, raw_data(buf_i32), c.uint(ITOA_BUFFER_SIZE))
	}
	options.count = COUNT_ITERATIONS

	return .Okay
}

setup_u32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	buf_u32 = make([dynamic]u8, ITOA_BUFFER_SIZE, allocator)
	return .Okay
}

teardown_u32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_u32 := u32(4294967295) // u32::MAX
	len := num_format.itoa_u32(test_u32, raw_data(buf_u32), c.uint(ITOA_BUFFER_SIZE))
	if len > 0 {
		fmt.printf("Sample u32 output: %s\n", string(buf_u32[:len]))
	}
	delete(buf_u32)
	return .Okay
}

bench_u32 :: proc(options: ^time.Benchmark_Options, allocator := context.allocator) -> time.Benchmark_Error {
	test_u32 := u32(4294967295) // u32::MAX

	for i in 0 ..< COUNT_ITERATIONS {
		_ = num_format.itoa_u32(test_u32, raw_data(buf_u32), c.uint(ITOA_BUFFER_SIZE))
	}
	options.count = COUNT_ITERATIONS

	return .Okay
}

// ============================================================================
// Main benchmarks
// ============================================================================

main :: proc() {
	// Benchmark format_finite_f64
	fmt.println("Benchmarking format_finite_f64 (1,000,000 iterations)...")
	options_f64 := &time.Benchmark_Options{setup = setup_f64, bench = bench_f64, teardown = teardown_f64}
	time.benchmark(options_f64)
	fmt.printf("Time: %v\n", options_f64.duration)
	fmt.printf("Per call: %.2f ns\n", f64(time.duration_nanoseconds(options_f64.duration)) / 1_000_000.0)
	fmt.printf("Rounds/sec: %.2e\n\n", options_f64.rounds_per_second)

	// Benchmark format_finite_f32
	fmt.println("Benchmarking format_finite_f32 (1,000,000 iterations)...")
	options_f32 := &time.Benchmark_Options{setup = setup_f32, bench = bench_f32, teardown = teardown_f32}
	time.benchmark(options_f32)
	fmt.printf("Time: %v\n", options_f32.duration)
	fmt.printf("Per call: %.2f ns\n", f64(time.duration_nanoseconds(options_f32.duration)) / 1_000_000.0)
	fmt.printf("Rounds/sec: %.2e\n\n", options_f32.rounds_per_second)

	// Benchmark itoa_i64
	fmt.println("Benchmarking itoa_i64 (1,000,000 iterations)...")
	options_i64 := &time.Benchmark_Options{setup = setup_i64, bench = bench_i64, teardown = teardown_i64}
	time.benchmark(options_i64)
	fmt.printf("Time: %v\n", options_i64.duration)
	fmt.printf("Per call: %.2f ns\n", f64(time.duration_nanoseconds(options_i64.duration)) / 1_000_000.0)
	fmt.printf("Rounds/sec: %.2e\n\n", options_i64.rounds_per_second)

	// Benchmark itoa_u64
	fmt.println("Benchmarking itoa_u64 (1,000,000 iterations)...")
	options_u64 := &time.Benchmark_Options{setup = setup_u64, bench = bench_u64, teardown = teardown_u64}
	time.benchmark(options_u64)
	fmt.printf("Time: %v\n", options_u64.duration)
	fmt.printf("Per call: %.2f ns\n", f64(time.duration_nanoseconds(options_u64.duration)) / 1_000_000.0)
	fmt.printf("Rounds/sec: %.2e\n\n", options_u64.rounds_per_second)

	// Benchmark itoa_i32
	fmt.println("Benchmarking itoa_i32 (1,000,000 iterations)...")
	options_i32 := &time.Benchmark_Options{setup = setup_i32, bench = bench_i32, teardown = teardown_i32}
	time.benchmark(options_i32)
	fmt.printf("Time: %v\n", options_i32.duration)
	fmt.printf("Per call: %.2f ns\n", f64(time.duration_nanoseconds(options_i32.duration)) / 1_000_000.0)
	fmt.printf("Rounds/sec: %.2e\n\n", options_i32.rounds_per_second)

	// Benchmark itoa_u32
	fmt.println("Benchmarking itoa_u32 (1,000,000 iterations)...")
	options_u32 := &time.Benchmark_Options{setup = setup_u32, bench = bench_u32, teardown = teardown_u32}
	time.benchmark(options_u32)
	fmt.printf("Time: %v\n", options_u32.duration)
	fmt.printf("Per call: %.2f ns\n", f64(time.duration_nanoseconds(options_u32.duration)) / 1_000_000.0)
	fmt.printf("Rounds/sec: %.2e\n", options_u32.rounds_per_second)
}
