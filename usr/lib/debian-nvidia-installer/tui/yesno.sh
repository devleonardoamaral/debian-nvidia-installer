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

# Caixa de diálogo personalizada
tui::yesno::custom() {
    local title="$1"
    local message="$2"
    local yes_label="$3"
    local no_label="$4"

    tui::show_yesno "$title" "$message" "$yes_label" "$no_label"
}

# Caixa de diálogo de confirmação com botões "Sim" e "Não"
tui::yesno::default() {
    local title="$1"
    local message="$2"

    tui::yesno::custom \
        "$title" \
        "$message" \
        "$(tr::t "default.tui.button.yes")" \
        "$(tr::t "default.tui.button.no")"
}

# Caixa de diálogo de confirmação com botões "Confirmar" e "Cancelar"
tui::yesno::confirmcancel() {
    local title="$1"
    local message="$2"

    tui::yesno::custom \
        "$title" \
        "$message" \
        "$(tr::t "default.tui.button.confirm")" \
        "$(tr::t "default.tui.button.cancel")"
}