#!/usr/bin/env bash

source "$LIB_DIR"/packages.sh

test::packages::check_sources_components() {
    local total_tests=3
    local passed_tests=0
    local test_name="test::packages::check_sources_components"

    local tempfile

    tempfile=$(mktemp)

    # Conteúdo simulado do arquivo sources.list para teste
    cat <<EOF > "$tempfile"
#deb cdrom:[Debian GNU/Linux trixie-DI-rc2 _Trixie_ - Official RC amd64 NETINST with firmware 20250701-23:07]/ trixie contrib main non-free-firmware

deb http://deb.debian.org/debian/ trixie main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian/ trixie main non-free-firmware contrib non-free

deb http://security.debian.org/debian-security trixie-security main non-free-firmware contrib non-free
deb-src http://security.debian.org/debian-security trixie-security main non-free-firmware contrib non-free

# trixie-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://deb.debian.org/debian/ trixie-updates main non-free-firmware contrib non-free
deb-src http://deb.debian.org/debian/ trixie-updates main non-free-firmware contrib non-free

# This system was installed using removable media other than
# CD/DVD/BD (e.g. USB stick, SD card, ISO image file).
# The matching "deb cdrom" entries were disabled at the end
# of the installation process.
# For information about how to configure apt package sources,
# see the sources.list(5) manual.
EOF

    # Teste 1: componentes "contrib", "non-free" e "non-free-firmware", deve retornar true
    packages::check_sources_components "$tempfile" "contrib"
    test::calc_step_result "1" "$?" "passed_tests"

    # Teste 2: componentes "contrib", "non-free" e "non-free-firmware", deve retornar true
    packages::check_sources_components "$tempfile" "contrib" "non-free" "non-free-firmware"
    test::calc_step_result "2" "$?" "passed_tests"

    # Teste 3: componente "testcomp" não existe, deve retornar false
    ! packages::check_sources_components "$tempfile" "testcomponent"
    test::calc_step_result "3" "$?" "passed_tests"

    rm "$tempfile"

    test::calc_test_result "$test_name" "$passed_tests" "$total_tests"
    return $?
}

test::packages::add_sources_components() {
    local total_tests=4
    local passed_tests=0
    local test_name="test::packages::add_sources_components"

    local tempfile

    tempfile=$(mktemp)

    # Conteúdo simulado do arquivo sources.list para teste
    cat <<EOF > "$tempfile"
#deb cdrom:[Debian GNU/Linux trixie-DI-rc2 _Trixie_ - Official RC amd64 NETINST with firmware 20250701-23:07]/ trixie contrib main non-free-firmware

deb http://deb.debian.org/debian/ trixie main
deb-src http://deb.debian.org/debian/ trixie main

deb http://security.debian.org/debian-security trixie-security main non-free-firmware contrib
deb-src http://security.debian.org/debian-security trixie-security main non-free-firmware contrib non-free

# trixie-updates, to get updates before a point release is made;
# see https://www.debian.org/doc/manuals/debian-reference/ch02.en.html#_updates_and_backports
deb http://deb.debian.org/debian/ trixie-updates main non-free
deb-src http://deb.debian.org/debian/ trixie-updates main non-free testcomponent

# This system was installed using removable media other than
# CD/DVD/BD (e.g. USB stick, SD card, ISO image file).
# The matching "deb cdrom" entries were disabled at the end
# of the installation process.
# For information about how to configure apt package sources,
# see the sources.list(5) manual.
EOF

    # Teste 1.1: adiciona o componente "contrib", deve retornar true
    packages::add_sources_components "$tempfile" "contrib" > /dev/null 2>&1
    test::calc_step_result "1.1" "$?" "passed_tests"

    # Teste 1.2: verifica se o componente "contrib" foi adicionado, deve retornar true
    packages::check_sources_components "$tempfile" "contrib"
    test::calc_step_result "1.2" "$?" "passed_tests"

    # Teste 1.1: adiciona os componentes "contrib" e "non-free", deve retornar true
    packages::add_sources_components "$tempfile" "contrib" "non-free" > /dev/null 2>&1
    test::calc_step_result "2.1" "$?" "passed_tests"

    # Teste 1.2: verifica se os componentes "contrib" e "non-free" foram adicionados, deve retornar true
    packages::check_sources_components "$tempfile" "contrib" "non-free"
    test::calc_step_result "2.2" "$?" "passed_tests"

    rm "$tempfile"

    test::calc_test_result "$test_name" "$passed_tests" "$total_tests"
    return $?
}

test::packages::is_installed() {
    local total_tests=2
    local passed_tests=0
    local test_name="test::packages::is_installed"

    # Teste 1: pacote apt existe, deve retornar true
    packages::is_installed "apt"
    test::calc_step_result "1" "$?" "passed_tests"

    # Teste 2: pacote testepackageinstalled não existe, deve retornar false
    ! packages::is_installed "testepackageinstalled"
    test::calc_step_result "2" "$?" "passed_tests"

    test::calc_test_result "$test_name" "$passed_tests" "$total_tests"
    return $?
}

test::exec_test "test::packages" \
    "test::packages::check_sources_components" \
    "test::packages::add_sources_components" \
    "test::packages::is_installed"
