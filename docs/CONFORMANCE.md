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

**Phases 1a + 1b (current).** Generates a typed Ada record per message plus
`Serialize`/`Parse_<Message>` over the wire runtime. Supported:

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

### Codegen roadmap (toward 100% proto3 + JSON)

1. **3 (remaining)** well-known types (`Any`, `Timestamp`, `Duration`, `Struct`,
   wrappers, `FieldMask`, `Empty`) and their special JSON forms.
2. **4** wire up Google's official conformance-test-runner protocol and drive
   the proto3 + JSON conformance suite to a green (or explicitly-documented) run.

## Explicitly not implemented (yet)

- Groups (wire types 3/4): parser raises `Parse_Error` (a proto2-only feature
  removed from proto3, so rejecting them is correct).
- JSON mapping, well-known types, reflection/descriptors, text format.
- Proto2 field presence semantics and extensions.
- `map`/`oneof` semantic helpers in generated code (maps are still parseable as
  nested message bytes via the runtime).

## Determinism

- Deterministic output follows insertion order of added fields.
- No canonical reordering is applied by field number.
