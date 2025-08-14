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
            3) tui::navigate::posinstall ;;
            4) break ;; # Encerra a navegação
        esac
    done
}

tui::navigate::posinstall() {
    case $(tui::menu::posinstall) in
        1) posinstall::install_cuda ;;
        2) posinstall::install_optix ;;
        3) posinstall::switch_nvidia_pvma ;;
        # 4) Volta ao menu principal por padrão
    esac
    return
}

tui::navigate::flavors() {
    case $(tui::menu::flavors) in
        1) installer::install_debian_proprietary ;;
        2) installer::install_debian_opensource ;;
        3) installer::install_cuda_proprietary ;;
        4) installer::install_cuda_opensource ;;
        # 5) Volta ao menu principal por padrão
    esac
    return
}