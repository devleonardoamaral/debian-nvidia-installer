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

installer::install_package() {
    local pkg="$1"

    log::info "$(tr::t_args "installer::install_package.verifying" "$pkg")"
    
    # Verifica se o pacote já está instalado antes de continuar
    if packages::is_installed "$pkg"; then
        log::info "$(tr::t_args "installer::install_package.missing" "$pkg")"
        return 0
    fi

    log::info "$(tr::t_args "installer::install_package.install.start" "$pkg")"
    log::info "$(tr::t "installer::install_package.update.start")"

    # Tenta atualizar, mas continua mesmo se falhar
    if packages::update; then
        log::info "$(tr::t "installer::install_package.update.success")"
    else
        log::warn "$(tr::t "installer::install_package.update.failure")"
    fi

    # Caso de sucesso na instalação
    if packages::install "$pkg"; then
        log::info "$(tr::t_args "installer::install_package.install.success" "$pkg")"
        return 0
    fi
    
    # Caso de falha na instalação
    log::error "$(tr::t_args "installer::install_package.install.failure" "$pkg")"
    return 1
}

tr::add "pt_BR" "installer::install_package.verifying" "Verificando se o pacote está instalado..."
tr::add "pt_BR" "installer::install_package.missing" "O pacote já está instalado."
tr::add "pt_BR" "installer::install_package.install.start" "Iniciando a instalação do pacote: %1"
tr::add "pt_BR" "installer::install_package.update.start" "Iniciando a atualização dos repositórios..."
tr::add "pt_BR" "installer::install_package.update.success" "Repositórios atualizados com sucesso."
tr::add "pt_BR" "installer::install_package.update.failure" "Falha ao atualizar os repositórios."
tr::add "pt_BR" "installer::install_package.install.success" "Pacote %1 instalado com sucesso."
tr::add "pt_BR" "installer::install_package.install.failure" "Falha ao instalar o pacote %1."

tr::add "en_US" "installer::install_package.verifying" "Verifying if the package is installed..."
tr::add "en_US" "installer::install_package.missing" "The package is already installed."
tr::add "en_US" "installer::install_package.install.start" "Starting installation of package: %1"
tr::add "en_US" "installer::install_package.update.start" "Starting repository update..."
tr::add "en_US" "installer::install_package.update.success" "Repositories updated successfully."
tr::add "en_US" "installer::install_package.update.failure" "Failed to update repositories."
tr::add "en_US" "installer::install_package.install.success" "Package %1 installed successfully."
tr::add "en_US" "installer::install_package.install.failure" "Failed to install package %1."

installer::remove_package() {
    local pkg="$1"

    log::info "$(tr::t_args "installer::remove_package.start" "$pkg")"

    if ! packages::remove "$pkg"; then
        log::error "$(tr::t_args "installer::remove_package.failue" "$pkg")"
        return 1
    fi

    log::info "$(tr::t_args "installer::remove_package.success" "$pkg")"
    return 0
}

tr::add "pt_BR" "installer::remove_package.start" "Iniciando a remoção do pacote: %1"
tr::add "pt_BR" "installer::remove_package.failue" "Falha ao remover o pacote %1."
tr::add "pt_BR" "installer::remove_package.success" "Pacote %1 removido com sucesso."

tr::add "en_US" "installer::remove_package.start" "Starting removal of package: %1"
tr::add "en_US" "installer::remove_package.failue" "Failed to remove package %1."
tr::add "en_US" "installer::remove_package.success" "Package %1 removed successfully."

installer::install_nvidia_proprietary() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_nvidia_proprietary.tui.yesno.proprietarydriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! installer::install_package "nvidia-kernel-dkms"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi
    
    log::info "$(tr::t "installer::install_nvidia_proprietary.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_nvidia_proprietary.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
    return 0
}

tr::add "pt_BR" "installer::install_nvidia_proprietary.tui.yesno.proprietarydriver.confirm" "Você está prestes a instalar o driver proprietário da NVIDIA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_nvidia_proprietary.success" "Driver NVIDIA Proprietário instalado com sucesso."

tr::add "en_US" "installer::install_nvidia_proprietary.tui.yesno.proprietarydriver.confirm" "You are about to install the proprietary NVIDIA driver.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_nvidia_proprietary.success" "Proprietary NVIDIA Driver installed successfully."

installer::install_nvidia_open() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_nvidia_open.tui.yesno.opendriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! installer::install_package "nvidia-open-kernel-dkms"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi
    
    log::info "$(tr::t "installer::install_nvidia_open.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_nvidia_open.success")"
    tui::msgbox::need_restart
    return 0
}

tr::add "pt_BR" "installer::install_nvidia_open.tui.yesno.opendriver.confirm" "Você está prestes a instalar o driver Open Source da NVIDIA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_nvidia_open.success" "Driver NVIDIA Open Source instalado com sucesso."

tr::add "en_US" "installer::install_nvidia_open.tui.yesno.opendriver.confirm" "You are about to install the Open Source NVIDIA driver.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_nvidia_open.success" "Open Source NVIDIA Driver installed successfully."

installer::install_pre_requisites() {
    local ARCH KERNEL VERSION HEADER_PKG
    ARCH=$(uname -m)
    KERNEL=$(uname -r)

    # Define o nome do pacote de cabeçalho do kernel com base na arquitetura
    case "$ARCH" in
        "i386"|"i686")
            if [[ "$KERNEL" == *"686-pae"* ]]; then
                HEADER_PKG="linux-headers-686-pae"
            else
                HEADER_PKG="linux-headers-686"
            fi
            ;;
        "x86_64")
            # Adiciona suporte para arquitetura i386 em sistemas de 64 bits
            # Importante para o driver da nvidia adicionar bibliotecas de 32 bits que alguns pacotes podem precisar
            log::info "$(tr::t "installer::install_pre_requisites.architecture.check.i386.start")"
            if util::multiarch::check "i386"; then
                log::info "$(tr::t "installer::install_pre_requisites.architecture.check.i386.success")"
            else
                log::info "$(tr::t "installer::install_pre_requisites.architecture.add.i386.start")"
                dpkg --add-architecture i386 || \
                    log::error "$(tr::t "installer::install_pre_requisites.architecture.add.i386.failure")"
            fi

            HEADER_PKG="linux-headers-amd64"
            ;;
        *)
            log::critical "$(tr::t_args "installer::install_pre_requisites.unsupported_arch" "$ARCH")"
            tui::msgbox::error "$(tr::t_args "installer::install_pre_requisites.unsupported_arch" "$ARCH")" "$(tr::t "default.tui.button.abort")"
            script::exit
            ;;
    esac

    if ! packages::check_sources_components "" "contrib" "non-free" "non-free-firmware"; then
        log::info "$(tr::t "installer::install_pre_requisites.check.sources.missing")"
        if ! packages::add_sources_components "" "contrib" "non-free" "non-free-firmware"; then
            log::info "$(tr::t "installer::install_pre_requisites.check.sources.failure")"
            log::critical "$(tr::t "default.script.canceled.byfailure")"
            return 1
        fi
    fi

    log::info "$(tr::t "installer::install_pre_requisites.check.sources.success")"
    log::info "$(tr::t_args "installer::install_pre_requisites.install.start" "$HEADER_PKG")"

    if ! installer::install_package "$HEADER_PKG"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        return 1
    fi
    
    log::info "$(tr::t "installer::install_pre_requisites.install.success")"

    return 0
}

tr::add "pt_BR" "installer::install_pre_requisites.unsupported_arch" "Arquitetura %1 não suportada."
tr::add "pt_BR" "installer::install_pre_requisites.check.sources.missing" "Componentes 'contrib', 'non-free' e 'non-free-firmware' não encontrados no sources.list."
tr::add "pt_BR" "installer::install_pre_requisites.check.sources.failure" "Falha ao adicionar componentes ao sources.list."
tr::add "pt_BR" "installer::install_pre_requisites.check.sources.success" "Componentes 'contrib', 'non-free' e 'non-free-firmware' habilitados no sources.list."
tr::add "pt_BR" "installer::install_pre_requisites.install.start" "Iniciando a instalação do pacote de cabeçalho do kernel: %1"
tr::add "pt_BR" "installer::install_pre_requisites.install.success" "Pacote de cabeçalho do kernel instalado com sucesso."
tr::add "pt_BR" "installer::install_pre_requisites.architecture.check.i386.start" "Verificando suporte para arquitetura i386..."
tr::add "pt_BR" "installer::install_pre_requisites.architecture.check.i386.success" "Arquitetura i386 já habilitada."
tr::add "pt_BR" "installer::install_pre_requisites.architecture.add.i386.failure" "Falha ao adicionar suporte para arquitetura i386."
tr::add "pt_BR" "installer::install_pre_requisites.architecture.add.i386.start" "Adicionando suporte para arquitetura i386."

tr::add "en_US" "installer::install_pre_requisites.unsupported_arch" "Unsupported architecture: %1."
tr::add "en_US" "installer::install_pre_requisites.check.sources.missing" "Components 'contrib', 'non-free' and 'non-free-firmware' not found in sources.list."
tr::add "en_US" "installer::install_pre_requisites.check.sources.failure" "Failed to add components to sources.list."
tr::add "en_US" "installer::install_pre_requisites.check.sources.success" "Components 'contrib', 'non-free' and 'non-free-firmware' enabled in sources.list."
tr::add "en_US" "installer::install_pre_requisites.install.start" "Starting installation of kernel header package: %1"
tr::add "en_US" "installer::install_pre_requisites.install.success" "Kernel header package installed successfully."
tr::add "en_US" "installer::install_pre_requisites.architecture.check.i386.start" "Checking support for i386 architecture..."
tr::add "en_US" "installer::install_pre_requisites.architecture.check.i386.success" "i386 architecture already enabled."
tr::add "en_US" "installer::install_pre_requisites.architecture.add.i386.failure" "Failed to add support for i386 architecture."
tr::add "en_US" "installer::install_pre_requisites.architecture.add.i386.start" "Adding support for i386 architecture."

installer::setup_mok() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    # Instala o pacote dkms com abstração
    if ! installer::install_package "dkms"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Avisa o usuário sobre a criação da senha do MOK
    tui::msgbox::warn "$(tr::t "installer::setup_mok.password")"

    # Gera a chave MOK
    if ! dkms generate_mok; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Importa a chave MOK
    log::info "$(tr::t "installer::setup_mok.importing")"
    if ! mokutil --import "$mok_pub_path"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    log::success "$(tr::t "installer::setup_mok.success")"
    tui::msgbox::warn "$(tr::t "installer::setup_mok.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
    script::exit "$(tr::t "installer::setup_mok.restart_required")" 0 # Encerra o script com mensagem de reinicialização
}

tr::add "pt_BR" "installer::setup_mok.password" "Você precisará criar uma senha para o MOK (Machine Owner Key) agora.\n\nCertifique-se de lembrar dessa senha, pois ela será necessária daqui a pouco para completar a instalação do driver NVIDIA."
tr::add "pt_BR" "installer::setup_mok.importing" "Importando a chave MOK..."
tr::add "pt_BR" "installer::setup_mok.success" "Chave MOK importada com sucesso."
tr::add "pt_BR" "installer::setup_mok.restart_required" "Reinicie o sistema para completar a configuração do MOK."

tr::add "en_US" "installer::setup_mok.password" "You will need to create a password for the MOK (Machine Owner Key) now.\n\nMake sure to remember this password, as it will be required shortly to complete the NVIDIA driver installation."
tr::add "en_US" "installer::setup_mok.importing" "Importing MOK key..."
tr::add "en_US" "installer::setup_mok.success" "MOK key imported successfully."
tr::add "en_US" "installer::setup_mok.restart_required" "Please restart the system to complete MOK setup."

installer::check_secure_boot() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    log::info "$(tr::t "log.installer.secureboot.start")"

    # Verifica se mokutil está disponível, senão tenta instalar
    if ! command -v mokutil &>/dev/null; then
        if ! installer::install_package "mokutil"; then
            log::critical "$(tr::t "default.script.canceled.byfailure")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
        fi
    fi

    # Verifica se o Secure Boot está ativado e se a chave MOK já está registrada
    if mokutil --sb-state | grep -q "enabled"; then
        log::info "$(tr::t "installer::check_secure_boot.enabled")"

        if [[ -f "$mok_pub_path" ]] && mokutil --test-key "$mok_pub_path" | grep -q "is already enrolled"; then
            log::info "$(tr::t "installer::check_secure_boot.mok.already_enrolled")"
            return 0
        fi

        log::warning "$(tr::t "installer::check_secure_boot.mok.missing")"
        tui::msgbox::warn "$(tr::t "installer::check_secure_boot.mok.missing")"

        if tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::check_secure_boot.mok.prompt")"; then
            installer::setup_mok || {
                log::critical "$(tr::t "installer::check_secure_boot.mok.setup.failure")"
                script::exit "" 1
            }
        else
            log::info "$(tr::t "default.script.canceled.byuser")"
            tui::msgbox::warn "$(tr::t "installer::check_secure_boot.mok.abortedbyuser")"
            return 1
        fi
    else
        log::info "$(tr::t "installer::check_secure_boot.disabled")"
    fi

    return 0
}

tr::add "pt_BR" "log.installer.secureboot.start" "Iniciando verificação do Secure Boot..."
tr::add "pt_BR" "installer::check_secure_boot.enabled" "Secure Boot está ATIVADO."
tr::add "pt_BR" "installer::check_secure_boot.mok.already_enrolled" "Chave MOK já registrada."
tr::add "pt_BR" "installer::check_secure_boot.mok.missing" "Chave MOK não registrada. É necessário registrá-la para continuar."
tr::add "pt_BR" "installer::check_secure_boot.mok.prompt" "Você precisa registrar a chave MOK (Machine Owner Key) para continuar.\n\nDeseja registrar agora?"
tr::add "pt_BR" "installer::check_secure_boot.mok.setup.failure" "Falha ao configurar a chave MOK."
tr::add "pt_BR" "installer::check_secure_boot.mok.abortedbyuser" "Configuração da chave MOK abortada pelo usuário.\n\nNão será possível continuar a instalação do driver NVIDIA sem registrar a chave MOK, reinicie o script para tentar novamente ou assine a chave MOK manualmente.\n\nConsulte: https://wiki.debian.org/SecureBoot#MOK_-_Machine_Owner_Key"
tr::add "pt_BR" "installer::check_secure_boot.disabled" "Secure Boot está DESATIVADO. Você pode continuar sem registrar a chave MOK."

tr::add "en_US" "log.installer.secureboot.start" "Starting Secure Boot check..."
tr::add "en_US" "installer::check_secure_boot.enabled" "Secure Boot is ENABLED."
tr::add "en_US" "installer::check_secure_boot.mok.already_enrolled" "MOK key already enrolled."
tr::add "en_US" "installer::check_secure_boot.mok.missing" "MOK key not enrolled. You need to enroll it to continue."
tr::add "en_US" "installer::check_secure_boot.mok.prompt" "You need to enroll the MOK (Machine Owner Key) to continue.\n\nDo you want to enroll now?"
tr::add "en_US" "installer::check_secure_boot.mok.setup.failure" "Failed to set up MOK key."
tr::add "en_US" "installer::check_secure_boot.mok.abortedbyuser" "MOK key setup aborted by user.\n\nYou will not be able to continue the NVIDIA driver installation without enrolling the MOK key, please restart the script to try again or manually enroll the MOK key.\n\nSee: https://wiki.debian.org/SecureBoot#MOK_-_Machine_Owner_Key"
tr::add "en_US" "installer::check_secure_boot.disabled" "Secure Boot is DISABLED. You can continue without enrolling the MOK key."

# Função principal para instalação do driver NVIDIA
installer::install_nvidia() {
    log::info "$(tr::t "installer::install_nvidia.start")"
    
    local nvidia_gpus

    log::info "$(tr::t "installer::install_nvidia.verify.gpu.start")"
    nvidia_gpus="$(nvidia::fetch_nvidia_gpus)"

    if [[ -n "$nvidia_gpus" ]]; then
        log::info "$(tr::t "installer::install_nvidia.verify.gpu.found")"

        while IFS= read -r line; do
            log::info "\t - ${line}"
        done <<< "$nvidia_gpus"

        tui::msgbox::custom "$(tr::t "installer::install_nvidia.verify.gpu.msgbox.title")" "$nvidia_gpus"
    else
        log::error "$(tr::t "installer::install_nvidia.verify.gpu.not_found")"
        tui::msgbox::warn "$(tr::t "installer::install_nvidia.verify.gpu.not_found")"
        return 1
    fi

    if ! (installer::install_pre_requisites && installer::check_secure_boot); then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    tui::navigate::flavors
}

tr::add "pt_BR" "installer::install_nvidia.start" "Iniciando a instalação do driver NVIDIA..."
tr::add "pt_BR" "installer::install_nvidia.verify.gpu.start" "Verificando a presença de GPUs NVIDIA no sistema..."
tr::add "pt_BR" "installer::install_nvidia.verify.gpu.found" "GPUs NVIDIA encontradas:"
tr::add "pt_BR" "installer::install_nvidia.verify.gpu.not_found" "Nenhuma GPU NVIDIA encontrada no sistema."
tr::add "pt_BR" "installer::install_nvidia.verify.gpu.msgbox.title" "GPUs NVIDIA Encontradas"

tr::add "en_US" "installer::install_nvidia.start" "Starting NVIDIA driver installation..."
tr::add "en_US" "installer::install_nvidia.verify.gpu.start" "Checking for NVIDIA GPUs in the system..."
tr::add "en_US" "installer::install_nvidia.verify.gpu.found" "NVIDIA GPUs found:"
tr::add "en_US" "installer::install_nvidia.verify.gpu.not_found" "No NVIDIA GPU found in the system."
tr::add "en_US" "installer::install_nvidia.verify.gpu.msgbox.title" "NVIDIA GPUs Found"

# Função principal para desinstalação do driver NVIDIA
installer::uninstall_nvidia() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::uninstall_nvidia.tui.yesno.uninstall.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    log::info "$(tr::t "installer::uninstall_nvidia.start")"

    if ! installer::remove_package "*nvidia*"; then
        log::critical "$(tr::t "installer::uninstall_nvidia.failure")"
    fi

    installer::remove_package "libnvoptix1"

    # Remove o blacklist do nouveau
    log::info "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.start")"
    if [[ -L /etc/modprobe.d/nvidia-blacklists-nouveau.conf ]]; then
        if rm /etc/modprobe.d/nvidia-blacklists-nouveau.conf; then
            log::info "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.success")"
        else
            log::error "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.failure")"
        fi
    fi

    # Reinstala o nouveau como fallback
    log::info "$(tr::t "installer::uninstall_nvidia.reinstall.nouveau.start")"
    if ! apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
    fi
    log::info "$(tr::t "installer::uninstall_nvidia.reinstall.nouveau.success")"

    log::info "$(tr::t "installer::uninstall_nvidia.success")"
    tui::msgbox::warn "$(tr::t "installer::uninstall_nvidia.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar
    return 0
}

tr::add "pt_BR" "installer::uninstall_nvidia.tui.yesno.uninstall.confirm" "Você está prestes a desinstalar o driver NVIDIA do sistema.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::uninstall_nvidia.start" "Iniciando a desinstalação do driver NVIDIA..."
tr::add "pt_BR" "installer::uninstall_nvidia.remove.nouveau.blacklist.start" "Removendo blacklist do driver nouveau..."
tr::add "pt_BR" "installer::uninstall_nvidia.remove.nouveau.blacklist.success" "Blacklist do driver nouveau removida com sucesso."
tr::add "pt_BR" "installer::uninstall_nvidia.remove.nouveau.blacklist.failure" "Falha ao remover a blacklist do driver nouveau."
tr::add "pt_BR" "installer::uninstall_nvidia.reinstall.nouveau.start" "Reinstalando o driver nouveau..."
tr::add "pt_BR" "installer::uninstall_nvidia.reinstall.nouveau.success" "Driver nouveau reinstalado com sucesso."
tr::add "pt_BR" "installer::uninstall_nvidia.success" "Driver NVIDIA desinstalado com sucesso."
tr::add "pt_BR" "installer::uninstall_nvidia.failure" "Falha durante a desinstalação do driver NVIDIA."

tr::add "en_US" "installer::uninstall_nvidia.tui.yesno.uninstall.confirm" "You are about to uninstall the NVIDIA driver from the system.\n\nDo you want to continue?"
tr::add "en_US" "installer::uninstall_nvidia.start" "Starting NVIDIA driver uninstallation..."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.start" "Removing nouveau driver blacklist..."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.success" "Nouveau driver blacklist removed successfully."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.failure" "Failed to remove the nouveau driver blacklist."
tr::add "en_US" "installer::uninstall_nvidia.reinstall.nouveau.start" "Reinstalling the nouveau driver..."
tr::add "en_US" "installer::uninstall_nvidia.reinstall.nouveau.success" "Nouveau driver reinstalled successfully."
tr::add "en_US" "installer::uninstall_nvidia.success" "NVIDIA driver uninstalled successfully."
tr::add "en_US" "installer::uninstall_nvidia.failure" "Failure during NVIDIA driver uninstallation."
