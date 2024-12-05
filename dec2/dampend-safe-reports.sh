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

dampen_validation() {
  local -a numbers sub_numbers
  numbers=($1)
  for ((i = 0; i < ${#numbers[@]}; i++)); do
    sub_numbers=$(remove_index_from_array "${numbers[*]}" "$i")
    if [[ $(validate_report "${sub_numbers[*]}") -eq 1 ]]; then
      echo 1
      return 0
    fi
  done
  echo 0
}

remove_index_from_array() {
  local -a array
  array=($1)
  unset 'array[$2]'
  echo "${array[*]}"
}

main() {
  local report
  local -i safe_reports
  local -a numbers

  while read -r report; do
    numbers=(${report})
    if [[ $(validate_report "${numbers[*]}") -eq 1 || $(dampen_validation "${numbers[*]}") -eq 1 ]]; then
     (( safe_reports++ ))
   fi
  done<"$1"

  echo "${safe_reports}"
}

main "$@"