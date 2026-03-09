#!/usr/bin/env bash
set -euo pipefail

BASELINE_FILE="benchmarks/baseline.env"
BIN="./bin/protobuf-ada-bench"

if [[ ! -f "$BASELINE_FILE" ]]; then
  echo "missing $BASELINE_FILE"
  exit 1
fi
source "$BASELINE_FILE"

if [[ ! -x "$BIN" ]]; then
  echo "missing executable $BIN"
  exit 1
fi

runs="${RUNS:-3}"
if (( runs < 1 )); then
  runs=1
fi

enc_sum=0
dec_sum=0

for ((i=1; i<=runs; i++)); do
  out="$($BIN)"
  enc=$(awk -F= '/^encode_seconds=/{gsub(/ /, "", $2); print $2}' <<< "$out")
  dec=$(awk -F= '/^decode_seconds=/{gsub(/ /, "", $2); print $2}' <<< "$out")
  if [[ -z "$enc" || -z "$dec" ]]; then
    echo "unable to parse benchmark output"
    echo "$out"
    exit 1
  fi
  enc_sum=$(awk -v a="$enc_sum" -v b="$enc" 'BEGIN{print a+b}')
  dec_sum=$(awk -v a="$dec_sum" -v b="$dec" 'BEGIN{print a+b}')
done

enc_avg=$(awk -v s="$enc_sum" -v r="$runs" 'BEGIN{printf "%.9f", s/r}')
dec_avg=$(awk -v s="$dec_sum" -v r="$runs" 'BEGIN{printf "%.9f", s/r}')

enc_limit=$(awk -v b="$ENCODE_SECONDS" -v p="$MAX_REGRESSION_PERCENT" 'BEGIN{printf "%.9f", b*(1+p/100.0)}')
dec_limit=$(awk -v b="$DECODE_SECONDS" -v p="$MAX_REGRESSION_PERCENT" 'BEGIN{printf "%.9f", b*(1+p/100.0)}')

printf 'encode_avg=%s (baseline=%s, limit=%s)\n' "$enc_avg" "$ENCODE_SECONDS" "$enc_limit"
printf 'decode_avg=%s (baseline=%s, limit=%s)\n' "$dec_avg" "$DECODE_SECONDS" "$dec_limit"

awk -v v="$enc_avg" -v lim="$enc_limit" 'BEGIN{if (v>lim) exit 1}' || {
  echo "encode regression exceeded threshold"
  exit 1
}

awk -v v="$dec_avg" -v lim="$dec_limit" 'BEGIN{if (v>lim) exit 1}' || {
  echo "decode regression exceeded threshold"
  exit 1
}

echo "benchmark regression guard passed"
