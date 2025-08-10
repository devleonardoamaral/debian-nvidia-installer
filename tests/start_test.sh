#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

declare -g SCRIPT_DIR

LIB_DIR="$(dirname "${SCRIPT_DIR}")/usr/lib/debian-nvidia-installer"

declare -g LIB_DIR

test::calc_step_result() {
    local step_name="$1"
    local step_status="$2"
    local varname="$3"

    if (( $step_status == 0 )); then
        eval "$varname=\$(( $varname + 1 ))"
        echo "    Etapa $step_name passou"
    else
        echo "    Etapa $step_name falhou"
    fi
}

test::calc_test_result() {
    local test_name=$1
    local passed_tests=$2
    local total_tests=$3

    local percent=$(( 100 * passed_tests / total_tests ))

    echo "    ${test_name}() -> $percent% ($passed_tests/$total_tests etapas passaram)"

    if [ $passed_tests -eq $total_tests ]; then
        return 0
    else
        return 1
    fi
}

test::exec_test() {
    local test_name="$1"
    shift

    local success=0
    local failure=0

    echo "INICIANDO ${test_name}"

    for test_func in "$@"; do
        if "$test_func"; then
            (( success++ ))
        else
            (( failure++ ))
        fi
    done

    local total=$((success + failure))
    local percent=0
    if (( total > 0 )); then
        percent=$(( 100 * success / total ))
    fi

    echo "$percent% ($success/$total testes passaram)"
}

for file in "$SCRIPT_DIR"/tests/*.sh; do source "$file"; done

