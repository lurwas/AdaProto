# protobuf-ada-best

Ada 2012 protobuf (Proto3 wire format) runtime with AUnit tests, C++ golden fixtures, and benchmark/test executables.

## Implemented

- Proto3 wire encoding/decoding for:
  - `int32`, `int64`, `uint32`, `uint64`
  - `sint32`, `sint64` (ZigZag)
  - `bool`, `enum`
  - `fixed32`, `fixed64`, `sfixed32`, `sfixed64`
  - `float` (`IEEE_Float_32`), `double` (`IEEE_Float_64`)
  - `string`, `bytes`, nested `message`
- Packed repeated encoding APIs for all packable scalar types.
- Packed repeated decoding APIs for all packable scalar types.
- String-based serialization/parsing APIs.
- Stream-based serialization/parsing APIs.

## Project Layout

- `src/` protobuf runtime (`Protobuf` package)
- `tests/` AUnit suite and test runners
- `fixtures/` golden bytes generated from C++ protobuf
- `tools/` fixture generator source

## Binaries

- `protobuf-ada-test`
- `protobuf-ada-junit`
- `protobuf-ada-bench`
- `protobuf-ada-fuzz`

Build:

```bash
gprbuild -P protobuf_ada.gpr
```

Run tests:

```bash
./bin/protobuf-ada-test
```

Generate JUnit XML:

```bash
./bin/protobuf-ada-junit > tests/junit.xml
```

Run benchmark:

```bash
./bin/protobuf-ada-bench
```

Run fuzz harness on one input file:

```bash
./bin/protobuf-ada-fuzz /path/to/input.bin
```

## Golden Fixtures (C++ protobuf)

Schema: `fixtures/schema.proto`

Regenerate fixtures (version-aware wrapper):

```bash
tools/generate_fixtures.sh
```

This writes:

- `fixtures/all_types.bin`
- `fixtures/empty.bin`
- `fixtures/advanced_types.bin`
- `fixtures/all_types_corpus.hex`
- `fixtures/malformed_corpus.hex`
- `fixtures/all_types.hex`
- `fixtures/empty.hex`
- `fixtures/advanced_types.hex`

Update and minimize malformed corpus:

```bash
tools/update_malformed_corpus.sh 128
```

## Coverage

Run statement coverage with threshold enforcement:

```bash
tools/check_gnatcov.sh
MIN_COVERAGE=80 tools/run_coverage.sh
```

## Performance Guard

Compare benchmark averages to baseline:

```bash
tools/bench_compare.sh
```

Baseline file:

- `benchmarks/baseline.env`

## Compatibility

Compiler compatibility smoke (all available `gnatmake-*` drivers):

```bash
tools/test_compiler_compat.sh
```

## Conformance Notes

See:

- `docs/CONFORMANCE.md`
