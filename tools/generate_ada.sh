#!/usr/bin/env bash
set -euo pipefail

# Build protoc-ada and (re)generate the Ada sources under tests/generated/
# from every schema in tests/proto/. Run this after editing a .proto or the
# generator; the committed output is what the test suite compiles against.

gprbuild -q -P protoc_ada.gpr

mkdir -p tests/generated
for proto in tests/proto/*.proto; do
  ./bin/protoc-ada "$proto" tests/generated
done

echo "regenerated Ada sources in tests/generated/"
