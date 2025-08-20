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

declare -g MOK_PUB_KEY="/var/lib/dkms/mok.pub"

# Verifica se o mokutil está instalado no sistema
mok::check_mokutil() {
    if command -v mokutil &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Verifica se o Secure Boot está habilitado
mok::check_secure_boot() {
    if mokutil --sb-state | grep -q "enabled"; then
        return 0
    else
        return 1
    fi
}

# Verifica se o MOK está inscrito
mok::check_mok() {
    local key="${1:-$MOK_PUB_KEY}"
    if [[ -f "$key" ]] && mokutil --test-key "$key" | grep -iq "already enrolled"; then
        return 0
    else
        return 1
    fi
}

# Gera a chave MOK
mok::generate_mok() {
    dkms generate_mok
}

# Importa a chave MOK, precisa da interação do usuário para definir a senha
mok::import_mok() {
    local key="${1:-$MOK_PUB_KEY}"
    mokutil --import "$key"
}
