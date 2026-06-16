#!/usr/bin/env bash
#
# Run Google's official conformance-test-runner against bin/conformance-runner,
# with conformance/failure_list_proto3.txt marking the documented expected
# failures. A clean run prints "CONFORMANCE SUITE PASSED ... 0 unexpected
# failures".
#
# The runner itself is a large C++/Bazel program built from the protobuf repo
# (it is NOT vendored here). Point $CONFORMANCE_TEST_RUNNER at the binary, or
# build it once:
#
#   git clone --depth 1 --recurse-submodules --shallow-submodules \
#       -b v29.3 https://github.com/protocolbuffers/protobuf.git
#   cmake -S protobuf -B protobuf/build -DCMAKE_BUILD_TYPE=Release \
#       -Dprotobuf_BUILD_TESTS=OFF -Dprotobuf_BUILD_CONFORMANCE=ON \
#       -Dprotobuf_ABSL_PROVIDER=module
#   cmake --build protobuf/build --target conformance_test_runner -j"$(nproc)"
#   export CONFORMANCE_TEST_RUNNER=$PWD/protobuf/build/conformance_test_runner
#
# Pass --enforce_recommended to also run the RECOMMENDED tests.
set -euo pipefail

cd "$(dirname "$0")/.."

RUNNER="${CONFORMANCE_TEST_RUNNER:-}"
if [[ -z "$RUNNER" || ! -x "$RUNNER" ]]; then
  echo "Set CONFORMANCE_TEST_RUNNER to Google's conformance_test_runner binary." >&2
  echo "See the header of $0 for build instructions." >&2
  exit 1
fi

if [[ ! -x ./bin/conformance-runner ]]; then
  echo "bin/conformance-runner not built; run: gprbuild -P protobuf_ada.gpr" >&2
  exit 1
fi

exec "$RUNNER" --failure_list conformance/failure_list_proto3.txt "$@" \
  ./bin/conformance-runner
