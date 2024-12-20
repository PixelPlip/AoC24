#!/usr/bin/env bash

# Grep for all matches "mul(123,321)"
matches=$(grep -oP 'mul\(\d+,\d+\)' "$1")
# Remove all prefixed "mul("
matches=${matches//mul\(/}
# Remove all suffixed ")"
matches=${matches//\)/}

while IFS=$',\n' read -r num1 num2; do
  ((total += num1 * num2))
done<<<"$matches"

echo "$total"