#!/usr/bin/env bash

# debian-nvidia-installer - NVIDIA Driver Installer for Debian (TUI)
# Copyright (C) 2025 Leonardo Amaral
#
# This file is part of debian-nvidia-installer.
#
# debian-nvidia-installer is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# debian-nvidia-installer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with debian-nvidia-installer. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>.

# Escapa caracteres que podem quebrar regex
utils::escape_chars() {
    local string="$1"
    printf '%s\n' "$string" | sed 's/[][\/.^$*?()+]/\\&/g'
}

# Verifica se o script está sendo executado com privilégios sudo
utils::check_sudo() {
    [[ "$EUID" -eq 0 ]]
}

# Reexecuta o script como sudo
utils::force_sudo() {
    local self
    self="$(readlink -f "$0")"
    shift
    exec sudo --preserve-env "$self" "$@"
}

# Verifica se uma arquitetura multiarch está habilitada
utils::multiarch::check() {
    local arch="$1"

    if [[ -z "$arch" ]]; then
        return 255
    fi

    if ! dpkg --print-foreign-architectures | grep -q "^$arch\$"; then
        return 1
    fi

    return 0
}

# Habilita uma arquitetura multiarch
utils::multiarch::enable() {
    local arch="$1"

    if [[ -z "$arch" ]]; then
        return 255
    fi

    if utils::multiarch::check "$arch"; then
        return 0
    fi

    if ! dpkg --add-architecture "$arch"; then
        return 1
    fi

    return 0
}
