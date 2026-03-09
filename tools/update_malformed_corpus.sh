#!/usr/bin/env bash
set -euo pipefail

OUT="fixtures/malformed_corpus.hex"
TMP="${OUT}.tmp"
COUNT="${1:-128}"

mkdir -p fixtures
: > "$TMP"

# Keep existing corpus entries and normalize.
if [[ -f "$OUT" ]]; then
  sed 's/[[:space:]]//g' "$OUT" | sed '/^$/d' >> "$TMP"
fi

# Add deterministic pseudo-random malformed records.
seed=0x1234abcd
for ((i=0; i<COUNT; i++)); do
  seed=$(( (seed * 1103515245 + 12345) & 0x7fffffff ))
  len=$(( seed % 48 ))
  if (( len == 0 )); then
    echo "80" >> "$TMP"
    continue
  fi
  hex=""
  for ((j=0; j<len; j++)); do
    seed=$(( (seed * 1103515245 + 12345) & 0x7fffffff ))
    byte=$(( seed & 0xff ))
    hex+=$(printf '%02x' "$byte")
  done
  echo "$hex" >> "$TMP"
done

# Minimize/dedupe: keep unique lines, shortest first.
awk 'length($0) > 0' "$TMP" | awk '!seen[$0]++' | awk '{ print length($0) ":" $0 }' | sort -n | cut -d: -f2- > "$OUT"
rm -f "$TMP"

echo "updated $OUT"
