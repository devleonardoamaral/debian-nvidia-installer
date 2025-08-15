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
    local choice
    local ret

    choice=$(tui::show_menu "$(tr::t "tui.menu.main.title")" "$(tr::t "tui.menu.main.subtitle")" \
        1 "$(tr::t "tui.menu.main.option.installdrivers")" \
        2 "$(tr::t "tui.menu.main.option.uninstalldrivers")"\
        3 "$(tr::t "tui.menu.main.option.posinstall")" \
        4 "$(tr::t "default.tui.button.exit")")
    ret="$?"
    
    echo "${choice:-4}"
    return "$ret"
}

tr::add "pt_BR" "tui.menu.main.title" "DEBIN NVIDIA INSTALLER"
tr::add "pt_BR" "tui.menu.main.subtitle" "Selecione uma opção:"
tr::add "pt_BR" "tui.menu.main.option.installdrivers" "Instalar Drivers NVIDIA"
tr::add "pt_BR" "tui.menu.main.option.uninstalldrivers" "Desinstalar Drivers NVIDIA"
tr::add "pt_BR" "tui.menu.main.option.posinstall" "Opções pós-instalação"

tr::add "en_US" "tui.menu.main.title" "DEBIAN NVIDIA INSTALLER"
tr::add "en_US" "tui.menu.main.subtitle" "Select an option:"
tr::add "en_US" "tui.menu.main.option.installdrivers" "Install NVIDIA Drivers"
tr::add "en_US" "tui.menu.main.option.uninstalldrivers" "Uninstall NVIDIA Drivers"
tr::add "en_US" "tui.menu.main.option.posinstall" "Post-installation Options"

tui::menu::posinstall() {
    local choice
    local ret

    choice=$(tui::show_menu "$(tr::t "tui.menu.posinstall.title")" "$(tr::t "tui.menu.posinstall.subtitle")" \
        1 "$(tr::t "tui.menu.posinstall.option.cuda")" \
        2 "$(tr::t "tui.menu.posinstall.option.switchpvma")" \
        3 "$(tr::t "tui.menu.posinstall.option.s0ixpm")" \
        4 "$(tr::t "default.tui.button.exit")")
    ret="$?"

    echo "${choice:-4}"
    return "$ret"
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
    local ret

    choice=$(tui::show_menu "" "$(tr::t "tui.driverflavors.subtitle")" \
        1 "$(tr::t "tui.menu.driverflavors.option.install.debian.proprietary535")" \
        2 "$(tr::t "tui.menu.driverflavors.option.install.debian.proprietary550")" \
        3 "$(tr::t "tui.menu.driverflavors.option.install.debian.opensource")" \
        4 "$(tr::t "tui.menu.driverflavors.option.install.cuda.proprietary")" \
        5 "$(tr::t "tui.menu.driverflavors.option.install.cuda.opensource")" \
        6 "$(tr::t "default.tui.button.exit")")
    ret="$?"

    echo "${choice:-6}"
    return "$ret"
}

tr::add "pt_BR" "tui.driverflavors.subtitle" "Selecione qual driver insalar:"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.proprietary535" "v535 Proprietário [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.proprietary550" "v550 Proprietário [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.debian.opensource" "v550 Código Aberto [Debian Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.proprietary" "v580 Proprietário [Cuda Repo]"
tr::add "pt_BR" "tui.menu.driverflavors.option.install.cuda.opensource" "v580 Código Aberto [Cuda Repo]"

tr::add "en_US" "tui.driverflavors.subtitle" "Select which driver to install:"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.proprietary535" "v535 Proprietário [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.proprietary550" "v550 Proprietary [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.debian.opensource" "v550 Open Source [Debian Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.proprietary" "v580 Proprietary [Cuda Repo]"
tr::add "en_US" "tui.menu.driverflavors.option.install.cuda.opensource" "v580 Open Source [Cuda Repo]"
