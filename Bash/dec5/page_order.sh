#!/usr/bin/env bash
#set -o nounset

declare -i DEBUG
declare -a PRINT_RULES
declare TREE_ROOT
declare -A PAGE_TREE

debug() {
  ((DEBUG)) && echo "$1" >&2
}

calculate_height() {
  local node left right current_height left_height right_height
  node="$1"
  current_height="$2"

  debug "[calculate_height] Calculating tree height. Current node: $node. Current height: $current_height"

  left=$(get_left "${PAGE_TREE[$node]}")
  right=$(get_right "${PAGE_TREE[$node]}")

  debug "[calculate_height] Node value: ${PAGE_TREE[$node]}"
  debug "[calculate_height] Left node: $left"
  debug "[calculate_height] Right node: $right"

  if [[ "$left" != "0" ]]; then
    left_height=$(calculate_height "$left" "$((current_height + 1))")
  fi
  if [[ "$right" != "0" ]]; then
    right_height=$(calculate_height "$right" "$((current_height + 1))")
  fi

  (( left_height > current_height )) && (( current_height = left_height ))
  (( right_height > current_height )) && (( current_height = right_height ))
  echo "$current_height"
}

tree_to_array() {
  local current_node left right
  local -a tree_array
  local -i qpos tree_height
  current_node="$1"
  read -ra tree_array <<<"$2"
  qpos="$3"
  tree_height="$4"

  debug "[tree_to_array] Current: $current_node. Array: $tree_array. Qpos: $qpos"

  #if [[ "$current_node" == "0" ]]; then echo "${tree_array[@]}"; return 0; fi
  if (( qpos >= (tree_height ** 2) )); then echo "${tree_array[@]}"; return 0; fi

  if [[ "$current_node" != "0" ]]; then
    if (( qpos == 0 )); then
      tree_array[$qpos]=$TREE_ROOT
    fi
    tree_array[$(((qpos * 2) + 1))]=$(get_left "${PAGE_TREE[$current_node]}")
    tree_array[$(((qpos * 2) + 2))]=$(get_right "${PAGE_TREE[$current_node]}")
  fi

  ((qpos++))
  read -ra tree_array <<<"$(tree_to_array "${tree_array[$qpos]}" "${tree_array[*]}" "$qpos" "$tree_height")"

  echo "${tree_array[*]}"
}

print_tree() {
  local -i elements slots height arrpos spaces tempint
  local -a tree_array

  (( arrpos = 0 ))                            # Keeps track of position in array.
  (( spaces = 8 ))                            # Specify the spaces between each element on the lowest level.
  debug "[print_tree] Pre height calculation"
  calculate_height "$TREE_ROOT" 0
  height=$(calculate_height "$TREE_ROOT" 0)   # The height of the tree.
  debug "[print_tree] Tree height: $height"
  (( elements = height ** 2 ))                # The number of elements on the lowest level of the tree.
  (( slots = elements * spaces ))             # How many prints, including spaces, on every level.
  (( tempint = slots ))                       # A temporary int to keep track of how many spaces there should
                                              #   be between each element for each level.
  debug "[print_tree] Getting tree array"
  read -r -a tree_array <<<"$(tree_to_array "$TREE_ROOT" "" 0 "$height")"
  #tree_array=(47 97 53 0 29 75 14 1 2 3 4 5 6 7 8)
  debug "[print_tree] Tree array: ${tree_array[*]}"

  if (( height == 0 )); then
    printf "\n\t%d\n" "$TREE_ROOT"
    exit 0
  fi

  # Loop for every level of the tree and print a newline to separate
  for (( row=1; row <= height+1; row++ )); do
    printf "\n"

    # Loop for every slot
    for (( column=1; column < slots; column++ )); do
      # Print an element or a '*' with correct spacing for every level
      if (( column % tempint == (tempint / 2) )); then
        if [[ -z "${tree_array[$arrpos]}" ]]; then
          printf "*"
        else
          printf "%s" "${tree_array[$arrpos]}"
        fi

        # Increase array position variable
        (( arrpos++ ))
      else
        # Print the spacing
        printf " "
      fi
    done
    (( tempint /= 2 ))
  done
}

get_left() {
  local left right
  IFS="|" read -r left right <<<"$1"
  echo "$left"
}

get_right() {
  local left right
  IFS="|" read -r left right <<<"$1"
  echo "$right"
}

#######################################
# Sets the left or right child of a
# parent node. Overwrites
# Globals:
#   PAGE_TREE
# Arguments:
#   parent
#   child
#   direction
# Outputs:
#   Fail if parent node does not exist
#######################################
set_leaf_node() {
  local parent child direction left right
  parent="$1"
  child="$2"
  direction="$3"

  if [[ -z "${PAGE_TREE[$parent]}" ]]; then
    # Parent node does not exist - fail
    debug "[set_leaf_node] Parent: $parent did not exist in tree"
    return 1
  fi

  left=$(get_left "${PAGE_TREE[$parent]}")
  right=$(get_right "${PAGE_TREE[$parent]}")

  case "$direction" in
    l) PAGE_TREE[$parent]="$child|$right";;
    r) PAGE_TREE[$parent]="$left|$child";;
  esac

  PAGE_TREE[$child]="0|0"
}

# The parent exists in the tree and the node does not
add_node() {
  local node parent direction left right

  node="$1"
  parent="$2"
  direction="$3"

  debug "[add_node] Trying to node $node to parent $parent."
  left=$(get_left "${PAGE_TREE[$parent]}")
  right=$(get_right "${PAGE_TREE[$parent]}")

  if [[ "$direction" == "l" ]]; then
    if [[ "$left" == "0" ]]; then
      PAGE_TREE[$parent]="$node|$right"
      PAGE_TREE[$node]="0|0"
      return 0
    else
      # Check if node should be added to left of left-child
      if check_if_rule_exist "$node|$left"; then
        add_node "$node" "$left" "l"
      else
        add_node "$node" "$left" "r"
      fi
    fi

  elif [[ "$direction" == "r" ]]; then
    if [[ "$right" == "0" ]]; then
      PAGE_TREE[$parent]="$left|$node"
      PAGE_TREE[$node]="0|0"
      return 0
    else
      # Check if node should be added to right of right-child
      if check_if_rule_exist "$right|$node"; then
        add_node "$node" "$right" "r"
      else
        add_node "$node" "$right" "l"
      fi
    fi
  fi
}

check_if_rule_exist() {
  local rule
  for rule in "${PRINT_RULES[@]}"; do
    if [[ "$rule" == "$1" ]]; then
      return 0
    fi
  done
  return 1
}

remove_child_from_parent() {
  local left right key

  debug "[remove_child_from_parent] removing $1 from its parent"

  # Find node containg the child to remove
  for key in "${!PAGE_TREE[@]}"; do
    left=$(get_left "${PAGE_TREE[$key]}")
    right=$(get_right "${PAGE_TREE[$key]}")
    if [[ "$left" == "$1" ]]; then
      PAGE_TREE[$key]="0|$right"
      return 0
    elif [[ "$right" == "$1" ]]; then
      PAGE_TREE[$key]="$left|0"
      return 0
    fi
  done
}

check_x_before_y() {
  if [[ "$(xby "$1" "$2" "$TREE_ROOT")" == "1" ]]; then
    return 0
  else
    return 1
  fi
}

# Returns:
#   0: no match
#   1: x found
#   2: y found
xby() {
  if [[ "$3" == "0" ]]; then echo 0; return 0; fi
  if [[ "$3" == "$1" ]]; then echo 1; return 0; fi
  if [[ "$3" == "$2" ]]; then echo 2; return 0; fi

  local left right found

  left=$(get_left "${PAGE_TREE[$3]}")
  found=$(xby "$1" "$2" "$left")
  if [[ "$return" != 0 ]]; then echo "$found"; return 0; fi

  right=$(get_right "${PAGE_TREE[$3]}")
  found=$(xby "$1" "$2" "$right")
  echo "$found"
}

setup_page_tree() {
  local root left right
  local -i index
  local -a rest_list

  debug "[setup_page_tree] Setting up page tree"

  # Set root
  TREE_ROOT=$(get_left "${PRINT_RULES[0]}")
  PAGE_TREE[$TREE_ROOT]="0|0"
  set_leaf_node "$TREE_ROOT" "$(get_right "${PRINT_RULES[0]}")" "r"
  debug "[setup_page_tree] Page tree after root node:"
  debug "$(print_tree)"

  for rule in "${PRINT_RULES[@]}"; do
    left=$(get_left "$rule")
    right=$(get_right "$rule")

    debug ""
    debug "[setup_page_tree] Looking at rule: $rule"

    if [[ -n "${PAGE_TREE[$left]}" ]]; then
      # If right child is unset - set it; else nothing
      if [[ $(get_right "${PAGE_TREE[$left]}") == "0" ]]; then
        debug "                  Setting page $right to the right of node $left."
        set_leaf_node "$left" "$right" "r"
      else
        #debug "                  Node $left found but already has a right child."
        debug "                  Node $left found, adding node $right somewere to the right of it."
        add_node "$right" "$left" "r"
      fi

    elif [[ -n "${PAGE_TREE[$right]}" ]]; then
      # If left child is unset - set it; else nothing
      if [[ $(get_left "${PAGE_TREE[$right]}") == "0" ]]; then
        debug "                  Setting page $left to the left of node $right."
        set_leaf_node "$right" "$left" "l"
      else
        #debug "                  Node $right found but already has a left child."
        debug "                  Node $left found, adding node $right somewere to the right of it."
        add_node "$left" "$right" "l"
      fi

    else
       debug "                  None of the pages exist in the tree, adding rule to rest list."
       rest_list+=("$rule")
    fi
  done

  debug "[setup_page_tree] Rules in rest list: ${rest_list[*]}"
}

read_print_rules() {
  local rules rule
  rules=$(grep -oP "^\d+\|\d+$" <"$1")
  while read -r rule; do
    PRINT_RULES+=("$rule")
  done<<<"$rules"
}

main() {
  if [[ "$1" == "-d" ]]; then ((DEBUG=1)); shift; fi

  read_print_rules "$1"
  setup_page_tree
  #debug "[main] Page tree nodes: ${!PAGE_TREE[*]}"
  #print_tree
  echo "[main] Page tree structure:"
  for key in "${!PAGE_TREE[@]}"; do
    printf "%s->%s " "$key" "${PAGE_TREE[$key]}"
  done
}

main "$@"