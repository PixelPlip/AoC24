#!/usr/bin/env bash

main() {
  local id1 id2
  local -i index distance total
  local -a left right

  while read -r id1 id2; do
    left+=("$id1")
    right+=("$id2")
  done<"$1"

  IFS=$'\n' left=($(sort -n <<<"${left[*]}"))
  IFS=$'\n' right=($(sort -n <<<"${right[*]}"))

  for ((index = 0; index < "${#left[@]}"; index++)); do
    ((distance=left[index]-right[index]))
    ((distance < 0)) && ((distance*=-1))
    ((total+=distance))
  done

  echo "${total}"
}

main "$@"