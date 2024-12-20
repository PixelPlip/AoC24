#!/usr/bin/env bash

main() {
  local id1 id2
  local -i score
  local -a left right

  while read -r id1 id2; do
    left+=("${id1}")
    right+=("${id2}")
  done<"$1"

  for ((i = 0; i < "${#left[@]}"; i++)); do
    ((score += $(grep -o ${left[i]} <<< "${right[*]}" | wc -l) * ${left[i]}))
  done

  echo "${score}"
}

main "$@"