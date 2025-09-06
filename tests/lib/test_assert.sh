#!/usr/bin/env bash

# -----------------------------
# Bash Test Assertions Library
# -----------------------------

# Generic failure function
# Usage: test::fail "message"
test::fail() {
    echo "FAIL: $*"
    return 1
}

# -----------------------------
# Basic Assertions
# -----------------------------

# Compare two strings
# Usage: test::assert_eq "expected" "actual"
test::assert_eq() {
    local expected="$1"
    local actual="$2"

    if ! [ "$expected" = "$actual" ]; then
        test::fail "expected '$expected', got '$actual'"
        return 1
    fi

    return 0
}

# Compare two integers
# Usage: test::assert_int_eq 123 456
test::assert_int_eq() {
    local expected="$1"
    local actual="$2"

    if ! [ "$expected" -eq "$actual" ]; then
        test::fail "expected integer '$expected', got '$actual'"
        return 1
    fi

    return 0
}

# Check if a string contains a substring
# Usage: test::assert_contains "haystack" "needle"
test::assert_contains() {
    local haystack="$1"
    local needle="$2"

    if ! [[ "$haystack" == *"$needle"* ]]; then
        test::fail "expected '$haystack' to contain '$needle'"
        return 1
    fi

    return 0
}

# Check if a string does NOT contain a substring
# Usage: test::assert_not_contains "haystack" "needle"
test::assert_not_contains() {
    local haystack="$1"
    local needle="$2"

    if [[ "$haystack" == *"$needle"* ]]; then
        test::fail "expected '$haystack' to NOT contain '$needle'"
        return 1
    fi

    return 0
}

# -----------------------------
# File and Directory Assertions
# -----------------------------

# Check the exit code of a command
# Usage: test::assert_exit_code 0 ls /tmp
test::assert_exit_code() {
    local expected_code="$1"
    shift
    "$@" >/dev/null 2>&1
    local actual_code=$?

    if [ "$actual_code" -ne "$expected_code" ]; then
        test::fail "expected exit code $expected_code, got $actual_code"
        return 1
    fi

    return 0
}

# Check if a symlink or file exists
# Usage: test::assert_file_or_symlink_exists "/path/to/file"
test::assert_file_or_symlink_exists() {
    local file="$1"
    if [ ! -f "$file" ] && [ ! -h "$file" ]; then
        test::fail "expected file or symlink '$file' to exist"
        return 1
    fi

    return 0
}

# Check if a symlink exists
# Usage: test::assert_symlink_exists "/path/to/file"
test::assert_symlink_exists() {
    local file="$1"
    if [ ! -h "$file" ]; then
        test::fail "expected symlink '$file' to exist"
        return 1
    fi

    return 0
}

# Check if a file exists
# Usage: test::assert_file_exists "/path/to/file"
test::assert_file_exists() {
    local file="$1"
    if [ ! -f "$file" ]; then
        test::fail "expected file '$file' to exist"
        return 1
    fi

    return 0
}

# Check if a directory exists
# Usage: test::assert_dir_exists "/path/to/dir"
test::assert_dir_exists() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        test::fail "expected directory '$dir' to exist"
        return 1
    fi

    return 0
}

# -----------------------------
# File Content Assertions
# -----------------------------

# Check if file content equals expected string
# Usage: test::assert_file_content_eq "/path/to/file" "expected content"
test::assert_file_content_eq() {
    local file="$1"
    local expected="$2"

    if [ ! -f "$file" ]; then
        test::fail "file '$file' does not exist"
        return 1
    fi

    local content
    content="$(<"$file")"

    if [ "$content" != "$expected" ]; then
        test::fail "expected file '$file' content to be '$expected', got '$content'"
        return 1
    fi

    return 0
}

# Check if file contains a specific line
# Usage: test::assert_file_contains_line "/path/to/file" "expected line"
test::assert_file_contains_line() {
    local file="$1"
    local line="$2"

    if [ ! -f "$file" ]; then
        test::fail "file '$file' does not exist"
        return 1
    fi

    if ! grep -Fxq "$line" "$file"; then
        test::fail "expected file '$file' to contain line '$line'"
        return 1
    fi

    return 0
}

# Check if file contains a substring anywhere
# Usage: test::assert_file_contains "/path/to/file" "substring"
test::assert_file_contains() {
    local file="$1"
    local substring="$2"

    if [ ! -f "$file" ]; then
        test::fail "file '$file' does not exist"
        return 1
    fi

    if ! grep -Fq "$substring" "$file"; then
        test::fail "expected file '$file' to contain '$substring'"
        return 1
    fi

    return 0
}

# Check if file does NOT contain a substring
# Usage: test::assert_file_not_contains "/path/to/file" "substring"
test::assert_file_not_contains() {
    local file="$1"
    local substring="$2"

    if [ ! -f "$file" ]; then
        test::fail "file '$file' does not exist"
        return 1
    fi

    if grep -Fq "$substring" "$file"; then
        test::fail "expected file '$file' to NOT contain '$substring'"
        return 1
    fi

    return 0
}

# -----------------------------
# Variable Assertions
# -----------------------------

# Check if a variable is set
# Usage: test::assert_var_set VAR_NAME
test::assert_var_set() {
    local var_name="$1"
    if [ -z "${!var_name+x}" ]; then
        test::fail "expected variable '$var_name' to be set"
        return 1
    fi

    return 0
}

# Check if a variable is non-empty
# Usage: test::assert_var_nonempty VAR_NAME
test::assert_var_nonempty() {
    local var_name="$1"
    if [ -z "${!var_name}" ]; then
        test::fail "expected variable '$var_name' to be non-empty"
        return 1
    fi

    return 0
}

# -----------------------------
# Array Assertions
# -----------------------------

# Check if an array contains a value
# Usage: test::assert_array_contains "value" "${array[@]}"
test::assert_array_contains() {
    local value="$1"
    shift
    local element
    for element in "$@"; do
        if [ "$element" = "$value" ]; then
            return 0
        fi
    done
    test::fail "expected array to contain '$value'"
    return 1
}

# Check if an array does NOT contain a value
# Usage: test::assert_array_not_contains "value" "${array[@]}"
test::assert_array_not_contains() {
    local value="$1"
    shift
    local element
    for element in "$@"; do
        if [ "$element" = "$value" ]; then
            test::fail "expected array to NOT contain '$value'"
            return 1
        fi
    done
    return 0
}

# -----------------------------
# Command Output Assertions
# -----------------------------

# Check if a command outputs expected string
# Usage: test::assert_output_eq "expected" command args...
test::assert_output_eq() {
    local expected="$1"
    shift
    local output
    output="$("$@")"

    if [ "$output" != "$expected" ]; then
        test::fail "expected output '$expected', got '$output'"
        return 1
    fi

    return 0
}

# Check if a command outputs string containing a substring
# Usage: test::assert_output_contains "needle" command args...
test::assert_output_contains() {
    local needle="$1"
    shift
    local output
    output="$("$@")"

    if [[ "$output" != *"$needle"* ]]; then
        test::fail "expected output to contain '$needle', got '$output'"
        return 1
    fi

    return 0
}
