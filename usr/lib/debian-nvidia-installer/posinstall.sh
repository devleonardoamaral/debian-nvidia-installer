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

posinstall::install_cuda_toolkit::install() {
    local pkgs=("$@")
    local pkgs_count=${#pkgs[@]}
    local installed_pkgs=()

    if ! packages::update; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Verifica quais pacotes já estão instalados
    for pkg in "${pkgs[@]}"; do
        if packages::is_installed "$pkg"; then
            installed_pkgs+=("$pkg")
        fi
    done

    # Se algum pacote já estiver instalado, pergunta se deseja desinstalar
    # Senao, pergunta se deseja instalar
    if [[ ${#installed_pkgs[@]} -gt 0 ]]; then
        if tui::yesno::default "" "$(tr::t "posinstall::install_cuda.uninstall.confirm")"; then
            log::info "$(tr::t "posinstall::install_cuda.uninstall.start")"

            for pkg in "${installed_pkgs[@]}"; do
                log::info "$(tr::t_args "posinstall::install_cuda.uninstall.pkg.start" "$pkg")"

                if ! packages::purge "$pkg"; then
                    log::critical "$(tr::t "default.script.canceled.byfailure")"
                    log::input _ "$(tr::t "default.script.pause")"
                    return 1
                fi

                log::info "$(tr::t_args "posinstall::install_cuda.uninstall.pkg.success" "$pkg")"
            done

            log::info "$(tr::t "posinstall::install_cuda.uninstall.success")"
            tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
            log::input _ "$(tr::t "default.script.pause")"
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

                if ! packages::install "$pkg"; then
                    log::critical "$(tr::t "default.script.canceled.byfailure")"
                    log::input _ "$(tr::t "default.script.pause")"
                    return 1
                fi

                log::info "$(tr::t_args "posinstall::install_cuda.install.pkg.success" "$pkg")"
            done

            log::info "$(tr::t "posinstall::install_cuda.install.success")"
            tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
            log::input _ "$(tr::t "default.script.pause")"
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

# Instala o CUDA Toolkit e as bibliotecas de desenvolvimento CUDA
posinstall::install_cuda_toolkit() {
    if ! nvidia::is_driver_installed; then
        echo "$(tr::t "posinstall::install_cuda_toolkit.missingdriver")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    origin_repo="$(apt-cache policy "nvidia-driver" | grep 'http' | head -n1 | awk '{print $2}')"

    case "$origin_repo" in
        *developer.download.nvidia.com* )
            echo "$(tr::t "posinstall::install_cuda_toolkit.cuda")"
            posinstall::install_cuda_toolkit::install "cuda-toolkit-13-0"
            ;;
        *deb.debian.org* )
            echo "$(tr::t "posinstall::install_cuda_toolkit.debian")"
            posinstall::install_cuda_toolkit::install "nvidia-cuda-dev" "nvidia-cuda-toolkit"
            ;;
        * )
            echo "$(tr::t "posinstall::install_cuda_toolkit.unknown")"
            ;;
    esac
}

tr::add "pt_BR" "posinstall::install_cuda_toolkit.missingdriver" "Nenhum driver NVIDIA instalado."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.cuda" "Driver instalado via repositório CUDA."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.debian" "Driver instalado via repositório Debian."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.unknown" "Driver instalado via outro método ou fonte desconhecida."

tr::add "en_US" "posinstall::install_cuda_toolkit.missingdriver" "No NVIDIA driver installed."
tr::add "en_US" "posinstall::install_cuda_toolkit.cuda" "Driver installed via CUDA repository."
tr::add "en_US" "posinstall::install_cuda_toolkit.debian" "Driver installed via Debian repository."
tr::add "en_US" "posinstall::install_cuda_toolkit.unknown" "Driver installed via another method or unknown source."

# Alterna o modo PreservedVideoMemoryAllocation
posinstall::switch_nvidia_pvma() {
    tui::msgbox::dangerous_action
    tui::msgbox::optimus_incompatible
    log::info "$(tr::t "posinstall::switch_nvidia_pvma.start")"

    local pvma_status
    if ! pvma_status=$(nvidia::get_pvma); then
        if [[ $? -eq 2 ]]; then
            log::error "$(tr::t "posinstall::switch_nvidia_pvma.status.error")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
        fi
        pvma_status=0
    fi

    if [[ -z "$pvma_status" ]] || [[ "$pvma_status" -eq 0 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_pvma.status.off")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.pvma.activate.confirm")"; then
            if nvidia::change_option_pvma "1"; then
                # Atualiza o initramfs para garantir que a opção seja definida
                update-initramfs -u | tee -a /dev/fd/3
                log::info "$(tr::t "posinstall::switch_nvidia_pvma.action.on")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
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
                # Atualiza o initramfs para garantir que a opção seja definida
                update-initramfs -u | tee -a /dev/fd/3
                log::info "$(tr::t "posinstall::switch_nvidia_pvma.action.off")"
                tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
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

# Alterna o modo NVreg_EnableS0ixPowerManagement
posinstall::switch_nvidia_s0ixpm() {
    tui::msgbox::dangerous_action
    tui::msgbox::optimus_incompatible
    log::info "$(tr::t "posinstall::switch_nvidia_s0ixpm.start")"

    local s0ixpm_status
    if ! s0ixpm_status=$(nvidia::get_s0ixpm); then
        if [[ $? -eq 2 ]]; then
            log::error "$(tr::t "posinstall::switch_nvidia_s0ixpm.status.error")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
        fi
        s0ixpm_status=0
    fi

    if [[ -z "$s0ixpm_status" ]] || [[ "$s0ixpm_status" -eq 0 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_s0ixpm.status.off")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.s0ixpm.activate.confirm")"; then
            if nvidia::change_option_s0ixpm "1"; then
                # Atualiza o initramfs para garantir que a opção seja definida
                update-initramfs -u | tee -a /dev/fd/3
                log::info "$(tr::t "posinstall::switch_nvidia_s0ixpm.action.on")"
                tui::msgbox::need_restart
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
    elif [[ "$s0ixpm_status" -eq 1 ]]; then
        log::info "$(tr::t "posinstall::switch_nvidia_s0ixpm.status.on")"

        if tui::yesno::default "" "$(tr::t "tui.yesno.extra.nvidia.s0ixpm.deactivate.confirm")"; then
            if nvidia::change_option_s0ixpm "0"; then
                # Atualiza o initramfs para garantir que a opção seja definida
                update-initramfs -u | tee -a /dev/fd/3
                log::info "$(tr::t "posinstall::switch_nvidia_s0ixpm.action.off")"
                tui::msgbox::need_restart
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
        log::error "$(tr::t "posinstall::switch_nvidia_s0ixpm.error.status")"
        return 1
    fi
}

tr::add "pt_BR" "posinstall::switch_nvidia_s0ixpm.start" "Iniciando a alternância do modo S0ix Power Management..."
tr::add "pt_BR" "posinstall::switch_nvidia_s0ixpm.status.error" "Erro ao verificar o status do S0ix Power Management."
tr::add "pt_BR" "posinstall::switch_nvidia_s0ixpm.status.off" "S0ix Power Management está desabilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_s0ixpm.status.on" "S0ix Power Management está habilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_s0ixpm.action.off" "S0ix Power Management desabilitado."
tr::add "pt_BR" "posinstall::switch_nvidia_s0ixpm.action.on" "S0ix Power Management habilitado."
tr::add "pt_BR" "tui.yesno.extra.nvidia.s0ixpm.activate.confirm" "Você deseja ativar o S0ix Power Management?"
tr::add "pt_BR" "tui.yesno.extra.nvidia.s0ixpm.deactivate.confirm" "Você deseja desativar o S0ix Power Management?"

tr::add "en_US" "posinstall::switch_nvidia_s0ixpm.start" "Starting S0ix Power Management mode switch..."
tr::add "en_US" "posinstall::switch_nvidia_s0ixpm.status.error" "Error checking S0ix Power Management status."
tr::add "en_US" "posinstall::switch_nvidia_s0ixpm.status.off" "S0ix Power Management is disabled."
tr::add "en_US" "posinstall::switch_nvidia_s0ixpm.status.on" "S0ix Power Management is enabled."
tr::add "en_US" "posinstall::switch_nvidia_s0ixpm.action.off" "S0ix Power Management disabled."
tr::add "en_US" "posinstall::switch_nvidia_s0ixpm.action.on" "S0ix Power Management enabled."
tr::add "en_US" "tui.yesno.extra.nvidia.s0ixpm.activate.confirm" "Do you want to enable S0ix Power Management?"
tr::add "en_US" "tui.yesno.extra.nvidia.s0ixpm.deactivate.confirm" "Do you want to disable S0ix Power Management?"

