# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Ada 2012 runtime for the Protobuf **Proto3 wire format** — hand-written encode/decode, no schema compiler or codegen. The public API is a single package, `Protobuf` (`src/protobuf.ads` / `src/protobuf.adb`). Everything else (`tests/`, `tools/`, `fixtures/`) exists to test, benchmark, fuzz, and check conformance of that one package.

## Build & test

```bash
gprbuild -P protobuf_ada.gpr        # build all four executables into bin/
./bin/protobuf-ada-test             # run the AUnit suite
./bin/protobuf-ada-junit > tests/junit.xml   # same tests, JUnit XML output
./bin/protobuf-ada-bench            # encode/decode timing (prints encode_seconds=/decode_seconds=)
./bin/protobuf-ada-fuzz <input.bin> # parse one raw byte blob; nonzero exit on unexpected exception
```

Compiler defaults (`protobuf_ada.gpr`): `-gnat2012 -O2 -gnata`. `-gnata` keeps assertions/preconditions enabled — do not assume they are compiled out.

There is no single-test filter; the AUnit runner in `tests/protobuf_ada_test.adb` always runs the whole `Protobuf_Tests.Suite`. To narrow scope, edit the registrations in `tests/protobuf_tests.adb` (~37 routines registered via `Register_Routine`).

CI (`.github/workflows/ci.yml`) additionally builds under ASan and UBSan, runs the suite under Valgrind (`--leak-check=full --error-exitcode=1`), and smoke-tests the fuzz harness. To reproduce a sanitizer build locally:

```bash
gprbuild -P protobuf_ada.gpr -cargs -gnat2012 -g -O1 -fsanitize=address -fno-omit-frame-pointer -largs -fsanitize=address
```

## Coverage, benchmark guard, compat

```bash
MIN_COVERAGE=80 tools/run_coverage.sh   # gnatcov stmt coverage, fails under threshold; writes coverage/
tools/check_gnatcov.sh                   # verify gnatcov + its RTS project are installed
tools/bench_compare.sh                   # runs bench RUNS times, fails if avg exceeds baseline + MAX_REGRESSION_PERCENT
tools/test_compiler_compat.sh            # rebuild smoke against every gnatmake-* driver on PATH
```

`tools/run_coverage.sh` requires a gnatcov install with its RTS project (`share/gnatcoverage/gnatcov_rts/gnatcov_rts_full.gpr`); it instruments, builds into `obj/protobuf_ada-gnatcov-instr/`, runs the test binary to emit `protobuf-ada-test.srctrace`, then reports.

The benchmark guard reads `benchmarks/baseline.env` (`ENCODE_SECONDS`, `DECODE_SECONDS`, `MAX_REGRESSION_PERCENT`, `RUNS`). Bump those numbers **intentionally** only when an algorithmic change legitimately shifts timing — they are the regression gate, not informational.

## Architecture notes

- **`Message_Buffer`** is a `limited private` accumulator. The `Add_*` procedures append wire-encoded fields in insertion order; `To_String` / `Serialize_To_String` return the raw bytes; `Write_To_Stream` writes them. Output is deterministic by insertion order — there is **no** canonical reordering by field number.
- **Parsing** (`Parse_From_String` / `Deserialize_From_String` / `Parse_From_Stream`) returns a `Parsed_Field_Vectors.Vector` of `Parsed_Field`, a variant record discriminated on `Wire_Type`. Parsing is schema-agnostic: it recovers wire type + field number + raw value only. Typed interpretation is a separate, caller-chosen step via the `As_*` accessors (e.g. the same varint can be read with `As_Int64`, `As_SInt64`, `As_UInt64`, or `As_Bool`). The fuzz harness (`tests/protobuf_ada_fuzz.adb`) demonstrates this pattern.
- **Packed repeated fields** have dedicated `Add_Packed_*` / `Decode_Packed_*` APIs for every packable scalar type.
- **Errors**: malformed input raises `Protobuf.Parse_Error`; encode-side failures raise `Encode_Error`. Bytes are carried as Ada `String` (one `Character` per byte), not `Stream_Element_Array`.
- **Deliberately unimplemented** (see `docs/CONFORMANCE.md`): groups (wire types 3/4 → `Parse_Error`), schema codegen, proto2 presence/extensions, and map-field semantics (maps parse as nested message bytes). Unknown fields are preserved as raw `Parsed_Field` values.

## Golden fixtures

`fixtures/` holds bytes generated from the **C++ protobuf** reference implementation, so the Ada runtime is tested against an authoritative encoder. Schema is `fixtures/schema.proto`. The generator is C++ (`tools/generate_fixtures.cpp`, prebuilt binary `tools/generate_fixtures`).

```bash
tools/generate_fixtures.sh              # regenerate all *.bin / *.hex fixtures (needs protobuf-compiler + libprotobuf-dev)
tools/update_malformed_corpus.sh 128    # regenerate + minimize the malformed-input corpus
```

`tests/fixture_loader.adb` locates fixtures by trying `fixtures/`, `../fixtures/`, `../../fixtures/` — so tests work whether run from the repo root or a subdirectory.

## Caveat: build artifacts are committed

`obj/`, `bin/`, and stray `*.ali` / `*.o` / `*.srctrace` files are checked into the repo and there is no `.gitignore`. After building, `git status` will show churn in these. Avoid committing regenerated build artifacts unless that is the actual intent of the change.
