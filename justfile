set windows-shell := ["nu", "-c"]
set shell := ["bash", "-c"]

# cargo limitation is that .cargo/config.toml is read relative to CWD regardless of --manifest-path
RUST_FFI_DIR := replace(justfile_directory(), "\\", "/") + "/rust-ffi"

# Which linker Odin hands the object files to. `-linker:` takes exactly four values: `default` (Odin
# picks - MSVC `link.exe` on Windows), `lld` (Windows and Linux; NOT on a stock macOS, where Odin
# links through Apple's clang and clang ships no lld), `radlink` (Windows only, and bundled with the
# Odin toolchain so it needs no install - which is why it is the Windows default here) and `mold`
# (Linux only, and not bundled - `apt install mold` first). Odin has no build cache and relinks on
# every `just run`, so the link step is a cost paid on each iteration.
#
# UNLIKE the other Odin projects here, the Windows default is `default` (MSVC link.exe) and NOT
# radlink. radlink LINKS this project without complaint but produces a binary that dies immediately
# with "A fatal exception (code 0xc000001d)" - STATUS_ILLEGAL_INSTRUCTION - while the same `odin test .`
# passes 34/34 under `default` and under `lld`. The suspect is this project's Rust staticlib and its
# CRT arrangement: `+crt-static` flips the linker directive to /defaultlib:libcmt and pulls in
# legacy_stdio_definitions.lib (see the native-libs-rs recipe below), and radlink evidently resolves
# that combination differently. Do not switch this to radlink without running the tests, not just
# building them - the failure is at runtime, so a successful link proves nothing here.
#
# Override for a single command without editing this file. It is an env var rather than a recipe
# argument because `odin` errors on a repeated flag, so a `-linker:` passed through a recipe's *args
# would collide with the one the recipe already adds:
#
#     ODIN_LINKER=lld just run -lto:thin   # -lto on Windows *requires* -linker:lld
#
# See the odin-lang-skeleton justfile for the full per-value notes.
linker := env_var_or_default("ODIN_LINKER", "default")


# odinfmt walks subdirectories itself, so this needs no per-file loop - one process replaces the
# previous one-subprocess-per-.odin-file python walk.
# ---
# odinfmt every odin file under this directory or subdirectories
format:
    odinfmt -w .

# lint checks for style and potential bugs. Accepts extra args like `--show-timings`as needed
lint *args:
    odin check . -vet -vet-cast -strict-style -vet-tabs -no-entry-point {{args}}
    odin check examples -vet -vet-cast -strict-style -vet-tabs
    odin check bench -vet -vet-cast -strict-style -vet-tabs

bench-build *args:
    odin build bench -o:speed -microarch:native -linker:{{linker}} {{args}}

bench *args:
    odin run bench -o:speed -microarch:native -linker:{{linker}} {{args}}

examples *args:
    odin run examples -linker:{{linker}} {{args}}

build-rs *args:
    cd {{RUST_FFI_DIR}}; \
    cargo build --release {{args}}

# print the native static libs to link against the built staticlib. Run this
# after changing CRT flags (e.g. +crt-static in .cargo/config.toml): the
# /defaultlib:msvcrt directive flips to libcmt and legacy_stdio_definitions.lib
# may appear/drop, so the `foreign import` list in num_format.odin must match.
# (cd into RUST_FFI_DIR so .cargo/config.toml is picked up - it is CWD-relative.)
native-libs-rs:
    cd {{RUST_FFI_DIR}}; \
    cargo rustc --release -q -- --print=native-static-libs

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
    odin test . -linker:{{linker}} {{args}}
