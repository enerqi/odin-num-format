# `cmd.exe` for one reason: it starts in ~9ms. just launches a shell per recipe LINE, so shell startup
# is a fixed tax on every recipe. Bare `<shell> exit` under hyperfine: cmd ~9ms, `nu -c` ~41ms (what
# this file used to set), `powershell -NoLogo -NoProfile -Command` ~143ms. cmd is also more portable
# than either: on every Windows and on GitHub's windows runners, no install, and no profile to make a
# recipe unreproducible.
#
# The cost is that cmd is a poor language for a multi-line recipe, and it does not accept `;` as a
# command separator at all. That is why the five `*-rs` recipes below no longer start with
# `cd {{RUST_FFI_DIR}}; \` — they use just's `[working-directory(...)]` attribute instead, which sets
# the recipe's CWD before the shell is even launched. Shorter, and it is the same on every platform.
set windows-shell := ["cmd.exe", "/c"]
set shell := ["bash", "-c"]
set unstable  # user-defined functions (`target_path` below) are still gated
set lazy

# Set by the newest just feature used below - user-defined functions (1.49), for `target_path`.
# Older features also needed: `[working-directory(...)]` 1.38, `join()` 1.37, `set lazy` 1.47. Without
# this an old just reports a plain syntax error at the offending line, which reads like a corrupt
# justfile rather than an out-of-date tool.
set minimum-version := "1.49.0"

# cargo's limitation is that .cargo/config.toml is read relative to CWD regardless of --manifest-path,
# which is why the `*-rs` recipes run WITH rust-ffi as their working directory rather than passing
# `--manifest-path`. The path itself stays here for anything that needs to name it.
RUST_FFI_DIR := replace(justfile_directory(), "\\", "/") + "/rust-ffi"

example_name := "example.exe"
bench_name := "bench.exe"
test_main_name := "test-main.exe"

# `join`, not the `/` operator: `/` always emits a forward slash, and cmd.exe rejects a forward-slash
# path in *command* position ("'target' is not recognized") even quoted. Odin takes either in an
# `-out:` argument, but the `rerun_*` recipes invoke the binary directly, so they need the native
# separator `join` gives. bash needs no `./` prefix - a path containing a slash is already a path.
target_path(dir, name) := join("target", dir, name)

# Which linker Odin hands the object files to. `-linker:` takes exactly four values: `default` (Odin
# picks - MSVC `link.exe` on Windows), `lld` (Windows and Linux; NOT on a stock macOS, where Odin
# links through Apple's clang and clang ships no lld), `radlink` (Windows only, and bundled with the
# Odin toolchain so it needs no install - which is why it is the Windows default in the other projects
# here) and `mold` (Linux only, and not bundled - `apt install mold` first). Odin has no build cache
# and relinks on every `just bench`, so the link step is a cost paid on each iteration.
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
# The sibling bridge deal-simulations project (odin-sims) hit the same class of radlink failure from a
# different direction: there radlink crashes at LINK time with its own `0xc000001d` when live
# `core:debug/trace` code is linked alongside the DDS static library. The concrete factor the two share
# is `dbghelp.lib` - `just native-libs-rs` below prints it among this project's required native libs,
# and `core:debug/trace` is a dbghelp consumer too. So the shape to be suspicious of is dbghelp in the
# link plus a static non-Odin library, rather than anything specific to Rust or to DDS.
#
# Override for a single command without editing this file. It is an env var rather than a recipe
# argument because `odin` errors on a repeated flag, so a `-linker:` passed through a recipe's *args
# would collide with the one the recipe already adds:
#
#     ODIN_LINKER=lld just bench -lto:thin   # -lto on Windows *requires* -linker:lld
#
# See the odin-lang-skeleton justfile for the full per-value notes.
linker := env_var_or_default("ODIN_LINKER", "default")


# odinfmt walks subdirectories itself, so this needs no per-file loop - one process replaces the
# previous one-subprocess-per-.odin-file python walk.
# ---
# odinfmt every odin file under this directory or subdirectories
format:
	odinfmt -w .

# lint checks for style and potential bugs. Accepts extra args like `--show-timings` as needed
lint *args:
	odin check . -vet -vet-cast -strict-style -vet-tabs -no-entry-point {{args}}
	odin check examples -vet -vet-cast -strict-style -vet-tabs {{args}}
	odin check bench -vet -vet-cast -strict-style -vet-tabs {{args}}

# The build recipes below now write into target/ rather than letting odin drop the exe/pdb/obj in the
# repo root. odin does not create the output directory (the linker fails with LNK1104), so this runs
# first. Created all at once rather than one per line because just starts a new shell per recipe line
# and on Windows the shell launch dwarfs the work.
# ---
# ensure the build artifacts top level directory exists
[unix]
@mktarget_dirs:
	mkdir -p target/debug target/release

# `if not exist` rather than swallowing md's "already exists" with `2>nul`, so a genuine failure still
# sets a non-zero exit. The loop variable is a single `%d`, NOT the `%%d` a .bat file would use:
# doubling is escaping for batch *files*, and `cmd /c` takes a command *line*.
# ---
# ensure the build artifacts top level directory exists
[windows]
@mktarget_dirs:
	for %d in (debug release) do @if not exist target\%d md target\%d || exit /b 1

# build the benchmarks without running them
bench-build *args: mktarget_dirs
	odin build bench -o:speed -microarch:native -linker:{{linker}} -out:{{ target_path("release", bench_name) }} {{args}}

# `-keep-executable` so `rerun-bench` can skip the recompile - the point of a benchmark recipe is the
# run, and Odin has no build cache, so `just bench` otherwise rebuilds and relinks the Rust staticlib
# into a fresh binary every time you want another sample.
# ---
# run the benchmarks, optimized
bench *args: mktarget_dirs
	odin run bench -o:speed -microarch:native -keep-executable -linker:{{linker}} -out:{{ target_path("release", bench_name) }} {{args}}

# re-run the last built benchmark WITHOUT recompiling. Requires a prior `just bench`/`bench-build`.
rerun-bench *args:
	{{ target_path("release", bench_name) }} {{args}}

# run the examples
examples *args: mktarget_dirs
	odin run examples -keep-executable -linker:{{linker}} -out:{{ target_path("debug", example_name) }} {{args}}

# re-run the last built examples binary WITHOUT recompiling. Requires a prior `just examples`.
rerun-examples *args:
	{{ target_path("debug", example_name) }} {{args}}

# run all tests
test *args: mktarget_dirs
	odin test . -linker:{{linker}} -out:{{ target_path("debug", test_main_name) }} {{args}}

# Filtering is a `core:testing` define rather than a compiler flag - there is no `-test-name:` (a stale
# spelling fails with `Unknown flag: 'test-name'` before anything builds). NAME takes a comma-separated
# list and the package prefix is optional, so `my_test` and `one,two` both work.
# ---
# run one named test (comma-separated for several)
test1 name *args: mktarget_dirs
	odin test . -define:ODIN_TEST_NAMES={{name}} -linker:{{linker}} -out:{{ target_path("debug", test_main_name) }} {{args}}

# delete the Odin build artifacts (the Rust side has its own `clean-rs`)
[unix]
clean:
	rm -rf target
	just mktarget_dirs

# cmd's equivalent of `rm -rf` is `rmdir /s /q`. Guarded by `if exist` because rmdir exits non-zero on
# a missing path, which would fail the recipe on an already-clean tree.
# ---
# delete the Odin build artifacts (the Rust side has its own `clean-rs`)
[windows]
clean:
	if exist target rmdir /s /q target
	just mktarget_dirs


#
# The Rust FFI side. Every recipe below runs WITH rust-ffi as its working directory - not via a `cd`
# in the recipe body, which needed a `;` separator cmd does not accept - because .cargo/config.toml
# (where +crt-static lives) is read relative to CWD regardless of --manifest-path.
#

# build the Rust staticlib these bindings link against
[working-directory("rust-ffi")]
build-rs *args:
	cargo build --release {{args}}

# print the native static libs to link against the built staticlib. Run this after changing CRT flags
# (e.g. +crt-static in .cargo/config.toml): the /defaultlib:msvcrt directive flips to libcmt and
# legacy_stdio_definitions.lib may appear/drop, so the `foreign import` list in num_format.odin must
# match.
# ---
# print the native static libs the staticlib needs linked alongside it
[working-directory("rust-ffi")]
native-libs-rs:
	cargo rustc --release -q -- --print=native-static-libs

# cargo clean the Rust staticlib build
[working-directory("rust-ffi")]
clean-rs:
	cargo clean

# rustfmt + clippy (warnings are errors) over the Rust staticlib
[working-directory("rust-ffi")]
lint-rs *args:
	cargo fmt {{args}}
	cargo clippy {{args}} -- -D warnings

# cargo test the Rust staticlib
[working-directory("rust-ffi")]
test-rs:
	cargo test
