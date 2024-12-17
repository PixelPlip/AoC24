#!/usr/bin/env bash

declare -A PRINT_RULES

read_rules_from_file() {
  local rule
  while read -r rule; do
    PRINT_RULES[${rule//|/}]=1
  done< <(grep -oP "^\d+\|\d+$" <"$1")
}

check_page_before_page() {
  if [[ -n ${PRINT_RULES[$1$2]} ]]; then
    return 0
  else
    return 1
  fi
}

main() {
  local -a line_pages
  local -i valid_line total i number_of_pages
  read_rules_from_file "$1"

  while IFS="," read -r -a line_pages; do
    (( valid_line = 1 ))
    (( number_of_pages = ${#line_pages[@]} ))
    for (( i = 0; i < number_of_pages - 1; i++ )); do
      if ! check_page_before_page "${line_pages[i]}" "${line_pages[$((i+1))]}"; then
        (( valid_line = 0 ))
        break
      fi
    done
    (( valid_line )) && (( total += line_pages[ (number_of_pages / 2) ] ))
  done< <(grep -oP "^(\d+,)+\d+$" <"$1")

  echo "$total"
}

main "$@"