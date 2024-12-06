#!/usr/bin/env bash

# Grep for all matches "mul(123,321)"
matches=$(grep -oP "mul\(\d+,\d+\)|do\(\)|don't\(\)" "$1")
# Remove all prefixed "mul"
matches=${matches//mul/}
# Remove all prefixed "("
matches=${matches//\(/}
# Remove all suffixed ")"
matches=${matches//\)/}

should_do=1
while IFS=$' \n' read -r instruction; do

  if [[ "$instruction" == "do" ]]; then
    (( should_do = 1 ))

  elif [[ "$instruction" == "don't" ]]; then
    (( should_do = 0 ))

  elif (( should_do == 1)); then
    IFS=$',\n' read -r num1 num2 <<< "$instruction"
    (( total += num1 * num2 ))
  fi
done<<<"$matches"

echo "$total"