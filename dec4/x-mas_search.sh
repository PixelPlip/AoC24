#!/usr/bin/env bash

declare -A matrix
declare -a a_positions

check_M_location() {
  local -i row column
  row="$1"
  column="$2"

  if [[ ( ("${matrix[$((row-1)),$((column-1))]}" == "M" && "${matrix[$((row+1)),$((column+1))]}" == "S") ||
          ("${matrix[$((row-1)),$((column-1))]}" == "S" && "${matrix[$((row+1)),$((column+1))]}" == "M") ) &&
        ( ("${matrix[$((row-1)),$((column+1))]}" == "M" && "${matrix[$((row+1)),$((column-1))]}" == "S") ||
          ("${matrix[$((row-1)),$((column+1))]}" == "S" && "${matrix[$((row+1)),$((column-1))]}" == "M") )   ]]; then
    echo 1
  else
    echo 0
  fi
}

main() {
  local -i row column index
  row=0
  while read -r line; do
    for (( column = 0; column < ${#line}; column++ )); do
      letter=${line:column:1}
      matrix[$row,$column]="$letter"
      if [[ "$letter" == "A" ]]; then
        a_positions+=("$row,$column")
      fi
    done
    (( row++ ))
  done<"$1"

  for (( index = 0; index < ${#a_positions[@]}; index++ )); do
    IFS="," read -r row column <<< "${a_positions["$index"]}"
    (( total += $(check_M_location "$row" "$column") ))
  done

  echo "$total"
}

main "$@"