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

installer::remove_package() {
    local pkg="$1"

    log::info "Removendo pacote $pkg..."

    if ! packages::remove "$pkg"; then
        log::error "Falha ao remover pacote $pkg."
        return 1
    fi

    log::info "Pacote $pkg removido com sucesso." 

    return 0
}

installer::install_nvidia_proprietary() {
    if ! tui::show_yesno "Aviso" "Você está prestes a instalar o driver do flavor Proprietário da Nvidia.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Instalação cancelada pelo usuário."
        return 1
    fi

    log::info "Instalando drivers da Nvidia..."

    if ! installer::install_package "nvidia-kernel-dkms"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-kernel-dkms"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-driver"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "Falha na instalação do pacote do driver: firmware-misc-nonfree"
        return 1
    fi
    
    log::info "Drivers instalados com sucesso!"
    tui::show_msgbox "" "Instalação concluída com sucesso!"
    return 0
}

installer::install_nvidia_open() {
    if ! tui::show_yesno "Aviso" "Você está prestes a instalar o driver do flavor Open Source da Nvidia.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Instalação cancelada pelo usuário."
        return 1
    fi

    log::info "Instalando drivers da Nvidia..."

    if ! installer::install_package "nvidia-open-kernel-dkms"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-open-kernel-dkms"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-driver"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "Falha na instalação do pacote do driver: firmware-misc-nonfree"
        return 1
    fi
    
    log::info "Drivers instalados com sucesso!"
    tui::show_msgbox "" "Instalação concluída com sucesso!"
    return 0
}

installer::install_pre_requisites() {
    local ARCH KERNEL VERSION HEADER_PKG
    ARCH=$(uname -m)
    KERNEL=$(uname -r)

    case "$ARCH" in
        "i386"|"i686")
            if [[ "$KERNEL" == *"686-pae"* ]]; then
                HEADER_PKG="linux-headers-686-pae"
            else
                HEADER_PKG="linux-headers-686"
            fi
            ;;
        "x86_64")
            HEADER_PKG="linux-headers-amd64"
            ;;
        *)
            log::critical "Arquitetura não suportada: $ARCH"
            tui::show_msgbox "Erro" "Arquitetura $ARCH não é suportada!" "Abortar"
            exit 1
            ;;
    esac

    log::info "Instalando pré-requisitos para $ARCH..."

    if ! installer::install_package "mokutil"; then
        log::critical "Falha na instalação do pacote mokutil. Abortando."
        return 1
    fi

    if ! installer::install_package "$HEADER_PKG"; then
        log::critical "Falha na instalação do pacote ${HEADER_PKG}. Abortando."
        return 1
    fi
    
    log::info "Pré-requisitos instalados com sucesso!"
    return 0
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

        tui::show_msgbox "GPUs Nvidia detectadas:" "$nvidia_gpus"
    else
        log::error "Nenhuma GPU Nvidia detectada no sistema."
        tui::show_msgbox "Erro" "Nenhuma GPU Nvidia detectada no sistema." "Abortar"
        NAVIGATION_STATUS=0
        return 1
    fi

    if ! installer::install_pre_requisites; then
        dialog "Erro" "Falha na instalação dos pré-requisitos." "Abortar"
        NAVIGATION_STATUS=0
        return 1
    fi

    tui::navigate::flavors
}

installer::uninstall_nvidia() {
    if ! tui::show_yesno "Aviso" "Você está prestes a desinstalar o driver da Nvidia.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Desinstalação cancelada pelo usuário."
        return 1
    fi

    log::info "Iniciando desinstalação dos drivers da Nvidia!"

    if ! installer::remove_package "*nvidia*" && installer::installer::remove_package "libnvoptix1"; then
        log::critical "Falha na desinstalação dos drivers da Nvidia!"
        return 1
    fi

    if ! apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau; then
        log::critical "Falha na reinstalação do driver nouveau!"
    fi

    log::info "Desinstalação dos drivers da Nvidia concluída."
    tui::show_msgbox "" "Desinstalação concluída!"
    tui::show_msgbox "AVISO" "Reinicie o sistema para que as alterações sejam aplicadas."
    return 0
}