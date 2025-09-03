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

post_installation::is_cuda_toolkit_installed() {
    local repo
    repo="$(nvidia::get_source_alias)"

    if [ -z "$repo" ]; then
        return 1
    fi

    case "$repo" in
        debian)

            if packages::is_installed "nvidia-cuda-dev" || packages::is_installed "nvidia-cuda-toolkit"; then
                return 0
            else
                return 1
            fi
            ;;
        cuda)
            if packages::is_installed "cuda-toolkit-13-0"; then
                return 0
            else
                return 1
            fi
            ;;
        unknown)
                return 2
            ;;
    esac

    return 1
}

posinstall::install_cuda_toolkit() {
    local repo
    repo="$(nvidia::get_source_alias)"

    log::info "$(tr::t_args "posinstall::install_cuda_toolkit.start" "$repo")"

    if ! tui::yesno::default "" "$(tr::t "posinstall::install_cuda_toolkit.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! packages::update; then
        log::error "$(tr::t "posinstall::install_cuda_toolkit.update_failure")"
        tui::msgbox::error "$(tr::t "posinstall::install_cuda_toolkit.update_failure")"
        return 1
    fi

    case "$repo" in
        debian)

            if ! packages::install "nvidia-cuda-dev" "nvidia-cuda-toolkit"; then
                log::error "$(tr::t "posinstall::install_cuda_toolkit.install_failure")"
                tui::msgbox::error "$(tr::t "posinstall::install_cuda_toolkit.install_failure")"
                return 1
            fi
            ;;
        cuda)
            if ! packages::install "cuda-toolkit-13-0"; then
                log::error "$(tr::t "posinstall::install_cuda_toolkit.install_failure")"
                tui::msgbox::error "$(tr::t "posinstall::install_cuda_toolkit.install_failure")"
                return 1
            fi
            ;;
        *)
            log::error "$(tr::t "posinstall::install_cuda_toolkit.invalid_repo")"
            tui::msgbox::error "$(tr::t "posinstall::install_cuda_toolkit.invalid_repo")"
            return 1
            ;;
    esac

    log::info "$(tr::t "posinstall::install_cuda_toolkit.success")"
    tui::msgbox::warn "$(tr::t "posinstall::install_cuda_toolkit.success")"
    return 0
}

tr::add "pt_BR" "posinstall::install_cuda_toolkit.start" "Iniciando instalação do CUDA Toolkit através do repositório %1."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.confirm" "Você está prestes a instalar o CUDA Toolkit. Deseja continuar?"
tr::add "pt_BR" "posinstall::install_cuda_toolkit.update_failure" "Instalação do CUDA Toolkit falhou: não foi possível atualizar a lista de pacotes."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.install_failure" "Instalação do CUDA Toolkit falhou: erro na instalação dos pacotes."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.invalid_repo" "Erro inesperado: repositório inválido."
tr::add "pt_BR" "posinstall::install_cuda_toolkit.success" "Instalação do CUDA Toolkit concluída com sucesso."

tr::add "en_US" "posinstall::install_cuda_toolkit.start" "Starting CUDA Toolkit installation via %1 repository."
tr::add "en_US" "posinstall::install_cuda_toolkit.confirm" "You are about to install the CUDA Toolkit. Do you want to continue?"
tr::add "en_US" "posinstall::install_cuda_toolkit.update_failure" "CUDA Toolkit installation failed: could not update package list."
tr::add "en_US" "posinstall::install_cuda_toolkit.install_failure" "CUDA Toolkit installation failed: error installing packages."
tr::add "en_US" "posinstall::install_cuda_toolkit.invalid_repo" "Unexpected error: invalid repository."
tr::add "en_US" "posinstall::install_cuda_toolkit.success" "CUDA Toolkit installation completed successfully."

posinstall::uninstall_cuda_toolkit() {
    local repo
    repo="$(nvidia::get_source_alias)"

    log::info "$(tr::t_args "posinstall::uninstall_cuda_toolkit.start" "$repo")"

    if ! tui::yesno::default "" "$(tr::t "posinstall::uninstall_cuda_toolkit.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    case "$repo" in
        debian)

            if ! packages::purge "nvidia-cuda-dev" "nvidia-cuda-toolkit"; then
                log::error "$(tr::t "posinstall::uninstall_cuda_toolkit.uninstall_failure")"
                tui::msgbox::error "$(tr::t "posinstall::uninstall_cuda_toolkit.uninstall_failure")"
                return 1
            fi
            ;;
        cuda)
            if ! packages::purge "cuda-toolkit-13-0"; then
                log::error "$(tr::t "posinstall::uninstall_cuda_toolkit.uninstall_failure")"
                tui::msgbox::error "$(tr::t "posinstall::uninstall_cuda_toolkit.uninstall_failure")"
                return 1
            fi
            ;;
        *)
            log::error "$(tr::t "posinstall::uninstall_cuda_toolkit.invalid_repo")"
            tui::msgbox::error "$(tr::t "posinstall::uninstall_cuda_toolkit.invalid_repo")"
            return 1
            ;;
    esac

    log::info "$(tr::t "posinstall::uninstall_cuda_toolkit.success")"
    tui::msgbox::warn "$(tr::t "posinstall::uninstall_cuda_toolkit.success")"
    return 0
}

tr::add "pt_BR" "posinstall::uninstall_cuda_toolkit.start" "Iniciando desinstalação do CUDA Toolkit através do repositório %1."
tr::add "pt_BR" "posinstall::uninstall_cuda_toolkit.confirm" "Você está prestes a desinstalar o CUDA Toolkit. Deseja continuar?"
tr::add "pt_BR" "posinstall::uninstall_cuda_toolkit.uninstall_failure" "Desinstalação do CUDA Toolkit falhou: erro na remoção dos pacotes."
tr::add "pt_BR" "posinstall::uninstall_cuda_toolkit.invalid_repo" "Erro inesperado: repositório inválido."
tr::add "pt_BR" "posinstall::uninstall_cuda_toolkit.success" "Desinstalação do CUDA Toolkit concluída com sucesso."

tr::add "en_US" "posinstall::uninstall_cuda_toolkit.start" "Starting CUDA Toolkit uninstallation via %1 repository."
tr::add "en_US" "posinstall::uninstall_cuda_toolkit.confirm" "You are about to uninstall the CUDA Toolkit. Do you want to continue?"
tr::add "en_US" "posinstall::uninstall_cuda_toolkit.uninstall_failure" "CUDA Toolkit uninstallation failed: error removing packages."
tr::add "en_US" "posinstall::uninstall_cuda_toolkit.invalid_repo" "Unexpected error: invalid repository."
tr::add "en_US" "posinstall::uninstall_cuda_toolkit.success" "CUDA Toolkit uninstallation completed successfully."

posinstall::enable_nvidia_pvma() {
    log::info "$(tr::t "posinstall::enable_nvidia_pvma.start")"

    tui::msgbox::dangerous_action
    # tui::msgbox::optimus_incompatible

    if ! tui::yesno::default "" "$(tr::t "posinstall::enable_nvidia_pvma.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! nvidia::change_option_pvma "1"; then
        log::error "$(tr::t "posinstall::enable_nvidia_pvma.failure")"
        return 1
    fi

    log::info "$(tr::t "posinstall::enable_nvidia_pvma.success")"
    tui::msgbox::need_restart
    return 0
}

tr::add "pt_BR" "posinstall::enable_nvidia_pvma.start" "Ativando PreserveVideoMemoryAllocation..."
tr::add "pt_BR" "posinstall::enable_nvidia_pvma.confirm" "Você está prestes a ativar o PreserveVideoMemoryAllocation. Deseja continuar?"
tr::add "pt_BR" "posinstall::enable_nvidia_pvma.failure" "Falha ao ativar o PreserveVideoMemoryAllocation."
tr::add "pt_BR" "posinstall::enable_nvidia_pvma.success" "PreserveVideoMemoryAllocation ativado com sucesso."

tr::add "en_US" "posinstall::enable_nvidia_pvma.start" "Enabling PreserveVideoMemoryAllocation..."
tr::add "en_US" "posinstall::enable_nvidia_pvma.confirm" "You are about to enable PreserveVideoMemoryAllocation. Do you want to continue?"
tr::add "en_US" "posinstall::enable_nvidia_pvma.failure" "Failed to enable PreserveVideoMemoryAllocation."
tr::add "en_US" "posinstall::enable_nvidia_pvma.success" "PreserveVideoMemoryAllocation enabled successfully."

posinstall::disable_nvidia_pvma() {
    log::info "$(tr::t "posinstall::disable_nvidia_pvma.start")"

    tui::msgbox::dangerous_action
    # Não precisa do warning sobre Optimus ao desativar

    if ! tui::yesno::default "" "$(tr::t "posinstall::disable_nvidia_pvma.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! nvidia::change_option_pvma "0"; then
        log::error "$(tr::t "posinstall::disable_nvidia_pvma.failure")"
        return 1
    fi

    log::info "$(tr::t "posinstall::disable_nvidia_pvma.success")"
    tui::msgbox::need_restart
    return 0
}

tr::add "pt_BR" "posinstall::disable_nvidia_pvma.start" "Desativando PreserveVideoMemoryAllocation..."
tr::add "pt_BR" "posinstall::disable_nvidia_pvma.confirm" "Você está prestes a desativar o PreserveVideoMemoryAllocation. Deseja continuar?"
tr::add "pt_BR" "posinstall::disable_nvidia_pvma.failure" "Falha ao desativar o PreserveVideoMemoryAllocation."
tr::add "pt_BR" "posinstall::disable_nvidia_pvma.success" "PreserveVideoMemoryAllocation desativado com sucesso."

tr::add "en_US" "posinstall::disable_nvidia_pvma.start" "Disabling PreserveVideoMemoryAllocation..."
tr::add "en_US" "posinstall::disable_nvidia_pvma.confirm" "You are about to disable PreserveVideoMemoryAllocation. Do you want to continue?"
tr::add "en_US" "posinstall::disable_nvidia_pvma.failure" "Failed to disable PreserveVideoMemoryAllocation."
tr::add "en_US" "posinstall::disable_nvidia_pvma.success" "PreserveVideoMemoryAllocation disabled successfully."

# Habilitar S0ixPM
posinstall::enable_nvidia_s0ixpm() {
    log::info "$(tr::t "posinstall::enable_nvidia_s0ixpm.start")"

    tui::msgbox::dangerous_action
    # tui::msgbox::optimus_incompatible

    if ! tui::yesno::default "" "$(tr::t "posinstall::enable_nvidia_s0ixpm.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! nvidia::change_option_s0ixpm "1"; then
        log::error "$(tr::t "posinstall::enable_nvidia_s0ixpm.failure")"
        return 1
    fi

    log::info "$(tr::t "posinstall::enable_nvidia_s0ixpm.success")"
    tui::msgbox::need_restart
    return 0
}

tr::add "pt_BR" "posinstall::enable_nvidia_s0ixpm.start" "Ativando o modo S0ix Power Management..."
tr::add "pt_BR" "posinstall::enable_nvidia_s0ixpm.confirm" "Você está prestes a ativar o modo S0ix Power Management. Deseja continuar?"
tr::add "pt_BR" "posinstall::enable_nvidia_s0ixpm.failure" "Falha ao ativar o modo S0ix Power Management."
tr::add "pt_BR" "posinstall::enable_nvidia_s0ixpm.success" "Modo S0ix Power Management ativado com sucesso."

tr::add "en_US" "posinstall::enable_nvidia_s0ixpm.start" "Enabling S0ix Power Management..."
tr::add "en_US" "posinstall::enable_nvidia_s0ixpm.confirm" "You are about to enable S0ix Power Management. Do you want to continue?"
tr::add "en_US" "posinstall::enable_nvidia_s0ixpm.failure" "Failed to enable S0ix Power Management."
tr::add "en_US" "posinstall::enable_nvidia_s0ixpm.success" "S0ix Power Management enabled successfully."

posinstall::disable_nvidia_s0ixpm() {
    log::info "$(tr::t "posinstall::disable_nvidia_s0ixpm.start")"

    tui::msgbox::dangerous_action
    # Não precisa do warning sobre Optimus ao desativar

    if ! tui::yesno::default "" "$(tr::t "posinstall::disable_nvidia_s0ixpm.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! nvidia::change_option_s0ixpm "0"; then
        log::error "$(tr::t "posinstall::disable_nvidia_s0ixpm.failure")"
        return 1
    fi

    log::info "$(tr::t "posinstall::disable_nvidia_s0ixpm.success")"
    tui::msgbox::need_restart
    return 0
}

tr::add "pt_BR" "posinstall::disable_nvidia_s0ixpm.start" "Desativando o modo S0ix Power Management..."
tr::add "pt_BR" "posinstall::disable_nvidia_s0ixpm.confirm" "Você está prestes a desativar o modo S0ix Power Management. Deseja continuar?"
tr::add "pt_BR" "posinstall::disable_nvidia_s0ixpm.failure" "Falha ao desativar o modo S0ix Power Management."
tr::add "pt_BR" "posinstall::disable_nvidia_s0ixpm.success" "Modo S0ix Power Management desativado com sucesso."

tr::add "en_US" "posinstall::disable_nvidia_s0ixpm.start" "Disabling S0ix Power Management..."
tr::add "en_US" "posinstall::disable_nvidia_s0ixpm.confirm" "You are about to disable S0ix Power Management. Do you want to continue?"
tr::add "en_US" "posinstall::disable_nvidia_s0ixpm.failure" "Failed to disable S0ix Power Management."
tr::add "en_US" "posinstall::disable_nvidia_s0ixpm.success" "S0ix Power Management disabled successfully."

# Habilita os serviços de energia da NVIDIA
posinstall::enable_power_services() {
    log::info "$(tr::t "posinstall::enable_power_service.start")"

    tui::msgbox::warn "$(tr::t "posinstall::enable_power_service.warning")"

    if ! tui::yesno::default "" "$(tr::t "posinstall::enable_power_service.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! nvidia::enable_power_services; then
        return 1
    fi

    log::info "$(tr::t "posinstall::enable_power_service.success")"
    return 0
}

tr::add "pt_BR" "posinstall::enable_power_service.start" "Habilitando serviços de energia NVIDIA..."
tr::add "pt_BR" "posinstall::enable_power_service.warning" "Habilite os serviços auxiliares de energia NVIDIA apenas se estiver enfrentando problemas com suspensão ou hibernação. Esses serviços não são necessários por padrão e podem afetar o comportamento do sistema."
tr::add "pt_BR" "posinstall::enable_power_service.confirm" "Você está prestes a habilitar os serviços de energia NVIDIA. Deseja continuar?"
tr::add "pt_BR" "posinstall::enable_power_service.failure" "Falha ao habilitar o serviço: %1"
tr::add "pt_BR" "posinstall::enable_power_service.success" "Serviços de energia NVIDIA habilitados com sucesso."

tr::add "en_US" "posinstall::enable_power_service.start" "Enabling NVIDIA power services..."
tr::add "en_US" "posinstall::enable_power_service.warning" "Enable NVIDIA power auxiliary services only if you are experiencing issues with suspend or hibernate. These services are not required by default and may affect system behavior."
tr::add "en_US" "posinstall::enable_power_service.confirm" "You are about to enable NVIDIA power services. Do you want to continue?"
tr::add "en_US" "posinstall::enable_power_service.failure" "Failed to enable service: %1"
tr::add "en_US" "posinstall::enable_power_service.success" "NVIDIA power services enabled successfully."

# Desabilita os serviços de energia da NVIDIA
posinstall::disable_power_services() {
    log::info "$(tr::t "posinstall::disable_power_service.start")"

    if ! tui::yesno::default "" "$(tr::t "posinstall::disable_power_service.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! nvidia::disable_power_services; then
        return 1
    fi

    log::info "$(tr::t "posinstall::disable_power_service.success")"
    return 0
}

tr::add "pt_BR" "posinstall::disable_power_service.start" "Desabilitando serviços de energia NVIDIA..."
tr::add "pt_BR" "posinstall::disable_power_service.confirm" "Você está prestes a desabilitar os serviços de energia NVIDIA. Deseja continuar?"
tr::add "pt_BR" "posinstall::disable_power_service.failure" "Falha ao desabilitar o serviço: %1"
tr::add "pt_BR" "posinstall::disable_power_service.success" "Serviços de energia NVIDIA desabilitados com sucesso."

tr::add "en_US" "posinstall::disable_power_service.start" "Disabling NVIDIA power services..."
tr::add "en_US" "posinstall::disable_power_service.confirm" "You are about to disable NVIDIA power services. Do you want to continue?"
tr::add "en_US" "posinstall::disable_power_service.failure" "Failed to disable service: %1"
tr::add "en_US" "posinstall::disable_power_service.success" "NVIDIA power services disabled successfully."
