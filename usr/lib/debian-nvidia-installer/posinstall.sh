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

# Instala o CUDA Toolkit e as bibliotecas de desenvolvimento CUDA
posinstall::install_cuda() {
    local pkgs=("nvidia-cuda-dev" "nvidia-cuda-toolkit")
    local pkgs_count=${#pkgs[@]}
    local installed_pkgs=()

    # Verifica quais pacotes já estão instalados
    for pkg in "${pkgs[@]}"; do
        if packages::is_installed "$pkg"; then
            INSTALLED+=("$pkg")
        fi
    done

    # Se algum pacote já estiver instalado, pergunta se deseja desinstalar
    # Senao, pergunta se deseja instalar
    if [[ ${#installed_pkgs[@]} -gt 0 ]]; then
        if tui::yesno::default "" "$(tr::t "posinstall::install_cuda.uninstall.confirm")"; then
            log::info "$(tr::t "posinstall::install_cuda.uninstall.start")"

            for pkg in "${installed_pkgs[@]}"; do
                log::info "$(tr::t_args "posinstall::install_cuda.uninstall.pkg.start" "$pkg")"

                if ! installer::remove_package "$pkg"; then
                    log::critical "$(tr::t "default.script.canceled.byfailure")"
                    log::input _ "$(tr::t "default.script.pause")"
                    return 1
                fi

                log::info "$(tr::t_args "posinstall::install_cuda.uninstall.pkg.success" "$pkg")"
            done

            log::info "$(tr::t "posinstall::install_cuda.uninstall.success")"
            tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
            return 0
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 1
        fi
    else
        if tui::yesno::default "" "$(tr::t "posinstall::install_cuda.install.confirm")"; then
            log::info "$(tr::t "posinstall::install_cuda.install.start")"

            for pkg in "${pkgs[@]}"; do
                log::info "$(tr::t_args "posinstall::install_cuda.install.pkg.start" "$pkg")"

                if ! installer::install_package "$pkg"; then
                    log::critical "$(tr::t "default.script.canceled.byfailure")"
                    log::input _ "$(tr::t "default.script.pause")"
                    return 1
                fi

                log::info "$(tr::t_args "posinstall::install_cuda.install.pkg.success" "$pkg")"
            done

            log::info "$(tr::t "posinstall::install_cuda.install.success")"
            tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
            return 0
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 1
        fi
    fi
}

tr::add "pt_BR" "posinstall::install_cuda.install.confirm" "Você deseja instalar o CUDA Toolkit e as bibliotecas de desenvolvimento CUDA?"
tr::add "pt_BR" "posinstall::install_cuda.install.start" "Iniciando a instalação do CUDA Toolkit e bibliotecas de desenvolvimento..."
tr::add "pt_BR" "posinstall::install_cuda.install.pkg.start" "Instalando o pacote: %1"
tr::add "pt_BR" "posinstall::install_cuda.install.pkg.success" "Pacote %1 instalado com sucesso."
tr::add "pt_BR" "posinstall::install_cuda.install.success" "CUDA Toolkit e bibliotecas de desenvolvimento instalados com sucesso."
tr::add "pt_BR" "posinstall::install_cuda.uninstall.confirm" "Você deseja desinstalar o CUDA Toolkit e as bibliotecas de desenvolvimento CUDA?"
tr::add "pt_BR" "posinstall::install_cuda.uninstall.start" "Iniciando a desinstalação do CUDA Toolkit e bibliotecas de desenvolvimento..."
tr::add "pt_BR" "posinstall::install_cuda.uninstall.pkg.start" "Desinstalando o pacote: %1"
tr::add "pt_BR" "posinstall::install_cuda.uninstall.pkg.success" "Pacote %1 desinstalado com sucesso."
tr::add "pt_BR" "posinstall::install_cuda.uninstall.success" "CUDA Toolkit e bibliotecas de desenvolvimento desinstalados com sucesso."

tr::add "en_US" "posinstall::install_cuda.install.confirm" "Do you want to install the CUDA Toolkit and CUDA development libraries?"
tr::add "en_US" "posinstall::install_cuda.install.start" "Starting installation of CUDA Toolkit and development libraries..."
tr::add "en_US" "posinstall::install_cuda.install.pkg.start" "Installing package: %1"
tr::add "en_US" "posinstall::install_cuda.install.pkg.success" "Package %1 installed successfully."
tr::add "en_US" "posinstall::install_cuda.install.success" "CUDA Toolkit and development libraries installed successfully."
tr::add "en_US" "posinstall::install_cuda.uninstall.confirm" "Do you want to uninstall the CUDA Toolkit and CUDA development libraries?"
tr::add "en_US" "posinstall::install_cuda.uninstall.start" "Starting uninstallation of CUDA Toolkit and development libraries..."
tr::add "en_US" "posinstall::install_cuda.uninstall.pkg.start" "Uninstalling package: %1"
tr::add "en_US" "posinstall::install_cuda.uninstall.pkg.success" "Package %1 uninstalled successfully."
tr::add "en_US" "posinstall::install_cuda.uninstall.success" "CUDA Toolkit and development libraries uninstalled successfully."

posinstall::install_optix() {
    local pkg="libnvoptix1"

    if packages::is_installed "$pkg"; then
        if tui::yesno::default "" "$(tr::t "posinstall::install_optix.uninstall.confirm")"; then
            log::info "$(tr::t "posinstall::install_optix.uninstall.start")"

            if installer::remove_package "$pkg"; then
                log::info "$(tr::t "posinstall::install_optix.uninstall.success")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
                return 0
            else
                log::critical "$(tr::t "default.script.canceled.byfailure")"
                log::input _ "$(tr::t "default.script.pause")"
                return 1
            fi
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 1
        fi
    else
        if tui::yesno::default "" "$(tr::t "posinstall::install_optix.install.confirm")"; then
            log::info "$(tr::t "posinstall::install_optix.install.start")"

            if installer::install_package "$pkg"; then
                log::info "$(tr::t "posinstall::install_optix.install.success")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
                return 0
            else
                log::critical "$(tr::t "default.script.canceled.byfailure")"
                log::input _ "$(tr::t "default.script.pause")"
                return 1
            fi
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 1
        fi
    fi
}

tr::add "pt_BR" "posinstall::install_optix.install.confirm" "Você deseja instalar a biblioteca OptiX?"
tr::add "pt_BR" "posinstall::install_optix.install.start" "Iniciando a instalação da biblioteca OptiX..."
tr::add "pt_BR" "posinstall::install_optix.install.success" "Biblioteca OptiX instalada com sucesso."
tr::add "pt_BR" "posinstall::install_optix.uninstall.confirm" "Você deseja desinstalar a biblioteca OptiX?"
tr::add "pt_BR" "posinstall::install_optix.uninstall.start" "Iniciando a desinstalação da biblioteca OptiX..."
tr::add "pt_BR" "posinstall::install_optix.uninstall.success" "Biblioteca OptiX desinstalada com sucesso."

tr::add "en_US" "posinstall::install_optix.install.confirm" "Do you want to install the OptiX library?"
tr::add "en_US" "posinstall::install_optix.install.start" "Starting installation of the OptiX library..."
tr::add "en_US" "posinstall::install_optix.install.success" "OptiX library installed successfully."
tr::add "en_US" "posinstall::install_optix.uninstall.confirm" "Do you want to uninstall the OptiX library?"
tr::add "en_US" "posinstall::install_optix.uninstall.start" "Starting uninstallation of the OptiX library..."
tr::add "en_US" "posinstall::install_optix.uninstall.success" "OptiX library uninstalled successfully."

# Alterna o modo NVIDIA DRM
posinstall::switch_nvidia_drm() {
    local file="$NVIDIA_DRM_FILE"
    local modeset

    log::info "$(tr::t "posinstall::switch_nvidia_drm.start")"

    modeset="$(nvidia::is_drm_enabled)"
    
    if [[ "$modeset" -eq 1 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_drm.status.on")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.drm.deactivate.confirm")"; then
            if nvidia::set_drm 1; then
                log::info "$(tr::t "posinstall::switch_nvidia_drm.action.off")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
                log::input _ "$(tr::t "default.script.pause")"
                return 0
            else
                log::critical "$(tr::t "default.script.canceled.byfailure")"
                log::input _ "$(tr::t "default.script.pause")"
                return 1
            fi
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 255
        fi
    elif [[ "$modeset" -eq 0 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_drm.status.off")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.drm.activate.confirm")"; then
            if nvidia::set_drm 0; then
                log::info "$(tr::t "posinstall::switch_nvidia_drm.action.on")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
                log::input _ "$(tr::t "default.script.pause")"
                return 0
            else
                log::critical "$(tr::t "default.script.canceled.byfailure")"
                log::input _ "$(tr::t "default.script.pause")"
                return 1
            fi
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 255
        fi
    else
        log::error "$(tr::t "posinstall::switch_nvidia_drm.error.status")"
        return 1
    fi
}

tr::add "pt_BR" "posinstall::switch_nvidia_drm.start" "Iniciando a alternância do modo NVIDIA DRM..."
tr::add "pt_BR" "posinstall::switch_nvidia_drm.status.on" "NVIDIA DRM está habilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_drm.status.off" "NVIDIA DRM está desabilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_drm.action.off" "NVIDIA DRM desabilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_drm.action.on" "NVIDIA DRM habilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_drm.error.status" "Erro ao verificar o status do NVIDIA DRM."
tr::add "pt_BR" "tui.yesno.extra.nvidia.drm.deactivate.confirm" "Você deseja desativar o NVIDIA DRM?"
tr::add "pt_BR" "tui.yesno.extra.nvidia.drm.activate.confirm" "Você deseja ativar o NVIDIA DRM?"

tr::add "en_US" "posinstall::switch_nvidia_drm.start" "Starting NVIDIA DRM mode switch..."
tr::add "en_US" "posinstall::switch_nvidia_drm.status.on" "NVIDIA DRM is enabled."
tr::add "en_US" "posinstall::switch_nvidia_drm.status.off" "NVIDIA DRM is disabled."
tr::add "en_US" "posinstall::switch_nvidia_drm.action.off" "NVIDIA DRM disabled."
tr::add "en_US" "posinstall::switch_nvidia_drm.action.on" "NVIDIA DRM enabled."
tr::add "en_US" "posinstall::switch_nvidia_drm.error.status" "Error checking NVIDIA DRM status."
tr::add "en_US" "tui.yesno.extra.nvidia.drm.deactivate.confirm" "Do you want to deactivate NVIDIA DRM?"

# Alterna o modo PreservedVideoMemoryAllocation
posinstall::switch_nvidia_pvma() {
    local file="$NVIDIA_OPTIONS_FILE"
    local module="nvidia-current"
    local option="NVreg_PreserveVideoMemoryAllocations"

    log::info "$(tr::t "posinstall::switch_nvidia_pvma.start")"

    local pvma_status
    if pvma_status=$(nvidia::get_pvma); then
        log::error "$(tr::t "posinstall::switch_nvidia_pvma.status.error")"
        return 1
    fi

    if [[ -z "$pvma_status" ]] || [[ "$pvma_status" -eq 0 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_pvma.status.off")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.pvma.activate.confirm")"; then
            if nvidia::change_option_pvma "1"; then
                log::info "$(tr::t "posinstall::switch_nvidia_pvma.action.on")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
                log::input _ "$(tr::t "default.script.pause")"
                return 0
            else
                log::critical "$(tr::t "default.script.canceled.byfailure")"
                log::input _ "$(tr::t "default.script.pause")"
                return 1
            fi
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 255
        fi
    elif [[ "$pvma_status" -eq 1 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_pvma.status.on")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.pvma.deactivate.confirm")"; then
            if nvidia::change_option_pvma "0"; then
                log::info "$(tr::t "posinstall::switch_nvidia_pvma.action.off")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
                log::input _ "$(tr::t "default.script.pause")"
                return 0
            else
                log::critical "$(tr::t "default.script.canceled.byfailure")"
                log::input _ "$(tr::t "default.script.pause")"
                return 1
            fi
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            return 255
        fi
    else
        log::error "$(tr::t "posinstall::switch_nvidia_pvma.error.status")"
        return 1
    fi
}

tr::add "pt_BR" "posinstall::switch_nvidia_pvma.start" "Iniciando a alternância do modo PreservedVideoMemoryAllocation..."
tr::add "pt_BR" "posinstall::switch_nvidia_pvma.status.error" "Erro ao verificar o status do PreservedVideoMemoryAllocation."
tr::add "pt_BR" "posinstall::switch_nvidia_pvma.status.off" "PreservedVideoMemoryAllocation está desabilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_pvma.status.on" "PreservedVideoMemoryAllocation está habilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_pvma.action.off" "PreservedVideoMemoryAllocation desabilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_pvma.action.on" "PreservedVideoMemoryAllocation habilitado."
tr::add "pt_BR" "tui.yesno.extra.nvidia.pvma.activate.confirm" "Você deseja ativar o PreservedVideoMemoryAllocation?"
tr::add "pt_BR" "tui.yesno.extra.nvidia.pvma.deactivate.confirm" "Você deseja desativar o PreservedVideoMemoryAllocation?"

tr::add "en_US" "posinstall::switch_nvidia_pvma.start" "Starting PreservedVideoMemoryAllocation mode switch..."
tr::add "en_US" "posinstall::switch_nvidia_pvma.status.error" "Error checking PreservedVideoMemoryAllocation status."
tr::add "en_US" "posinstall::switch_nvidia_pvma.status.off" "PreservedVideoMemoryAllocation is disabled."
tr::add "en_US" "posinstall::switch_nvidia_pvma.status.on" "PreservedVideoMemoryAllocation is enabled."
tr::add "en_US" "posinstall::switch_nvidia_pvma.action.off" "PreservedVideoMemoryAllocation disabled."
tr::add "en_US" "posinstall::switch_nvidia_pvma.action.on" "PreservedVideoMemoryAllocation enabled."
tr::add "en_US" "tui.yesno.extra.nvidia.pvma.activate.confirm" "Do you want to enable PreservedVideoMemoryAllocation?"
tr::add "en_US" "tui.yesno.extra.nvidia.pvma.deactivate.confirm" "Do you want to disable PreservedVideoMemoryAllocation?"
