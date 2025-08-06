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

installer::install_package() {
    local pkg="$1"

    log::info "Verificando pacote: $pkg..."
    
    # Verifica se o pacote já está instalado antes de continuar
    if packages::is_installed "$pkg"; then
        log::info "Pacote $pkg já instalado. Instalação ignorada."
        return 0
    fi

    log::info "Pacote $pkg não encontrado no sistema. Iniciando instalação..."

    log::info "Atualizando lista de pacotes..."

    # Tenta atualizar, mas continua mesmo se falhar
    if packages::update; then
        log::info "Lista de pacotes atualizada com sucesso."
    else
        log::warn "Falha ao atualizar lista de pacotes."
    fi

    # Caso de sucesso na instalação
    if packages::install "$pkg"; then
        log::info "Pacote $pkg instalado com sucesso."
        return 0
    fi
    
    # Caso de falha na instalação
    log::error "Falha na instalação de $pkg."
    return 1
}

installer::install_nvidia_open() {
    tui::show_dialog "Aviso" "Iniciando instalação dos Drivers Open da NVIDIA" "Continuar"
}

installer::install_nvidia_proprietary() {
    tui::show_dialog "Aviso" "Iniciando instalação dos Drivers Proprietary da NVIDIA" "Continuar"
}

installer::install_nvidia() {
    log::info "Iniciando instalação dos drivers Nvidia..."
    
    local nvidia_gpus

    log::info "Procurando por GPUs Nvidia no sistema..."
    nvidia_gpus="$(nvidia::fetch_nvidia_gpus)"

    if [[ -n "$nvidia_gpus" ]]; then
        log::info "GPUs Nvidia detectadas no sistema:"

        while IFS= read -r line; do
            log::info "\t - ${line}"
        done <<< "$nvidia_gpus"
    else
        log::error "Nenhuma GPU Nvidia detectada no sistema."
        tui::show_dialog "Aviso" "Nenhuma GPU Nvidia detectada no sistema." "Abortar"
        NAV_RESTART=0
        return 1 # encerra a função antes de continuar
    fi

    tui::navigate::flavors
    return 0
}

installer::uninstall_nvidia() {
    tui::show_dialog "Aviso" "Iniciando desinstalação dos Drivers NVIDIA" "Continuar"
}