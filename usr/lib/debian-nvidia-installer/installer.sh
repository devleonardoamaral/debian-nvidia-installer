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

installer::post_installation() {
    # Força uma atualização de pacotes no Flatpak para que sejam instaladas as bibliotecas do driver NVIDIA
    if packages::is_installed "flatpak"; then
        log::capture_cmd flatpak update -y
        tui::msgbox::warn "$(tr::t "installer::post_installation.warn.flatpak")"
    fi

    return 0
}

tr::add "pt_BR" "installer::post_installation.warn.flatpak" "Após reiniciar o sistema, atualize os pacotes Flatpak executando no terminal:\n\nflatpak update -y\n\nIsso garante que os Flatpak utilizem as bibliotecas gráficas atualizadas do novo driver instalado, evitando falhas ou problemas de compatibilidade."

tr::add "en_US" "installer::post_installation.warn.flatpak" "After restarting the system, update Flatpak packages by running in the terminal:\n\nflatpak update -y\n\nThis ensures that Flatpak apps use the updated graphics libraries from the newly installed driver, preventing failures or compatibility issues."

installer::install_debian_proprietary535() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_debian_proprietary535.tui.yesno.proprietarydriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
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

    nvidia::change_option_pvma "1"

    return 0
}

tr::add "pt_BR" "installer::install_debian_proprietary535.tui.yesno.proprietarydriver.confirm" "Você está prestes a instalar o driver proprietário da NVIDIA.\n\nDeseja continuar?"

tr::add "en_US" "installer::install_debian_proprietary535.tui.yesno.proprietarydriver.confirm" "You are about to install the proprietary NVIDIA driver.\n\nDo you want to continue?"

installer::install_debian_proprietary550() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_debian_proprietary550.tui.yesno.proprietarydriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
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

    nvidia::change_option_pvma "1"

    return 0
}

tr::add "pt_BR" "installer::install_debian_proprietary550.tui.yesno.proprietarydriver.confirm" "Você está prestes a instalar o driver proprietário da NVIDIA.\n\nDeseja continuar?"

tr::add "en_US" "installer::install_debian_proprietary550.tui.yesno.proprietarydriver.confirm" "You are about to install the proprietary NVIDIA driver.\n\nDo you want to continue?"

installer::install_debian_opensource550() {
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t "installer::install_debian_opensource550.tui.yesno.opendriver.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
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

    nvidia::change_option_pvma "1"

    return 0
}

tr::add "pt_BR" "installer::install_debian_opensource550.tui.yesno.opendriver.confirm" "Você está prestes a instalar o driver Open Source da NVIDIA.\n\nDeseja continuar?"

tr::add "en_US" "installer::install_debian_opensource550.tui.yesno.opendriver.confirm" "You are about to install the Open Source NVIDIA driver.\n\nDo you want to continue?"

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

    log::warn "$(tr::t "installer::setup_mok.success")"
    tui::msgbox::warn "$(tr::t "installer::setup_mok.success")"

    script::exit
}

tr::add "pt_BR" "installer::setup_mok.password" "Agora você precisará criar uma senha para a MOK (Machine Owner Key).\n\nLembre-se desta senha, pois será necessária na próxima etapa para concluir a instalação do driver NVIDIA."
tr::add "pt_BR" "installer::setup_mok.importing" "Importando a chave MOK..."
tr::add "pt_BR" "installer::setup_mok.success" "A chave MOK foi importada com sucesso. Para concluir a inscrição da chave, siga os passos abaixo:\n\n1. Reinicie o computador e aguarde a tela azul do MOK Manager.\n2. Selecione 'Enroll MOK'.\n3. Selecione 'Continue'.\n4. Selecione 'Yes'.\n5. Digite a senha que você criou para a MOK.\n6. Conclua selecionando 'Reboot'.\n\nDica: se possível, tire uma foto desta tela para referência futura."

tr::add "en_US" "installer::setup_mok.password" "You will now need to create a password for the MOK (Machine Owner Key).\n\nRemember this password, as it will be required in the next step to complete the NVIDIA driver installation."
tr::add "en_US" "installer::setup_mok.importing" "Importing MOK key..."
tr::add "en_US" "installer::setup_mok.success" "MOK key imported successfully. To complete the key enrollment, follow these steps:\n\n1. Restart your computer and wait for the MOK Manager blue screen.\n2. Select 'Enroll MOK'.\n3. Select 'Continue'.\n4. Select 'Yes'.\n5. Enter the password you created for the MOK.\n6. Finish by selecting 'Reboot'.\n\nTip: if possible, take a photo of this screen for future reference."

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
tr::add "pt_BR" "installer::check_secure_boot.mok.already_enrolled" "MOK já registrada."
tr::add "pt_BR" "installer::check_secure_boot.mok.missing" "Sistema não possui uma MOK registrada."
tr::add "pt_BR" "installer::check_secure_boot.mok.prompt" "O sistema possui Secure Boot habilitado, mas não há uma MOK (Machine Owner Key) configurada. Sem uma MOK, os drivers NVIDIA podem não funcionar corretamente. Você pode resolver isso de duas maneiras:\n\n1. Configurando uma MOK\n2. Desativando o Secure Boot na BIOS\n\nPara mais informações: https://wiki.debian.org/SecureBoot#MOK_-_Machine_Owner_Key\n\nDeseja iniciar o processo guiado de configuração da MOK agora?"
tr::add "pt_BR" "installer::check_secure_boot.mok.setup.failure" "Falha ao configurar a chave MOK."
tr::add "pt_BR" "installer::check_secure_boot.mok.abortedbyuser" "Você optou por não configurar a MOK. Com o Secure Boot habilitado e sem uma MOK, os drivers NVIDIA não funcionarão corretamente. A instalação será cancelada.\n\nPara prosseguir no futuro, você pode:\n1. Configurar a MOK manualmente (veja instruções em: https://wiki.debian.org/SecureBoot#MOK_-_Machine_Owner_Key)\n2. Desativar o Secure Boot na BIOS"
tr::add "pt_BR" "installer::check_secure_boot.disabled" "Secure Boot está DESATIVADO. Você pode continuar sem registrar a chave MOK."

tr::add "en_US" "log.installer.secureboot.start" "Starting Secure Boot check..."
tr::add "en_US" "installer::check_secure_boot.enabled" "Secure Boot is ENABLED."
tr::add "en_US" "installer::check_secure_boot.mok.already_enrolled" "MOK already enrolled."
tr::add "en_US" "installer::check_secure_boot.mok.missing" "System does not have a enrolled MOK."
tr::add "en_US" "installer::check_secure_boot.mok.prompt" "The system has Secure Boot enabled, but no MOK (Machine Owner Key) is configured. Without a MOK, NVIDIA drivers may not function correctly. You can resolve this in one of two ways:\n\n1. Configuring a MOK\n2. Disabling Secure Boot in the BIOS\n\nFor more information: https://wiki.debian.org/SecureBoot#MOK_-_Machine_Owner_Key\n\nWould you like to start the guided MOK configuration process now?"
tr::add "en_US" "installer::check_secure_boot.mok.setup.failure" "Failed to set up MOK key."
tr::add "en_US" "installer::check_secure_boot.mok.abortedbyuser" "You have chosen not to configure a MOK. With Secure Boot enabled and no MOK, NVIDIA drivers will not function correctly. The installation will be canceled.\n\nTo proceed in the future, you can:\n1. Configure a MOK manually (see instructions at: https://wiki.debian.org/SecureBoot#MOK_-_Machine_Owner_Key)\n2. Disable Secure Boot in the BIOS"
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
        log::warn "$(tr::t "installer::install_nvidia.verify_gpu.failure")"
        tui::msgbox::warn "$(tr::t "installer::install_nvidia.verify_gpu.failure.msgbox")"
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

    # Adds the non-free components to the repositories
    log::info "$(tr::t "installer::install_nvidia.sources_components")"
    if [ -f "/etc/apt/sources.list.d/debian.sources" ]; then
        if ! sed -i 's/^Components:.*$/Components: main contrib non-free non-free-firmware/' "/etc/apt/sources.list.d/debian.sources"; then
            log::critical "$(tr::t "installer::install_nvidia.sources_components.failure")"
            return 1
        fi

        log::info "$(tr::t "installer::install_nvidia.sources_components.success")"
    else
        if ! packages::check_sources_components "/etc/apt/sources.list" "contrib" "non-free" "non-free-firmware"; then
            log::info "$(tr::t "installer::install_nvidia.sources_components.missing")"

            if ! packages::add_sources_components "/etc/apt/sources.list" "contrib" "non-free" "non-free-firmware"; then
                log::critical "$(tr::t "installer::install_nvidia.sources_components.failure")"
                return 1
            else
                log::info "$(tr::t "installer::install_nvidia.sources_components.success")"
            fi
        else
            log::info "$(tr::t "installer::install_nvidia.sources_components.ok")"
        fi
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

    log::info "$(tr::t "installer::install_nvidia.pre.success")"

    # Abre a janela para escolher qual driver instalar
    if ! tui::menu::flavors; then
        return 1
    fi

    # Habilita o DRM modeset NVIDIA
    if ! packages::is_installed "cuda-keyring"; then # Já é ativado nos drivers CUDA
        if ! nvidia::enable_modeset; then
            log::error "$(tr::t "installer::install_nvidia.modeset.failure")"
            log::input _ "$(tr::t "default.script.pause")"
        fi
    fi

    # Faz configurações e checagens pós-instalação
    if ! installer::post_installation; then
        log::input _ "$(tr::t "default.script.pause")"
    fi

    log::info "$(tr::t "installer::install_nvidia.success")"
    tui::msgbox::custom "" "$(tr::t "installer::install_nvidia.success")"
    tui::msgbox::need_restart # Exibe aviso que é necessário reiniciar

    script::exit
}

tr::add "pt_BR" "installer::install_nvidia.start" "Iniciando pré-instalação..."
tr::add "pt_BR" "installer::install_nvidia.installed_drivers" "Verificando por drivers instalados no sistema..."
tr::add "pt_BR" "installer::install_nvidia.installed_drivers.already_installed" "Driver NVIDIA detectado no sistema, remova o driver instalado no sistema antes de prosseguir com uma nova instalação. Operação abortada."
tr::add "pt_BR" "installer::install_nvidia.verify_gpu" "Procurando por GPUs NVIDIA..."
tr::add "pt_BR" "installer::install_nvidia.verify_gpu.success" "GPU NVIDIA detectada:"
tr::add "pt_BR" "installer::install_nvidia.verify_gpu.failure" "Nenhuma GPU NVIDIA detectada."
tr::add "pt_BR" "installer::install_nvidia.verify_gpu.failure.msgbox" "Nenhuma GPU NVIDIA detectada.\n\nAlgumas bibliotecas específicas de GPU não serão instaladas automaticamente. Para garantir uma instalação completa, execute o script com o hardware NVIDIA presente no sistema."
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
tr::add "pt_BR" "installer::install_nvidia.pre.success" "Pré-instalação concluída. Iniciando menu de instalação dos drivers NVIDIA..."
tr::add "pt_BR" "installer::install_nvidia.modeset.failure" "Falha na ativação do DRM Modeset."
tr::add "pt_BR" "installer::install_nvidia.success" "Driver da NVIDIA instalado com sucesso."

tr::add "en_US" "installer::install_nvidia.start" "Starting pre-installation..."
tr::add "en_US" "installer::install_nvidia.installed_drivers" "Checking for installed drivers on the system..."
tr::add "en_US" "installer::install_nvidia.installed_drivers.already_installed" "NVIDIA driver detected on the system. Please remove the existing driver before proceeding with a new installation. Operation aborted."
tr::add "en_US" "installer::install_nvidia.verify_gpu" "Searching for NVIDIA GPUs..."
tr::add "en_US" "installer::install_nvidia.verify_gpu.success" "NVIDIA GPU detected:"
tr::add "en_US" "installer::install_nvidia.verify_gpu.failure" "No NVIDIA GPU detected."
tr::add "en_US" "installer::install_nvidia.verify_gpu.failure.msgbox" "No NVIDIA GPU detected.\n\nSome GPU-specific libraries will not be installed automatically. For a complete installation, run the script with the NVIDIA hardware present in the system."
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
tr::add "en_US" "installer::install_nvidia.pre.success" "Pre-installation completed. Launching NVIDIA driver installation menu..."
tr::add "en_US" "installer::install_nvidia.modeset.failure" "Failed to activate DRM Modeset."
tr::add "en_US" "installer::install_nvidia.success" "NVIDIA driver installed successfully."




# ----------------------------------------------------------------------------
# Function: installer::uninstall_nvidia
# Description:
#     Main function to completely uninstall the NVIDIA driver stack.
#     This function removes kernel parameters, uninstalls NVIDIA-related
#     packages, cleans up residual configuration files, restores Nouveau,
#     and ensures the system is properly updated after changes.
# Params:
#     None
# Returns:
#     255 - If the user cancels the operation.
#     0   - On success (though script::exit will terminate the script).
# ----------------------------------------------------------------------------
installer::uninstall_nvidia() {
    # Ask user confirmation before proceeding
    if ! tui::yesno::default \
        "$(tr::t "default.tui.title.warn")" \
        "$(tr::t "installer::uninstall_nvidia.tui.yesno.uninstall.confirm")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    log::info "$(tr::t "installer::uninstall_nvidia.start")"

    # Remove the nvidia-drm.modeset parameter from the kernel command line in GRUB
    grub::remove_kernel_parameter "nvidia-drm.modeset" "=" "[0-9]+"

    # Update GRUB configuration
    if ! grub::update; then
        log::error "$(tr::t "installer::uninstall_nvidia.update_grub.failed")"
    fi

    # Collect all installed NVIDIA-related packages
    # Excludes firmware packages and the debian-nvidia-installer script itself
    local pkgs=()

    # Base exclude list
    exclude="debian-nvidia-installer"

    # If XFCE is installed, also exclude libxnvctrl0 (all architectures)
    if packages::is_installed xfce4-sensors-plugin; then
        exclude="$exclude|libxnvctrl0(:.*)?"
    fi

    # Build pkgs array
    mapfile -t pkgs < <(
        dpkg -l | awk -v ex="$exclude" '($2 ~ /nvidia/ || $2 ~ /^libxnv/ || $2 ~ /^cuda-drivers$/ || $2 ~ /cuda-toolkit/) && $2 !~ "^("ex")$" {print $2}'
    )

    # Remove CUDA repository version lock if present
    cudarepo::unlock_cuda_version

    # Remove CUDA repository if present
    cudarepo::uninstall_cuda_repository

    # Purge NVIDIA-related packages if found
    if [ "${#pkgs[@]}" -gt 0 ]; then
        packages::purge "${pkgs[@]}"
    else
        log::info "$(tr::t "installer::uninstall_nvidia.no_packages")"
    fi

    # Clean up residual NVIDIA configuration files, including Nouveau blacklist
    for f in "/etc/modprobe.d/nvidia*.conf"; do
        [ -e "$f" ] && [ ! -d "$f" ] || continue
        log::info "$(tr::t_args "installer::uninstall_nvidia.removingfile" "$f")"
        rm -f "$f"
    done

    log::info "$(tr::t "installer::uninstall_nvidia.reinstall.nouveau.start")"
    log::info "$(tr::t "installer::uninstall_nvidia.remove.nouveau.blacklist.start")"

    # Update APT repositories
    packages::update

    # Reinstall Nouveau packages
    packages::reinstall xserver-xorg-core xserver-xorg-video-nouveau

    # Ensure required firmware for Nouveau to use NVIDIA hardware is installed
    packages::install firmware-misc-nonfree firmware-nvidia-graphics

    # Update initramfs to make sure Nouveau loads correctly
    initramfs::update

    log::info "$(tr::t "installer::uninstall_nvidia.reinstall.nouveau.success")"

    # Final success message and restart prompt
    log::info "$(tr::t "installer::uninstall_nvidia.success")"
    tui::msgbox::warn "$(tr::t "installer::uninstall_nvidia.success")"
    tui::msgbox::need_restart

    # Exit script safely
    script::exit
}

tr::add "pt_BR" "installer::uninstall_nvidia.tui.yesno.uninstall.confirm" "Você está prestes a desinstalar o driver NVIDIA do sistema.\n\nDeseja continuar?"
tr::add "pt_BR" "installer::uninstall_nvidia.start" "Iniciando a desinstalação do driver NVIDIA..."
tr::add "pt_BR" "installer::uninstall_nvidia.update_grub.failed" "Falha ao atualizar o GRUB."
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
tr::add "en_US" "installer::uninstall_nvidia.update_grub.failed" "Failed to update GRUB."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.start" "Removing nouveau driver blacklist..."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.success" "Nouveau driver blacklist removed successfully."
tr::add "en_US" "installer::uninstall_nvidia.remove.nouveau.blacklist.failure" "Failed to remove the nouveau driver blacklist."
tr::add "en_US" "installer::uninstall_nvidia.reinstall.nouveau.start" "Reinstalling the nouveau driver..."
tr::add "en_US" "installer::uninstall_nvidia.reinstall.nouveau.success" "Nouveau driver reinstalled successfully."
tr::add "en_US" "installer::uninstall_nvidia.success" "NVIDIA driver uninstalled successfully."
tr::add "en_US" "installer::uninstall_nvidia.no_packages" "No NVIDIA packages found to uninstall."
tr::add "en_US" "installer::uninstall_nvidia.removingfile" "Removing file: %1 ..."
