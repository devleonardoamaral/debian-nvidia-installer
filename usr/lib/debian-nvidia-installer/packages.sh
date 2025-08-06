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
    local sources_file results lines components_found

    if [ -n "$1" ]; then
        sources_file="$1"
    else
        sources_file="/etc/apt/sources.list"
    fi

    shift

    results=0
    lines=0
    components_found=0

    # Lê linha por linha do arquivo até o final
    while IFS= read -r line; do

        # Verifica se a linha começa com deb|deb-src e um espaço
        if [[ "$line" =~ ^(deb|deb-src)[[:space:]] ]]; then
            ((lines++)) # Conta as linhas válidas
            components_found=0 # Reseta o contador a cada nova linha válida

            # Extraí os componentes do final do source em um array
            read -ra extracted_components <<< "$(grep -oP '^(deb|deb-src)\s+\S+\s+\S+\s+\S+\s+\K.*' <<< "$line")"
            
            # Percorre os parametros de entrada e compara se todos existem no array de componentes
            for param in "$@"; do
                for comp in "${extracted_components[@]}"; do
                    if [[ "$param" == "$comp" ]]; then
                        ((components_found++))
                        break
                    fi
                done
            done

            # Salva o resultado da verificação
            if [[ "$components_found" -eq "$#" ]]; then
                ((results++))
            fi
        fi
    done < "$sources_file" || return 1 # Retorna 1 como fallback, caso o arquivo não seja encontrado

    if [[ "$lines" -eq "$results" ]]; then
        return 0 # Todos os parametros existem em todas as linhas de source do arquivo
    else
        return 1 # Uma ou mais linhas possuem componentes faltando
    fi
}

# Atualiza a lista de pacotes
packages::update() {
    local ret
    log::info "Atualizando lista de pacotes..."

    apt update
    ret=$?

    if (( $ret == 0 )); then
        log::info "Lista de pacotes atualizada com sucesso."
        return $ret
    fi

    log::warn "Falha ao atualizar lista de pacotes."
    return $ret
}

# Verifica se um pacote está instalado.
packages::is_installed() {
    dpkg -s "$1" &>/dev/null # Emite return 0 ou 1.
}

# Instala um pacote no sistema
packages::install() {
    apt install -y "$1"
}