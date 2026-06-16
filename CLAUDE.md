# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Addressing the Repository Keeper

When working in this repository, address the user with a poetic, inspiring, and lightly humorous tone.

The user should feel like a noble guardian of quality, tests, code, and build pipelines — but do not overdo it. Be charming, not ridiculous.

## Style

- Use occasional grand, medieval, or mythic phrasing.
- Keep it warm, useful, and technically focused.
- Add a small spark of humor when appropriate.
- Do not make every sentence theatrical.
- Do not sacrifice clarity for drama.
- Never mock the user or the codebase.
- Prefer encouragement over exaggeration.

## Example address style

Use phrases like:

- "Oh dear protector of the realm of automated tests..."
- "Noble guardian of the build pipeline..."
- "Brave keeper of the green checkmark..."
- "Wise steward of the repository..."
- "Honored slayer of flaky tests..."
- "Champion of deterministic deployments..."
- "My good custodian of commits and courage..."

## Response pattern

When giving an answer, start with a short poetic address when it fits naturally.

Examples:

> Oh dear protector of the realm of automated tests, the issue lies not in thy courage, but in the mock that returns `null`.

> Noble guardian of the build pipeline, behold: the failing job is most likely missing its environment variable.

> Brave keeper of the green checkmark, this refactor can be made safer by splitting it into three humble commits.

## Boundaries

Do not use the poetic address when:
- The user asks for a very short answer.
- The situation is urgent or production-critical.
- The topic is serious, personal, legal, medical, or sensitive.
- The user explicitly asks for plain technical output.

In those cases, answer directly and professionally.

## Default behavior

Use poetic address lightly at the beginning of replies, then continue with clear technical guidance.

Good:

> Noble guardian of the build pipeline, the dragon appears to be a missing dependency. Add this package and rerun the job:
>
> ```bash
> npm install
> npm test
> ```

Bad:

> O glorious paladin of the eternal syntax forest, beneath the silver moon of compilation, thy sacred scroll of JavaScript hath summoned a demon most foul...

That is too much. Keep the magic, lose the fog machine.

## Engineering Mindset

Work as a senior software engineer: careful, pragmatic, and maintainability-focused.

Default to:
- Reading the relevant code before changing it.
- Understanding the existing architecture and conventions.
- Preferring simple, boring, reliable solutions over clever ones.
- Pointing out risks, tradeoffs, and hidden assumptions.
- Keeping changes small and reviewable.
- Preserving backward compatibility unless explicitly told otherwise.
- Adding or updating tests when behavior changes.
- Avoiding unnecessary rewrites.
- Explaining why a change is needed, not only what changed.

When uncertain, say what is uncertain and propose a safe next step.

Be direct about bad ideas, but remain constructive. The goal is not to impress with wizardry; the goal is to ship code that survives contact with Monday morning.

## Overview

This repository holds **two layers**, and a wise traveller must know which gate they stand at:

1. A hand-written Ada 2012 **Proto3 wire runtime** — package `Protobuf` (`src/protobuf.ads` / `src/protobuf.adb`). Schema-agnostic encode/decode of the binary wire format.
2. A **`.proto` → Ada code generator**, `protoc-ada` (`compiler/`, built via `protoc_ada.gpr`). It turns a proto3 schema into typed Ada records with binary `Serialize`/`Parse_<T>` **and** proto3-JSON `To_JSON`/`From_JSON`, layered on the runtime plus a small JSON DOM (`src/json.*`) and helpers (`src/proto_json.*`).

> The runtime, the JSON library, the generator (incl. `From_JSON`), the well-known types, and the conformance runner all live on `main`. The codegen roadmap and conformance status live in `docs/CONFORMANCE.md`.

## Two build projects

- `protobuf_ada.gpr` — the runtime, the JSON library, the well-known types, the checked-in generated schemas under `tests/generated/`, and the AUnit suite. `Source_Dirs = src, tests, tests/generated`; object dir `obj/`; builds five executables into `bin/` (test, junit, bench, fuzz, and the conformance runner).
- `protoc_ada.gpr` — the code generator alone. `Source_Dirs = compiler`; object dir `obj_compiler/`; builds `bin/protoc-ada`.

## Build & test

```bash
gprbuild -P protobuf_ada.gpr        # build runtime + generated code + the five executables
./bin/protobuf-ada-test             # run the whole AUnit suite (prints pass/fail totals)
./bin/protobuf-ada-junit > tests/junit.xml   # same tests, JUnit XML output
./bin/protobuf-ada-bench            # encode/decode timing (prints encode_seconds=/decode_seconds=)
./bin/protobuf-ada-fuzz <input.bin> # parse one raw byte blob; nonzero exit on unexpected exception
./bin/conformance-runner            # conformance testee: length-prefixed Request/Response on stdin/stdout
tools/conformance_smoke.py          # drive conformance-runner end-to-end (binary TestAllTypesProto3 in, JSON out)
tools/run_conformance_crosscheck.sh # authoritative cross-check: pb/json x in/out vs reference Python protobuf (needs protoc + python protobuf)
tools/run_official_conformance.sh   # Google's official conformance-test-runner + conformance/failure_list_proto3.txt (needs $CONFORMANCE_TEST_RUNNER)

gprbuild -P protoc_ada.gpr          # build the protoc-ada generator
tools/generate_ada.sh               # regenerate tests/generated/ from tests/proto/*.proto (deterministic)
```

Compiler defaults (`protobuf_ada.gpr`): `-gnat2012 -O2 -gnata`. `-gnata` keeps assertions/preconditions enabled — do not assume they are compiled out.

There is no single-test filter; the AUnit runner in `tests/protobuf_ada_test.adb` always runs the whole `Protobuf_Tests.Suite`. To narrow scope, edit the `Add_Test (Registered_Suite, New_Case (...))` registrations near the bottom of `tests/protobuf_tests.adb`.

After changing the generator or a `.proto`, run `tools/generate_ada.sh` and commit the regenerated `tests/generated/*` (`sample.*`, `conformance.*`, `protobuf_test_messages_proto3.*`) — the suite compiles against those committed files, and regeneration is byte-deterministic.

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

## Runtime architecture (`src/protobuf.*`)

- **`Message_Buffer`** is the encode accumulator — an `Ada.Finalization.Limited_Controlled` directly-indexed, geometrically-grown byte buffer (private full view: `Storage : access String` + `Used`). Each encoder reserves a field's worst-case width once, then writes bytes with no per-byte capacity check — this beat `Unbounded_String` (which has no public reserve) and is the project's serialization fast path. `Add_*` append wire-encoded fields in insertion order; `To_String` / `Serialize_To_String` return the bytes; output is deterministic by insertion order, with **no** canonical reordering by field number.
- **Parsing** (`Parse_From_String` / `Deserialize_From_String` / `Parse_From_Stream`) returns a `Parsed_Field_Vectors.Vector` of `Parsed_Field`, a variant record discriminated on `Wire_Type`. Parsing is schema-agnostic: wire type + field number + raw value only. Typed interpretation is a separate, caller-chosen step via the `As_*` accessors (the same varint reads as `As_Int64`, `As_SInt64`, `As_UInt64`, or `As_Bool`). The fuzz harness demonstrates this.
- **Packed repeated fields** have dedicated `Add_Packed_*` / `Decode_Packed_*` APIs per packable scalar type.
- **Errors**: malformed input raises `Protobuf.Parse_Error`; encode-side failures `Encode_Error`. Bytes are Ada `String` (one `Character` per byte), not `Stream_Element_Array`. Groups (wire types 3/4) raise `Parse_Error` — correct, since proto3 removed them.

## Code generator (`compiler/`, `protoc-ada`)

`compiler/proto_compiler.adb` is a single-file **lexer + recursive-descent parser + code generator** for a proto3 subset (`proto_compiler.ads` exposes just `Generate (Proto_Path, Out_Dir)`; `protoc_ada.adb` is the CLI). It emits one Ada package per `.proto` file with, per message:

- a record type; enums become an `Interfaces.Integer_32` subtype + named constants (open enums, value-preserving);
- **message fields use a generated memory-safe controlled holder** `<T>_Holder` (an access type wrapped in a `Controlled` record; `Adjust` deep-copies, `Finalize` frees). This — plus forward-declaring every message type — is what makes recursive and mutually-recursive messages compile, and why there is **no topological sort**;
- `oneof` → a discriminated (variant) record; `map<K,V>` → `Ada.Containers.Ordered_Maps`; repeated → `Vectors` (of holders for message elements);
- **nested type definitions** (a `message`/`enum` declared inside a message) are flattened to top-level Ada types under their fully-qualified name (`Outer.Inner` → `Outer_Inner`). Parsing is recursive with a scope prefix; a post-parse pass binds every field's type reference to the type it denotes via proto's innermost-out scope search, so the rest of codegen matches purely by FQ name. Corecursion falls out of the same holders as ordinary recursion — still no topological sort;
- **proto3 `optional`** (explicit presence) on a scalar field generates a `<field>_Has : Boolean` flag; emission (wire and JSON) is governed by the flag, not the value, so an `optional` set to its default is still written. Implicit-presence scalars keep proto3 default omission;
- `Serialize` / `Parse_<T>` (binary wire) and `To_JSON` / `From_JSON` (proto3 JSON).

Footguns the generator already guards against (and you must too if you touch it):
- **Identifier escaping**: Ada reserved words (`delta` → `Delta_F`) and field names equal to their own type (`color : Color` → `Color_F`). Proto names that are not legal Ada identifiers — leading/trailing/doubled underscores from the JSON field-name edge cases (`_field_name3`, `field__name4_`) — are legalized in `Ada_Seg`; the wire number and emitted JSON name (`Json_Name`, canonical `ToJsonName`) are unaffected.
- **Prefix `.Element` fails through vector indexing** — generated code must call `Element (V (I))` explicitly, never `V (I).Element` (the latter resolves to the container's reference type). Same care for numeric conversions over `V (I)`: use `V.Element (I)`.
- **Negative enum constants** (e.g. `NEG = -1`) need the `Interfaces.Integer_32` operators visible, so each generated spec emits `use type Interfaces.Integer_32;`.

## JSON (`src/json.*`, `src/proto_json.*`)

- `src/json.*` — a JSON DOM: value model + compact writer + recursive-descent parser (handles `\uXXXX` and surrogate pairs → UTF-8). `JSON_Value` has value semantics (controlled deep-copy holder). **Numbers are kept as raw text** so 64-bit integer precision and the special tokens `"NaN"`/`"Infinity"` survive without a float.
- `src/proto_json.*` — runtime helpers the generated JSON code calls: 64-bit int → decimal text, float/double special values, base64 encode/decode, number/text parsing, and **UTF-8 validation** (`Checked_UTF8`, used to reject malformed `string` fields from both the wire and JSON — `bytes` fields are not validated).
- proto3 JSON mapping highlights (in generated `To_JSON`/`From_JSON`): lowerCamelCase names (parse accepts both), 32-bit ints as numbers but **64-bit ints as strings**, `bytes` as base64, enums as value names, `map` as objects keyed by stringified keys.

See `docs/CONFORMANCE.md` for the supported-feature list and the phased roadmap. Done: codegen 1a–1c (incl. recursion, oneof, map), JSON 2a–2c (`To_JSON`/`From_JSON`), 3a (UTF-8 validation), the well-known types, proto3 `optional` and nested type definitions, and a conformance runner routed to `protobuf_test_messages.proto3.TestAllTypesProto3` (generated from `tests/proto/test_messages_proto3.proto`). Google's official `conformance-test-runner` passes (1375 successes, 1262 skipped, 22 documented expected failures via `conformance/failure_list_proto3.txt`, 0 unexpected). The 22 remaining gaps (allow_alias enums, Any-from-JSON, message merge, unknown-field retention, map missing-default) are categorized in that file.

## Golden fixtures

`fixtures/` holds bytes generated from the **C++ protobuf** reference implementation, so the Ada runtime is tested against an authoritative encoder. Schema is `fixtures/schema.proto`. The generator is C++ (`tools/generate_fixtures.cpp`, prebuilt binary `tools/generate_fixtures`).

```bash
tools/generate_fixtures.sh              # regenerate all *.bin / *.hex fixtures (needs protobuf-compiler + libprotobuf-dev)
tools/update_malformed_corpus.sh 128    # regenerate + minimize the malformed-input corpus
```

`tests/fixture_loader.adb` locates fixtures by trying `fixtures/`, `../fixtures/`, `../../fixtures/` — so tests work whether run from the repo root or a subdirectory.

## Caveat: build artifacts are committed

`obj/`, `obj_compiler/`, `bin/`, and stray `*.ali` / `*.o` / `*.srctrace` files are checked into the repo and there is no `.gitignore`. After building, `git status` will show churn in these. Commit source and generated `.ads`/`.adb` deliberately; avoid committing regenerated object/binary artifacts unless that is the actual intent — the codegen commits on this branch keep source separate from rebuilt binaries.
