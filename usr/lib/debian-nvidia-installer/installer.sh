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

    log::info "Verificando pacote: $pkg..."
    
    # Verifica se o pacote já está instalado antes de continuar
    if packages::is_installed "$pkg"; then
        log::info "Pacote $pkg já instalado. Instalação ignorada."
        return 0
    fi

    log::info "Pacote $pkg não encontrado no sistema. Iniciando instalação..."

    log::info "Atualizando lista de pacotes..."

    # Tenta atualizar, mas continua mesmo se falhar
    if packages::update; then
        log::info "Lista de pacotes atualizada com sucesso."
    else
        log::warn "Falha ao atualizar lista de pacotes."
    fi

    # Caso de sucesso na instalação
    if packages::install "$pkg"; then
        log::info "Pacote $pkg instalado com sucesso."
        return 0
    fi
    
    # Caso de falha na instalação
    log::error "Falha na instalação de $pkg."
    return 1
}

installer::remove_package() {
    local pkg="$1"

    log::info "Removendo pacote $pkg..."

    if ! packages::remove "$pkg"; then
        log::error "Falha ao remover pacote $pkg."
        return 1
    fi

    log::info "Pacote $pkg removido com sucesso." 

    return 0
}

installer::install_nvidia_proprietary() {
    if ! tui::show_yesno "AVISO" "Você está prestes a instalar o driver do flavor Proprietário da Nvidia.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Instalação cancelada pelo usuário."
        return 1
    fi

    log::info "Instalando drivers da Nvidia..."

    if ! installer::install_package "nvidia-kernel-dkms"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-kernel-dkms"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-driver"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "Falha na instalação do pacote do driver: firmware-misc-nonfree"
        return 1
    fi
    
    log::info "Drivers instalados com sucesso!"
    tui::show_msgbox "" "Instalação concluída com sucesso!"
    tui::show_msgbox "AVISO" "Reinicie o sistema para que as alterações sejam aplicadas."
    return 0
}

installer::install_nvidia_open() {
    if ! tui::show_yesno "AVISO" "Você está prestes a instalar o driver do flavor Open Source da Nvidia.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Instalação cancelada pelo usuário."
        return 1
    fi

    log::info "Instalando drivers da Nvidia..."

    if ! installer::install_package "nvidia-open-kernel-dkms"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-open-kernel-dkms"
        return 1
    fi

    if ! installer::install_package "nvidia-driver"; then
        log::critical "Falha na instalação do pacote do driver: nvidia-driver"
        return 1
    fi

    if ! installer::install_package "firmware-misc-nonfree"; then
        log::critical "Falha na instalação do pacote do driver: firmware-misc-nonfree"
        return 1
    fi
    
    log::info "Drivers instalados com sucesso!"
    tui::show_msgbox "" "Instalação concluída com sucesso!"
    tui::show_msgbox "AVISO" "Reinicie o sistema para que as alterações sejam aplicadas."
    return 0
}

installer::install_pre_requisites() {
    local ARCH KERNEL VERSION HEADER_PKG
    ARCH=$(uname -m)
    KERNEL=$(uname -r)

    case "$ARCH" in
        "i386"|"i686")
            if [[ "$KERNEL" == *"686-pae"* ]]; then
                HEADER_PKG="linux-headers-686-pae"
            else
                HEADER_PKG="linux-headers-686"
            fi
            ;;
        "x86_64")
            HEADER_PKG="linux-headers-amd64"
            ;;
        *)
            log::critical "Arquitetura não suportada: $ARCH"
            tui::show_msgbox "Erro" "Arquitetura $ARCH não é suportada!" "Abortar"
            exit 1
            ;;
    esac

    log::info "Instalando pré-requisitos para $ARCH..."

    if ! installer::install_package "mokutil"; then
        log::critical "Falha na instalação do pacote mokutil. Abortando."
        return 1
    fi

    if ! installer::install_package "$HEADER_PKG"; then
        log::critical "Falha na instalação do pacote ${HEADER_PKG}. Abortando."
        return 1
    fi
    
    log::info "Pré-requisitos instalados com sucesso!"
    return 0
}

installer::install_cuda() {
    local PACKAGES=("nvidia-cuda-dev" "nvidia-cuda-toolkit")
    local INSTALLED=()

    for pkg in "${PACKAGES[@]}"; do
        if packages::is_installed "$pkg"; then
            INSTALLED+=("$pkg")
        fi
    done

    if [[ ${#INSTALLED[@]} -gt 0 ]]; then
        local MSG="Os seguintes pacotes já estão instalados:\n\n"
        MSG+=$(printf "%s\n" "${INSTALLED[@]}")
        MSG+="\nDeseja removê-los?"

        if tui::show_yesno "Pacotes já instalados" "$MSG" "Remover" "Cancelar"; then
            for pkg in "${INSTALLED[@]}"; do
                if ! installer::remove_package "$pkg"; then
                    log::critical "Falha ao remover o pacote: $pkg"
                    log::input _ "Pressione Enter para continuar..."
                    return 1
                fi
                log::info "Removido com sucesso: $pkg"
            done
            return 0
        else
            log::info "Remoção cancelada pelo usuário."
            return 0
        fi
    fi

    if ! tui::show_yesno "AVISO" \
        "Você está prestes a instalar as bibliotecas Nvidia CUDA.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Instalação cancelada pelo usuário."
        return 1
    fi

    for pkg in "${PACKAGES[@]}"; do
        if ! installer::install_package "$pkg"; then
            log::critical "Falha na instalação do pacote: $pkg"
            return 1
        fi
    done

    log::info "Instalação concluída!"
    tui::show_msgbox "" "Instalação concluída!"
    return 0
}

installer::install_optix() {
    local PACKAGE="libnvoptix1"

    if packages::is_installed "$PACKAGE"; then
        if tui::show_yesno "Pacote já instalado" \
            "O pacote $PACKAGE já está instalado.\n\nDeseja removê-lo?" "Remover" "Cancelar"; then

            if ! installer::remove_package "$PACKAGE"; then
                log::critical "Falha ao remover pacote: $PACKAGE"
                log::input _ "Pressione Enter para continuar..."
                return 1
            fi

            log::info "Pacote removido com sucesso."
            return 0  # Encerra após a remoção
        else
            log::info "Ação cancelada pelo usuário."
            return 0  # Encerra mesmo se o usuário decidir não remover
        fi
    fi

    if ! tui::show_yesno "AVISO" \
        "Você está prestes a instalar as bibliotecas Nvidia OptiX.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Instalação cancelada pelo usuário."
        return 1
    fi

    if ! installer::install_package "$PACKAGE"; then
        log::critical "Falha na instalação do pacote: $PACKAGE"
        return 1
    fi

    log::info "Instalação concluída!"
    tui::show_msgbox "" "Instalação concluída!"
    return 0
}

installer::switch_nvidia_drm() {
    local drm_file="/sys/module/nvidia_drm/parameters/modeset"
    local conf_file="/etc/modprobe.d/nvidia-options.conf"
    local modeset_line="options nvidia-drm modeset=1"
    local current_state

    if [[ ! -f "$drm_file" ]]; then
        log::error "O módulo nvidia_drm não está carregado ou o arquivo $drm_file não existe."
        log::input _ "Pressione Enter para continuar..."
        return 1
    fi

    current_state=$(cat "$drm_file")

    if [[ "$current_state" == "Y" ]]; then
        log::info "O DRM da NVIDIA está ATIVADO (modeset=1)."
        
        if tui::show_yesno "DRM Ativo" "O DRM da NVIDIA já está ativado.\n\nDeseja DESATIVÁ-LO?" "Desativar" "Cancelar"; then
            if [[ -f "$conf_file" ]] && grep -qF "$modeset_line" "$conf_file"; then
                sed -i "\|^$modeset_line$|d" "$conf_file"
                log::info "Linha removida de $conf_file: $modeset_line"
            fi
            log::info "DRM da NVIDIA foi desativado na configuração."
            tui::show_msgbox "DRM Desativado" "O DRM da NVIDIA foi desativado na configuração.\n\nReinicie o sistema para aplicar a mudança."
        else
            log::info "Ação cancelada pelo usuário."
            return 0
        fi

    elif [[ "$current_state" == "N" ]]; then
        log::info "O DRM da NVIDIA está DESATIVADO (modeset=0)."

        if tui::show_yesno "DRM Desativado" "O DRM da NVIDIA está desativado.\n\nDeseja ATIVÁ-LO?" "Ativar" "Cancelar"; then
            if ! grep -qF "$modeset_line" "$conf_file"; then
                echo "$modeset_line" >> "$conf_file"
                log::info "Linha adicionada a $conf_file: $modeset_line"
            else
                log::info "A linha já existe em $conf_file. Nenhuma alteração necessária."
            fi
            log::info "DRM da NVIDIA foi ativado na configuração."
            tui::show_msgbox "DRM Ativado" "O DRM da NVIDIA foi ativado na configuração.\n\nReinicie o sistema para aplicar a mudança."
        else
            log::info "Ação cancelada pelo usuário."
            return 0
        fi

    else
        log::critical "Valor inesperado encontrado em $drm_file: $current_state"
        tui::show_msgbox "Erro" "Valor inesperado em $drm_file: $current_state"
        return 1
    fi

    return 0
}

installer::switch_nvidia_pvma() {
    local conf_file="/etc/modprobe.d/nvidia-options.conf"
    local pvma_line="options nvidia NVreg_PreserveVideoMemoryAllocations=1"
    local current_state

    if [[ -f "$conf_file" ]] && grep -qF "$pvma_line" "$conf_file"; then
        current_state="Y"
    else
        current_state="N"
    fi

    if [[ "$current_state" == "Y" ]]; then
        log::info "PVMA (PreserveVideoMemoryAllocations) da NVIDIA está ATIVADO na configuração."

        if tui::show_yesno "PVMA Ativo" \
            "O recurso PreserveVideoMemoryAllocations já está ativado.\n\nDeseja DESATIVÁ-LO?" "Desativar" "Cancelar"; then
            if grep -qF "$pvma_line" "$conf_file"; then
                sed -i "\|^$pvma_line$|d" "$conf_file"
                log::info "Linha removida de $conf_file: $pvma_line"
            fi
            log::info "PVMA foi desativado na configuração."
            tui::show_msgbox "PVMA Desativado" "O recurso PreserveVideoMemoryAllocations foi desativado.\n\nReinicie o sistema para aplicar a mudança."
        else
            log::info "Ação cancelada pelo usuário."
            return 0
        fi

    elif [[ "$current_state" == "N" ]]; then
        log::info "PVMA (PreserveVideoMemoryAllocations) da NVIDIA está DESATIVADO na configuração."

        if tui::show_yesno "PVMA Desativado" \
            "O recurso PreserveVideoMemoryAllocations está desativado.\n\nDeseja ATIVÁ-LO?" "Ativar" "Cancelar"; then
            echo "$pvma_line" >> "$conf_file"
            log::info "Linha adicionada a $conf_file: $pvma_line"
            log::info "PVMA foi ativado na configuração."
            tui::show_msgbox "PVMA Ativado" "O recurso PreserveVideoMemoryAllocations foi ativado.\n\nReinicie o sistema para aplicar a mudança."
        else
            log::info "Ação cancelada pelo usuário."
            return 0
        fi

    else
        log::critical "Estado inesperado ao verificar PVMA."
        tui::show_msgbox "Erro" "Não foi possível determinar o estado atual do PVMA."
        return 1
    fi

    return 0
}

setup_mok() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    # Instala o pacote dkms com abstração
    if ! installer::install_package "dkms"; then
        log::critical "Não foi possível instalar o pacote 'dkms', necessário para configurar o MOK."
        log::input _ "Pressione Enter para continuar..."
        return 1
    fi

    tui::show_msgbox "MOK - Requer senha" \
        "Você precisará criar uma senha para a chave MOK.\n\nAnote essa senha com segurança, pois ela será exigida após reinicialização."

    if ! dkms generate_mok; then
        log::critical "Falha ao gerar a chave MOK."
        log::input _ "Pressione Enter para continuar..."
        return 1
    fi

    log::info "Importando chave MOK..."
    if ! mokutil --import "$mok_pub_path"; then
        log::critical "Falha ao importar chave MOK."
        log::input _ "Pressione Enter para continuar..."
        return 1
    fi

    log::success "Chave MOK configurada com sucesso!"
    tui::show_msgbox "Reinicialização necessária" \
        "A chave MOK foi importada.\n\nReinicie o sistema e, no menu do MOK Manager:\n\n - Escolha: Enroll MOK\n - Confirme\n - Digite a senha\n - Reinicie novamente\n\nDepois disso, execute este script novamente."

    exit 0
}

check_secure_boot() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    log::info "Verificando estado do Secure Boot..."

    # Verifica se mokutil está disponível, senão tenta instalar
    if ! command -v mokutil &>/dev/null; then
        log::warn "mokutil não está instalado. Tentando instalar..."
        if ! installer::install_package "mokutil"; then
            log::critical "mokutil não pode ser instalado. Verificação do Secure Boot falhou."
            log::input _ "Pressione Enter para continuar..."
            return 1
        fi
    fi

    if mokutil --sb-state | grep -q "enabled"; then
        log::info "Secure Boot está ATIVADO."

        if [[ -f "$mok_pub_path" ]] && mokutil --test-key "$mok_pub_path" | grep -q "is already enrolled"; then
            log::info "Chave MOK já está registrada. Nenhuma ação necessária."
            return 0
        fi

        log::warning "Chave MOK não encontrada ou não registrada."
        tui::show_msgbox "MOK ausente" \
            "O Secure Boot está ativado, mas a chave MOK não está registrada.\n\nDrivers NVIDIA podem não funcionar corretamente sem assinatura de kernel."

        if tui::show_yesno "Configurar MOK?" \
            "Deseja configurar a chave MOK agora com o assistente?" "Sim" "Não"; then
            setup_mok
        else
            log::critical "Configuração de MOK necessária foi recusada."
            tui::show_msgbox "Abortado" \
                "Configure a chave MOK manualmente ou desative o Secure Boot para continuar.\n\nConsulte:\nhttps://wiki.debian.org/SecureBoot"
            return 1
        fi
    else
        log::info "Secure Boot está DESATIVADO. Nenhuma ação necessária."
    fi

    return 0
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

        tui::show_msgbox "GPUs Nvidia detectadas:" "$nvidia_gpus"
    else
        log::error "Nenhuma GPU Nvidia detectada no sistema."
        tui::show_msgbox "Erro" "Nenhuma GPU Nvidia detectada no sistema." "Abortar"
        NAVIGATION_STATUS=0
        return 1
    fi

    if ! installer::install_pre_requisites; then
        dialog "Erro" "Falha na instalação dos pré-requisitos." "Abortar"
        NAVIGATION_STATUS=0
        return 1
    fi

    if ! check_secure_boot; then
        return 1
    fi

    tui::navigate::flavors
}

installer::uninstall_nvidia() {
    if ! tui::show_yesno "AVISO" "Você está prestes a desinstalar o driver da Nvidia.\n\nDeseja continuar?" "Confirmar" "Cancelar"; then
        log::info "Desinstalação cancelada pelo usuário."
        return 1
    fi

    log::info "Iniciando desinstalação dos drivers da Nvidia..."

    if ! installer::remove_package "*nvidia*"; then
        log::critical "Falha na desinstalação dos drivers da Nvidia!"
        return 1
    fi

    installer::remove_package "libnvoptix1"

    # Reinstala o nouveau como fallback
    if ! apt install --reinstall xserver-xorg-core xserver-xorg-video-nouveau; then
        log::critical "Falha na reinstalação do nouveau!"
        log::input _ "Pressione Enter para continuar..."
        return 1
    fi

    log::info "Desinstalação dos drivers da Nvidia concluída."
    tui::show_msgbox "" "Desinstalação concluída!"
    tui::show_msgbox "AVISO" "Reinicie o sistema para que as alterações sejam aplicadas."
    return 0
}