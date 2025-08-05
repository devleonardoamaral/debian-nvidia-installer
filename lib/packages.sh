#!/usr/bin/env bash

# Verifica os componentes do sources.list
# Verifica se os $parametros[@] existem em cada entrada deb|deb-src do sources.list
packages::check_sources_components() {
    local sources_file="/etc/apt/sources.list"
    local results=0
    local lines=0
    local components_found=0

    # Lê linha por linha do arquivo até o final
    while IFS= read -r line; do

        # Verifica se a linha começa com deb|deb-src e um espaço
        if [[ "$line" =~ ^(deb|deb-src)[[:space:]] ]]; then
            ((lines++)) # Conta as linhas válidas
            components_found=0 # Reseta o contador a cada nova linha válida

            # Extraí os componentes do final do source em um array
            read -ra extracted_components <<< "$(grep -oP '^(deb|deb-src)\s+\S+\s+\S+\s+\S+\s+\K.*' <<< "$line")"
            
            # Percorre os parametros de entrada e compara se todos existem no array de componentes
            for param in "$@"; do
                for comp in "${extracted_components[@]}"; do
                    if [[ "$param" == "$comp" ]]; then
                        ((components_found++))
                        break
                    fi
                done
            done

            # Salva o resultado da verificação
            if [[ "$components_found" -eq "$#" ]]; then
                ((results++))
            fi
        fi
    done < "$sources_file" || return 1 # Retorna 1 como fallback, caso o arquivo não seja encontrado

    if [[ "$lines" -eq "$results" ]]; then
        return 0 # Todos os parametros existem em todas as linhas de source do arquivo
    else
        return 1 # Uma ou mais linhas possuem componentes faltando
    fi
}

# Atualiza a lista de pacotes
packages::update() {
    local ret
    log::info "Atualizando lista de pacotes..."

    apt update
    ret=$?

    if (( $ret == 0 )); then
        log::info "Lista de pacotes atualizada com sucesso."
        return $ret
    fi

    log::warn "Falha ao atualizar lista de pacotes."
    return $ret
}

# Verifica se um pacote está instalado.
packages::is_installed() {
    dpkg -s "$1" &>/dev/null # Emite return 0 ou 1.
}

# Instala um pacote no sistema
packages::install() {
    local pkg="$1"

    log::info "Verificando pacote: $pkg..."
    
    # Verifica se o pacote já está instalado antes de continuar
    if packages::is_installed "$pkg"; then
        log::info "Pacote $pkg já instalado. Instalação ignorada."
        return 0
    fi

    log::info "Pacote $pkg não encontrado no sistema. Iniciando instalação..."

    # Tenta atualizar, mas continua mesmo se falhar
    if ! packages::update; then
        log::warn "Continuando com lista de pacotes desatualizada."
    fi

    # Caso de sucesso na instalação
    if apt install -y "$pkg"; then
        log::info "Pacote $pkg instalado com sucesso."
        return 0
    fi
    
    # Caso de falha na instalação
    log::error "Falha na instalação de $pkg."
    return 1
}