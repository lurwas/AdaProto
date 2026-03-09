#!/usr/bin/env bash
set -euo pipefail

if command -v gnatcov >/dev/null 2>&1; then
  echo "gnatcov found: $(command -v gnatcov)"
  gnatcov --version | head -n 1
  exit 0
fi

echo "gnatcov not found in PATH."
echo

echo "Step 1: check whether Ubuntu provides it on your host:"
echo "  apt-cache search gnatcov"
echo "  sudo apt install gnatcov"
echo

echo "If unavailable (common on Ubuntu 24.04), install GNATcoverage via AdaCore toolchain."
echo "Then add its bin directory to PATH, for example:"
echo '  export PATH="/opt/adacore/<toolchain>/bin:$PATH"'
echo

echo "Step 2: verify after install:"
echo "  gnatcov --version"
echo

echo "Step 3: run project coverage:"
echo "  MIN_COVERAGE=80 tools/run_coverage.sh"

exit 1
