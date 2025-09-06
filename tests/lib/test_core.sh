#!/usr/bin/env bash

# Runs all test scripts in a specified directory and its subdirectories.
# Params:
#   $1 - Path to the root tests directory containing subdirectories with test scripts
# Return:
#   0 if all tests pass
#   1 if one or more tests fail
test::start_tests() {
    local tests_dir="$1"
    local failures=0

    local categories=()
    test::populate_array_from_dir categories "$tests_dir"

    local total_tests=0
    for cat in "${categories[@]}"; do
        local cat_tests=()
        test::populate_array_from_dir cat_tests "$cat"
        (( total_tests += ${#cat_tests[@]} ))
    done

    local executed_tests=0

    for cat in "${categories[@]}"; do
        local cat_basename="$(basename "$cat")"
        echo "Executing $cat_basename tests..."

        local cat_tests=()
        test::populate_array_from_dir cat_tests "$cat"

        for test_file in "${cat_tests[@]}"; do
            source "$test_file" || (( failures++ ))
            (( executed_tests++ ))
            local progress=$(( executed_tests * 100 / total_tests ))
            echo -e "Progress: $progress% ($executed_tests/$total_tests)\r"
        done
    done
    (( failures > 0 )) && return 1 || return 0
}