#!/usr/bin/env bash

# Configurações de segurança
set -euo pipefail # Aborta em erros, trata variáveis não definidas e pipes com falha

# Definindo cores (constantes)
FRED='\033[1;31m'      # Vermelho com negrito
FYELLOW='\033[1;33m'   # Amarelo com negrito
FBLUE='\033[1;34m'     # Azul com negrito
FMAG="\x1b[1;35m"      # Magenta com negrito
FBOLD='\033[1m'        # Negrito
FRESET='\033[0m'       # Reset

# Funções de logging
log_error() {
    echo -e "${FRED}Erro:${FRESET}${FBOLD} $1 ${FRESET}" >&2
}

log_info() {
    echo -e "${FBLUE}Info:${FRESET} $1" >&2
}

log_warn() {
    echo -e "${FYELLOW}Warn:${FRESET}${FBOLD} $1 ${FRESET}" >&2
}

log_input() {
    echo -ne "${FMAG}>>>${FRESET}${FBOLD} $1 ${FRESET}" >&2
}

# Função para tratamento de erros
handle_error() {
    log_error "$1"
    echo -e "${FRED}CRITICAL: Execução abortada!${FRESET}"
    exit 1
}

# Função para verificar se há GPU NVIDIA
check_nvidia_gpu() {
    log_info "Buscando por GPUs Nvidia..."

    if ! lspci | grep -qi "NVIDIA"; then
        log_warn "Nenhuma GPU NVIDIA detectada!"
        log_input "Deseja continuar a instalação? [S/N] "

        while true; do
            read -r resposta

            case "${resposta^^}" in
                "S") break ;;
                "N") handle_error "Instalação cancelada pelo usuário." ;;
                *) log_warn "Opção inválida." ;;
            esac
        done
    fi

    log_info "GPU Nvidia detectada."
}

# Função para configurar o MOK
setup_mok() {
    local mok_pub_path="/var/lib/dkms/mok.pub"

    log_info "Instalando dkms..."
    (sudo apt update && sudo apt install -y dkms) || handle_error "Falha ao instalar dkms."

    log_warn "Crie uma senha para a chave MOK (anote-a!):"
    sudo dkms generate_mok || handle_error "Falha ao gerar chave MOK."

    log_info "Importando chave..."
    sudo mokutil --import "$mok_pub_path" || handle_error "Falha ao importar chave."

    log_info "Chave MOK configurada com sucesso!"
    log_warn "Reinicie o sistema, complete o registro no MOK Manager (enroll MOK > continue > confirm > insira a senha > reboot) e execute este script novamente."
    exit 0
}

# Função para verificar o Secure Boot
check_secure_boot() {
    log_info "Verificando estado do Secure Boot..."
    local mok_pub_path="/var/lib/dkms/mok.pub"

    if command -v mokutil &>/dev/null; then
        if mokutil --sb-state | grep -q "enabled"; then
            log_info "Estado do Secure Boot: ATIVADO."

            if [[ -f "$mok_pub_path" ]] && [[ "$(sudo mokutil --test-key $mok_pub_path)" == *"is already enrolled"* ]]; then
                log_info "Chave MOK encontrada. Pulando geração."
                return 0
            else
                log_warn "Chave MOK não encontrada. Drivers NVIDIA podem requerer assinatura manual."
                log_warn "Consulte: https://wiki.debian.org/SecureBoot"

                while true; do
                    log_input "Deseja configurar o MOK agora com o assistente? [S/N]"
                    read -r resposta

                    case "${resposta^^}" in
                        "S") setup_mok; break ;;
                        "N") handle_error "Configure a chave MOK manualmente e execute novamente o script ou desative o Secure Boot." ;;
                        *) log_warn "Opção inválida." ;;
                    esac
                done
            fi
        else
            log_info "Estado do Secure Boot: DESATIVADO."
        fi
    else
        handle_error "mokutil não instalado. Não foi possível verificar Secure Boot."
    fi
}

# Função para habilitar os repositórios necessários
enable_nonfree_repos() {
    log_info "Verificando repositórios non-free..."
    
    local sources_file="/etc/apt/sources.list"
    local temp_file=$(mktemp)
    local changed=0

    while IFS= read -r line; do
        if [[ "$line" =~ ^(deb|deb-src)[[:space:]] ]]; then
            # Extrai a base da linha (URL/distro) e componentes atuais
            base=$(echo "$line" | sed -E 's/^(deb|deb-src)\s+(\S+)\s+(\S+)\s+.*/\1 \2 \3/')
            current_components=$(echo "$line" | grep -oP '^(deb|deb-src)\s+\S+\s+\S+\s+\K.*')

            # Verifica componentes faltantes
            missing_components=""
            [[ " $current_components " != *" contrib "* ]] && missing_components+=" contrib"
            [[ " $current_components " != *" non-free "* ]] && missing_components+=" non-free"
            [[ " $current_components " != *" non-free-firmware "* ]] && missing_components+=" non-free-firmware"

            if [[ -n "$missing_components" ]]; then
                new_line="$base ${current_components%% }${missing_components}"
                if [[ "$line" != "$new_line" ]]; then
                    log_info "Atualizando: $line"
                    log_info "Para: $new_line"
                    echo "$new_line" >> "$temp_file"
                    changed=1
                    continue
                fi
            fi
        fi
        echo "$line" >> "$temp_file"
    done < "$sources_file"

    if [[ $changed -eq 1 ]]; then
        log_info "Atualizando /etc/apt/sources.list..."
        sudo cp "$temp_file" "$sources_file" || { rm -f "$temp_file"; return 1; }
        sudo chmod 644 "$sources_file"
        log_info "Atualizando lista de pacotes..."
        sudo apt update || return 1
    else
        log_info "Repositórios já contêm contrib/non-free."
    fi

    rm -f "$temp_file"
    return 0
}

# Função para instalar os pré-requisitos
install_pre_requisites() {
    local ARCH HEADER_PKG
    ARCH=$(uname -m)

    case "$ARCH" in
        "i386"|"i686")
            if grep -q "PAE" /proc/cpuinfo; then
                HEADER_PKG="linux-headers-686-pae"
            else
                HEADER_PKG="linux-headers-686"
            fi
            ;;
        "x86_64")
            HEADER_PKG="linux-headers-amd64"
            ;;
        *)
            handle_error "Arquitetura não suportada: $ARCH"
            ;;
    esac

    log_info "Instalando pré-requisitos para $ARCH..."
    log_info "Pacotes: $HEADER_PKG mokutil"
    
    if ! sudo apt update; then
        handle_error "Falha ao atualizar repositórios APT"
    fi

    if ! sudo apt install -y "$HEADER_PKG" mokutil; then
        handle_error "Falha ao instalar pacotes: $HEADER_PKG mokutil"
    fi

    log_info "Pré-requisitos instalados com sucesso!"
}

# Função para instalar bibliotecas extras da Nvidia
install_nvidia_libs() {
    log_info "Instalando bibliotecas CUDA..."
    if ! (sudo apt update && sudo apt install -y nvidia-cuda-dev nvidia-cuda-toolkit); then
        handle_error "Falha as bibliotecas CUDA."
    fi

    while true; do
        log_warn "Verifique se sua GPU é compatível antes de instalar OptiX."
        log_input "Deseja instalar OptiX? [S/N]"
        read -r resposta

        # Seleciona qual flavor do driver instalar
        case "${resposta^^}" in
            "S") 
                log_info "Instalando bibliotecas OptiX..."
                if ! (sudo apt update && sudo apt install -y libnvoptix1); then
                    handle_error "Falha as bibliotecas OptiX."
                fi
                break
            ;;
            "N") break ;;
            *) log_warn "Opção inválida." ;;
        esac
    done

    while true; do
        log_warn "Verifique se sua GPU é compatível antes de instalar Nvidia NGX Runtime."
        log_input "Deseja instalar Nvidia NGX Runtime? [S/N]"
        read -r resposta

        # Seleciona qual flavor do driver instalar
        case "${resposta^^}" in
            "S") 
                log_info "Instalando bibliotecas Nvidia NGX Runtime..."
                if ! (sudo apt update && sudo apt install -y libnvidia-ngx1); then
                    handle_error "Falha as bibliotecas Nvidia NGX Runtime."
                fi
                break
            ;;
            "N") break ;;
            *) log_warn "Opção inválida." ;;
        esac
    done   
}

# Função para instalar os drivers proprietários
install_proprietary_drivers() {
    log_info "Instalando drivers..."
    if ! (sudo apt update && sudo apt install -y nvidia-kernel-dkms nvidia-driver firmware-misc-nonfree); then
        handle_error "Falha ao instalar drivers."
    fi

    install_nvidia_libs
}

# Função para instalar os drivers open
install_open_drivers() {
    log_info "Instalando drivers..."
    if ! (sudo apt update && sudo apt install -y nvidia-open-kernel-dkms nvidia-driver firmware-misc-nonfree); then
        handle_error "Falha ao instalar drivers."
    fi

    install_nvidia_libs
}

# --------------- EXECUÇÃO -----------------

log_warn "Não utilize este script se sua GPU for Nvidia Tesla."

# Verifica se o script está sendo executado como root
if [  "$(id -u)" -ne 0 ]; then
    log_warn "Este script requer privilégios de root."
    log_info "Solicitando privilégios de root..."
    exec sudo --preserve-env "$0" "$@"
    exit 1
fi

log_info "Iniciando instalação..."

# Verifica se há uma GPU Nvidia antes de prosseguir
check_nvidia_gpu

# Verificação dos Repositórios
while true; do
    log_warn "Para instalar os drivers da Nvidia é necessário ativar os repositórios 'contrib', 'non-free' e 'non-free-firmware'."
    log_warn "Consulte: https://wiki.debian.org/NvidiaGraphicsDrivers"
    log_input "Deseja que o script atualize os repositórios automaticamente? [S/N]"
    read -r resposta

    # Seleciona qual flavor do driver instalar
    case "${resposta^^}" in
        "S") enable_nonfree_repos || handle_error "Erro ao habilitar repositórios non-free."; break ;;
        "N") break ;;
        *) log_warn "Opção inválida." ;;
    esac
done

# Instalação dos pre-requisitos
install_pre_requisites

# Verificação do Secure Boot
check_secure_boot

# Instalação dos drivers
while true; do
    log_input "Qual flavor do driver da Nvidia você quer instalar? [Proprietary/Open]"
    read -r resposta

    # Seleciona qual flavor do driver instalar
    case "${resposta^^}" in
        "PROPRIETARY") install_proprietary_drivers; break ;;
        "OPEN") install_open_drivers; break ;;
        *) log_warn "Opção inválida." ;;
    esac
done

log_warn "DRIVERS DA NVIDIA INSTALADOS COM SUCESSO!"
log_warn "Reinicie o sistema para que o driver seja iniciado corretamente."