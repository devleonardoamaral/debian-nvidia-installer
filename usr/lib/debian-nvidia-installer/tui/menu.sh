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

tui::menu::main() {
    while true; do
        log::info "$(tr::t "tui::menu::main.nav.start")"

        NAVIGATION_STATUS=1

        local choice
        choice=$(tui::show_menu "$(tr::t "tui.menu.main.title") $SCRIPT_VERSION" "$(tr::t "tui.menu.main.subtitle")" \
            1 "$(tr::t "tui.menu.main.option.installdrivers")" \
            2 "$(tr::t "tui.menu.main.option.uninstalldrivers")"\
            3 "$(tr::t "tui.menu.main.option.posinstall")" \
            4 "$(tr::t "default.tui.button.exit")")
        choice="${choice:-4}"

        case "$choice" in
            1) installer::install_nvidia ;;
            2) installer::uninstall_nvidia ;;
            3)
                if nvidia::is_driver_installed; then
                    tui::menu::posinstall
                else
                    tui::msgbox::warn "$(tr::t "tui::menu::main.drivernotinstalled")"
                fi
                ;;
            4) break ;; # Encerra a navegação
        esac
    done
}

tr::add "pt_BR" "tui::menu::main.nav.start" "[TUI] Abrindo o menu Principal..."
tr::add "pt_BR" "tui.menu.main.title" "DEBIAN NVIDIA INSTALLER"
tr::add "pt_BR" "tui.menu.main.subtitle" "Selecione uma opção:"
tr::add "pt_BR" "tui.menu.main.option.installdrivers" "Instalar Drivers"
tr::add "pt_BR" "tui.menu.main.option.uninstalldrivers" "Desinstalar Drivers"
tr::add "pt_BR" "tui.menu.main.option.posinstall" "Opções pós-instalação"
tr::add "pt_BR" "tui::menu::main.drivernotinstalled" "Não foi possível detectar o driver da NVIDIA no sistema.\n\nInstale o driver e reinicie o sistema para que o driver seja carregado antes de acessar as opções pós-instalação."

tr::add "en_US" "tui::menu::main.nav.start" "[TUI] Opening the Main menu..."
tr::add "en_US" "tui.menu.main.title" "DEBIAN NVIDIA INSTALLER"
tr::add "en_US" "tui.menu.main.subtitle" "Select an option:"
tr::add "en_US" "tui.menu.main.option.installdrivers" "Install Drivers"
tr::add "en_US" "tui.menu.main.option.uninstalldrivers" "Uninstall Drivers"
tr::add "en_US" "tui.menu.main.option.posinstall" "Post-installation Options"
tr::add "en_US" "tui::menu::main.drivernotinstalled" "Could not detect the NVIDIA driver on the system.\n\nInstall the driver and restart the system so that the driver is loaded before accessing the post-installation options."

tui::menu::posinstall() {
    local option_labels=()
    local option_actions=()
    local menu_items=()
    local is_cuda_installed pvma_val s0ixpm_val
    local choice i tag status

    while true; do
        log::info "$(tr::t "tui::menu::posinstall.nav.start")"
        post_installation::is_cuda_toolkit_installed
        is_cuda_installed=$?

        # Construindo o menu dinamicamente
        option_labels=()
        option_actions=()

        # Serviços auxiliares de energia da NVIDIA
        if [ "$(nvidia::get_source_alias)" != "unknown" ]; then
            nvidia::is_power_services_enabled
            status=$?
            log::info "$(tr::t_args "tui::menu::posinstall.power_service.status" "$status")"
            if [ "$status" -eq 0 ]; then
                option_labels+=("$(tr::t "tui::menu::posinstall.option.disable_power_service")")
                option_actions+=("posinstall::disable_power_services")
            else
                option_labels+=("$(tr::t "tui::menu::posinstall.option.enable_power_service")")
                option_actions+=("posinstall::enable_power_services")
            fi
        fi

        # PVMA
        pvma_val="$(nvidia::get_pvma)"
        status=$?
        if [ "$status" -eq 0 ]; then
            log::info "$(tr::t_args "tui::menu::posinstall.pvma.status" "$pvma_val")"

            if [ "$pvma_val" -eq 1 ]; then
                option_labels+=("$(tr::t "tui::menu::posinstall.option.disable_pvma")")
                option_actions+=("posinstall::disable_nvidia_pvma")
            else
                option_labels+=("$(tr::t "tui::menu::posinstall.option.enable_pvma")")
                option_actions+=("posinstall::enable_nvidia_pvma")
            fi
        fi

        # S0ixPM
        s0ixpm_val="$(nvidia::get_s0ixpm)"
        status=$?
        if [ "$status" -eq 0 ]; then
            log::info "$(tr::t_args "tui::menu::posinstall.s0ixpm.status" "$s0ixpm_val")"

            if [ "$s0ixpm_val" -eq 1 ]; then
                option_labels+=("$(tr::t "tui::menu::posinstall.option.disable_s0ixpm")")
                option_actions+=("posinstall::disable_nvidia_s0ixpm")
            else
                option_labels+=("$(tr::t "tui::menu::posinstall.option.enable_s0ixpm")")
                option_actions+=("posinstall::enable_nvidia_s0ixpm")
            fi
        fi

        # CUDA
        if [ "$is_cuda_installed" -eq 0 ]; then
            option_labels+=("$(tr::t "tui::menu::posinstall.option.cuda.uninstall")")
            option_actions+=("posinstall::uninstall_cuda_toolkit")
        elif [ "$is_cuda_installed" -eq 1 ]; then
            option_labels+=("$(tr::t "tui::menu::posinstall.option.cuda.install")")
            option_actions+=("posinstall::install_cuda_toolkit")
        else
            log::error "$(tr::t "tui::menu::posinstall.option.cuda.error")"
        fi

        # Sempre adiciona a opção de sair
        option_labels+=("$(tr::t "default.tui.button.exit")")
        option_actions+=("break")

        # Monta array intercalando tags e rótulos
        menu_items=()
        for i in "${!option_labels[@]}"; do
            tag=$((i + 1))
            menu_items+=("$tag" "${option_labels[i]}")
        done

        # Exibindo o menu
        choice=$(tui::show_menu "$(tr::t "tui::menu::posinstall.title")" \
                        "$(tr::t "tui::menu::posinstall.subtitle")" \
                        "${menu_items[@]}")

        # ESC ou cancelamento
        if [ $? -eq 255 ]; then
            break
        fi

        choice="${choice:-${#option_labels[@]}}"
        # Executa a ação correspondente
        i=$((choice - 1))
        eval "${option_actions[i]}"

        log::input _ "$(tr::t "default.script.pause")"
    done
}

tr::add "pt_BR" "tui::menu::posinstall.nav.start" "[TUI] Abrindo o menu de Pós Instalação"
tr::add "pt_BR" "tui::menu::posinstall.title" "OPÇÕES PÓS-INSTALAÇÃO"
tr::add "pt_BR" "tui::menu::posinstall.subtitle" "Selecione uma opção:"
tr::add "pt_BR" "tui::menu::posinstall.power_service.status" "Status dos serviços auxiliares de energia NVIDIA: %1"
tr::add "pt_BR" "tui::menu::posinstall.option.enable_power_service" "Ativar serviços de energia NVIDIA"
tr::add "pt_BR" "tui::menu::posinstall.option.disable_power_service" "Desativar serviços de energia NVIDIA"
tr::add "pt_BR" "tui::menu::posinstall.pvma.status" "Opção NVreg_PreserveVideoMemoryAllocations=%1"
tr::add "pt_BR" "tui::menu::posinstall.option.enable_pvma" "Ativar NVreg_PreserveVideoMemoryAllocations"
tr::add "pt_BR" "tui::menu::posinstall.option.disable_pvma" "Desativar NVreg_PreserveVideoMemoryAllocations"
tr::add "pt_BR" "tui::menu::posinstall.s0ixpm.status" "Opção NVreg_EnableS0ixPowerManagement=%1"
tr::add "pt_BR" "tui::menu::posinstall.option.enable_s0ixpm" "Ativar NVreg_EnableS0ixPowerManagement"
tr::add "pt_BR" "tui::menu::posinstall.option.disable_s0ixpm" "Desativar NVreg_EnableS0ixPowerManagement"
tr::add "pt_BR" "tui::menu::posinstall.option.cuda.error" "Não foi possível determinar o repositório para instalação do CUDA Toolkit. Reinstale os drivers utilizando este script e tente novamente."
tr::add "pt_BR" "tui::menu::posinstall.option.cuda.install" "Instalar CUDA Toolkit"
tr::add "pt_BR" "tui::menu::posinstall.option.cuda.uninstall" "Desinstalar CUDA Toolkit"

tr::add "en_US" "tui::menu::posinstall.nav.start" "[TUI] Opening the Post-Installation menu..."
tr::add "en_US" "tui::menu::posinstall.title" "POST-INSTALLATION OPTIONS"
tr::add "en_US" "tui::menu::posinstall.subtitle" "Select an option:"
tr::add "en_US" "tui::menu::posinstall.power_service.status" "NVIDIA auxiliary power services status: %1"
tr::add "en_US" "tui::menu::posinstall.option.enable_power_service" "Enable NVIDIA power management services"
tr::add "en_US" "tui::menu::posinstall.option.disable_power_service" "Disable NVIDIA power management services"
tr::add "en_US" "tui::menu::posinstall.pvma.status" "Option NVreg_PreserveVideoMemoryAllocations=%1"
tr::add "en_US" "tui::menu::posinstall.option.enable_pvma" "Enable NVreg_PreserveVideoMemoryAllocations"
tr::add "en_US" "tui::menu::posinstall.option.disable_pvma" "Disable NVreg_PreserveVideoMemoryAllocations"
tr::add "en_US" "tui::menu::posinstall.s0ixpm.status" "Option NVreg_EnableS0ixPowerManagement=%1"
tr::add "en_US" "tui::menu::posinstall.option.enable_s0ixpm" "Enable NVreg_EnableS0ixPowerManagement"
tr::add "en_US" "tui::menu::posinstall.option.disable_s0ixpm" "Disable NVreg_EnableS0ixPowerManagement"
tr::add "en_US" "tui::menu::posinstall.option.cuda.error" "Could not determine the repository for installing the CUDA Toolkit. Please reinstall the drivers using this script and try again."
tr::add "en_US" "tui::menu::posinstall.option.cuda.install" "Install CUDA Toolkit"
tr::add "en_US" "tui::menu::posinstall.option.cuda.uninstall" "Uninstall CUDA Toolkit"

tui::menu::flavors() {
    log::info "$(tr::t "tui::menu::flavors.nav.start")"

    local version_stable="${CUDA_DRIVER_VERSIONS["stable"]}"
    local version_latest="${CUDA_DRIVER_VERSIONS["latest"]}"

    tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.stable.proprietary" "v${version_stable} Proprietário [Cuda Repo]"
    tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.stable.opensource" "v${version_stable} Código Aberto [Cuda Repo]"
    tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.latest.proprietary" "v${version_latest} Proprietário (instável) [Cuda Repo]"
    tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.latest.opensource" "v${version_latest} Código Aberto (instável) [Cuda Repo]"

    tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.stable.proprietary" "v${version_stable} Proprietary [Cuda Repo]"
    tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.stable.opensource" "v${version_stable} Open Source [Cuda Repo]"
    tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.latest.proprietary" "v${version_latest} Proprietary (unstable) [Cuda Repo]"
    tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.latest.opensource" "v${version_latest} Open Source (unstable) [Cuda Repo]"

    local choice status
    choice=$(tui::show_menu "" "$(tr::t "tui.driverflavors.subtitle")" \
        1 "$(tr::t "tui.menu.driverflavors.option.install.debian.proprietary535")" \
        2 "$(tr::t "tui.menu.driverflavors.option.install.debian.proprietary550")" \
        3 "$(tr::t "tui.menu.driverflavors.option.install.debian.opensource")" \
        4 "$(tr::t "tui.menu.driverflavors.option.install.cuda.stable.proprietary")" \
        5 "$(tr::t "tui.menu.driverflavors.option.install.cuda.stable.opensource")" \
        6 "$(tr::t "tui.menu.driverflavors.option.install.cuda.latest.proprietary")" \
        7 "$(tr::t "tui.menu.driverflavors.option.install.cuda.latest.opensource")" \
        8 "$(tr::t "default.tui.button.exit")")
    choice="${choice:-6}"

    case "$choice" in
        1)
            installer::install_debian_proprietary535
            status=$?
            ;;
        2)
            installer::install_debian_proprietary550
            status=$?
            ;;
        3)
            installer::install_debian_opensource
            status=$?
            ;;
        4)
            cudarepo::install_driver "stable" "proprietary"
            status=$?
            ;;
        5)
            cudarepo::install_driver "stable" "open-source"
            status=$?
            ;;
        6)
            cudarepo::install_driver "latest" "proprietary"
            status=$?
            ;;
        7)
            cudarepo::install_driver "latest" "open-source"
            status=$?
            ;;
        # 8) Volta ao menu principal por padrão
    esac

    return "$status"
}

tr::add "pt_BR" "tui::menu::flavors.nav.start" "[TUI] Abrindo o menu Seleção de Drivers Nvidia..."
tr::add "pt_BR" "tui.driverflavors.subtitle" "Selecione qual driver insalar:"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.proprietary535" "v535 Proprietário [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.proprietary550" "v550 Proprietário [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.opensource" "v550 Código Aberto [Debian Repo]"

tr::add "en_US" "tui::menu::flavors.nav.start" "[TUI] Opening the Nvidia Driver Selection menu..."
tr::add "en_US" "tui.driverflavors.subtitle" "Select which driver to install:"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.proprietary535" "v535 Proprietary [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.proprietary550" "v550 Proprietary [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.opensource" "v550 Open Source [Debian Repo]"