# Proto3 Conformance Notes

## Supported wire features

- Varint, fixed32, fixed64, length-delimited wire types.
- Scalar encoding/decoding: `int32`, `int64`, `uint32`, `uint64`, `sint32`, `sint64`, `bool`, `enum`.
- Fixed-width types: `fixed32`, `fixed64`, `sfixed32`, `sfixed64`, `float`, `double`.
- Length-delimited payloads: `string`, `bytes`, nested message bytes.
- Packed repeated encode APIs for all packable scalar types.
- Packed repeated decode helper APIs for all packable scalar types.
- String and stream serialization/deserialization.

## Unknown fields

- Parser preserves unknown fields in parsed output as raw `Parsed_Field` values.
- No schema-aware projection is performed at runtime.

## Schema compiler (protoc-ada)

A `.proto` -> Ada code generator is being built toward full proto3 + JSON
conformance, in phases. Build it with `gprbuild -P protoc_ada.gpr`; regenerate
the checked-in sources with `tools/generate_ada.sh`.

**The generator** produces a typed Ada package per `.proto`, with a record
per message plus binary `Serialize`/`Parse_<Message>` over the wire runtime.
Supported:

- `syntax = "proto3";`, `package`, `import`/`option` (ignored), top-level
  `message` and `enum`.
- Singular scalar fields: `int32/64`, `uint32/64`, `sint32/64`, `fixed32/64`,
  `sfixed32/64`, `float`, `double`, `bool`, `string`, `bytes`.
- `enum` fields (open enums: int32-valued subtype + named constants).
- `repeated` scalar/enum fields (packed encode by default; explicit
  `[packed=false]` encodes unpacked -- one tag+value entry per element; both
  packed and unpacked decode accepted) and `repeated string`/`bytes`.
- `message` fields, including recursive and mutually-recursive ones. Each
  message gets a generated memory-safe controlled holder (an access type
  wrapped in a `Controlled` record that deep-copies on assignment and frees on
  finalize); singular fields use the holder for presence, repeated use vectors
  of holders. Forward declarations let types reference one another in any order.
- `oneof` -> a discriminated (variant) record; a set member is always written
  (even at its default value) and last-seen wins on decode.
- `map<K,V>` -> `Ordered_Maps`; encoded as repeated key(1)/value(2) entry
  messages, with scalar/enum/string or message values.
- proto3 default omission (default-valued scalars are not written).
- Ada reserved-word field names are escaped (e.g. `delta` -> `Delta_F`), and
  field names that collide with their own type (`color : Color`) are escaped.
- Field names that are not legal Ada identifiers -- leading, trailing, or
  doubled underscores (the proto3 JSON field-name edge cases, e.g.
  `_field_name3`, `field__name4_`) -- are legalized for the internal Ada type
  only; the wire field number and the emitted JSON name are unaffected.

Each message also gets `To_JSON`/`From_JSON` (proto3 <-> JSON), via the `JSON`
DOM and the `Proto_JSON` runtime helpers:

- **Serialize** (`To_JSON`): lowerCamelCase field names, 32-bit ints as JSON
  numbers, 64-bit ints as JSON strings, `bytes` as base64, `bool`/float/double
  (non-finite floats as "NaN"/"Infinity"/"-Infinity"), enums as their value
  names (unknown values as numbers), repeated as arrays, `map` as objects keyed
  by the stringified key, nested messages as nested objects, the active `oneof`
  member as its own field, and default-valued fields omitted.
- **Parse** (`From_JSON`): the inverse. Field names match either camelCase or
  the raw proto name; numbers accepted bare or quoted; 64-bit ints from strings;
  `bytes` from standard or URL-safe base64; enums from name or number; map keys
  parsed from their string form; missing/null fields keep the default.

**UTF-8 validation**: `string` fields are validated as well-formed UTF-8 when
decoded (from the wire and from JSON) and rejected with `Proto_JSON.Decode_Error`
if not; `bytes` fields accept arbitrary octets.

**proto3 `optional`**: explicit-presence scalar fields are supported. The
generated record carries a `<field>_Has : Boolean` flag beside the value, and
emission (wire and JSON) is governed by that flag rather than the value -- so an
`optional` set to its default (e.g. `0`) is still written, while an absent one is
omitted. Implicit-presence (no-`optional`) scalars keep the omit-at-default rule.

**Nested type definitions**: messages and enums declared inside a message are
supported. They are flattened to top-level Ada types under their fully-qualified
name (`Outer.Inner` -> `Outer_Inner`), and each field's type reference is bound
to the type it denotes via proto's innermost-out scope search before code
generation. Corecursion (a nested message referring back to its enclosing type)
works through the same controlled holders as ordinary recursion.

### Well-known types (`src/proto_wkt.*`)

A runtime library of `google.protobuf.*` types with their binary wire
(de)serialization and special proto3-JSON forms. Done so far:

- `Empty` (wire: no fields; JSON: `{}`).
- The nine scalar wrapper types (`Int32Value`, `StringValue`, `BytesValue`, …):
  on the wire a message with field 1; in JSON the bare wrapped value
  (e.g. `Int32Value{5}` <-> `5`, `BytesValue` <-> base64, 64-bit <-> string).
- `Duration` (`{seconds, nanos}`; JSON `"<secs>[.<frac>]s"` with 0/3/6/9 frac
  digits and sign) and `Timestamp` (JSON RFC 3339, always emitted as UTC `…Z`;
  parsing accepts a `Z` or a numeric offset).
- `FieldMask` (repeated `paths`; JSON one comma-joined string of lowerCamelCase
  paths).
- `Struct`/`Value`/`ListValue` -- dynamic, recursive JSON-shaped values backed
  by the JSON DOM (JSON is pass-through; binary is the recursive Value wire
  encoding). Note: `Struct` numbers are doubles, per proto3.
- `Any` -- binary is `{type_url, value}`; JSON is `{"@type": url, …}` resolved
  through a type-name registry (well-known types under `"value"`, regular
  messages inlined). All the WKTs above register themselves; generated code can
  register its own message types via `Proto_WKT.Register_Any_Type`.

**Generator integration**: a field of type `google.protobuf.X` resolves to
`Proto_WKT.X` -- the generator emits a controlled holder over the external WKT
type (presence), routes binary encode/decode through `Proto_WKT.Serialize` /
`Proto_WKT.Parse_X`, and JSON through `Proto_WKT.To_JSON`/`From_JSON` (so the
special forms apply). Supported for singular, repeated, `oneof`-member, and
map-value WKT fields. As a `oneof` member or a `map` value the WKT is stored in
the same controlled holder used for message values, so encode/decode and the
special JSON forms apply uniformly.

### Conformance runner (`bin/conformance-runner`)

A testee that speaks Google's conformance-test-runner protocol: it reads a
4-byte little-endian length then that many bytes of a `ConformanceRequest` from
stdin, and writes a `ConformanceResponse` the same way, looping until stdin
closes. `tests/proto/conformance.proto` is the real subset (matching wire field
numbers); `Conformance_Harness.Handle` (unit-tested) parses the payload and
re-serializes it in the requested format across protobuf and JSON.

The harness is routed to Google's canonical message
`protobuf_test_messages.proto3.TestAllTypesProto3`, generated from
`tests/proto/test_messages_proto3.proto`. To drive Google's official suite,
point its `conformance-test-runner` at `bin/conformance-runner`; requests for
other message types (proto2, editions) are `skipped`.

**Coverage of `TestAllTypesProto3`.** `test_messages_proto3.proto` reproduces
the upstream message's package, name, and canonical field numbers for every
construct the generator and runtime model: all scalar types, nested/foreign
messages and enums, recursion and corecursion, repeated, packed-repeated, and
explicitly unpacked (`[packed=false]`) fields, the full range of map key/value
shapes, a `oneof`, the JSON field-name edge cases (canonical `ToJsonName`
derivation, incl. leading/trailing/doubled underscores), and the well-known
types (wrappers, `Duration`, `Timestamp`, `FieldMask`, `Struct`, `Any`,
`Value`, and `NullValue` -- a WKT enum that is int32 on the wire but JSON
`null`).

Every construct the message declares round-trips, in both directions, across
binary and JSON (exercised by the `conformance harness` unit test and an
end-to-end smoke through the actual `bin/conformance-runner`).

### Authoritative cross-check (`tools/run_conformance_crosscheck.sh`)

Google's official `conformance-test-runner` is a large C++/Bazel program that is
not buildable in every environment. `tools/conformance_crosscheck.py` reproduces
what it does -- driving the testee over the real conformance wire protocol
(4-byte LE length + `ConformanceRequest`/`ConformanceResponse`) -- using
Google's **reference Python protobuf implementation** as the oracle. For a
battery of authoritatively-built `TestAllTypesProto3` messages (scalars, fixed/
float, nested message+enum, repeated/packed/unpacked, maps, oneofs, the
well-known types, `Struct`, and the JSON field-name edge cases) it exercises all
four directions and compares the Ada runner's output to the oracle:

    protobuf payload -> protobuf output      JSON payload -> protobuf output
    protobuf payload -> JSON output          JSON payload -> JSON output

All 52 cases (13 messages x pb/json x in/out) pass. Run it with `protoc` and the
Python `protobuf` package available:

```bash
gprbuild -P protobuf_ada.gpr
tools/run_conformance_crosscheck.sh   # honours $PROTOC / $PY_PROTOBUF overrides
```

### Official conformance run (`tools/run_official_conformance.sh`)

Google's official C++ `conformance-test-runner` has been run against
`bin/conformance-runner`. The current result:

    CONFORMANCE SUITE PASSED: 1372 successes, 1262 skipped,
                              25 expected failures, 0 unexpected failures.

The 1262 skipped are input types this proto3-only testee does not handle
(proto2, editions, text format). The 25 expected failures are documented and
categorized in `conformance/failure_list_proto3.txt`; passing that file via
`--failure_list` is what makes the suite report **0 unexpected failures**:

```bash
gprbuild -P protobuf_ada.gpr
export CONFORMANCE_TEST_RUNNER=.../conformance_test_runner   # see script header
tools/run_official_conformance.sh
```

The 25 remaining gaps, by feature: `allow_alias` enums (8), `Any` from JSON (6),
wire-level message merge (4), unknown-field retention (2), `Value` accepting
JSON null (2), a map entry with a missing message value (2), and duplicate
oneof members in JSON (1). The `tools/run_conformance_crosscheck.sh` oracle
above complements this for environments without the C++ runner.

### Codegen roadmap (toward 100% proto3 + JSON)

1. Close the 25 documented expected failures in
   `conformance/failure_list_proto3.txt` -- in rough order of effort:
   duplicate-oneof rejection and `Value`-null, then `allow_alias` enums and the
   map missing-default, then `Any`-from-JSON resolution, and finally the
   architectural items (message merge on decode, unknown-field retention).

## Explicitly not implemented (yet)

- Groups (wire types 3/4): parser raises `Parse_Error` (a proto2-only feature
  removed from proto3, so rejecting them is correct).
- Reflection/descriptors and text format.
- Proto2 field presence semantics and extensions.
- `map`/`oneof` semantic helpers in generated code (maps are still parseable as
  nested message bytes via the runtime).

## Determinism

- Deterministic output follows insertion order of added fields.
- No canonical reordering is applied by field number.
