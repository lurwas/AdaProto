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
- `repeated` scalar/enum fields (packed encode; both packed and unpacked
  decode accepted) and `repeated string`/`bytes`.
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

Unsupported constructs (nested type definitions, `optional`) raise a clear
`Compile_Error` with line number.

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
special forms apply). Supported for singular and repeated WKT fields; a WKT as
a map value is rejected with a clear error (a follow-up).

### Codegen roadmap (toward 100% proto3 + JSON)

1. **4** wire up Google's official conformance-test-runner protocol and drive
   the proto3 + JSON conformance suite to a green (or explicitly-documented) run.

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
