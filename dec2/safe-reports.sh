#!/usr/bin/env bash

validate_decending_report() {
  local -a numbers
  numbers=($1)
  for ((i = 1; i < ${#numbers[@]}; i++)); do
    if ! (( numbers[i-1] > numbers[i] && (numbers[i-1] - numbers[i]) <= 3 )); then
      echo 0
      return 0
    fi
  done
  echo 1
}

validate_acending_report() {
  local -a numbers
  numbers=($1)
  for ((i = 1; i < ${#numbers[@]}; i++)); do
    if ! (( numbers[i-1] < numbers[i] && (numbers[i] - numbers[i-1]) <= 3 )); then
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
    if (( numbers[0] > numbers[1] )); then
      (( safe_reports += $(validate_decending_report "${numbers[*]}") ))
    else
      (( safe_reports += $(validate_acending_report "${numbers[*]}") ))
    fi
  done<"$1"

  echo "${safe_reports}"
}

main "$@"