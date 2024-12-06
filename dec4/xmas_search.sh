#!/usr/bin/env bash

declare -A matrix
declare -a x_positions
declare sequence="XMAS"

check_right() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( column++ ))
  done
  echo 1
}

check_down_right() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( column++ ))
    (( row++ ))
  done
  echo 1
}

check_down() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( row++ ))
  done
  echo 1
}

check_down_left() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( column-- ))
    (( row++ ))
  done
  echo 1
}

check_left() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( column-- ))
  done
  echo 1
}

check_up_left() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( column-- ))
    (( row-- ))
  done
  echo 1
}

check_up() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( row-- ))
  done
  echo 1
}

check_up_right() {
  local -i row column i
  row="$1"
  column="$2"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( column++ ))
    (( row-- ))
  done
  echo 1
}

main() {
  local -i row column
  row=0
  while read -r line; do
    for (( column = 0; column < ${#line}; column++ )); do
      letter=${line:column:1}
      matrix[$row,$column]="$letter"
      if [[ "$letter" == "X" ]]; then
        x_positions+=("$row,$column")
      fi
    done
    (( row++ ))
  done<"$1"

  for (( coord = 0; coord < ${#x_positions[@]}; coord++ )); do
    IFS="," read -r row column <<< "${x_positions["$coord"]}"
    #printf "Row: %s, Column: %s, Letter: %s, Output:\n%s\n" "$row" "$column" "${matrix[$row,$column]}" "$(check_right $row $column)"
    (( total += $(check_right "$row" "$column") ))
    (( total += $(check_down_right "$row" "$column") ))
    (( total += $(check_down "$row" "$column") ))
    (( total += $(check_down_left "$row" "$column") ))
    (( total += $(check_left "$row" "$column") ))
    (( total += $(check_up_left "$row" "$column") ))
    (( total += $(check_up "$row" "$column") ))
    (( total += $(check_up_right "$row" "$column") ))
  done

  echo "$total"
}

main "$@"