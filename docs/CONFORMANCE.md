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

**Phase 1a (current).** Generates a typed Ada record per message plus
`Serialize`/`Parse_<Message>` over the wire runtime. Supported:

- `syntax = "proto3";`, `package`, `import`/`option` (ignored), top-level `message`.
- Singular scalar fields: `int32/64`, `uint32/64`, `sint32/64`, `fixed32/64`,
  `sfixed32/64`, `float`, `double`, `bool`, `string`, `bytes`.
- proto3 default omission (default-valued scalars are not written).
- Ada reserved-word field names are escaped (e.g. `delta` -> `Delta_F`).

Unsupported constructs raise a clear `Compile_Error` with line number.

### Codegen roadmap (toward 100% proto3 + JSON)

1. **1b** repeated (packed + unpacked decode), nested messages, enums.
2. **1c** `oneof`, `map<K,V>`, recursive messages, default-value edge cases.
3. **2** proto3 canonical JSON mapping (parse + serialize).
4. **3** well-known types (`Any`, `Timestamp`, `Duration`, `Struct`, wrappers,
   `FieldMask`, `Empty`), UTF-8 validation of `string` fields.
5. **4** wire up Google's official conformance-test-runner protocol and drive
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
