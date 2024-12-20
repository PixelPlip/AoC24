#!/usr/bin/env bash

validate_report() {
  local -a numbers
  numbers=($1)
  for ((i = 1; i < ${#numbers[@]}; i++)); do
    if ! (( (numbers[0] > numbers[1] && numbers[i-1] > numbers[i] && (numbers[i-1] - numbers[i]) <= 3) ||
            (numbers[0] < numbers[1] && numbers[i-1] < numbers[i] && (numbers[i] - numbers[i-1]) <= 3) )); then
      echo 0
      return 0
    fi
  done
  echo 1
}

main() {
  local report
  local -i safe_reports
  local -a numbers

  while read -r report; do
    numbers=(${report})
    (( safe_reports += $(validate_report "${numbers[*]}") ))
  done<"$1"

  echo "${safe_reports}"
}

main "$@"