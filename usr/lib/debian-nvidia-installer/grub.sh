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

declare -g GRUB_FILE="/etc/default/grub"

utils::escape_chars() {
    local string="$1"
    printf '%s\n' "$string" | sed 's/[][\/.^$*?()+]/\\&/g'
}

# Função para adicionar ou modificar parâmetros do kernel no GRUB
grub::add_kernel_parameter() {
    local file="$GRUB_FILE"

    if [[ ! -f "$file" ]]; then
        echo "File $file does not exist." >&2
        return 1
    fi

    local param_name
    param_name="$(utils::escape_chars "$1")"

    local sep
    sep="$(utils::escape_chars "$2")"

    local param_value
    param_value="$(utils::escape_chars "$3")"

    # Verifica se o parâmetro já existe
    if grep -E "^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*${param_name}${sep}[^\"]*\"" "$file" | \
        grep -qE "(\"|[[:space:]])${param_name}${sep}"; then
        # Atualiza o parâmetro existente com o novo valor
        sed -i.bak -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/([\" ])(${param_name}${sep})([^\" ]*)?/\1\2${param_value}/g" "$file"
    else
        # Adiciona o parâmetro no final
        sed -i.bak -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/(^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)/\1 ${param_name}${sep}${param_value}/" "$file"
        # Remove espaços depois da aspas iniciais
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/=\"[[:space:]]+/=\"/" "$file"
    fi

    if [[ $? -ne 0 ]]; then
        echo "Failed to add/update kernel parameter in $file" >&2
        return 1
    fi

    return 0
}

# Função para remover um parâmetro do kernel no GRUB
grub::remove_kernel_parameter() {
    local file="$GRUB_FILE"
    local param_name
    param_name="$(utils::escape_chars "$1")"
    local sep
    sep="$(utils::escape_chars "$2")"
    local param_value
    param_value="$3"

    if [[ ! -f "$file" ]]; then
        echo "File $file does not exist." >&2
        return 1
    fi

    # Remove o parâmetro com valor opcional (=valor)
    sed -i.bak -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/([\" ])${param_name}${sep}${param_value}([\" ])/\1\2/g" "$file"

    # Remove espaços duplos
    sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/  +/ /g" "$file"

    # Remove espaços antes das aspas finais
    sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/[[:space:]]+\"/\"/" "$file"

    # Remove espaços depois da aspas iniciais
    sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/=\"[[:space:]]+/=\"/" "$file"

    if [[ $? -ne 0 ]]; then
        echo "Failed to remove kernel parameter in $file" >&2
        return 1
    fi

    return 0
}

# Atualiza o GRUB
grub::update() {
    update-grub | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}