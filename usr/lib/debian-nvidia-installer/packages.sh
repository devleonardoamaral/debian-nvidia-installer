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

# Verifica os componentes do sources.list
# Verifica se os $parametros[@] existem em cada entrada deb|deb-src do sources.list
packages::check_sources_components() {
    local sources_file="/etc/apt/sources.list"

    if [ -n "$1" ]; then
        sources_file="$1"
    fi
    
    shift

    local valid_lines_with_components=0
    local total_valid_lines=0
    local matched_components=0

    # Lê o arquivo linha por linha
    while IFS= read -r current_line; do

        # Verifica se a linha começa com "deb" ou "deb-src"
        if [[ "$current_line" =~ ^(deb|deb-src)[[:space:]] ]]; then
            ((total_valid_lines++))
            matched_components=0

            # Extrai os componentes (últimos campos da linha)
            read -ra current_components <<< "$(echo "$current_line" | cut -d' ' -f5-)"
            
            # Verifica se todos os componentes esperados estão presentes na linha
            for required_component in "$@"; do
                for found_component in "${current_components[@]}"; do
                    if [[ "$required_component" == "$found_component" ]]; then
                        ((matched_components++))
                        break
                    fi
                done
            done

            # Se todos os componentes obrigatórios estiverem presentes, conta como válida
            if [[ "$matched_components" -eq "$#" ]]; then
                ((valid_lines_with_components++))
            fi
        fi
    done < "$sources_file" || return 1 # Fallback se o arquivo não existir

    # Retorna sucesso apenas se todas as linhas válidas tiverem todos os componentes
    if [[ "$total_valid_lines" -eq "$valid_lines_with_components" ]]; then
        return 0
    else
        return 1
    fi
}

# Adiciona novos componentes ao sources.list e atualiza a lista pacotes
packages::add_sources_components() {    
    local sources_file="/etc/apt/sources.list"

    if [ -n "$1" ]; then
        sources_file="$1"
    fi

    shift

    local temp_file=$(mktemp)
    local changed=0

    # Lê o arquivo linha por linha
    while IFS= read -r line; do
        if [[ "$line" =~ ^(deb|deb-src)[[:space:]] ]]; then
            # Extrai a base da linha (URL/distro) e componentes atuais
            base=$(echo "$line" | awk '{print $1, $2, $3, $4}')
            current_components=$(echo "$line" | cut -d' ' -f5-)

            # Verifica componentes faltantes
            missing_components=""
            for comp in "$@"; do
                if [[ ! " $current_components " =~ [[:space:]]$comp[[:space:]] ]]; then
                    missing_components+=" $comp"
                fi
            done

            # Se há componentes faltando na linha, ela é reconstruída
            if [[ -n "$missing_components" ]]; then
                new_line="${base} ${current_components}${missing_components}"
                new_line=$(echo "$new_line" | xargs) # Remove espaços duplicados
                echo "$new_line" >> "$temp_file"
                changed=1
                continue
            fi
        fi
        echo "$line" >> "$temp_file"
    done < "$sources_file"

    if [[ $changed -eq 1 ]]; then
        cp "$temp_file" "$sources_file" || { rm -f "$temp_file"; return 1; }
        chmod 644 "$sources_file"
        packages::update || return 1
    fi

    rm -f "$temp_file"
    return 0
}

# Atualiza a lista de pacotes
packages::update() {
    apt-get update | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Verifica se um pacote está instalado.
packages::is_installed() {
    dpkg -s "$1" &>/dev/null # Emite return 0 ou 1.
}

# Instala um pacote no sistema
packages::install() {
    apt-get install -y "$1" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Desisntala um pacote do sistema
packages::remove() {
    apt-get purge -y "$1" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}