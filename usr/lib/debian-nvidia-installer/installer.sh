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

installer::pre_installation() {
    return 0
}

installer::post_installation() {
    # Força uma atualização de pacotes no Flatpak para que sejam instaladas as bibliotecas do driver NVIDIA
    if packages::is_installed "flatpak"; then
        flatpak update -y | tee -a /dev/fd/3
        tui::msgbox::warn "$(tr::t "installer::post_installation.warn.flatpak")"
    fi

    return 0
}

tr::add "pt_BR" "installer::post_installation.warn.flatpak" "Antes de usar pacotes flatpak, reinicie o sistema e atualize os pacotes executando o seguinte comando no terminal:\n\nflatpak update -y"

tr::add "en_US" "installer::post_installation.warn.flatpak" "Before using Flatpak packages, restart the system and update the packages by running the following command in the terminal:\n\nflatpak update -y"

installer::install_debian_proprietary535() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_debian_proprietary535.tui.yesno.proprietarydriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! installer::pre_installation; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "nvidia-tesla-535-kernel-dkms" "nvidia-tesla-535-driver" "firmware-misc-nonfree"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Habilita o DRM modeset NVIDIA
    nvidia::enable_modeset

    if ! installer::post_installation; then
        log::input _ "$(tr::t "default.script.pause")"
    fi
    
    log::info "$(tr::t "installer::install_debian_proprietary535.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_debian_proprietary535.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar

    script::exit
}

tr::add "pt_BR" "installer::install_debian_proprietary535.tui.yesno.proprietarydriver.confirm" "Você está prestes a instalar o driver proprietário da NVIDIA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_debian_proprietary535.success" "Driver NVIDIA Proprietário instalado com sucesso."

tr::add "en_US" "installer::install_debian_proprietary535.tui.yesno.proprietarydriver.confirm" "You are about to install the proprietary NVIDIA driver.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_debian_proprietary535.success" "Proprietary NVIDIA Driver installed successfully."

installer::install_debian_proprietary550() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_debian_proprietary550.tui.yesno.proprietarydriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! installer::pre_installation; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi
    
    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "nvidia-kernel-dkms" "nvidia-driver" "firmware-misc-nonfree"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala bibliotecas extras para GPUs RTX
    local gpus
    mapfile -t gpus < <(nvidia::fetch_nvidia_gpus)  # Cada linha vira um elemento do array

    for gpu_name in "${gpus[@]}"; do
        if [[ "$gpu_name" =~ RTX ]]; then
            # Instala a biblioteca OptiX e Runtime NGX (DLSS)
            packages::install "libnvoptix1" "libnvidia-ngx1"
        fi
    done

    # Habilita o DRM modeset NVIDIA
    nvidia::enable_modeset

    if ! installer::post_installation; then
        log::input _ "$(tr::t "default.script.pause")"
    fi
    
    log::info "$(tr::t "installer::install_debian_proprietary550.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_debian_proprietary550.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar

    script::exit
}

tr::add "pt_BR" "installer::install_debian_proprietary550.tui.yesno.proprietarydriver.confirm" "Você está prestes a instalar o driver proprietário da NVIDIA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_debian_proprietary550.success" "Driver NVIDIA Proprietário instalado com sucesso."

tr::add "en_US" "installer::install_debian_proprietary550.tui.yesno.proprietarydriver.confirm" "You are about to install the proprietary NVIDIA driver.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_debian_proprietary550.success" "Proprietary NVIDIA Driver installed successfully."

installer::install_debian_opensource() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_debian_opensource.tui.yesno.opendriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if ! installer::pre_installation; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "nvidia-open-kernel-dkms" "nvidia-driver" "firmware-misc-nonfree"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala bibliotecas extras para GPUs RTX
    local gpus
    mapfile -t gpus < <(nvidia::fetch_nvidia_gpus)  # Cada linha vira um elemento do array

    for gpu_name in "${gpus[@]}"; do
        if [[ "$gpu_name" =~ RTX ]]; then
            # Instala a biblioteca OptiX e Runtime NGX (DLSS)
            packages::install "libnvoptix1" "libnvidia-ngx1"
        fi
    done

    # Habilita o DRM modeset NVIDIA
    nvidia::enable_modeset

    if ! installer::post_installation; then
        log::input _ "$(tr::t "default.script.pause")"
    fi
        
    log::info "$(tr::t "installer::install_debian_opensource.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_debian_opensource.success")"
    tui::msgbox::need_restart

    script::exit
}

tr::add "pt_BR" "installer::install_debian_opensource.tui.yesno.opendriver.confirm" "Você está prestes a instalar o driver Open Source da NVIDIA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_debian_opensource.success" "Driver NVIDIA Open Source instalado com sucesso."

tr::add "en_US" "installer::install_debian_opensource.tui.yesno.opendriver.confirm" "You are about to install the Open Source NVIDIA driver.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_debian_opensource.success" "Open Source NVIDIA Driver installed successfully."

installer::install_cuda_proprietary() {
    local temp_download_file="/tmp/cudakeyring.deb"
    trap 'rm -f "$temp_download_file"' RETURN

    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_cuda_proprietary.tui.yesno.cuda.proprietary.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if [[ ! -f "$temp_download_file" ]]; then
        wget -O "$temp_download_file" https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb | tee -a /dev/fd/3 
        if [[ "${PIPESTATUS[0]}" -ne 0 ]]; then
            log::critical "$(tr::t "installer::install_cuda_proprietary.repo.download.failure")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
        fi
    fi

    if ! packages::install "$temp_download_file"; then
        log::critical "$(tr::t "installer::install_cuda_proprietary.repo.install.failure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    if ! packages::update; then
        log::critical "$(tr::t "installer::install_cuda_proprietary.packages.update.failure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    if ! installer::pre_installation; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "cuda-drivers"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    if ! installer::post_installation; then
        log::input _ "$(tr::t "default.script.pause")"
    fi

    log::info "$(tr::t "installer::install_cuda_proprietary.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_cuda_proprietary.success")"
    tui::msgbox::need_restart

    script::exit
}

tr::add "pt_BR" "installer::install_cuda_proprietary.tui.yesno.cuda.proprietary.confirm" "Você está prestes a instalar o driver Proprietário da NVIDIA fornecido pelo repositório CUDA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_cuda_proprietary.repo.download.failure" "Download do cuda-keyring falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_proprietary.repo.install.failure" "Instalação do cuda-keyring falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_proprietary.packages.update.failure" "Atualização da lista de pacotes locais falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_proprietary.failure" "Instalação dos drivers Nvidia falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_proprietary.success" "Driver NVIDIA instalado com sucesso."

tr::add "en_US" "installer::install_cuda_proprietary.tui.yesno.cuda.proprietary.confirm" "You are about to install the NVIDIA Proprietary driver provided by the CUDA repository.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_cuda_proprietary.repo.download.failure" "Failed to download the cuda-keyring. Operation aborted."
tr::add "en_US" "installer::install_cuda_proprietary.repo.install.failure" "Failed to install the cuda-keyring. Operation aborted."
tr::add "en_US" "installer::install_cuda_proprietary.packages.update.failure" "Failed to update the local package list. Operation aborted."
tr::add "en_US" "installer::install_cuda_proprietary.failure" "Failed to install the NVIDIA drivers. Operation aborted."
tr::add "en_US" "installer::install_cuda_proprietary.success" "NVIDIA Driver installed successfully."

installer::install_cuda_opensource() {
    local temp_download_file="/tmp/cudakeyring.deb"
    trap 'rm -f "$temp_download_file"' RETURN

    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_cuda_opensource.tui.yesno.cuda.proprietary.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    if [[ ! -f "$temp_download_file" ]]; then
        wget -O "$temp_download_file" https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb | tee -a /dev/fd/3 
        if [[ "${PIPESTATUS[0]}" -ne 0 ]]; then
            log::critical "$(tr::t "installer::install_cuda_opensource.repo.download.failure")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
        fi
    fi

    if ! packages::install "$temp_download_file"; then
        log::critical "$(tr::t "installer::install_cuda_opensource.repo.install.failure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    if ! packages::update; then
        log::critical "$(tr::t "installer::install_cuda_opensource.packages.update.failure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    if ! installer::pre_installation; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "nvidia-open"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    if ! installer::post_installation; then
        log::input _ "$(tr::t "default.script.pause")"
    fi

    log::info "$(tr::t "installer::install_cuda_opensource.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_cuda_opensource.success")"
    tui::msgbox::need_restart

    script::exit
}

tr::add "pt_BR" "installer::install_cuda_opensource.tui.yesno.cuda.proprietary.confirm" "Você está prestes a instalar o driver de Código Aberto da NVIDIA fornecido pelo repositório CUDA.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::install_cuda_opensource.repo.download.failure" "Download do cuda-keyring falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_opensource.repo.install.failure" "Instalação do cuda-keyring falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_opensource.packages.update.failure" "Atualização da lista de pacotes locais falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_opensource.failure" "Instalação dos drivers Nvidia falhou. Operação abortada."
tr::add "pt_BR" "installer::install_cuda_opensource.success" "Driver NVIDIA instalado com sucesso."

tr::add "en_US" "installer::install_cuda_opensource.tui.yesno.cuda.proprietary.confirm" "You are about to install the NVIDIA Open Source driver provided by the CUDA repository.\n\nDo you want to continue?"
tr::add "en_US" "installer::install_cuda_opensource.repo.download.failure" "Failed to download the cuda-keyring. Operation aborted."
tr::add "en_US" "installer::install_cuda_opensource.repo.install.failure" "Failed to install the cuda-keyring. Operation aborted."
tr::add "en_US" "installer::install_cuda_opensource.packages.update.failure" "Failed to update the local package list. Operation aborted."
tr::add "en_US" "installer::install_cuda_opensource.failure" "Failed to install the NVIDIA drivers. Operation aborted."
tr::add "en_US" "installer::install_cuda_opensource.success" "NVIDIA Driver installed successfully."

installer::setup_mok() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    # Instala o pacote dkms com abstração
    if ! packages::install "dkms"; then
        return 1
    fi

    # Avisa o usuário sobre a criação da senha do MOK
    tui::msgbox::warn "$(tr::t "installer::setup_mok.password")"

    # Gera a chave MOK
    if ! mok::generate_mok; then
        return 1
    fi

    # Importa a chave MOK
    log::info "$(tr::t "installer::setup_mok.importing")"
    if ! mok::import_mok; then
        return 1
    fi

    log::success "$(tr::t "installer::setup_mok.success")"
    tui::msgbox::warn "$(tr::t "installer::setup_mok.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar

    log::warn "$(tr::t "installer::setup_mok.restart_required")"

    script::exit
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
        if ! packages::install "mokutil"; then
            log::critical "$(tr::t "default.script.canceled.byfailure")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
        fi
    fi

    # Verifica se o Secure Boot está ativado e se a chave MOK já está registrada
    if mok::check_secure_boot; then
        log::info "$(tr::t "installer::check_secure_boot.enabled")"

        if mok::check_mok; then
            log::info "$(tr::t "installer::check_secure_boot.mok.already_enrolled")"
            return 0
        fi

        log::warn "$(tr::t "installer::check_secure_boot.mok.missing")"
        tui::msgbox::warn "$(tr::t "installer::check_secure_boot.mok.missing")"

        if tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::check_secure_boot.mok.prompt")"; then
            installer::setup_mok
            log::input _ "$(tr::t "default.script.pause")"
            script::exit "$(tr::t "default.script.canceled.byfailure")" 1
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

installer::set_up_dracut() {
    if packages::is_installed "dracut"; then
        local filename="10-nvidia.conf"
        local directory="/etc/dracut.conf.d"
        local content='install_items+=" /etc/modprobe.d/nvidia-blacklists-nouveau.conf /etc/modprobe.d/nvidia.conf /etc/modprobe.d/nvidia-options.conf "' 
        
        # Garante a existência do diretório do dracut
        mkdir -p "$directory"

        # Adiciona a configuração caso ela não exista no arquivo
        if ! grep -qxF "$content" "$directory/$filename" 2>/dev/null; then
            echo "$content" | tee -a "$directory/$filename" > /dev/null
        fi
    fi
}

# Função principal para instalação do driver NVIDIA
installer::install_nvidia() {
    log::info "$(tr::t "installer::install_nvidia.start")"

    # Verifica se o driver da NVIDIA já está instalado no sistema
    log::info "$(tr::t "installer::install_nvidia.installed_drivers")"
    if nvidia::is_driver_installed; then
        log::info "$(tr::t "installer::install_nvidia.installed_drivers.already_installed")"
        tui::msgbox::warn "$(tr::t "installer::install_nvidia.installed_drivers.already_installed")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi
    
    # Verifica se há GPUs NVIDIA disponíveis no sistema
    log::info "$(tr::t "installer::install_nvidia.verify_gpu")"
    local nvidia_gpus
    nvidia_gpus="$(nvidia::fetch_nvidia_gpus)"

    if [[ -n "$nvidia_gpus" ]]; then
        log::info "$(tr::t "installer::install_nvidia.verify_gpu.success")"

        while IFS= read -r line; do
            log::info "\t - ${line}"
        done <<< "$nvidia_gpus"
    else
        log::error "$(tr::t "installer::install_nvidia.verify_gpu.failure")"
        tui::msgbox::warn "$(tr::t "installer::install_nvidia.verify_gpu.failure")"
        return 1
    fi

    # Verifica se a arquitetura do sistema é suportada
    log::info "$(tr::t "installer::install_nvidia.verify_arch")"
    local ARCH
    ARCH="$(uname -m)"
    if ! [ "$ARCH" == "x86_64" ]; then
        script::exit "$(tr::t_args "installer::install_nvidia.unsupported_arch" "$ARCH")" 1
    fi

    # Habilita o multiarch para i386
    log::info "$(tr::t "installer::install_nvidia.enable_multiarch")"
    if ! dpkg --add-architecture i386; then
        log::warn "$(tr::t "installer::install_nvidia.enable_multiarch.failure")"
        # Multiarqutetura não é crítico, é opcional apenas para habilitar pacotes extras para i386
    else
        log::info "$(tr::t "installer::install_nvidia.enable_multiarch.success")"
    fi

    # Adiciona os componentes non-free nos repositórios
    log::info "$(tr::t "installer::install_nvidia.sources_components")"
    if ! packages::check_sources_components "" "contrib" "non-free" "non-free-firmware"; then
        log::info "$(tr::t "installer::install_nvidia.sources_components.missing")"

        if ! packages::add_sources_components "" "contrib" "non-free" "non-free-firmware"; then
            log::critical "$(tr::t "installer::install_nvidia.sources_components.failure")"
            return 1
        else
            log::info "$(tr::t "installer::install_nvidia.sources_components.success")"
        fi
    else
        log::info "$(tr::t "installer::install_nvidia.sources_components.ok")"
    fi
    
    # Atualiza a lista de pacote
    log::info "$(tr::t "installer::install_nvidia.update_packages")"
    if ! packages::update; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Verifica se o Secure Boot está ativo e configura a chave MOK
    if ! installer::check_secure_boot; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala o header do kernel
    log::info "$(tr::t "installer::install_nvidia.kernel_headers")"
    if ! packages::install "linux-headers-amd64"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Configura o dracut caso ele esteja instalado
    log::info "$(tr::t "installer::install_nvidia.dracut")"
    installer::set_up_dracut
    
    log::info "$(tr::t "installer::install_nvidia.success")"

    # Abre a janela para escolher qual driver instalar
    tui::menu::flavors
}

tr::add "pt_BR" "installer::install_nvidia.start" "Iniciando pré-instalação..."
tr::add "pt_BR" "installer::install_nvidia.installed_drivers" "Verificando por drivers instalados no sistema..."
tr::add "pt_BR" "installer::install_nvidia.installed_drivers.already_installed" "Driver NVIDIA detectado no sistema, remova o driver instalado no sistema antes de prosseguir com uma nova instalação. Operação abortada."
tr::add "pt_BR" "installer::install_nvidia.verify_gpu" "Procurando por hardware NVIDIA..."
tr::add "pt_BR" "installer::install_nvidia.verify_gpu.success" "Hardware NVIDIA detectado:"
tr::add "pt_BR" "installer::install_nvidia.verify_gpu.failure" "Nenhum hardware NVIDIA encontrado. Operação abortada."
tr::add "pt_BR" "installer::install_nvidia.verify_arch" "Verificando arquitetura do sistema..."
tr::add "pt_BR" "installer::install_nvidia.unsupported_arch" "Arquitetura %1 não é suportada através deste instalador. Operação abortada."
tr::add "pt_BR" "installer::install_nvidia.enable_multiarch" "Habilitando suporte à arquitetura i386..."
tr::add "pt_BR" "installer::install_nvidia.enable_multiarch.failure" "Falha ao habilitar suporte à arquitetura i386."
tr::add "pt_BR" "installer::install_nvidia.enable_multiarch.success" "Suporte à arquitetura i386 habilitada com sucesso."
tr::add "pt_BR" "installer::install_nvidia.sources_components" "Verificando por componentes necessários ausentes na lista de origens..."
tr::add "pt_BR" "installer::install_nvidia.sources_components.ok" "Lista de origens possuí todos os componentes necessários habilitados."
tr::add "pt_BR" "installer::install_nvidia.sources_components.missing" "Lista de origens possuí componentes ausentes. Habilitando componentes ausentes na lista de origem..."
tr::add "pt_BR" "installer::install_nvidia.sources_components.success" "Componentes ausentes na lista de origem foram habilitados com sucesso."
tr::add "pt_BR" "installer::install_nvidia.sources_components.failure" "Falha ao habilitar componentes ausentes na lista de origens. Operação abortada."
tr::add "pt_BR" "installer::install_nvidia.update_packages" "Atualizando lista de pacotes..."
tr::add "pt_BR" "installer::install_nvidia.kernel_headers" "Instalando metapacote dos cabeçalhos do kernel..."
tr::add "pt_BR" "installer::install_nvidia.dracut" "Verificando se é necessário configurar o dracut..."
tr::add "pt_BR" "installer::install_nvidia.success" "Pré-instalação concluída. Iniciando menu de instalação dos drivers NVIDIA..."

tr::add "en_US" "installer::install_nvidia.start" "Starting pre-installation..."
tr::add "en_US" "installer::install_nvidia.installed_drivers" "Checking for installed drivers on the system..."
tr::add "en_US" "installer::install_nvidia.installed_drivers.already_installed" "NVIDIA driver detected on the system. Please remove the existing driver before proceeding with a new installation. Operation aborted."
tr::add "en_US" "installer::install_nvidia.verify_gpu" "Searching for NVIDIA hardware..."
tr::add "en_US" "installer::install_nvidia.verify_gpu.success" "NVIDIA hardware detected:"
tr::add "en_US" "installer::install_nvidia.verify_gpu.failure" "No NVIDIA hardware found. Operation aborted."
tr::add "en_US" "installer::install_nvidia.verify_arch" "Checking system architecture..."
tr::add "en_US" "installer::install_nvidia.unsupported_arch" "Architecture %1 is not supported by this installer. Operation aborted."
tr::add "en_US" "installer::install_nvidia.enable_multiarch" "Enabling support for i386 architecture..."
tr::add "en_US" "installer::install_nvidia.enable_multiarch.failure" "Failed to enable support for i386 architecture."
tr::add "en_US" "installer::install_nvidia.enable_multiarch.success" "Support for i386 architecture successfully enabled."
tr::add "en_US" "installer::install_nvidia.sources_components" "Checking for missing required components in the sources list..."
tr::add "en_US" "installer::install_nvidia.sources_components.ok" "All required components are already enabled in the sources list."
tr::add "en_US" "installer::install_nvidia.sources_components.missing" "Some components are missing in the sources list. Enabling missing components..."
tr::add "en_US" "installer::install_nvidia.sources_components.success" "Missing components have been successfully enabled in the sources list."
tr::add "en_US" "installer::install_nvidia.sources_components.failure" "Failed to enable missing components in the sources list. Operation aborted."
tr::add "en_US" "installer::install_nvidia.update_packages" "Updating package list..."
tr::add "en_US" "installer::install_nvidia.kernel_headers" "Installing kernel header metapackage..."
tr::add "en_US" "installer::install_nvidia.dracut" "Checking if dracut configuration is required..."
tr::add "en_US" "installer::install_nvidia.success" "Pre-installation completed. Launching NVIDIA driver installation menu..."

# Função principal para desinstalação do driver NVIDIA
installer::uninstall_nvidia() {
    # Exibe a mensagem para o usuário escolher se quer continuar a operação
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::uninstall_nvidia.tui.yesno.uninstall.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    log::info "$(tr::t "installer::uninstall_nvidia.start")"

    # Remove o modeset da Nvidia dos parâmetros do Kernel no GRUB
    grub::remove_kernel_parameter "nvidia-drm.modeset" "=" "[0-9]+" | tee -a /dev/fd/3
    # Atualiza o GRUB
    grub::update

    # Verifica quais pacotes da Nvidia estão instalados
    # Garante que os firwares não sejam removidos e nem o próprio script
    local pkgs=()
    mapfile -t pkgs < <(dpkg -l | awk '($2 ~ /nvidia/ || $2 ~ /^libxnv/ || $2 ~ /cuda-toolkit/ || $2 ~ /^cuda-keyring$/) && $2 != "debian-nvidia-installer" {print $2}')

    # Remove o repositório CUDA, caso ele exista
    nvidia::remove_cuda_repo | tee -a /dev/fd/3

    # Desinstala os pacotes encontrados ou pula a desistalação
    if [ "${#pkgs[@]}" -gt 0 ]; then
        packages::purge "${pkgs[@]}"
    else
        log::info "$(tr::t "installer::uninstall_nvidia.no_packages")"
    fi

    # Remove arquivos residuais de instalações anteriores da NVIDIA
    log::info "$(tr::t_args "installer::uninstall_nvidia.removingfile" "/etc/modprobe.d/nvidia.conf")"
    rm -f "/etc/modprobe.d/nvidia.conf"
    log::info "$(tr::t_args "installer::uninstall_nvidia.removingfile" "/etc/modprobe.d/nvidia-options.conf")"
    rm -f "/etc/modprobe.d/nvidia-options.conf"
    log::info "$(tr::t_args "installer::uninstall_nvidia.removingfile" "/etc/modprobe.d/nvidia-modeset.conf")"
    rm -f "/etc/modprobe.d/nvidia-modeset.conf"
    
    log::info "$(tr::t "installer::uninstall_nvidia.reinstall.nouveau.start")"
    log::info "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.start")"

    # Remove o blacklist do driver Nouveau
    if [[ -e /etc/modprobe.d/nvidia-blacklists-nouveau.conf ]]; then
        if rm -f /etc/modprobe.d/nvidia-blacklists-nouveau.conf; then
            log::info "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.success")"
        else
            log::error "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.failure")"
        fi
    fi

    # Atualiza os repositórios
    packages::update
    # Reinstala o driver Nouveau
    apt-get install --reinstall -y xserver-xorg-core xserver-xorg-video-nouveau | tee -a /dev/fd/3
    # Garante que o firmware necessário para o Nouveau utilizar a Nvidia esteja presente
    apt-get install -y firmware-misc-nonfree firmware-nvidia-graphics | tee -a /dev/fd/3 
    # Atualiza o initramfs para garantir que o Nouveau seja carregado corretamente
    update-initramfs -u | tee -a /dev/fd/3 

    log::info "$(tr::t "installer::uninstall_nvidia.reinstall.nouveau.success")"

    # Mensagem de sucesso
    log::info "$(tr::t "installer::uninstall_nvidia.success")"
    tui::msgbox::warn "$(tr::t "installer::uninstall_nvidia.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar

    script::exit
}

tr::add "pt_BR" "installer::uninstall_nvidia.tui.yesno.uninstall.confirm" "Você está prestes a desinstalar o driver NVIDIA do sistema.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::uninstall_nvidia.start" "Iniciando a desinstalação do driver NVIDIA..."
tr::add "pt_BR" "installer::uninstall_nvidia.remove.nouveau.blacklist.start" "Removendo blacklist do driver nouveau..."
tr::add "pt_BR" "installer::uninstall_nvidia.remove.nouveau.blacklist.success" "Blacklist do driver nouveau removida com sucesso."
tr::add "pt_BR" "installer::uninstall_nvidia.remove.nouveau.blacklist.failure" "Falha ao remover a blacklist do driver nouveau."
tr::add "pt_BR" "installer::uninstall_nvidia.reinstall.nouveau.start" "Reinstalando o driver nouveau..."
tr::add "pt_BR" "installer::uninstall_nvidia.reinstall.nouveau.success" "Driver nouveau reinstalado com sucesso."
tr::add "pt_BR" "installer::uninstall_nvidia.success" "Driver NVIDIA desinstalado com sucesso."
tr::add "pt_BR" "installer::uninstall_nvidia.no_packages" "Nenhum pacote NVIDIA encontrado para desinstalar."
tr::add "pt_BR" "installer::uninstall_nvidia.removingfile" "Removendo arquivo: %1 ..."

tr::add "en_US" "installer::uninstall_nvidia.tui.yesno.uninstall.confirm" "You are about to uninstall the NVIDIA driver from the system.\n\nDo you want to continue?"
tr::add "en_US" "installer::uninstall_nvidia.start" "Starting NVIDIA driver uninstallation..."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.start" "Removing nouveau driver blacklist..."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.success" "Nouveau driver blacklist removed successfully."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.failure" "Failed to remove the nouveau driver blacklist."
tr::add "en_US" "installer::uninstall_nvidia.reinstall.nouveau.start" "Reinstalling the nouveau driver..."
tr::add "en_US" "installer::uninstall_nvidia.reinstall.nouveau.success" "Nouveau driver reinstalled successfully."
tr::add "en_US" "installer::uninstall_nvidia.success" "NVIDIA driver uninstalled successfully."
tr::add "en_US" "installer::uninstall_nvidia.no_packages" "No NVIDIA packages found to uninstall."
tr::add "en_US" "installer::uninstall_nvidia.removingfile" "Removendo arquivo: %1 ..."
