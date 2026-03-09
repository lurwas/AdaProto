#!/usr/bin/env bash
set -euo pipefail

MIN_COVERAGE="${MIN_COVERAGE:-80}"
REPORT_DIR="coverage"
REPORT_TXT="$REPORT_DIR/coverage.txt"
TRACE_FILE="protobuf-ada-test.srctrace"

if ! command -v gnatcov >/dev/null 2>&1; then
  echo "gnatcov is not installed"
  exit 1
fi

GNATCOV_BIN="$(command -v gnatcov)"
GNATCOV_PREFIX="$(cd "$(dirname "$GNATCOV_BIN")/.." && pwd)"
GNATCOV_RTS_DIR="$GNATCOV_PREFIX/share/gnatcoverage/gnatcov_rts"

if [[ ! -f "$GNATCOV_RTS_DIR/gnatcov_rts_full.gpr" ]]; then
  echo "gnatcov runtime project not found at $GNATCOV_RTS_DIR"
  echo "Install with: <gnatcov-dist>/doinstall \$HOME/.local"
  exit 1
fi

rm -rf "$REPORT_DIR"
mkdir -p "$REPORT_DIR"
rm -f "$TRACE_FILE"

# GNATcov needs both the GNATcov RTS project and the system GPR path (AUnit).
export GPR_PROJECT_PATH="$GNATCOV_RTS_DIR:/usr/share/gpr:${GPR_PROJECT_PATH:-}"

# Instrument source units for coverage collection.
gnatcov instrument \
  -P protobuf_ada.gpr \
  --level=stmt \
  --dump-trigger=main-end \
  --dump-filename-simple

# Build instrumented binaries.
gprbuild \
  -P protobuf_ada.gpr \
  --src-subdirs=protobuf_ada-gnatcov-instr \
  --implicit-with="$GNATCOV_RTS_DIR/gnatcov_rts_full.gpr" \
  -cargs:Ada -g

# Run tests to emit source trace data.
./bin/protobuf-ada-test

if [[ ! -f "$TRACE_FILE" ]]; then
  echo "expected source trace file '$TRACE_FILE' was not generated"
  exit 1
fi

mapfile -t SID_FILES < <(find obj -maxdepth 1 -type f -name '*.sid' | sort)
if [[ "${#SID_FILES[@]}" -eq 0 ]]; then
  echo "no .sid files found in obj/"
  exit 1
fi

# Generate report and xcov artifacts from source trace + SID files.
COVERAGE_CMD=(
  gnatcov coverage
  --level=stmt \
  --annotate=report \
  --annotate=xcov \
  --output-dir="$REPORT_DIR"
)
for sid in "${SID_FILES[@]}"; do
  COVERAGE_CMD+=("--sid=$sid")
done
COVERAGE_CMD+=("$TRACE_FILE")
"${COVERAGE_CMD[@]}" > "$REPORT_TXT"

# Compute weighted statement coverage from generated .xcov files.
percent=$(
  awk '
    /statement coverage \(/ {
      covered = $4
      total = $7
      gsub(/[^0-9.]/, "", covered)
      gsub(/[^0-9.]/, "", total)
      covered_sum += covered + 0
      total_sum += total + 0
    }
    END {
      if (total_sum > 0) {
        printf "%.2f", (covered_sum * 100.0) / total_sum
      }
    }
  ' "$REPORT_DIR"/*.xcov
)
if [[ -z "$percent" ]]; then
  echo "coverage artifacts generated in $REPORT_DIR, but percentage parsing failed"
  exit 1
fi

echo "statement_coverage=${percent}%"
awk -v p="$percent" -v m="$MIN_COVERAGE" 'BEGIN{if (p+0 < m+0) exit 1}' || {
  echo "coverage below threshold (${MIN_COVERAGE}%)"
  exit 1
}

echo "coverage threshold satisfied"
