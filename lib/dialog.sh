#!/usr/bin/env bash

# Configurações globais do Dialog
DIALOG_OPTS=(
    --clear
    --keep-tite
    --colors
)

# Menu com multiplas escolhas sem botão de cancelamento
tui::show_menu() {
    local title="$1"
    local prompt="$2"
    shift 2
    local menu_items=("$@")
    
    dialog "${DIALOG_OPTS[@]}" \
           --no-cancel \
           --stdout \
           --title "$title" \
           --menu "$prompt" \
           15 50 10 \
           "${menu_items[@]}"

    return $?
}

# Caixa de dialogo sem botão de cancelamento
tui::show_dialog() {
    local title="$1"
    local message="$2"
    local ok_label="${3:-OK}"

    dialog "${DIALOG_OPTS[@]}" \
           --no-cancel \
           --stdout \
           --title "$title" \
           --ok-label "$ok_label" \
           --msgbox "$message" \
           15 50

    return $?
}