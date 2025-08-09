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
declare -g SCRIPT_LANG

# Lista de traduções (arrays associativos)
declare -A T_PT_BR=(
    # TUI Títulos
    ["tui.title.warn"]="ATENÇÃO"
    ["tui.title.main"]="DEBIAN NVIDIA INSTALLER"
    ["tui.title.extras"]="EXTRAS"

    # TUI Botões
    ["tui.button.ok"]="Ok"
    ["tui.button.confirm"]="Confirmar"
    ["tui.button.abort"]="Abortar"
    ["tui.button.cancel"]="Cancelar"
    ["tui.button.remove"]="Remover"
    ["tui.button.exit"]="Sair"

    # TUI Opções de Menu
    ["tui.menutitle.selectoption"]="Selecione uma opção:"
    ["tui.menutitle.selectflavor"]="Selecione um dos flavors para instalar:"

    ["tui.menuoption.installdrivers"]="Instalar Drivers"
    ["tui.menuoption.uninstalldrivers"]="Desinstalar Drivers"
    ["tui.menuoption.extras"]="Extras"
    ["tui.menuoption.installcuda"]="CUDA Toolkit"
    ["tui.menuoption.installoptix"]="OptiX"
    ["tui.menuoption.switchnvidiadrm"]="Nvidia DRM"
    ["tui.menuoption.switchpvma"]="Preserve Video Memory Allocations"    
    ["tui.menuoption.installproprietary"]="Driver Proprietário"
    ["tui.menuoption.installopen"]="Driver Open Source"

    # TUI yesno
    ["tui.yesno.proprietarydriver.confirm"]="Você está prestes a instalar o driver do flavor Proprietário da Nvidia.\n\nDeseja continuar?"
    ["tui.yesno.opendriver.confirm"]="Você está prestes a instalar o driver do flavor Open Source da Nvidia.\n\nDeseja continuar?"
    
    ["tui.yesno.installcuda.confirm"]="Você está prestes a instalar as bibliotecas Nvidia CUDA.\n\nDeseja continuar?"

    ["tui.yesno.installcuda.installlist"]="Os seguintes pacotes já estão instalados:\n\n"
    ["tui.yesno.installcuda.installlist.confirm"]="\n\nDeseja removê-los?"

    ["tui.yesno.uninstalloptix.confirm"]="O pacote %1 já está instalado.\n\nDeseja removê-lo?"
    ["tui.yesno.installoptix.confirm"]="Você está prestes a instalar as bibliotecas Nvidia OptiX.\n\nDeseja continuar?"

    ["tui.yesno.installer.secureboot.mok.create"]="Deseja configurar a chave MOK agora com o assistente?"

    ["tui.yesno.installer.nvidia.uninstall.confirm"]="Você está prestes a desinstalar o driver da Nvidia.\n\nDeseja continuar?"

    ["tui.yesno.extra.drm.activate.confirm"]="DRM da NVIDIA está desativado.\n\nDeseja ATIVÁ-LO?"
    ["tui.yesno.extra.drm.deactivate.confirm"]="DRM da NVIDIA está ativado.\n\nDeseja DESATIVÁ-LO?"

    ["tui.yesno.extra.pvma.activate.confirm"]="O recurso PreserveVideoMemoryAllocations está desativado.\n\nDeseja ATIVÁ-LO?"
    ["tui.yesno.extra.pvma.deactivate.confirm"]="O recurso PreserveVideoMemoryAllocations já está ativado.\n\nDeseja DESATIVÁ-LO?"

    # TUI msgbox
    ["tui.msgbox.restartrequired"]="Reinicie o sistema para que as alterações sejam aplicadas."

    ["tui.msgbox.installer.mok.password"]="Você precisará criar uma senha para a chave MOK.\n\nAnote essa senha com segurança, pois ela será exigida após reinicialização."

    ["tui.msgbox.installer.mok.sign"]="A chave MOK foi importada.\n\nReinicie o sistema e, no menu do MOK Manager:\n\n - Escolha: Enroll MOK\n - Confirme\n - Digite a senha\n - Continue o boot do sistema\n\nDepois disso, execute este script novamente."

    ["tui.msgbox.installer.secureboot.mok.missing"]="O Secure Boot está ativado, mas a chave MOK não está registrada.\n\nDrivers NVIDIA podem não funcionar corretamente sem assinatura de kernel."

    ["tui.msgbox.installer.secureboot.mok.abort"]="Configure a chave MOK manualmente ou desative o Secure Boot para continuar.\n\nConsulte:\nhttps://wiki.debian.org/SecureBoot"

    # Logs
    ["log.script.exit"]="Ecerrando script..."
    ["log.script.pause"]="Pressione ENTER para continuar..."

    ["log.install.success"]="Instalação concluída com sucesso."
    
    ["log.operation.canceled.byuser"]="Operação cancelada pelo usuário."
    ["log.operation.canceled.byfailure"]="Operação falhou."

    ["log.rootaccess.required"]="Privilégios root são requeridos."

    ["log.dependencies.verifying"]="Verificando e instalando dependências..."
    ["log.dependencies.ok"]="Todas as dependências estão instaladas."
    ["log.dependencies.failed"]="Falha ao instalar dependências."

    ["log.installer.update.start"]="Atualizando lista de pacotes..."
    ["log.installer.update.failure"]="Falha ao atualizar lista de pacotes."
    ["log.installer.update.success"]="Lista de pacotes atualizada com sucesso."

    ["log.installer.installpackage.verifying"]="Verificando pacote: %1"
    ["log.installer.installpackage.alreadyinstalled"]="Pacote %1 já instalado"
    ["log.installer.installpackage.skipping"]="Instalação ignorada."
    ["log.installer.installpackage.installing"]="Pacote %1 não instalado. Iniciando instalação..."
    ["log.installer.installpackage.success"]="Pacote %1 instalado com sucesso."
    ["log.installer.installpackage.failure"]="Falha na instalação do pacote %1."

    ["log.installer.removepackage.start"]="Removendo pacote %1..."
    ["log.installer.removepackage.success"]="Pacote %1 removido com sucesso."
    ["log.installer.removepackage.failue"]="Falha ao remover pacote %1."

    ["log.installer.install.nvidia.start"]="Instalando drivers da Nvidia..."
    ["log.installer.install.nvidia.verify.gpu.start"]="Procurando por GPUs Nvidia no sistema..."
    ["log.installer.install.nvidia.verify.gpu.found"]="GPUs Nvidia detectadas no sistema:"
    ["log.installer.install.nvidia.verify.gpu.notfound"]="Nenhuma GPU Nvidia detectada no sistema."

    ["log.installer.uninstall.nvidia.start"]="Desinstalando drivers da Nvidia..."
    ["log.installer.uninstall.nvidia.success"]="Desinstalação dos drivers da Nvidia concluída."

    ["log.installer.installprerequisites.unsupportedarch"]="Arquitetura não suportada: %1"
    ["log.installer.installprerequisites.start"]="Instalando pré-requisitos para %1..."
    ["log.installer.installprerequisites.success"]="Pré-requisitos instalados com sucesso."

    ["log.extra.drm.failure.notfound"]="O módulo nvidia_drm não está carregado ou o arquivo %1 não existe."

    ["log.installer.mok.start"]="Importando chave MOK..."
    ["log.installer.mok.sign"]="Chave MOK importada, aguarando assinatura no próximo boot."

    ["log.installer.secureboot.start"]="Verificando estado do Secure Boot..."
    ["log.installer.secureboot.mok.success"]="Chave MOK já está registrada. Nenhuma ação necessária."
    ["log.installer.secureboot.mok.failure"]="Chave MOK não encontrada ou não registrada"
    ["log.installer.secureboot.mok.isactivated"]="Secure Boot está ATIVADO."
    ["log.installer.secureboot.mok.isdeactivated"]="Secure Boot está DESATIVADO. Nenhuma ação necessária."

    ["log.extra.drm.status.on"]="DRM da NVIDIA está ATIVADO."
    ["log.extra.drm.status.off"]="DRM da NVIDIA está DESATIVADO."

    ["log.extra.drm.action.on"]="DRM da NVIDIA foi ATIVADO."
    ["log.extra.drm.action.off"]="DRM da NVIDIA foi DESATIVADO."

    ["log.extra.drm.action.write.add"]="Configuração \"%1\" adicionada ao arquivo %2"
    ["log.extra.drm.action.write.remove"]="Configuração \"%1\" removida do arquivo %2"

    ["log.config.write.add"]="Configuração \"%1\" adicionada ao arquivo %2"
    ["log.config.write.remove"]="Configuração \"%1\" removida do arquivo %2"

    ["log.extra.pvma.status.on"]="PreserveVideoMemoryAllocations está ATIVADO."
    ["log.extra.pvma.status.off"]="PreserveVideoMemoryAllocations está DESATIVADO."

    ["log.extra.pvma.action.on"]="PreserveVideoMemoryAllocations foi ATIVADO."
    ["log.extra.pvma.action.off"]="PreserveVideoMemoryAllocations foi DESATIVADO."
)

# Translation list (associative arrays)
declare -A T_EN=(
    # TUI Titles
    ["tui.title.warn"]="WARNING"
    ["tui.title.main"]="DEBIAN NVIDIA INSTALLER"
    ["tui.title.extras"]="EXTRAS"

    # TUI Buttons
    ["tui.button.ok"]="Ok"
    ["tui.button.confirm"]="Confirm"
    ["tui.button.abort"]="Abort"
    ["tui.button.cancel"]="Cancel"
    ["tui.button.remove"]="Remove"
    ["tui.button.exit"]="Exit"

    # TUI Menu Options
    ["tui.menutitle.selectoption"]="Select an option:"
    ["tui.menutitle.selectflavor"]="Select one of the flavors to install:"

    ["tui.menuoption.installdrivers"]="Install Drivers"
    ["tui.menuoption.uninstalldrivers"]="Uninstall Drivers"
    ["tui.menuoption.extras"]="Extras"
    ["tui.menuoption.installcuda"]="CUDA Toolkit"
    ["tui.menuoption.installoptix"]="OptiX"
    ["tui.menuoption.switchnvidiadrm"]="NVIDIA DRM"
    ["tui.menuoption.switchpvma"]="Preserve Video Memory Allocations"
    ["tui.menuoption.installproprietary"]="Proprietary Driver"
    ["tui.menuoption.installopen"]="Open Source Driver"

    # TUI yesno
    ["tui.yesno.proprietarydriver.confirm"]="You are about to install the NVIDIA Proprietary flavor driver.\n\nDo you want to continue?"
    ["tui.yesno.opendriver.confirm"]="You are about to install the NVIDIA Open Source flavor driver.\n\nDo you want to continue?"

    ["tui.yesno.installcuda.confirm"]="You are about to install the NVIDIA CUDA libraries.\n\nDo you want to continue?"

    ["tui.yesno.installcuda.installlist"]="The following packages are already installed:\n\n"
    ["tui.yesno.installcuda.installlist.confirm"]="\n\nDo you want to remove them?"

    ["tui.yesno.uninstalloptix.confirm"]="The package %1 is already installed.\n\nDo you want to remove it?"
    ["tui.yesno.installoptix.confirm"]="You are about to install the NVIDIA OptiX libraries.\n\nDo you want to continue?"

    ["tui.yesno.installer.secureboot.mok.create"]="Do you want to configure the MOK key now using the wizard?"

    ["tui.yesno.installer.nvidia.uninstall.confirm"]="You are about to uninstall the NVIDIA driver.\n\nDo you want to continue?"

    ["tui.yesno.extra.drm.activate.confirm"]="NVIDIA DRM is disabled.\n\nDo you want to ENABLE it?"
    ["tui.yesno.extra.drm.deactivate.confirm"]="NVIDIA DRM is enabled.\n\nDo you want to DISABLE it?"

    ["tui.yesno.extra.pvma.activate.confirm"]="The PreserveVideoMemoryAllocations feature is currently disabled.\n\nDo you want to ENABLE it?"
    ["tui.yesno.extra.pvma.deactivate.confirm"]="The PreserveVideoMemoryAllocations feature is currently enabled.\n\nDo you want to DISABLE it?"

    # TUI msgbox
    ["tui.msgbox.restartrequired"]="Restart the system for the changes to take effect."

    ["tui.msgbox.installer.mok.password"]="You will need to create a password for the MOK key.\n\nWrite this password down safely, as it will be required after reboot."

    ["tui.msgbox.installer.mok.sign"]="The MOK key has been imported.\n\nRestart the system and, in the MOK Manager menu:\n\n - Choose: Enroll MOK\n - Confirm\n - Enter the password\n - Continue system boot\n\nAfter that, run this script again."

    ["tui.msgbox.installer.secureboot.mok.missing"]="Secure Boot is enabled, but the MOK key is not registered.\n\nNVIDIA drivers may not work properly without kernel signing."

    ["tui.msgbox.installer.secureboot.mok.abort"]="Configure the MOK key manually or disable Secure Boot to continue.\n\nSee:\nhttps://wiki.debian.org/SecureBoot"

    # Logs
    ["log.script.exit"]="Exiting script..."
    ["log.script.pause"]="Press ENTER to continue..."

    ["log.install.success"]="Installation completed successfully."

    ["log.operation.canceled.byuser"]="Operation canceled by user."
    ["log.operation.canceled.byfailure"]="Operation failed."

    ["log.rootaccess.required"]="Root privileges are required."

    ["log.dependencies.verifying"]="Checking and installing dependencies..."
    ["log.dependencies.ok"]="All dependencies are installed."
    ["log.dependencies.failed"]="Failed to install dependencies."

    ["log.installer.update.start"]="Updating package list..."
    ["log.installer.update.failure"]="Failed to update package list."
    ["log.installer.update.success"]="Package list updated successfully."

    ["log.installer.installpackage.verifying"]="Checking package: %1"
    ["log.installer.installpackage.alreadyinstalled"]="Package %1 is already installed"
    ["log.installer.installpackage.skipping"]="Installation skipped."
    ["log.installer.installpackage.installing"]="Package %1 not installed. Starting installation..."
    ["log.installer.installpackage.success"]="Package %1 installed successfully."
    ["log.installer.installpackage.failure"]="Failed to install package %1."

    ["log.installer.removepackage.start"]="Removing package %1..."
    ["log.installer.removepackage.success"]="Package %1 removed successfully."
    ["log.installer.removepackage.failue"]="Failed to remove package %1."

    ["log.installer.install.nvidia.start"]="Installing NVIDIA drivers..."
    ["log.installer.install.nvidia.verify.gpu.start"]="Searching for NVIDIA GPUs in the system..."
    ["log.installer.install.nvidia.verify.gpu.found"]="NVIDIA GPUs detected in the system:"
    ["log.installer.install.nvidia.verify.gpu.notfound"]="No NVIDIA GPUs detected in the system."

    ["log.installer.uninstall.nvidia.start"]="Uninstalling NVIDIA drivers..."
    ["log.installer.uninstall.nvidia.success"]="NVIDIA drivers uninstalled successfully."

    ["log.installer.installprerequisites.unsupportedarch"]="Unsupported architecture: %1"
    ["log.installer.installprerequisites.start"]="Installing prerequisites for %1..."
    ["log.installer.installprerequisites.success"]="Prerequisites installed successfully."

    ["log.extra.drm.failure.notfound"]="The nvidia_drm module is not loaded or the file %1 does not exist."

    ["log.installer.mok.start"]="Importing MOK key..."
    ["log.installer.mok.sign"]="MOK key imported, awaiting signing on next boot."

    ["log.installer.secureboot.start"]="Checking Secure Boot status..."
    ["log.installer.secureboot.mok.success"]="MOK key is already registered. No action needed."
    ["log.installer.secureboot.mok.failure"]="MOK key not found or not registered."
    ["log.installer.secureboot.mok.isactivated"]="Secure Boot is ENABLED."
    ["log.installer.secureboot.mok.isdeactivated"]="Secure Boot is DISABLED. No action needed."

    ["log.extra.drm.status.on"]="NVIDIA DRM is ENABLED."
    ["log.extra.drm.status.off"]="NVIDIA DRM is DISABLED."

    ["log.extra.drm.action.on"]="NVIDIA DRM has been ENABLED."
    ["log.extra.drm.action.off"]="NVIDIA DRM has been DISABLED."

    ["log.extra.drm.action.write.add"]="Configuration \"%1\" added to file %2"
    ["log.extra.drm.action.write.remove"]="Configuration \"%1\" removed from file %2"

    ["log.config.write.add"]="Configuration \"%1\" added to file %2"
    ["log.config.write.remove"]="Configuration \"%1\" removed from file %2"

    ["log.extra.pvma.status.on"]="PreserveVideoMemoryAllocations is ENABLED."
    ["log.extra.pvma.status.off"]="PreserveVideoMemoryAllocations is DISABLED."

    ["log.extra.pvma.action.on"]="PreserveVideoMemoryAllocations has been ENABLED."
    ["log.extra.pvma.action.off"]="PreserveVideoMemoryAllocations has been DISABLED."
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
        *) echo "${T_EN[$key]:-$key}" ;;
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