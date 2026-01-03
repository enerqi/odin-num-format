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

### 1. Build the Rust Library

```bash
just build-rs
```

This produces `num_format_ffi.lib` (static library).

### 2. Use in Your Code

```odin
import zmij "."

main :: proc() {
    // Floating-point formatting
    str, ok := zmij.format_f64_to_string(3.14159)
    if ok {
        defer delete(str)
        fmt.println(str)  // Output: "3.14159"
    }
    
    // Integer formatting
    int_str := zmij.format_i64(42)
    fmt.println(int_str)  // Output: "42"
}
```

Either run `odin` with `-extra-linker-flags` or copy `num_format_ffi.lib` to your project directory


## Repository Structure

```
.
├── rust-ffi/    # Rust C FFI library
│   ├── src/
│   │   ├── lib.rs                 # Main library (zmij + itoa wrappers)
│   ├── Cargo.toml                 # Rust package config
│   └── target/                    # Compiled library (after build)
├── zmij.odin                      # Odin FFI bindings
├── zmij_test.odin                 # Test suite
├── examples/                       # Example odin programs
├── bench/                          # Benchmark suite
├── ODIN_BINDINGS.md              # Complete API documentation
├── README.md                       # This file
```

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
rust_itoa_i64 :: proc(value: i64, buf: [^]u8, buf_len: c.uint) -> c.uint
rust_itoa_u64 :: proc(value: u64, buf: [^]u8, buf_len: c.uint) -> c.uint
rust_itoa_i32 :: proc(value: i32, buf: [^]u8, buf_len: c.uint) -> c.uint
rust_itoa_u32 :: proc(value: u32, buf: [^]u8, buf_len: c.uint) -> c.uint

// Helper functions
format_i64(value: i64) -> string
format_u64(value: u64) -> string
format_i32(value: i32) -> string
format_u32(value: u32) -> string
```

## Usage Examples

### Floating-Point Formatting

```odin
import zmij "."

// Heap allocation
str, ok := zmij.format_f64_to_string(3.14159)
if ok {
    defer delete(str)
    fmt.println(str)  // "3.14159"
}

// Stack buffer (no allocation)
buf: [zmij.BUFFER_SIZE]u8
str, ok := zmij.format_f64_buffer(3.14159, buf[:])
if ok {
    fmt.println(str)  // View of stack buffer
}

// Special values
import "core:math"
fmt.println(zmij.format_f64_to_string(math.NaN_f64()))    // "NaN"
fmt.println(zmij.format_f64_to_string(math.Inf(1)))       // "inf"
fmt.println(zmij.format_f64_to_string(math.Inf(-1)))      // "-inf"
```

### Integer Formatting

```odin
import zmij "."

// Simple formatting
fmt.println(zmij.format_i64(42))           // "42"
fmt.println(zmij.format_i64(-9223372036854775808))  // i64::MIN
fmt.println(zmij.format_u64(18446744073709551615)) // u64::MAX

// Batch processing
values := []i64{0, 1, -1, 42, -42, 1000000}
for v in values {
    fmt.println(zmij.format_i64(v))
}
```

## Building

### Prerequisites

- Rust compiler with `cargo`
- Odin compiler

## Performance

Typical formatting times (release build, modern CPU):

| Operation | Time |
|-----------|------|
| `format_f64` | 10-20 ns |
| `format_finite_f64` | 8-15 ns |
| `format_i64` | ~20-30 ns |
| Stack buffer formatting | + minimal overhead |
| String allocation | allocator-dependent |

## Buffer Size Constants

```odin
// Floating-point (zmij)
BUFFER_SIZE :: 24  // Sufficient for any f64/f32

// Integer (itoa) 
ITOA_BUFFER_SIZE :: 40  // Sufficient for any i64/u64/i32/u32 (i128::MAX_STR_LEN)
```

## Memory Management

### Floating-Point Buffers

Always use at least `zmij.BUFFER_SIZE` (24 bytes):

```odin
// Safe for any f64 or f32 value
buf: [zmij.BUFFER_SIZE]u8
str, ok := zmij.format_f64_buffer(value, buf[:])
```

### Integer Buffers

Always use at least `ITOA_BUFFER_SIZE` (40 bytes):

```odin
// Safe for any i64/u64/i32/u32 value
buf: [40]u8  // itoa::Buffer size (i128::MAX_STR_LEN)
len := rust_itoa_i64(value, raw_data(buf), c.uint(len(buf)))
```

## Error Handling

Helper functions return `(result, ok: bool)`:

```odin
str, ok := zmij.format_f64_to_string(value)
if !ok {
    fmt.eprintln("Format failed")
    return
}
```

Raw FFI functions return byte count (0 = error):

```odin
len := zmij.format_f64(value, raw_data(buf), c.uint(len(buf)))
if len == 0 {
    fmt.eprintln("Buffer too small or invalid")
    return
}
```

## Documentation

See **ODIN_BINDINGS.md** for:
- Complete API reference
- Detailed usage patterns
- Platform-specific instructions
- Integration examples

## Testing

Run test suite:

```bash
# Odin tests
odin test .

# Rust tests (in wrapper)
cd rust-ffi
cargo test
cd ..
```

## Troubleshooting

### "Library not found"

Build the library file with Rust's `cargo` and set `-extra-linker-flags` when invoking `odin`

### Buffer Too Small

Ensure buffer meets minimum size:

```odin
// ✓ Correct (f64/f32)
buf: [zmij.BUFFER_SIZE]u8

// ✓ Correct (i64/u64/i32/u32)
buf: [40]u8

// ✗ Wrong
buf: [10]u8  // Too small!
```

### Linker Errors

Make sure the Rust library is built in release mode:

```bash
cd rust-ffi
cargo build --release
cd ..
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
