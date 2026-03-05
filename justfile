set windows-shell := ["nu", "-c"]
set shell := ["bash", "-c"]

# cargo limitation is that .cargo/config.toml is read relative to CWD regardless of --manifest-path
RUST_FFI_DIR := replace(justfile_directory(), "\\", "/") + "/rust-ffi"


# odinfmt every odin file under this directory or subdirectories
format:
    odinfmt -w bench/bench.odin
    odinfmt -w examples/example_num_format.odin
    odinfmt -w num_format.odin
    odinfmt -w num_format_test.odin

# lint checks for style and potential bugs. Accepts extra args like `--show-timings`as needed
lint *args:
    odin check . -vet -strict-style -no-entry-point {{args}}
    odin check examples -vet -strict-style
    odin check bench -vet -strict-style

bench-build *args:
    odin build bench -o:speed -microarch:native {{args}}

bench *args:
    odin run bench -o:speed -microarch:native {{args}}

examples *args:
    odin run examples {{args}}

build-rs *args:
    cd {{RUST_FFI_DIR}}; \
    cargo build --release {{args}}

clean-rs:
    cd {{RUST_FFI_DIR}}; \
    cargo clean

lint-rs *args:
    cd {{RUST_FFI_DIR}}; \
    cargo fmt {{args}}; \
    cargo clippy {{args}} -- -D warnings

test-rs:
    cd {{RUST_FFI_DIR}}; \
    cargo test

test *args:
    odin test . {{args}}
