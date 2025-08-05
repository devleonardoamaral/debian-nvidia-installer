#!/usr/bin/env bash

# Verifica se o script está sendo executado com privilégios sudo
# Caso não, reexecuta o script como sudo
utils::force_sudo() {
    if [  "$(id -u)" -ne 0 ]; then
        log::warn "Este script requer privilégios de root."
        log::info "Solicitando privilégios de root..."
        exec sudo --preserve-env "$0" "$@"
        exit 1
    fi
}

# Busca por GPUs Nvidia no sistema
utils::fetch_nvidia_gpus() {
    lspci | grep -i "NVIDIA Corporation" | grep -iE "VGA|3D" \
        | sed -E 's/.*NVIDIA Corporation (.*)/\1/I'
}