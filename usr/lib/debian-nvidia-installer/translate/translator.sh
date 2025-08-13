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
declare -g SCRIPT_LANG

# Lista de traduções (arrays associativos)
declare -Ag T_PT_BR=(
    ["default.script.rootaccess.required"]="Privilégio root requerido."
    ["default.script.exit"]="Script encerrado."
    ["default.script.exit.error"]="Script encerrado com erro %1."
    ["default.script.pause"]="Pressione Enter para continuar..."
    ["default.script.canceled.byuser"]="Operação cancelada pelo usuário."
    ["default.script.canceled.byfailure"]="Operação falhou."
    ["default.script.restartrequired"]="Reinicie o sistema para que as alterações sejam aplicadas."

    ["default.tui.title.warn"]="ATENÇÃO"
    ["default.tui.title.error"]="ERRO"

    ["default.tui.button.ok"]="Ok"
    ["default.tui.button.yes"]="Sim"
    ["default.tui.button.no"]="Não"
    ["default.tui.button.confirm"]="Confirmar"
    ["default.tui.button.abort"]="Abortar"
    ["default.tui.button.cancel"]="Cancelar"
    ["default.tui.button.remove"]="Remover"
    ["default.tui.button.exit"]="Sair"
)

# Translation list (associative arrays)
declare -Ag T_EN_US=(
    ["default.script.rootaccess.required"]="Root privilege required."
    ["default.script.exit"]="Script terminated."
    ["default.script.exit.error"]="Script terminated with error %1."
    ["default.script.pause"]="Press Enter to continue..."
    ["default.script.canceled.byuser"]="Operation canceled by user."
    ["default.script.canceled.byfailure"]="Operation failed."
    ["default.script.restartrequired"]="Restart the system for changes to take effect."

    ["default.tui.title.warn"]="WARNING"
    ["default.tui.title.error"]="ERROR"

    ["default.tui.button.ok"]="Ok"
    ["default.tui.button.yes"]="Yes"
    ["default.tui.button.no"]="No"
    ["default.tui.button.confirm"]="Confirm"
    ["default.tui.button.abort"]="Abort"
    ["default.tui.button.cancel"]="Cancel"
    ["default.tui.button.remove"]="Remove"
    ["default.tui.button.exit"]="Exit"
)

# Adiciona uma entrada de tradução.
tr::add() {
    local lang="$1"
    local key="$2"
    local value="$3"
    
    case "${lang^^}" in
        PT_BR)
            T_PT_BR["$key"]="$value"
            ;;
        EN_US)
            T_EN_US["$key"]="$value"
            ;;
        *)
            echo "Key '$key' not added. Unsupported language: $lang." >&2
            return 1
            ;;
    esac
    return 0
}

# Configura o idioma do script.
# Se o idioma não for suportado, usa o padrão (en_US).
tr::setup_lang() {
    local lang="$1"

    if [[ -z "$1" ]]; then
        echo "Language not specified. Using default: en_US." >&2
        SCRIPT_LANG="en_US"
        return 1
    fi

    case "${lang^^}" in
        PT_BR) SCRIPT_LANG="pt_BR" ;;
        EN_US) SCRIPT_LANG="en_US" ;;
        *) 
            echo "Unsupported language: $1. Using default: en_US." >&2
            SCRIPT_LANG="en_US"
            return 1
            ;;  # padrão
    esac

    return 0
}

# Detecta idioma do sistema operacional.
tr::detect_language() {
    # Se a variável FORCE_LANG estiver definida, usa seu valor.
    # Caso contrário, detecta o idioma do sistema.
    if [[ -v FORCE_LANG && -n "$FORCE_LANG" ]]; then
        # Remove espaços de FORCE_LANG
        FORCE_LANG="$(echo "$FORCE_LANG" | tr -d ' ')"
        tr::setup_lang "$FORCE_LANG"
    else
        tr::setup_lang "${LANG%%.*}"  # Remove .UTF-8 e afins
    fi
}

# Retorna a tradução da chave na linguagem atual ou a própria chave se não existir.
tr::t() {
    local key="$1"
    case "$SCRIPT_LANG" in
        pt_BR) echo "${T_PT_BR[$key]:-$key}" ;;
        en_US) echo "${T_EN_US[$key]:-$key}" ;;
        *) echo "${T_EN_US[$key]:-$key}" ;;
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