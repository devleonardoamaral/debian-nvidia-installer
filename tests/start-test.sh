#!/usr/bin/env bash

TEST_ROOT="$(dirname "$0")"
TEST_LIB="$TEST_ROOT/lib"
TEST_DIR="$TEST_ROOT/tests"

# Load core and asserts
source "$TEST_LIB/test_utils.sh"
source "$TEST_LIB/test_assert.sh"
source "$TEST_LIB/test_core.sh"

test::start() {
    local test_dir="$1"
    echo "$TEST_ROOT"
    test::start_tests "$test_dir"
    [ "$?" -eq 0 ] && return 0 || return 1
}

test::start "$TEST_DIR"