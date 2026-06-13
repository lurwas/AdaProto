#!/usr/bin/env python3
"""End-to-end smoke test of bin/conformance-runner over its real wire protocol.

Hand-encodes ConformanceRequests carrying binary TestAllTypesProto3 payloads,
asks for JSON output, frames each (4-byte LE length), pipes it to the runner,
then unframes and inspects the ConformanceResponse.
"""
import subprocess, struct

def varint(n):
    out = bytearray()
    while True:
        b = n & 0x7F
        n >>= 7
        out.append(b | (0x80 if n else 0))
        if not n:
            return bytes(out)

def tag(field, wire):
    return varint((field << 3) | wire)

def len_delim(field, data):
    return tag(field, 2) + varint(len(data)) + data

MSG_TYPE = b"protobuf_test_messages.proto3.TestAllTypesProto3"

def request_json(payload):
    """A ConformanceRequest: this protobuf payload in, JSON output requested."""
    req  = len_delim(1, payload)            # protobuf_payload
    req += tag(3, 0) + varint(2)            # requested_output_format = JSON
    req += len_delim(4, MSG_TYPE)           # message_type
    return req

def run(payload):
    """Frame a request, drive the runner, unframe + parse the response fields."""
    req = request_json(payload)
    framed = struct.pack("<I", len(req)) + req
    out = subprocess.run(["./bin/conformance-runner"], input=framed,
                         stdout=subprocess.PIPE, timeout=10).stdout
    assert len(out) >= 4, "no framed response"
    n = struct.unpack("<I", out[:4])[0]
    resp = out[4:4 + n]
    assert len(resp) == n, f"short response: {len(resp)} != {n}"

    i, found = 0, {}
    while i < len(resp):
        key = resp[i]; i += 1
        field, wire = key >> 3, key & 7
        if wire == 2:
            ln = 0; shift = 0
            while resp[i] & 0x80:
                ln |= (resp[i] & 0x7F) << shift; shift += 7; i += 1
            ln |= resp[i] << shift; i += 1
            found[field] = resp[i:i + ln]; i += ln
        elif wire == 0:
            while resp[i] & 0x80: i += 1
            i += 1
        else:
            raise SystemExit(f"unexpected wire type {wire}")
    NAMES = {1: "parse_error", 2: "runtime_error", 5: "skipped", 6: "serialize_error"}
    for f, v in found.items():
        if f in NAMES:
            raise SystemExit(f"runner returned {NAMES[f]}: {v!r}")
    assert 4 in found, f"expected a json_payload result, got fields {list(found)}"
    return found[4].decode()

# 1) scalars: optional_int32 = 42, optional_string = "hi"
js = run(tag(1, 0) + varint(42) + len_delim(14, b"hi"))
print(f"scalars -> {js}")
assert '"optionalInt32":42' in js and '"optionalString":"hi"' in js, js

# 2) NullValue: oneof_null_value (field 120) set -> JSON null
js = run(tag(120, 0) + varint(0))
print(f"null    -> {js}")
assert '"oneofNullValue":null' in js, js

print("\nEND-TO-END OK: runner round-trips TestAllTypesProto3 incl. NullValue -> JSON null")
