#!/usr/bin/env bash

declare -i DEBUG
declare -A PRINT_RULES
declare RED='\033[0;31m'
declare NC='\033[0m' # No Color

debug() {
  ((DEBUG)) && printf "$1" >&2
}

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

is_line_valid() {
  local -i i
  local -a pages
  pages=( "$@" )

  for (( i = 1; i < ${#pages[@]}; i++ )); do
    if ! check_page_before_page "${pages[i-1]}" "${pages[i]}"; then
      return 1
    fi
  done
  return 0
}

bubble_sort() {
  local -i unsorted number_of_pages i temp
  local -a pages
  pages=( "$@" )

  (( unsorted = 0 ))
  (( number_of_pages = ${#pages[@]} ))
  for (( i = 1; i < number_of_pages; i++ )); do
    if ! check_page_before_page "${pages[i-1]}" "${pages[i]}"; then
      (( unsorted = 1 ))
      (( temp = pages[i-1] ))
      (( pages[i-1] = pages[i] ))
      (( pages[i] = temp ))
      debug "Line: ${pages[*]:0:i-1} ${RED}${pages[i-1]} ${pages[i]}${NC} ${pages[*]:i+1:number_of_pages-i}\n"
    fi
  done

  if (( unsorted )); then
    pages=( $(bubble_sort "${pages[@]:0:number_of_pages-1}") ${pages[-1]} )
  fi
  echo "${pages[@]}"
}

main() {
  local -a line_pages
  local -i total number_of_pages

  if [[ "$1" == "-d" ]]; then ((DEBUG=1)); shift; fi
  read_rules_from_file "$1"

  while IFS="," read -r -a line_pages; do
    if ! is_line_valid "${line_pages[@]}"; then
      line_pages=( $(bubble_sort "${line_pages[@]}") )
      (( total += line_pages[ (${#line_pages[@]} / 2) ] ))
    fi
  done< <(grep -oP "^(\d+,)+\d+$" <"$1")

  echo "$total"
}

main "$@"