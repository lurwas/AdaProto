#!/usr/bin/env python3
"""End-to-end smoke test of bin/conformance-runner over its real wire protocol.

Hand-encodes a ConformanceRequest carrying a binary TestAllTypesProto3 payload,
asks for JSON output, frames it (4-byte LE length), pipes it to the runner, then
unframes and inspects the ConformanceResponse.
"""
import subprocess, struct, sys

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

# inner: TestAllTypesProto3 { optional_int32 = 42; optional_string = "hi"; }
payload  = tag(1, 0) + varint(42)
payload += len_delim(14, b"hi")

MSG_TYPE = b"protobuf_test_messages.proto3.TestAllTypesProto3"

# ConformanceRequest { protobuf_payload=1; requested_output_format=3; message_type=4 }
# requested_output_format: JSON = 2
req  = len_delim(1, payload)
req += tag(3, 0) + varint(2)
req += len_delim(4, MSG_TYPE)

framed = struct.pack("<I", len(req)) + req

proc = subprocess.run(["./bin/conformance-runner"], input=framed,
                      stdout=subprocess.PIPE, timeout=10)
out = proc.stdout
assert len(out) >= 4, "no framed response"
resp_len = struct.unpack("<I", out[:4])[0]
resp = out[4:4 + resp_len]
assert len(resp) == resp_len, f"short response: {len(resp)} != {resp_len}"

# Walk the ConformanceResponse fields; we want field 4 (json_payload, string)
# or field 3 (protobuf_payload). Surface parse_error(1)/serialize_error(6)/
# runtime_error(2)/skipped(5) if present.
i = 0
found = {}
while i < len(resp):
    key = resp[i]; i += 1
    field, wire = key >> 3, key & 7
    if wire == 2:
        n = 0; shift = 0
        while resp[i] & 0x80:
            n |= (resp[i] & 0x7F) << shift; shift += 7; i += 1
        n |= resp[i] << shift; i += 1
        val = resp[i:i + n]; i += n
        found[field] = val
    elif wire == 0:
        while resp[i] & 0x80: i += 1
        i += 1
    else:
        raise SystemExit(f"unexpected wire type {wire}")

NAMES = {1: "parse_error", 2: "runtime_error", 3: "protobuf_payload",
         4: "json_payload", 5: "skipped", 6: "serialize_error", 10: "text_payload"}
for f, v in found.items():
    print(f"response.{NAMES.get(f, f)} = {v!r}")

assert 4 in found, "expected a json_payload result"
js = found[4].decode()
assert '"optionalInt32"' in js and "42" in js, f"unexpected JSON: {js}"
assert '"optionalString"' in js and "hi" in js, f"unexpected JSON: {js}"
print("\nEND-TO-END OK: runner parsed protobuf TestAllTypesProto3 and emitted JSON")
