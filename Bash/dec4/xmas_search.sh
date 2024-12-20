#!/usr/bin/env bash

declare -A matrix
declare -a x_positions
declare sequence="XMAS"

check_X_location() {
  local -i row column row_increment column_increment i
  row="$1"
  column="$2"
  row_increment="$3"
  column_increment="$4"
  for (( i = 0; i < ${#sequence}; i++ )); do
    if [[ "${matrix[$row,$column]}" != "${sequence:i:1}" ]]; then
      echo 0
      return 0
    fi
    (( row += row_increment ))
    (( column += column_increment ))
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
    (( total += $(check_X_location "$row" "$column" -1  0) )) # Up
    (( total += $(check_X_location "$row" "$column" -1  1) )) # Up right
    (( total += $(check_X_location "$row" "$column"  0  1) )) # Right
    (( total += $(check_X_location "$row" "$column"  1  1) )) # Down Right
    (( total += $(check_X_location "$row" "$column"  1  0) )) # Down
    (( total += $(check_X_location "$row" "$column"  1 -1) )) # Down left
    (( total += $(check_X_location "$row" "$column"  0 -1) )) # Left
    (( total += $(check_X_location "$row" "$column" -1 -1) )) # Up Left
  done

  echo "$total"
}

main "$@"