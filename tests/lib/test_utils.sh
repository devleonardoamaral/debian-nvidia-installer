#!/usr/bin/env bash

# Populates a Bash array with all items from a specified directory.
# Params:
#   $1 - Name of the array to populate (passed by reference)
#   $2 - Path to the directory
# Return:
#   None (modifies the array in-place)
test::populate_array_from_dir() {
    local arr_name="$1"
    local tests_dir="$2"

    local -n arr_ref="$arr_name"

    for f in "$tests_dir"/*; do
        [ -e "$f" ] || continue
        arr_ref+=("$f")
    done
}