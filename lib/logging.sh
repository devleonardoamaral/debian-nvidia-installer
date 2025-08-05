#!/usr/bin/env bash

# Constantes de formatação ANSI
declare -r LOG_ESC_BOLD_RED='\033[1;31m'        # Vermelho com negrito
declare -r LOG_ESC_BOLD_YELLOW='\033[1;33m'     # Amarelo com negrito
declare -r LOG_ESC_BOLD_BLUE='\033[1;34m'       # Azul com negrito
declare -r LOG_ESC_BOLD_MAGENTA='\x1b[1;35m'    # Magenta com negrito
declare -r LOG_ESC_BOLD='\033[1m'               # Negrito
declare -r LOG_ESC_RESET='\033[0m'              # Reset

# Log info (saída padrão)
log::info() {
    echo -e "${LOG_ESC_BOLD_BLUE}Info:${LOG_ESC_RESET} $1" >&2
}

# Log warning (saída de erro)
log::warn() {
    echo -e "${LOG_ESC_BOLD_YELLOW}Warn:${LOG_ESC_RESET}${LOG_ESC_BOLD} $1 ${LOG_ESC_RESET}" >&2
}

# Log error (saída de erro)
log::error() {
    echo -e "${LOG_ESC_BOLD_RED}Erro:${LOG_ESC_RESET}${LOG_ESC_BOLD} $1 ${LOG_ESC_RESET}" >&2
}

# Log crítico (saída de erro + encerra script)
log::critical() {
    echo -e "${LOG_ESC_BOLD_RED}CRITICAL:${LOG_ESC_RESET}${LOG_ESC_BOLD} $1 ${LOG_ESC_RESET}" >&2
    echo -e "${LOG_ESC_BOLD_RED}Execução abortada!${LOG_ESC_RESET}" >&2
    exit 1
}

# Input de usuário. Armazena o valor do input na variável passada como parâmetro.
log::input() {
    local __varname=$1
    shift
    echo -ne "${LOG_ESC_BOLD_MAGENTA}>>>${LOG_ESC_RESET}${LOG_ESC_BOLD} $* ${LOG_ESC_RESET}" >&2
    read -r user_input
    printf -v "$__varname" '%s' "$user_input"
}