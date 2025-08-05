#!/usr/bin/env bash

# Calcula o diretório base do script
if ! SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P 2>/dev/null); then
    echo "ERRO: Falha ao determinar o diretório do script" >&2
    exit 1
fi
declare -g SCRIPT_DIR

# Importação dos módulos
for file in "$SCRIPT_DIR"/lib/*.sh; do source "$file"; done
for file in "$SCRIPT_DIR"/tui/*.sh; do source "$file"; done
for file in "$SCRIPT_DIR"/src/*.sh; do source "$file"; done

# Garante que o script só seja executado com privilégios root
utils::force_sudo 

# Instala as dependências necessárias para executar o script
log::info "Verificando dependências..."
packages::install "dialog"
log::info "Todas dependências verificadas com sucesso!"

# Inicia o Dialog de navegação
tui::navigate::main

# Limpeza / Encerramento
log::info "Execução encerrada!"
exit 0