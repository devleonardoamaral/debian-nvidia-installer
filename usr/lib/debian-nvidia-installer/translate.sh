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

# Idioma atual detectado
declare -g SCRIPT_LANG="en"

# Lista de traduções (arrays associativos)
declare -A T_PT_BR=(
    # Botões TUI
    ["tui.confirm"]="Confirmar"
    ["tui.abort"]="Abortar"
    ["tui.cancel"]="Cancelar"

    # Logs
    ["log.script.exit"]="Ecerrando script..."
    ["log.script.pause"]="Pressione ENTER para continuar..."
    
    ["log.rootaccess.required"]="Privilégios root são requeridos."
    ["log.dependencies.verifying"]="Verificando e instalando dependências..."
    ["log.dependencies.ok"]="Todas as dependências estão instaladas."
    ["log.dependencies.failed"]="Falha ao instalar dependências."
)

declare -A T_EN=(
    # TUI Buttons
    ["tui.confirm"]="Confirm"
    ["tui.abort"]="Abort"
    ["tui.cancel"]="Cancel"

    # Logs
    ["log.script.exit"]="Exiting script..."
    ["log.script.pause"]="Press ENTER to continue..."

    ["log.rootaccess.required"]="Root privileges are required."
    ["log.dependencies.verifying"]="Checking and installing dependencies..."
    ["log.dependencies.ok"]="All dependencies are installed."
    ["log.dependencies.failed"]="Failed to install dependencies."
)


# Detecta idioma do sistema operacional.
tr::detect_language() {
    local sys_lang="${LANG%%.*}"  # Remove .UTF-8 e afins
    case "$sys_lang" in
        pt_BR) SCRIPT_LANG="pt_BR" ;;
        en_US) SCRIPT_LANG="en" ;;
        *)     SCRIPT_LANG="en" ;;  # padrão
    esac
}

# Retorna a tradução da chave na linguagem atual ou a própria chave se não existir.
tr::t() {
    local key="$1"
    case "$SCRIPT_LANG" in
        pt_BR) echo "${T_PT_BR[$key]:-$key}" ;;
        en)    echo "${T_EN[$key]:-$key}" ;;
    esac
}

# Retorna a tradução da chave substituindo os placeholders %1, %2, ... pelos argumentos.
tr::t_args() {
    local string
    string="$(tr::t "$1")"
    shift

    local counter=1
    for argv in "$@"; do
        string="${string//%$counter/$argv}"
        (( counter++ ))
    done

    echo "$string"
}