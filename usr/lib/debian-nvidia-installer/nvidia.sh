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

declare -g NVIDIA_DRM_FILE="/sys/module/nvidia_drm/parameters/modeset"
declare -g NVIDIA_OPTIONS_DEBIAN="/etc/modprobe.d/nvidia-options.conf"
declare -g NVIDIA_OPTIONS_DEFAULT="/etc/modprobe.d/nvidia.conf"
declare -g NVIDIA_MODESET_CUDA="/etc/modprobe.d/nvidia-modeset.conf"

# Verifica se o driver NVIDIA está instalado
nvidia::is_driver_installed() {
    command -v nvidia-smi &>/dev/null
}

nvidia::get_source_alias() {
    origin_repo="$(apt-cache policy "nvidia-driver" | grep 'http' | head -n1 | awk '{print $2}')"

    case "$origin_repo" in
        *developer.download.nvidia.com* )
            echo "cuda"
            ;;
        *deb.debian.org* )
            echo "debian"
            ;;
        * )
            echo "unknown"
            ;;
    esac
}

nvidia::get_nvidia_module() {
    local source="$1"

    case "$1" in
        cuda )
            echo "nvidia"
            ;;
        debian )
            if packages::is_installed "nvidia-tesla-535-driver"; then
                echo "nvidia-tesla-535"
            else
                echo "nvidia-current"
            fi
            ;;
        * )
            echo "nvidia"
    esac
}

nvidia::get_modeset_file() {
    local source="$1"

    case "$1" in
        cuda )
            echo "$NVIDIA_MODESET_CUDA"
            ;;
        debian )
            echo "$NVIDIA_OPTIONS_DEBIAN"
            ;;
        * )
            echo "$NVIDIA_OPTIONS_DEFAULT"
    esac
}

nvidia::get_options_file() {
    local source="$1"

    case "$1" in
        cuda )
            echo "$NVIDIA_OPTIONS_DEFAULT"
            ;;
        debian )
            echo "$NVIDIA_OPTIONS_DEBIAN"
            ;;
        * )
            echo "$NVIDIA_OPTIONS_DEFAULT"
    esac
}

# Função para buscar GPUs NVIDIA usando lspci
nvidia::fetch_nvidia_gpus() {
    lspci | grep -i "NVIDIA Corporation" | grep -iE "VGA|3D" \
        | sed -E 's/.*NVIDIA Corporation (.*)/\1/I'
}

nvidia::remove_cuda_repo() {
    local dir="/etc/apt/sources.list.d"
    local file

    # Procura o arquivo do repositório CUDA para a arquitetura atual
    file="$(ls "$dir" | grep -E "^cuda-[^-]*-$(uname -m)\.list" | head -n 1)"

    if [[ -n "$file" ]]; then
        sudo rm -f "$dir/$file"
        echo "Removed CUDA repository: $dir/$file" >&2
    else
        echo "No CUDA repository found to remove." >&2
    fi
}

# Função para verficar se o DRM está habilitado
nvidia::is_drm_enabled() {
    local file="$NVIDIA_DRM_FILE"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local modeset
    modeset="$(cat "$file")"

    case "$modeset" in
        Y) echo 1 ;;
        N) echo 0 ;;
        *) return 1 ;;
    esac

    return 0
}

# Função para alterar ou adicionar uma opção específica no arquivo de configuração
nvidia::change_option() {
    local file="$1"
    local module="$2"
    local option="$3"
    local value="$4"

    module="$(utils::escape_chars "$2")"
    option="$(utils::escape_chars "$3")"
    value="$(utils::escape_chars "$4")"

    if [ ! -f "$file" ]; then
        echo "File not found: $file" >&2
        return 1
    fi

    # Se a linha com a opção já existir, altera
    if grep -Eq "^\s*options\s+${module}(\s+.*)?\b${option}=" "$file"; then
        sed -i -E "s/^(\s*options\s+${module}\s+.*)${option}=[^ ]*(.*)/\1${option}=${value}\2/" "$file"
        echo "Option $option changed to $value in $file" >&2
    else
        echo "" >> "$file"
        echo "options ${module} ${option}=${value}" >> "$file"
        echo "New options line added for $module in $file" >&2
    fi

    return 0    
}

# Função para obter o valor de uma opção específica do arquivo de configuração
nvidia::get_option() {
    local file="$1"
    local module="$2"
    local option="$3"

    if [ ! -f "$file" ]; then
        echo "File not found: $file" >&2
        return 2
    fi

    # Pega a primeira linha que contém o módulo e a opção
    local line
    line=$(grep -E "^\s*options\s+${module}(\s+|$).*${option}=" "$file" | head -n 1)

    # Regex para capturar o valor da opção (tudo até o próximo espaço ou final da linha)
    if [[ $line =~ ${option}=([^[:space:]]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    else
        echo "Option $option not found in $file" >&2
        return 1
    fi
}


# Função para desabilitar uma opção específica no arquivo de configuração
nvidia::disable_option() {
    nvidia::change_option "$1" "$2" "$3" "0"
}

# Função para habilitar uma opção específica no arquivo de configuração
nvidia::enable_option() {
    nvidia::change_option "$1" "$2" "$3" "1"
}

nvidia::enable_modeset() {
    nvidia::change_option "$(nvidia::get_options_file "$(nvidia::get_source_alias)")" "nvidia-drm" "modeset" "1"
}

# Função para obter a opção NVreg_PreserveVideoMemoryAllocations do arquivo de configuração
nvidia::get_pvma() {
    nvidia::get_option "$(nvidia::get_options_file "$(nvidia::get_source_alias)")" "$(nvidia::get_nvidia_module "$(nvidia::get_source_alias)")" "NVreg_PreserveVideoMemoryAllocations"
}

# Função para alterar a opção NVreg_PreserveVideoMemoryAllocations no arquivo de configuração
nvidia::change_option_pvma() {
    nvidia::change_option "$(nvidia::get_options_file "$(nvidia::get_source_alias)")" "$(nvidia::get_nvidia_module "$(nvidia::get_source_alias)")" "NVreg_PreserveVideoMemoryAllocations" "$1"
}

# Função para obter a opção NVreg_EnableS0ixPowerManagement do arquivo de configuração
nvidia::get_s0ixpm() {
    nvidia::get_option "$(nvidia::get_options_file "$(nvidia::get_source_alias)")" "$(nvidia::get_nvidia_module "$(nvidia::get_source_alias)")" "NVreg_EnableS0ixPowerManagement"
}

# Função para alterar a opção NVreg_EnableS0ixPowerManagement no arquivo de configuração
nvidia::change_option_s0ixpm() {
    nvidia::change_option "$(nvidia::get_options_file "$(nvidia::get_source_alias)")" "$(nvidia::get_nvidia_module "$(nvidia::get_source_alias)")" "NVreg_EnableS0ixPowerManagement" "$1"
}
