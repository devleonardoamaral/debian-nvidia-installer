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
tui::msgbox::custom() {
    local title="$1"
    local message="$2"
    local ok_label="$3"

    tui::show_msgbox "$title" "$message" "$ok_label"
}

# Caixa de diálogo de aviso que requer reinicialização
tui::msgbox::need_restart() {
    tui::msgbox::custom \
        "$(tr::t "default.tui.title.warn")" \
        "$(tr::t "default.script.restartrequired")" \
        "$(tr::t "default.tui.button.ok")"
}

# Caixa de diálogo de erro
tui::msgbox::error() {
    local message="$1"
    local ok_label="${2:-"$(tr::t "default.tui.button.ok")"}"

    tui::msgbox::custom \
        "$(tr::t "default.tui.title.error")" \
        "$message" \
        "$ok_label"
}

# Caixa de diálogo de aviso
tui::msgbox::warn() {
    local message="$1"

    tui::msgbox::custom \
        "$(tr::t "default.tui.title.warn")" \
        "$message" \
        "$(tr::t "default.tui.button.ok")"
}

# Caixa de diálogo de aviso
tui::msgbox::optimus_incompatible() {
    local message="$1"
    tui::msgbox::custom \
        "$(tr::t "default.tui.title.warn")" \
        "$(tr::t "tui::msgbox::optimus_incompatible")\n\n$message" \
        "$(tr::t "default.tui.button.ok")"
}

tr::add "pt_BR" "tui::msgbox::optimus_incompatible" "Esta funcionalidade não é compatível com sistemas Optimus!\n\nPara saber como identificar se seu dispositivo utiliza hardware Optimus, confira a documentação: https://wiki.debian.org/NVIDIA%20Optimus"
tr::add "en_US" "tui::msgbox::optimus_incompatible" "This feature is not compatible with Optimus systems!\n\nTo learn how to identify if your device uses Optimus hardware, check the documentation: https://wiki.debian.org/NVIDIA%20Optimus"

# Caixa de diálogo de aviso crítico
tui::msgbox::dangerous_action() {
    local message="$1"
    tui::msgbox::custom \
        "$(tr::t "default.tui.title.warn")" \
        "$(tr::t "tui::msgbox::dangerous_action")\n\n$message" \
        "$(tr::t "default.tui.button.ok")"
}

# Traduções
tr::add "pt_BR" "tui::msgbox::dangerous_action" "Esta funcionalidade é perigosa e pode quebrar seu sistema!\n\nCertifique-se de entender completamente o que está fazendo antes de prosseguir."
tr::add "en_US" "tui::msgbox::dangerous_action" "This action is dangerous and can break your system!\n\nMake sure you fully understand what you are doing before proceeding."
