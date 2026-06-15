#!/usr/bin/env python3
"""Authoritative conformance cross-check for bin/conformance-runner.

Google's official conformance-test-runner is a large C++/Bazel program that
cannot be built in every environment. This script reproduces what it does --
drive the testee over the real conformance wire protocol (4-byte LE length +
ConformanceRequest/ConformanceResponse) -- using Google's *reference* Python
protobuf implementation (the `protobuf` package) as the oracle.

For a battery of authoritatively-built TestAllTypesProto3 messages it exercises
all four directions and checks the Ada runner's output against the oracle:

    protobuf payload -> protobuf output   (reparse, compare == original)
    protobuf payload -> JSON output       (json_format.Parse, compare == original)
    JSON payload     -> protobuf output
    JSON payload     -> JSON output

Run via tools/run_conformance_crosscheck.sh, which wires up PYTHONPATH to the
isolated protobuf install and the generated *_pb2 modules.
"""
import struct
import subprocess
import sys

import conformance_pb2 as cpb
import test_messages_proto3_pb2 as tm
from google.protobuf import json_format

RUNNER = "./bin/conformance-runner"
MSG_TYPE = "protobuf_test_messages.proto3.TestAllTypesProto3"
PROTOBUF, JSON = cpb.PROTOBUF, cpb.JSON


def drive(req: cpb.ConformanceRequest) -> cpb.ConformanceResponse:
    """Frame one request, run the testee, unframe the response."""
    payload = req.SerializeToString()
    framed = struct.pack("<I", len(payload)) + payload
    out = subprocess.run([RUNNER], input=framed,
                         stdout=subprocess.PIPE, timeout=15).stdout
    if len(out) < 4:
        raise RuntimeError("no framed response")
    n = struct.unpack("<I", out[:4])[0]
    resp = cpb.ConformanceResponse()
    resp.ParseFromString(out[4:4 + n])
    return resp


def roundtrip(name, msg, fmt_in, fmt_out, results):
    """One conformance case: encode msg in fmt_in, request fmt_out, compare."""
    req = cpb.ConformanceRequest(message_type=MSG_TYPE,
                                 requested_output_format=fmt_out)
    if fmt_in == PROTOBUF:
        req.protobuf_payload = msg.SerializeToString()
    else:
        req.json_payload = json_format.MessageToJson(msg)

    label = f"{name} [{'pb' if fmt_in==PROTOBUF else 'json'}->" \
            f"{'pb' if fmt_out==PROTOBUF else 'json'}]"
    try:
        resp = drive(req)
    except Exception as e:                       # noqa: BLE001
        results.append((label, "ERROR", f"runner crashed: {e}"))
        return

    kind = resp.WhichOneof("result")
    if kind in ("parse_error", "serialize_error", "runtime_error"):
        results.append((label, "FAIL", f"{kind}: {getattr(resp, kind)!r}"))
        return
    if kind == "skipped":
        results.append((label, "SKIP", resp.skipped))
        return

    got = tm.TestAllTypesProto3()
    try:
        if fmt_out == PROTOBUF:
            got.ParseFromString(resp.protobuf_payload)
        else:
            json_format.Parse(resp.json_payload, got)
    except Exception as e:                        # noqa: BLE001
        results.append((label, "FAIL", f"oracle could not parse output: {e}"))
        return

    if got == msg:
        results.append((label, "PASS", ""))
    else:
        results.append((label, "FAIL", "output differs from oracle"))


def cases():
    """Authoritatively-built TestAllTypesProto3 messages, one per construct."""
    out = []

    m = tm.TestAllTypesProto3(optional_int32=42, optional_int64=-9000000000,
                              optional_uint32=7, optional_uint64=2**63,
                              optional_sint32=-5, optional_sint64=-12345678901,
                              optional_bool=True, optional_string="héllo",
                              optional_bytes=b"\x00\xff\x10")
    out.append(("scalars", m))

    m = tm.TestAllTypesProto3(optional_float=3.5, optional_double=-2.25,
                              optional_fixed32=123, optional_fixed64=456,
                              optional_sfixed32=-1, optional_sfixed64=-2)
    out.append(("fixed_and_float", m))

    m = tm.TestAllTypesProto3()
    m.optional_nested_message.a = 7
    m.optional_nested_enum = tm.TestAllTypesProto3.BAR
    out.append(("nested_message_enum", m))

    m = tm.TestAllTypesProto3(repeated_int32=[1, 2, 3, -4],
                              repeated_string=["a", "bb", ""],
                              packed_int32=[5, 6, 7],
                              packed_double=[1.5, 2.5])
    out.append(("repeated_and_packed", m))

    m = tm.TestAllTypesProto3(unpacked_int32=[9, 8, 7],
                              unpacked_sint32=[-1, 1],
                              unpacked_nested_enum=[tm.TestAllTypesProto3.FOO,
                                                    tm.TestAllTypesProto3.BAR])
    out.append(("unpacked", m))

    m = tm.TestAllTypesProto3()
    m.map_string_string["k"] = "v"
    m.map_int32_int32[3] = 9
    m.map_string_nested_message["n"].a = 11
    out.append(("maps_basic", m))

    m = tm.TestAllTypesProto3(oneof_uint32=99)
    out.append(("oneof_uint32", m))
    m = tm.TestAllTypesProto3()
    m.oneof_nested_message.a = 5
    out.append(("oneof_nested_message", m))

    m = tm.TestAllTypesProto3()
    m.optional_int32_wrapper.value = 5
    m.optional_string_wrapper.value = "w"
    m.optional_bool_wrapper.value = True
    out.append(("wrappers", m))

    m = tm.TestAllTypesProto3()
    m.optional_duration.seconds = 3
    m.optional_timestamp.seconds = 100
    m.optional_field_mask.paths.extend(["foo.bar", "baz"])
    out.append(("duration_timestamp_fieldmask", m))

    m = tm.TestAllTypesProto3()
    m.optional_struct["a"] = 1
    m.optional_struct["b"] = "two"
    out.append(("struct", m))

    m = tm.TestAllTypesProto3()
    m.fieldname1 = 1
    m.field_name2 = 2
    setattr(m, "_field_name3", 3)
    m.field0name5 = 5
    m.field_name17__ = 17
    out.append(("json_field_names", m))

    out.append(("empty", tm.TestAllTypesProto3()))
    return out


def main():
    results = []
    for name, msg in cases():
        for fi in (PROTOBUF, JSON):
            for fo in (PROTOBUF, JSON):
                roundtrip(name, msg, fi, fo, results)

    width = max(len(lbl) for lbl, _, _ in results)
    npass = nfail = nskip = nerr = 0
    for lbl, status, detail in results:
        if status == "PASS":
            npass += 1
            continue
        if status == "SKIP":
            nskip += 1
        elif status == "ERROR":
            nerr += 1
        else:
            nfail += 1
        print(f"{status:5} {lbl:<{width}}  {detail}")

    print(f"\n{npass} passed, {nfail} failed, {nerr} errors, {nskip} skipped "
          f"({len(results)} cases across pb/json x in/out)")
    sys.exit(1 if (nfail or nerr) else 0)


if __name__ == "__main__":
    main()
