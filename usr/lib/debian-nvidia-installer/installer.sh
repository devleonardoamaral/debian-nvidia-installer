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

    log::info "$(tr::t_args "log.installer.installpackage.verifying" "$pkg")"
    
    # Verifica se o pacote já está instalado antes de continuar
    if packages::is_installed "$pkg"; then
        log::info "$(tr::t_args "log.installer.installpackage.skipping" "$pkg")"
        return 0
    fi

    log::info "$(tr::t_args "log.installer.installpackage.installing" "$pkg")"
    log::info "$(tr::t "log.installer.update.start")"

    # Tenta atualizar, mas continua mesmo se falhar
    if packages::update; then
        log::info "$(tr::t "log.installer.update.success")"
    else
        log::warn "$(tr::t "log.installer.update.failure")"
    fi

    # Caso de sucesso na instalação
    if packages::install "$pkg"; then
        log::info "$(tr::t_args "log.installer.installpackage.success" "$pkg")"
        return 0
    fi
    
    # Caso de falha na instalação
    log::error "$(tr::t_args "log.installer.installpackage.failure" "$pkg")"
    return 1
}

installer::remove_package() {
    local pkg="$1"

    log::info "$(tr::t_args "log.installer.removepackage.start" "$pkg")"

    if ! packages::remove "$pkg"; then
        log::error "$(tr::t_args "log.installer.removepackage.failue" "$pkg")"
        return 1
    fi

    log::info "$(tr::t_args "log.installer.removepackage.success" "$pkg")"

    return 0
}

installer::install_nvidia_proprietary() {
    if ! tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.proprietarydriver.confirm")"; then
        log::info "$(tr::t "log.operation.canceled.byuser")"
        return 255
    fi

    if ! installer::install_package "nvidia-kernel-dkms"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi
    
    log::info "$(tr::t "log.install.success")"
    tui::show_msgbox "" "$(tr::t "log.install.success")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
    return 0
}

installer::install_nvidia_open() {
    if ! tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.opendriver.confirm")"; then
        log::info "$(tr::t "log.operation.canceled.byuser")"
        return 255
    fi

    if ! installer::install_package "nvidia-open-kernel-dkms"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi
    
    log::info "$(tr::t "log.install.success")"
    tui::show_msgbox "" "$(tr::t "log.install.success")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
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
            dpkg --add-architecture i386
            HEADER_PKG="linux-headers-amd64"
            ;;
        *)
            log::critical "$(tr::t_args "log.installer.installprerequisites.unsupportedarch" "$ARCH")"
            tui::show_msgbox "Erro" "$(tr::t_args "log.installer.installprerequisites.unsupportedarch" "$ARCH")" "$(tr::t "tui.button.abort")"
            exit 1
            ;;
    esac

    if ! packages::check_sources_components "" "contrib" "non-free" "non-free-firmware"; then
        log::info "$(tr::t "log.installer.pre.sources.missing")"
        if ! packages::add_sources_components "" "contrib" "non-free" "non-free-firmware"; then
            log::info "$(tr::t "log.installer.pre.sources.failure")"
            log::critical "$(tr::t "log.operation.canceled.byfailure")"
            return 1
        fi
    fi

    log::info "$(tr::t "log.installer.pre.sources.success")"

    log::info "$(tr::t_args "log.installer.installprerequisites.start" "$ARCH")"

    if ! installer::install_package "mokutil"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "$HEADER_PKG"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        return 1
    fi
    
    log::info "$(tr::t "log.installer.installprerequisites.success")"
    return 0
}

setup_mok() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    # Instala o pacote dkms com abstração
    if ! installer::install_package "dkms"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.installer.mok.password")"

    if ! dkms generate_mok; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    log::info "$(tr::t "log.installer.mok.start")"
    if ! mokutil --import "$mok_pub_path"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    log::success "$(tr::t "log.installer.mok.sign")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.installer.mok.sign")"

    exit 0
}

installer::check_secure_boot() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    log::info "$(tr::t "log.installer.secureboot.start")"

    # Verifica se mokutil está disponível, senão tenta instalar
    if ! command -v mokutil &>/dev/null; then
        if ! installer::install_package "mokutil"; then
            return 1
        fi
    fi

    if mokutil --sb-state | grep -q "enabled"; then
        log::info "$(tr::t "log.installer.secureboot.mok.isactivated")"

        if [[ -f "$mok_pub_path" ]] && mokutil --test-key "$mok_pub_path" | grep -q "is already enrolled"; then
            log::info "$(tr::t "log.installer.secureboot.mok.success")"
            return 0
        fi

        log::warning "$(tr::t "log.installer.secureboot.mok.failure")"
        tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.installer.secureboot.mok.missing")"

        if tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.installer.secureboot.mok.create")"; then
            setup_mok
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.installer.secureboot.mok.abort")"
            return 1
        fi
    else
        log::info "$(tr::t "log.installer.secureboot.mok.isdeactivated")"
    fi

    return 0
}


installer::install_nvidia() {
    log::info "$(tr::t "log.installer.install.nvidia.start")"
    
    local nvidia_gpus

    log::info "$(tr::t "log.installer.install.nvidia.verify.gpu.start")"
    nvidia_gpus="$(nvidia::fetch_nvidia_gpus)"

    if [[ -n "$nvidia_gpus" ]]; then
        log::info "$(tr::t "log.installer.install.nvidia.verify.gpu.found")"

        while IFS= read -r line; do
            log::info "\t - ${line}"
        done <<< "$nvidia_gpus"

        tui::show_msgbox "" "$(tr::t "log.installer.install.nvidia.verify.gpu.found")\n\n$nvidia_gpus"
    else
        log::error "$(tr::t "log.installer.install.nvidia.verify.gpu.notfound")"
        tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "log.installer.install.nvidia.verify.gpu.notfound")" "$(tr::t "tui.button.abort")"
        return 1
    fi

    if ! (installer::install_pre_requisites && installer::check_secure_boot); then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    tui::navigate::flavors
}

installer::uninstall_nvidia() {
    if ! tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.installer.nvidia.uninstall.confirm")"; then
        log::info "$(tr::t "log.operation.canceled.byuser")"
        return 255
    fi

    log::info "$(tr::t "log.installer.uninstall.nvidia.start")"

    if ! installer::remove_package "*nvidia*"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    installer::remove_package "libnvoptix1"

    # Reinstala o nouveau como fallback
    if ! apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    log::info "$(tr::t "log.installer.uninstall.nvidia.success")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "log.installer.uninstall.nvidia.success")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
    return 0
}