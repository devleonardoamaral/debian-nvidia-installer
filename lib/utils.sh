#!/usr/bin/env bash

# Verifica se o script está sendo executado com privilégios sudo
utils::check_sudo() {
    [[ "$EUID" -eq 0 ]]
}

# Reexecuta o script como sudo
utils::force_sudo() {
    exec sudo --preserve-env "$0" "$@"
}