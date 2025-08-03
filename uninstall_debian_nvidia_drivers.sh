#!/usr/bin/env bash

# Configurações de segurança
set -euo pipefail

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

# Função para tratamento de erros
handle_error() {
    log_error "$1"
    echo -e "${FRED}CRITICAL: Execução abortada!${FRESET}"
    exit 1
}

# --------------- EXECUÇÃO -----------------

log_info "Iniciando desinstalação dos drivers da Nvidia..."

# 1. Verifica se há drivers NVIDIA instalados
if ! dpkg -l | grep -q "nvidia"; then
    log_warn "Nenhum driver NVIDIA encontrado para remoção."
    exit 0
fi

# 2. Desinstalação principal (com tratamento de erro)
if ! sudo apt purge -y "*nvidia*" "libnvoptix*" "libnvidia-ngx*"; then
    handle_error "Falha na remoção dos pacotes NVIDIA."
fi

# 3. Limpeza e fallback
log_info "Limpando dependências não utilizadas..."
sudo apt autoremove -y || log_warn "Algumas dependências não puderam ser removidas."

log_info "Restaurando driver Nouveau..."
if ! sudo apt install -y --reinstall xserver-xorg-core xserver-xorg-video-nouveau; then
    log_error "Falha crítica ao reinstalar Nouveau."
fi

log_info "DRIVERS NVIDIA REMOVIDOS COM SUCESSO."
log_warn "Reinicie o sistema para completar o processo."
log_warn "sudo systemctl reboot"