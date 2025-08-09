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

# Idioma atual detectado
declare -g SCRIPT_LANG="en_US"

# Lista de traduções (arrays associativos)
declare -A T_PT_BR=(
    # TUI Títulos
    ["tui.menutitle.selectoption"]="Selecione uma opção:"

    # TUI Botões
    ["tui.ok"]="Ok"
    ["tui.confirm"]="Confirmar"
    ["tui.abort"]="Abortar"
    ["tui.cancel"]="Cancelar"
    ["tui.exit"]="Sair"

    # TUI Main
    ["tui.title.main"]="DEBIAN NVIDIA INSTALLER"
    ["tui.install.drivers"]="Instalar Drivers"
    ["tui.uninstall.drivers"]="Desinstalar Drivers"
    ["tui.extras"]="Extras"

    # TUI Extras
    ["tui.title.extras"]="EXTRAS"
    ["tui.install.cuda"]="CUDA Toolkit"
    ["tui.install.optix"]="OptiX"
    ["tui.switch.nvidiadrm"]="Nvidia DRM"
    ["tui.switch.pvma"]="Preserve Video Memory Allocations"

    # TUI Flavors
    ["tui.menutitle.selectflavor"]="Selecione um dos flavors para instalar:"
    ["tui.install.proprietary"]="Driver Proprietário"
    ["tui.install.open"]="Driver Open Source"    

    # Logs
    ["log.script.exit"]="Ecerrando script..."
    ["log.script.pause"]="Pressione ENTER para continuar..."
    
    ["log.rootaccess.required"]="Privilégios root são requeridos."
    ["log.dependencies.verifying"]="Verificando e instalando dependências..."
    ["log.dependencies.ok"]="Todas as dependências estão instaladas."
    ["log.dependencies.failed"]="Falha ao instalar dependências."

    ["log.operation.canceled.byuser"]="Operação cancelada pelo usuário."
    ["log.operation.canceled.byfailure"]="Operação falhou."

    ["log.installer.update.start"]="Atualizando lista de pacotes..."
    ["log.installer.update.failure"]="Falha ao atualizar lista de pacotes."
    ["log.installer.update.success"]="Lista de pacotes atualizada."

    ["log.installer.installpackage.verifying"]="Verificando pacote: %1"
    ["log.installer.installpackage.skipping"]="Pacote %1 já instalado. Instalação ignorada."
    ["log.installer.installpackage.installing"]="Pacote %1 não instalado. Iniciando instalação..."
    ["log.installer.installpackage.success"]="Pacote %1 instalado com sucesso."
    ["log.installer.installpackage.failure"]="Falha na instalação de %1."

    ["log.installer.removepackage.start"]="Removendo pacote %1..."
    ["log.installer.removepackage.success"]="Pacote %1 removido com sucesso."
    ["log.installer.removepackage.failue"]="Falha ao remover pacote %1."
)

# Translation list (associative arrays)
declare -A T_EN=(
    # TUI Titles
    ["tui.menutitle.selectoption"]="Select an option:"

    # TUI Buttons
    ["tui.ok"]="Ok"
    ["tui.confirm"]="Confirm"
    ["tui.abort"]="Abort"
    ["tui.cancel"]="Cancel"
    ["tui.exit"]="Exit"

    # TUI Main
    ["tui.title.main"]="DEBIAN NVIDIA INSTALLER"
    ["tui.install.drivers"]="Install Drivers"
    ["tui.uninstall.drivers"]="Uninstall Drivers"
    ["tui.extras"]="Extras"

    # TUI Extras
    ["tui.title.extras"]="EXTRAS"
    ["tui.install.cuda"]="CUDA Toolkit"
    ["tui.install.optix"]="OptiX"
    ["tui.switch.nvidiadrm"]="Nvidia DRM"
    ["tui.switch.pvma"]="Preserve Video Memory Allocations"

    # TUI Flavors
    ["tui.menutitle.selectflavor"]="Select one of the flavors to install:"
    ["tui.install.proprietary"]="Proprietary Driver"
    ["tui.install.open"]="Open Source Driver"

    # Logs
    ["log.script.exit"]="Exiting script..."
    ["log.script.pause"]="Press ENTER to continue..."
    
    ["log.rootaccess.required"]="Root privileges are required."
    ["log.dependencies.verifying"]="Checking and installing dependencies..."
    ["log.dependencies.ok"]="All dependencies are installed."
    ["log.dependencies.failed"]="Failed to install dependencies."

    ["log.operation.canceled.byuser"]="Operation canceled by the user."
    ["log.operation.canceled.byfailure"]="Operation failed."

    ["log.installer.update.start"]="Updating package list..."
    ["log.installer.update.failure"]="Failed to update package list."
    ["log.installer.update.success"]="Package list updated."

    ["log.installer.installpackage.verifying"]="Verifying package: %1"
    ["log.installer.installpackage.skipping"]="Package %1 already installed. Skipping installation."
    ["log.installer.installpackage.installing"]="Package %1 not installed. Starting installation..."
    ["log.installer.installpackage.success"]="Package %1 installed successfully."
    ["log.installer.installpackage.failure"]="Failed to install %1."

    ["log.installer.removepackage.start"]="Removing package %1..."
    ["log.installer.removepackage.success"]="Package %1 removed successfully."
    ["log.installer.removepackage.failue"]="Failed to remove package %1."
)


# Detecta idioma do sistema operacional.
tr::detect_language() {
    local sys_lang="${LANG%%.*}"  # Remove .UTF-8 e afins
    case "$sys_lang" in
        pt_BR) SCRIPT_LANG="pt_BR" ;;
        en_US) SCRIPT_LANG="en_US" ;;
        *)     SCRIPT_LANG="en_US" ;;  # padrão
    esac
}

# Retorna a tradução da chave na linguagem atual ou a própria chave se não existir.
tr::t() {
    local key="$1"
    case "$SCRIPT_LANG" in
        pt_BR) echo "${T_PT_BR[$key]:-$key}" ;;
        en_US) echo "${T_EN[$key]:-$key}" ;;
    esac
}

# Retorna a tradução da chave substituindo os placeholders %1, %2, ... pelos argumentos.
tr::t_args() {
    local string
    string="$(tr::t "$1")"
    shift

    local counter=1
    for argv in "$@"; do
        string="${string//%$counter/$argv}"
        (( counter++ ))
    done

    echo "$string"
}