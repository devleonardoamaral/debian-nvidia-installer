#!/usr/bin/env bash

# NAVIGATION_STATUS 0 : Navegação encerrada
# NAVIGATION_STATUS 1 : Navegação em andamento
declare -ig NAVIGATION_STATUS=1

# Configurações globais do Dialog
DIALOG_OPTS=(
    --clear
    --keep-tite
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
tui::show_msgbox() {
    local title="$1"
    local message="$2"
    local ok_label="${3:-OK}"

    dialog "${DIALOG_OPTS[@]}" \
           --no-cancel \
           --stdout \
           --title "$title" \
           --ok-label "$ok_label" \
           --msgbox "$message" \
           15 60

    return $?
}

# Caixa de dialogo de dupla escolha
tui::show_yesno() {
    local title="$1"
    local message="$2"
    local yes_label="${3:-Sim}"
    local no_label="${4:-Não}"

    dialog "${DIALOG_OPTS[@]}" \
           --stdout \
           --title "$title" \
           --yes-label "$yes_label" \
           --no-label "$no_label" \
           --yesno "$message" 15 50

    return $?
}