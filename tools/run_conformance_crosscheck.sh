#!/usr/bin/env bash
#
# Drive bin/conformance-runner through an authoritative cross-check (see
# tools/conformance_crosscheck.py). Google's official conformance-test-runner is
# a large C++/Bazel build; this instead uses Google's *reference* Python
# protobuf implementation as the oracle, over the same conformance wire protocol.
#
# Requirements (any reasonably recent versions):
#   - protoc            on PATH, or $PROTOC, or $PROTOC_BIN
#   - python3 with the `protobuf` package importable (or $PY_PROTOBUF on PYTHONPATH)
#
# Generates the conformance/test-message bindings into a temp dir, then runs the
# cross-check against the freshly built ./bin/conformance-runner.
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -x ./bin/conformance-runner ]]; then
  echo "bin/conformance-runner not found; build it with: gprbuild -P protobuf_ada.gpr" >&2
  exit 1
fi

PROTOC="${PROTOC:-${PROTOC_BIN:-protoc}}"
if ! command -v "$PROTOC" >/dev/null 2>&1; then
  echo "protoc not found (set \$PROTOC to a protoc binary)" >&2
  exit 1
fi

# Well-known-type .proto imports ship beside protoc under ../include.
PROTOC_INCLUDE="${PROTOC_INCLUDE:-$(cd "$(dirname "$(command -v "$PROTOC")")/.." && pwd)/include}"

GEN_DIR="$(mktemp -d)"
trap 'rm -rf "$GEN_DIR"' EXIT

"$PROTOC" -I tests/proto -I "$PROTOC_INCLUDE" --python_out="$GEN_DIR" \
  tests/proto/conformance.proto tests/proto/test_messages_proto3.proto

export PYTHONPATH="${PY_PROTOBUF:+$PY_PROTOBUF:}$GEN_DIR:${PYTHONPATH:-}"
exec python3 tools/conformance_crosscheck.py
