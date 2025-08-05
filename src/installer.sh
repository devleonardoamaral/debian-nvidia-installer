#!/usr/bin/env bash

installer::install_package() {
    local pkg="$1"

    log::info "Verificando pacote: $pkg..."
    
    # Verifica se o pacote já está instalado antes de continuar
    if packages::is_installed "$pkg"; then
        log::info "Pacote $pkg já instalado. Instalação ignorada."
        return 0
    fi

    log::info "Pacote $pkg não encontrado no sistema. Iniciando instalação..."

    # Tenta atualizar, mas continua mesmo se falhar
    packages::update || log::warn "Continuando com lista de pacotes desatualizada."

    # Caso de sucesso na instalação
    if packages::install "$pkg"; then
        log::info "Pacote $pkg instalado com sucesso."
        return 0
    fi
    
    # Caso de falha na instalação
    log::error "Falha na instalação de $pkg."
    return 1
}

installer::install_nvidia_open() {
    tui::show_dialog "Aviso" "Iniciando instalação dos Drivers Open da NVIDIA" "Continuar"
}

installer::install_nvidia_proprietary() {
    tui::show_dialog "Aviso" "Iniciando instalação dos Drivers Proprietary da NVIDIA" "Continuar"
}

installer::install_nvidia() {
    log::info "Iniciando instalação dos drivers Nvidia..."
    
    local nvidia_gpus

    log::info "Procurando por GPUs Nvidia no sistema..."
    nvidia_gpus="$(nvidia::fetch_nvidia_gpus)"

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

installer::uninstall_nvidia() {
    tui::show_dialog "Aviso" "Iniciando desinstalação dos Drivers NVIDIA" "Continuar"
}