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

tui::navigate::main() {
    while true; do       
        NAVIGATION_STATUS=1

        case $(tui::menu::main) in
            1) installer::install_nvidia ;;
            2) installer::uninstall_nvidia ;;
            3) 
                if nvidia::is_driver_installed; then
                    tui::navigate::posinstall
                else
                    tui::msgbox::warn "$(tr::t "tui::navigate::main.drivernotinstalled")"
                fi
                ;;
            4) break ;; # Encerra a navegação
        esac
    done
}

tr::add "pt_BR" "tui::navigate::main.drivernotinstalled" "Não foi possível detectar o driver da NVIDIA no sistema.\n\nInstale o driver e reinicie o sistema para que o driver seja carregado antes de acessar as opções pós-instalação."

tr::add "en_US" "tui::navigate::main.drivernotinstalled" "Could not detect the NVIDIA driver on the system.\n\nInstall the driver and restart the system so that the driver is loaded before accessing the post-installation options."

tui::navigate::posinstall() {
    case $(tui::menu::posinstall) in
        1) posinstall::install_cuda_toolkit ;;
        2) posinstall::switch_nvidia_pvma ;;
        3) posinstall::switch_nvidia_s0ixpm ;;
        # 4) Volta ao menu principal por padrão
    esac
    return
}

tui::navigate::flavors() {
    case $(tui::menu::flavors) in
        1) installer::install_debian_proprietary535 ;;
        2) installer::install_debian_proprietary550 ;;
        3) installer::install_debian_opensource ;;
        4) installer::install_cuda_proprietary ;;
        5) installer::install_cuda_opensource ;;
        # 6) Volta ao menu principal por padrão
    esac
    return
}