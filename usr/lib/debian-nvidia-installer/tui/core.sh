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

# Configurações globais do Dialog
DIALOG_OPTS=(
    --keep-tite
)

# Menu com multiplas escolhas sem botão de cancelamento
tui::show_menu() {
    local choice

    local title="$1"
    local prompt="$2"

    local ok_label="${3:-"$(tr::t "default.tui.button.confirm")"}"
    local cancel_label="${4:-"$(tr::t "default.tui.button.cancel")"}"

    shift 4
    local menu_items=("$@")

    choice="$(dialog "${DIALOG_OPTS[@]}" \
           --title "$title" \
           --ok-label "$ok_label" \
           --cancel-label "$cancel_label" \
           --menu "$prompt" \
           20 70 10 \
           "${menu_items[@]}" 2>&1 1>/dev/tty)"
    local status="$?"

    echo "$choice"
    return "$status"
}

# Caixa de dialogo sem botão de cancelamento
tui::show_msgbox() {
    local title="$1"
    local message="$2"
    local ok_label="${3:-"$(tr::t "default.tui.button.ok")"}"

    dialog "${DIALOG_OPTS[@]}" \
           --no-cancel \
           --title "$title" \
           --ok-label "$ok_label" \
           --msgbox "$message" \
           20 70 1>/dev/tty

    return "$?"
}

# Caixa de dialogo de dupla escolha
tui::show_yesno() {
    local title="$1"
    local message="$2"
    local yes_label="${3:-"$(tr::t "default.tui.button.confirm")"}"
    local no_label="${4:-"$(tr::t "default.tui.button.cancel")"}"

    dialog "${DIALOG_OPTS[@]}" \
           --title "$title" \
           --yes-label "$yes_label" \
           --no-label "$no_label" \
           --yesno "$message" 20 70 1>/dev/tty

    return "$?"
}

tui::show_dynamic_menu() {
    local title="$1"
    local prompt="$2"
    local ok_label="$3"
    local cancel_label="$4"

    # Name references
    local -n labels=$5
    local -n actions=$6

    local menu_items=()
    for i in "${!labels[@]}"; do
        tag=$((i + 1))
        menu_items+=("$tag" "${labels[i]}")
    done

    local choice
    choice=$(tui::show_menu "$title" "$prompt" "$ok_label" "$cancel_label" "${menu_items[@]}")
    local status="$?"

    if [ "$status" -ne 0 ]; then
        return 255
    fi

    local i=$((choice - 1))
    eval "${actions[i]}" 2>&1 | tee -a /dev/fd/3
}
