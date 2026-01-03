# Num Format

[Odin](http://odin-lang.org/) language bindings for Rust implementations of high-performance number-to-string conversion libraries.

Includes bindings for:
- **Zmij**: Fast floating-point (f64/f32) to string conversion
- **itoa**: Fast integer (i64/u64/i32/u32) to string conversion

## Overview

Convert numbers to strings efficiently with optimized C FFI bindings:

### Floating-Point (Zmij)
- **f64** and **f32** support
- **Special values**: NaN, ±∞ handled correctly
- **Fast**: 10-20 nanoseconds per format operation
- **Safe**: No heap allocation required, UTF-8 guaranteed
- **Optimized**: Separate codepaths for known-finite values

### Integer (itoa)
- **i64**, **u64**, **i32**, **u32** support
- **Fast**: Optimized integer formatting
- **Safe**: Buffer-aware with size validation
- **Direct**: Formats directly into caller's buffer

## Quick Start

### 1. Run Tests or Examples

**Windows (prebuilt library included):**

```bash
# Run unit tests
just test

# Run example programs
just examples

# Run benchmarks
just bench
```

**Linux/macOS (build required):**

```bash
# Build Rust FFI library first
just build-rs

# Run unit tests
just test

# Run example programs
just examples

# Run benchmarks
just bench
```

### 2. Use in Your Code

```odin
import num_format "."

main :: proc() {
    // Floating-point formatting
    str, ok := num_format.format_f64_to_string(3.14159)
    if ok {
        defer delete(str)
        fmt.println(str)  // Output: "3.14159"
    }
    
    // Integer formatting
    int_str := num_format.format_i64(42)
    fmt.println(int_str)  // Output: "42"
}
```

## Repository Structure

```
.
├── rust-ffi/                   # Rust C FFI library
│   ├── src/
│   │   └── lib.rs             # Main library (zmij + itoa wrappers)
│   ├── Cargo.toml             # Rust package config
│   └── target/                # Compiled library (after build)
├── num_format.odin            # Odin FFI bindings
├── num_format_test.odin       # Test suite
├── examples/
│   └── example_num_format.odin  # Example programs
├── bench/
│   └── bench.odin             # Benchmark suite
├── justfile                   # Build recipes
├── README.md                  # This file
└── LICENSE
```

## Build Commands

Use `just` to run build recipes (see `justfile` for details):

```bash
# Format all Odin files
just format

# Check for style and potential bugs
just lint

# Run unit tests
just test

# Run example programs
just examples

# Build benchmarks
just bench-build

# Run benchmarks
just bench
```

### Building the Rust FFI Library

**Windows:** A prebuilt library is included, so `build-rs` is optional.

**Linux/macOS:** The Rust FFI library must be built from source:

```bash
# Build Rust FFI library
just build-rs

# Run Rust FFI tests
just test-rs
```

To rebuild on Windows or when testing Rust changes:

```bash
just build-rs
just test-rs
```

### CPU Requirements

The Rust FFI library is compiled with `target-cpu=skylake` (AVX2 support required). This is configured in `rust-ffi/.cargo/config.toml` and targets modern x86-64 CPUs with AVX2 instruction set support (Intel Haswell/Broadwell or AMD Excavator and later).

## API Overview

### Floating-Point FFI (Zmij)

```odin
// Raw FFI functions
format_f64 :: proc(value: f64, buf: [^]u8, buf_len: c.uint) -> c.uint
format_f32 :: proc(value: f32, buf: [^]u8, buf_len: c.uint) -> c.uint
format_finite_f64 :: proc(value: f64, buf: [^]u8, buf_len: c.uint) -> c.uint
format_finite_f32 :: proc(value: f32, buf: [^]u8, buf_len: c.uint) -> c.uint

// Helper functions (Recommended)
format_f64_to_string(value: f64, allocator: Allocator) -> (string, bool)
format_f32_to_string(value: f32, allocator: Allocator) -> (string, bool)
format_f64_buffer(value: f64, buffer: []u8) -> (string, bool)
format_f32_buffer(value: f32, buffer: []u8) -> (string, bool)
format_finite_f64_to_string(value: f64, allocator: Allocator) -> (string, bool)
format_finite_f64_buffer(value: f64, buffer: []u8) -> (string, bool)
```

### Integer FFI (itoa)

```odin
// Raw FFI functions
itoa_i64 :: proc(value: i64, buf: [^]u8, buf_len: c.uint) -> c.uint
itoa_u64 :: proc(value: u64, buf: [^]u8, buf_len: c.uint) -> c.uint
itoa_i32 :: proc(value: i32, buf: [^]u8, buf_len: c.uint) -> c.uint
itoa_u32 :: proc(value: u32, buf: [^]u8, buf_len: c.uint) -> c.uint

// Helper functions
format_i64(value: i64) -> string
format_u64(value: u64) -> string
format_i32(value: i32) -> string
format_u32(value: u32) -> string
```

See `num_format.odin` for complete function documentation with detailed parameter descriptions and examples.

## Usage Patterns

### Pattern 1: Simple Floating-Point Formatting (with allocation)

Best for: When you need a string and allocation is acceptable.

```odin
import "core:fmt"
import num_format "."

str, ok := num_format.format_f64_to_string(3.14159)
if ok {
    defer delete(str)
    fmt.println(str)  // "3.14159"
}
```

### Pattern 2: Stack Buffer (no allocation)

Best for: Performance-critical code, short-lived strings.

```odin
buf: [num_format.BUFFER_SIZE]u8

str, ok := num_format.format_f64_buffer(3.14159, buf[:])
if ok {
    fmt.println(str)  // Safe, uses stack
}
```

### Pattern 3: Manual Buffer Management

Best for: When you need low-level control.

```odin
buf := make([dynamic]u8, num_format.BUFFER_SIZE)
defer delete(buf)

len := num_format.format_f64(3.14159, raw_data(buf), c.uint(cap(buf)))
if len > 0 {
    str := string(buf[:len])
    // Use str...
}
```

### Pattern 4: Batch Processing

Best for: Multiple values, efficient memory handling.

```odin
values := []f64{0.0, 1.0, 3.14159, 1e10, 1e-10}
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
```

### Pattern 5: Optimized Path (finite values)

Best for: When you've validated values are finite.

```odin
import "core:math"
import num_format "."

if math.is_finite(value) {
    str, ok := num_format.format_finite_f64_to_string(value)
} else {
    str, ok := num_format.format_f64_to_string(value)
}
```

### Pattern 6: Integer Formatting

Best for: Converting integers to strings.

```odin
import "core:fmt"
import num_format "."

fmt.println(num_format.format_i64(0))
fmt.println(num_format.format_i64(42))
fmt.println(num_format.format_i64(-42))
fmt.println(num_format.format_u64(18446744073709551615))  // u64::MAX
```

## Performance

Typical formatting times (release build, modern CPU):

| Operation | Time |
|-----------|------|
| `format_f64` | 10-20 ns |
| `format_finite_f64` | 8-15 ns |
| `format_i64` | ~20-30 ns |
| Stack buffer formatting | + minimal overhead |
| String allocation | allocator-dependent |

### Speed vs Memory Trade-off

| Method | Speed | Allocation | Best For |
|--------|-------|-----------|----------|
| `format_f64_buffer` | Fastest | None | Performance critical |
| `format_f64_to_string` | Fast | Yes | General purpose |
| `format_finite_f64_buffer` | Fastest | None | Validated finite |
| `format_i64` | Fast | None | Integer formatting |
| Raw FFI calls | Fastest | Caller managed | Low-level |

## Buffer Size Constants

```odin
// Floating-point (zmij)
BUFFER_SIZE :: 24  // Sufficient for any f64/f32

// Integer (itoa) 
ITOA_BUFFER_SIZE :: 40  // Sufficient for any i64/u64/i32/u32
```

## Memory Management

### Floating-Point Buffers

Always use at least `BUFFER_SIZE` (24 bytes):

```odin
// Stack allocation (preferred)
buf: [num_format.BUFFER_SIZE]u8
str, ok := num_format.format_f64_buffer(value, buf[:])

// Dynamic allocation (when needed)
buf := make([dynamic]u8, num_format.BUFFER_SIZE)
defer delete(buf)
str, ok := num_format.format_f64_buffer(value, buf[:])
```

### Integer Buffers

Always use at least `ITOA_BUFFER_SIZE` (40 bytes):

```odin
// For raw FFI calls
buf: [40]u8
len := num_format.itoa_i64(value, raw_data(buf), c.uint(len(buf)))

// Integer helpers return stack-based strings (no allocation)
str := num_format.format_i64(value)  // Valid during current scope
```

### Custom Allocators

All `*_to_string` functions accept optional allocator parameter:

```odin
// Use arena allocator
str, ok := num_format.format_f64_to_string(3.14, arena_allocator)
if ok {
    defer delete(str)
    // Use str
}
```

## Error Handling

### Helper Functions

Helper functions return `(result, ok: bool)`:

```odin
str, ok := num_format.format_f64_to_string(value)
if !ok {
    fmt.eprintln("Failed to format")
    return
}
defer delete(str)
```

### Raw FFI Functions

Raw FFI functions return byte count (0 = error):

```odin
len := num_format.format_f64(value, raw_data(buf), c.uint(len(buf)))
if len == 0 {
    fmt.eprintln("Buffer too small or invalid")
    return
}
```

### Buffer Size Errors

If buffer is too small, function returns 0:

```odin
small_buf: [2]u8

len := num_format.format_f64(123456.789, raw_data(small_buf[:]), 2)
// Returns 0 (buffer too small)
```

## Testing

Run all tests:

```bash
just test
```

Expected output shows tests for formatting, special values, and round-trip accuracy.

Run Rust FFI library tests:

```bash
just test-rs
```

## Platform Support

All platforms use the same API and commands:

```bash
# Build
just build-rs

# Test Rust FFI library
just test-rs

# Test Odin bindings
just test

# Examples
just examples

# Run your program
odin build . -out:program
./program
```

The library path is configured automatically via `-define:NUM_FORMAT_FFI_LIB` (see below). Works on:
- Windows (x64, AVX2 required)
- Linux (x64, AVX2 required)
- macOS (Intel with AVX2, or Apple Silicon)

**CPU Requirement**: The Rust FFI library is compiled with `target-cpu=skylake`, requiring AVX2 instruction set support (Intel Haswell/2013+ or AMD Excavator/2015+). Most modern CPUs meet this requirement. Configuration is in `rust-ffi/.cargo/config.toml`.

## Integration

### Using in Your Project

1. Copy `num_format.odin` to your project
2. Build the Rust library: `just build-rs` (in original project)
3. Import and use:
   ```odin
   import num_format "path/to/num_format"
   str, ok := num_format.format_f64_to_string(value)
   ```
4. The library path is configured automatically with sensible defaults. No additional flags needed. To override:
   ```bash
   odin build . -define:NUM_FORMAT_FFI_LIB="path/to/library"
   ```

### C Interop

The bindings use standard C FFI conventions:
- `[^]u8` for C pointers
- `c.uint` for C unsigned int
- C calling convention for foreign procedures
- UTF-8 strings (no null termination from formatter)

## Complete Example

```odin
package main

import "core:fmt"
import "core:math"
import num_format "."

main :: proc() {
    // Simple floating-point formatting
    if str, ok := num_format.format_f64_to_string(3.14159); ok {
        defer delete(str)
        fmt.println("Formatted:", str)  // "3.14159"
    }

    // Handle special values
    fmt.println(num_format.format_f64_to_string(math.NaN_f64()))     // "NaN", true
    fmt.println(num_format.format_f64_to_string(math.Inf(1)))        // "inf", true
    fmt.println(num_format.format_f64_to_string(math.Inf(-1)))       // "-inf", true

    // Stack buffer (no allocation)
    buf: [num_format.BUFFER_SIZE]u8
    if str, ok := num_format.format_f64_buffer(2.71828, buf[:]); ok {
        fmt.println("Stack:", str)  // "2.71828"
    }

    // Integer formatting
    fmt.println("Integer:", num_format.format_i64(42))
    fmt.println("Unsigned:", num_format.format_u64(100))

    // Batch processing
    values := []f64{0.0, 1.0, -1.0, 1e10, 1e-10}
    for v in values {
        if str, ok := num_format.format_f64_to_string(v); ok {
            defer delete(str)
            fmt.printf("%e → %q\n", v, str)
        }
    }
}
```

## Troubleshooting

### "Library not found"

**Problem:**
```
error: linker error: cannot find -lnum_format_ffi
```

**Solutions:**

1. **Build the Rust library first** (required):
   ```bash
   just build-rs
   ```

2. **Use justfile commands** (configured automatically):
   ```bash
   just test
   just examples
   just bench
   ```

3. **If building outside justfile**, the library path is configured with defaults (no additional flags needed). Override only if using a custom path:
   ```bash
   odin build . -define:NUM_FORMAT_FFI_LIB="path/to/library"
   ```

4. **Verify the library was built**:
   ```bash
   # Windows
   dir rust-ffi\target\release\num_format_ffi.*
   
   # Linux/macOS
   ls rust-ffi/target/release/libnum_format_ffi.*
   ```

### Buffer Too Small

Ensure buffer meets minimum size:

```odin
// ✓ Correct (f64/f32)
buf: [BUFFER_SIZE]u8

// ✓ Correct (i64/u64/i32/u32)
buf: [40]u8

// ✗ Wrong
buf: [10]u8  // Too small!
```

### Compilation Errors

Run the linter to check for issues:

```bash
just lint
```

Format your code:

```bash
just format
```

## References

- [Zmij Repository](https://github.com/dtolnay/zmij) - High-performance float formatter
- [itoa Crate](https://docs.rs/itoa) - Integer to string formatting
- [Odin Language](https://odin-lang.org)
- [Odin FFI Documentation](https://odin-lang.org/docs/overview/#foreign-procedures)

## License

- **Zmij library**: MIT (https://github.com/dtolnay/zmij)
- **itoa library**: MIT (https://github.com/dtolnay/itoa)
- **Odin bindings**: Provided as-is
