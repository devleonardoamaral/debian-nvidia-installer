#!/usr/bin/env bash

tui::menu::main() {
    local choice
    choice=$(tui::show_menu "MENU PRINCIPAL" "Escolha uma ação:" \
            1 "Instalar Drivers" \
            2 "Desinstalar Drivers" \
            3 "Extras" \
            4 "Sair")
    echo "${choice:-4}"
}

tui::menu::extras() {
    local choice
    choice=$(tui::show_menu "EXTRAS" "Selecione uma opção:" \
            1 "Instalar/Desinstalar CUDA" \
            2 "Instalar/Desinstalar OptiX" \
            3 "Ativar/Desativar Nvidia DRM" \
            4 "Ativar/Desativar PreserveVideoMemoryAllocations" \
            5 "Voltar")
    echo "${choice:-5}"
}

tui::menu::flavors() {
    local choice
    choice=$(tui::show_menu "INSTALAÇÃO NVIDIA" "Selecione um dos flavors para instalar:" \
    1 "Driver Proprietário" \
    2 "Driver Open Source" \
    3 "Voltar")

    echo "${choice:-3}"
}