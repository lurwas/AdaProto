#!/usr/bin/env bash
set -euo pipefail

EXPECTED_PROTOC_MAJOR="3"
EXPECTED_PROTOC_MINOR="21"

if ! command -v protoc >/dev/null 2>&1; then
  echo "protoc not found"
  exit 1
fi
if ! command -v g++ >/dev/null 2>&1; then
  echo "g++ not found"
  exit 1
fi

ver_raw="$(protoc --version | awk '{print $2}')"
major="${ver_raw%%.*}"
rest="${ver_raw#*.}"
minor="${rest%%.*}"

if [[ "$major" != "$EXPECTED_PROTOC_MAJOR" || "$minor" != "$EXPECTED_PROTOC_MINOR" ]]; then
  echo "warning: expected protoc ${EXPECTED_PROTOC_MAJOR}.${EXPECTED_PROTOC_MINOR}.x, found ${ver_raw}" >&2
fi

protoc --cpp_out=. fixtures/schema.proto
g++ -std=c++17 -O2 -I. tools/generate_fixtures.cpp fixtures/schema.pb.cc -lprotobuf -o tools/generate_fixtures
./tools/generate_fixtures

echo "fixtures regenerated with protoc ${ver_raw}"
