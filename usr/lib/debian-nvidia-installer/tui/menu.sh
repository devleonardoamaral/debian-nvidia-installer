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

tr::add "pt_BR" "tui.menu.main.title" "DEBIAN NVIDIA INSTALLER"
tr::add "pt_BR" "tui.menu.main.subtitle" "Selecione uma opção:"
tr::add "pt_BR" "tui.menu.main.option.installdrivers" "Instalar Drivers NVIDIA"
tr::add "pt_BR" "tui.menu.main.option.uninstalldrivers" "Desinstalar Drivers NVIDIA"
tr::add "pt_BR" "tui.menu.main.option.posinstall" "Opções pós-instalação"
tr::add "pt_BR" "tui::menu::main.drivernotinstalled" "Não foi possível detectar o driver da NVIDIA no sistema.\n\nInstale o driver e reinicie o sistema para que o driver seja carregado antes de acessar as opções pós-instalação."

tr::add "en_US" "tui.menu.main.title" "DEBIAN NVIDIA INSTALLER"
tr::add "en_US" "tui.menu.main.subtitle" "Select an option:"
tr::add "en_US" "tui.menu.main.option.installdrivers" "Install NVIDIA Drivers"
tr::add "en_US" "tui.menu.main.option.uninstalldrivers" "Uninstall NVIDIA Drivers"
tr::add "en_US" "tui.menu.main.option.posinstall" "Post-installation Options"
tr::add "en_US" "tui::menu::main.drivernotinstalled" "Could not detect the NVIDIA driver on the system.\n\nInstall the driver and restart the system so that the driver is loaded before accessing the post-installation options."

tui::menu::posinstall() {
    local choice
    choice=$(tui::show_menu "$(tr::t "tui.menu.posinstall.title")" "$(tr::t "tui.menu.posinstall.subtitle")" \
        1 "$(tr::t "tui.menu.posinstall.option.cuda")" \
        2 "$(tr::t "tui.menu.posinstall.option.switchpvma")" \
        3 "$(tr::t "tui.menu.posinstall.option.s0ixpm")" \
        4 "$(tr::t "default.tui.button.exit")")
    choice="${choice:-4}"

    case "$choice" in
        1) posinstall::install_cuda_toolkit ;;
        2) posinstall::switch_nvidia_pvma ;;
        3) posinstall::switch_nvidia_s0ixpm ;;
        # 4) Volta ao menu principal por padrão
    esac
    return
}

tr::add "pt_BR" "tui.menu.posinstall.title" "OPÇÕES PÓS-INSTALAÇÃO"
tr::add "pt_BR" "tui.menu.posinstall.subtitle" "Selecione uma opção:"
tr::add "pt_BR" "tui.menu.posinstall.option.cuda" "CUDA Toolkit"
tr::add "pt_BR" "tui.menu.posinstall.option.switchpvma" "Alternar PreservedVideoMemoryAllocation"
tr::add "pt_BR" "tui.menu.posinstall.option.s0ixpm" "Alternar S0ix Power Management"

tr::add "en_US" "tui.menu.posinstall.title" "POST-INSTALLATION OPTIONS"
tr::add "en_US" "tui.menu.posinstall.subtitle" "Select an option:"
tr::add "en_US" "tui.menu.posinstall.option.cuda" "CUDA Toolkit"
tr::add "en_US" "tui.menu.posinstall.option.switchpvma" "Switch PreservedVideoMemoryAllocation"
tr::add "en_US" "tui.menu.posinstall.option.s0ixpm" "Switch S0ix Power Management"

tui::menu::flavors() {
    local choice
    choice=$(tui::show_menu "" "$(tr::t "tui.driverflavors.subtitle")" \
        1 "$(tr::t "tui.menu.driverflavors.option.install.debian.proprietary535")" \
        2 "$(tr::t "tui.menu.driverflavors.option.install.debian.proprietary550")" \
        3 "$(tr::t "tui.menu.driverflavors.option.install.debian.opensource")" \
        4 "$(tr::t "tui.menu.driverflavors.option.install.cuda.proprietary")" \
        5 "$(tr::t "tui.menu.driverflavors.option.install.cuda.opensource")" \
        6 "$(tr::t "default.tui.button.exit")")
    choice="${choice:-6}"

    case "$choice" in
        1) installer::install_debian_proprietary535 ;;
        2) installer::install_debian_proprietary550 ;;
        3) installer::install_debian_opensource ;;
        4) installer::install_cuda_proprietary ;;
        5) installer::install_cuda_opensource ;;
        # 6) Volta ao menu principal por padrão
    esac
    return
}

tr::add "pt_BR" "tui.driverflavors.subtitle" "Selecione qual driver insalar:"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.proprietary535" "v535 Proprietário [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.proprietary550" "v550 Proprietário [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.opensource" "v550 Código Aberto [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.proprietary" "v580 Proprietário (instável) [Cuda Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.opensource" "v580 Código Aberto (instável) [Cuda Repo]"

tr::add "en_US" "tui.driverflavors.subtitle" "Select which driver to install:"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.proprietary535" "v535 Proprietário [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.proprietary550" "v550 Proprietary [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.opensource" "v550 Open Source [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.proprietary" "v580 Proprietary (unstable) [Cuda Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.opensource" "v580 Open Source (unstable) [Cuda Repo]"