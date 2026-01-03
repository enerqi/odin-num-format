# Development Guidelines for odin-num-format

## Build and Quality Checks

Use the `justfile` to run all recipes for building and quality checking:

### Individual Commands

- **`just format`** - Format all Odin files with odinfmt
  - Formats: `bench/bench.odin`, `examples/example_num_format.odin`, `num_format.odin`, `num_format_test.odin`

- **`just lint [args]`** - Run linter with style and vet checks
  - Runs: `odin check . -vet -strict-style -no-entry-point`
  - Optional args: `--show-timings` or other odin check flags

- **`just build-rs`** - Build the Rust FFI library from source
  - Runs: `cargo build --release --manifest-path rust-ffi/Cargo.toml`
  - Optional on Windows (prebuilt library included)
  - Required on Linux/macOS (prebuilt not yet available)

- **`just test-rs`** - Run Rust tests in the FFI library
  - Runs: `cargo test --manifest-path rust-ffi/Cargo.toml`
  - Useful for testing the underlying Rust implementations

- **`just test`** - Run all Odin unit tests
  - Runs: `odin test .`
  - All tests must pass before committing

- **`just examples`** - Run example programs to verify bindings work
  - Runs: `odin run examples`
  - Should show formatted output without errors

- **`just bench-build`** - Build the benchmark executable
  - Runs: `odin build bench -o:speed -microarch:native`

- **`just bench`** - Run performance benchmarks
  - Runs: `odin run bench -o:speed -microarch:native`
  - Outputs timing statistics for all functions

### Full Quality Check Workflow

**Windows:**
```bash
just format     # Format code
just lint       # Check style and potential bugs
just test       # Verify unit tests (uses prebuilt library)
just examples   # Check examples work
just bench      # Run benchmarks for performance verification
```

**Linux/macOS:**
```bash
just format     # Format code
just lint       # Check style and potential bugs
just build-rs   # Build Rust library (required)
just test       # Verify unit tests
just examples   # Check examples work
just bench      # Run benchmarks for performance verification
```

To test Rust changes on any platform:
```bash
just build-rs   # Rebuild Rust library
just test-rs    # Test Rust library
```

## FFI Bindings

### Library Path Configuration

The library path has sensible defaults (prebuilt library included). Override only if needed:

```bash
odin build . -define:NUM_FORMAT_FFI_LIB="path/to/library"
```

Configuration is in `num_format.odin`:
```odin
when ODIN_OS == .Windows {
	NUM_FORMAT_FFI_LIB :: #config(NUM_FORMAT_FFI_LIB, "rust-ffi/target/release/num_format_ffi.lib")
} else {
	NUM_FORMAT_FFI_LIB :: #config(NUM_FORMAT_FFI_LIB, "rust-ffi/target/release/num_format_ffi.a")
}
```

### Foreign Function Declarations

The Odin bindings use `link_prefix` attribute to manage C function naming:

- **Float functions** (zmij_ prefix): Use `@(link_prefix = "zmij_")`
  - `format_f64`, `format_f32`, `format_finite_f64`, `format_finite_f32`
  
- **Integer functions** (rust_ prefix): Use `@(link_prefix = "rust_")`
  - `itoa_i64`, `itoa_u64`, `itoa_i32`, `itoa_u32`

When updating FFI declarations, ensure the link_prefix matches the C library export symbols.

## Code Style

- Use Odin's standard formatting with `odinfmt`
- Configuration: See `odinfmt.json`
- The justfile is Windows-friendly with PowerShell integration

## Project Structure

- `num_format.odin` - Main FFI bindings and helper procs
- `num_format_test.odin` - Unit tests (18 tests total)
- `examples/` - Example usage programs
- `bench/` - Benchmark suite
- `rust-ffi/` - Rust library implementation (separate cargo project)
  - `.cargo/config.toml` - Build configuration with `target-cpu=skylake` (requires AVX2)
