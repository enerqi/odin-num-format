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

bench-build:
    odin build bench -o:speed -microarch:native -extra-linker-flags:"/LIBPATH:C:/Users/Enerqi/dev/odin-num-format/rust-ffi/target/release"

bench:
    odin run bench -o:speed -microarch:native -extra-linker-flags:"/LIBPATH:C:/Users/Enerqi/dev/odin-num-format/rust-ffi/target/release"

examples:
    odin run examples -extra-linker-flags:"/LIBPATH:C:/Users/Enerqi/dev/odin-num-format/rust-ffi/target/release"

build-rs:
    cargo build --release --manifest-path "{{replace(justfile_directory(), "\\", "/")}}/rust-ffi/Cargo.toml"

test-rs:
    cargo test --manifest-path "{{replace(justfile_directory(), "\\", "/")}}/rust-ffi/Cargo.toml"

test:
    odin test . -extra-linker-flags:"/LIBPATH:C:/Users/Enerqi/dev/odin-num-format/rust-ffi/target/release"
