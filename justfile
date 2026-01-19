set windows-shell := ["nu", "-c"]
set shell := ["bash", "-c"]


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
    cargo build --release --manifest-path "{{replace(justfile_directory(), "\\", "/")}}/rust-ffi/Cargo.toml" {{args}}

lint-rs *args:
    cargo fmt --manifest-path "{{replace(justfile_directory(), "\\", "/")}}/rust-ffi/Cargo.toml" {{args}}
    cargo clippy --manifest-path "{{replace(justfile_directory(), "\\", "/")}}/rust-ffi/Cargo.toml" {{args}} -- -D warnings

test-rs:
    cargo test --manifest-path "{{replace(justfile_directory(), "\\", "/")}}/rust-ffi/Cargo.toml"

test *args:
    odin test . {{args}}
