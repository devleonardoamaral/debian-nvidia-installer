#!/usr/bin/env bash


installer::install_nvidia() {
    log::info "Iniciando instalação dos drivers Nvidia..."
    
    local nvidia_gpus

    log::info "Procurando por GPUs Nvidia no sistema..."
    nvidia_gpus="$(utils::fetch_nvidia_gpus)"

    if [[ -n "$nvidia_gpus" ]]; then
        log::info "GPUs Nvidia detectadas no sistema:"

        while IFS= read -r line; do
            log::info "\t - ${line}"
        done <<< "$nvidia_gpus"
    else
        log::error "Nenhuma GPU Nvidia detectada no sistema."
        tui::show_dialog "Aviso" "Nenhuma GPU Nvidia detectada no sistema." "Abortar"
        NAV_RESTART=0
        return 1 # encerra a função antes de continuar
    fi

    tui::navigate::flavors
    return 0
}

installer::install_nvidia_open() {
    tui::show_dialog "Aviso" "Iniciando instalação dos Drivers Open da NVIDIA" "Continuar"
}

installer::install_nvidia_proprietary() {
    tui::show_dialog "Aviso" "Iniciando instalação dos Drivers Proprietary da NVIDIA" "Continuar"
}

installer::uninstall_nvidia() {
    tui::show_dialog "Aviso" "Iniciando desinstalação dos Drivers NVIDIA" "Continuar"
}