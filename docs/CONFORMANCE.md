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

## Explicitly not implemented

- Groups (wire types 3/4): parser raises `Parse_Error`.
- Schema compiler/codegen for Ada message classes.
- Proto2 field presence semantics and extensions.
- Map-field semantic helpers (maps are still parseable as nested message bytes).

## Determinism

- Deterministic output follows insertion order of added fields.
- No canonical reordering is applied by field number.
