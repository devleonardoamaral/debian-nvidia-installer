#!/usr/bin/env bash

source "$LIB_DIR"/packages.sh

test::packages::check_sources_components() {
    local total_tests=5
    local passed_tests=0
    local test_name="test::packages::check_sources_components"

    local testfile
    testfile=$(mktemp)
    trap 'rm -f "$testfile"' RETURN

    cat <<EOF > "$testfile"
deb http://deb.debian.org/debian/ trixie main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian/ trixie main non-free-firmware contrib non-free
# deb http://deb.debian.org/debian/ trixie main contrib  # commented
EOF

    # Case 1: single existing component
    packages::check_sources_components "$testfile" "contrib" >/dev/null 2>/dev/null
    test::calc_step_result "1 (exists)" "$?" "passed_tests"

    # Case 2: multiple existing components
    packages::check_sources_components "$testfile" "contrib" "non-free" "non-free-firmware" >/dev/null 2>/dev/null
    test::calc_step_result "2 (all exist)" "$?" "passed_tests"

    # Case 3: non-existing component
    ! packages::check_sources_components "$testfile" "fakecomp" >/dev/null 2>/dev/null
    test::calc_step_result "3 (non-existing)" "$?" "passed_tests"

    # Case 4: partially existing (one exists, one doesn’t)
    ! packages::check_sources_components "$testfile" "contrib" "foobar" >/dev/null 2>/dev/null
    test::calc_step_result "4 (partially existing)" "$?" "passed_tests"

    # Case 5: empty sources file
    : > "$testfile"
    ! packages::check_sources_components "$testfile" "contrib"
    test::calc_step_result "5 (empty file)" "$?" "passed_tests"

    test::calc_test_result "$test_name" "$passed_tests" "$total_tests"
    return $?
}

test::packages::add_sources_components() {
    local total_tests=5
    local passed_tests=0
    local test_name="test::packages::add_sources_components"

    local testfile
    testfile=$(mktemp)
    trap 'rm -f "$testfile"' RETURN

    cat <<EOF > "$testfile"
deb http://deb.debian.org/debian/ trixie main
deb-src http://deb.debian.org/debian/ trixie main
# commented line
EOF

    # Case 1: add single component "contrib"
    packages::add_sources_components "$testfile" "contrib" >/dev/null 2>/dev/null
    packages::check_sources_components "$testfile" "contrib" >/dev/null 2>/dev/null
    test::calc_step_result "1 (add contrib)" "$?" "passed_tests"

    # Case 2: add multiple components ("contrib" already exists, "non-free" is new)
    packages::add_sources_components "$testfile" "contrib" "non-free" >/dev/null 2>/dev/null
    packages::check_sources_components "$testfile" "contrib" "non-free" >/dev/null 2>/dev/null
    test::calc_step_result "2 (multiple without duplication)" "$?" "passed_tests"

    # Case 3: ensure commented lines are not modified
    ! grep -q "^#.*contrib" "$testfile"
    test::calc_step_result "3 (ignore commented)" "$?" "passed_tests"

    # Case 4: add mix of existing and new components
    packages::add_sources_components "$testfile" "contrib" "non-free-firmware" >/dev/null 2>/dev/null
    packages::check_sources_components "$testfile" "contrib" "non-free-firmware" >/dev/null 2>/dev/null
    test::calc_step_result "4 (mix existing/new)" "$?" "passed_tests"

    # Case 5: empty file should be updated correctly
    : > "$testfile"
    packages::add_sources_components "$testfile" "main" "contrib" >/dev/null 2>/dev/null
    packages::check_sources_components "$testfile" "main" "contrib" >/dev/null 2>/dev/null
    test::calc_step_result "5 (empty file)" "$?" "passed_tests"

    test::calc_test_result "$test_name" "$passed_tests" "$total_tests"
    return $?
}

test::packages::is_installed() {
    local total_tests=3
    local passed_tests=0
    local test_name="test::packages::is_installed"

    # Case 1: real package (apt should exist)
    packages::is_installed "apt" >/dev/null 2>/dev/null
    test::calc_step_result "1 (real package)" "$?" "passed_tests"

    # Case 2: fake package should not exist
    ! packages::is_installed "fakepackage123" >/dev/null 2>/dev/null
    test::calc_step_result "2 (non-existing package)" "$?" "passed_tests"

    # Case 3: empty argument should fail
    ! packages::is_installed "" >/dev/null 2>/dev/null
    test::calc_step_result "3 (empty argument)" "$?" "passed_tests"

    test::calc_test_result "$test_name" "$passed_tests" "$total_tests"
    return $?
}

test::exec_test \
    "test::packages" \
    "test::packages::check_sources_components" \
    "test::packages::add_sources_components" \
    "test::packages::is_installed"
