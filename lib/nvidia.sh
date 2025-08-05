#!/usr/bin/env bash

# Busca por GPUs Nvidia no sistema
nvidia::fetch_nvidia_gpus() {
    lspci | grep -i "NVIDIA Corporation" | grep -iE "VGA|3D" \
        | sed -E 's/.*NVIDIA Corporation (.*)/\1/I'
}