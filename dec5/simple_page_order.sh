#!/usr/bin/env bash

# Read rules to assosiative array
while read -r rule; do
  PRINT_RULES[${rule//|/}]=1
done< <(grep -oP "^\d+\|\d+$" <"$1")

while IFS="," read -r -a line_pages; do
  (( valid_line = 1 ))
  for (( i = 0; i < ${#line_pages[@]} - 1; i++ )); do
    if [[ -z ${PRINT_RULES[ ${line_pages[i]}${line_pages[$((i+1))]} ]} ]]; then
      (( valid_line = 0 ))
      break
    fi
  done
  (( valid_line )) && (( total += line_pages[ (${#line_pages[@]} / 2) ] ))
done< <(grep -oP "^(\d+,)+\d+$" <"$1")

echo "$total"