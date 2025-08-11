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

declare -g GRUB_FILE="/etc/default/grub"

# Função para adicionar parâmetros ao GRUB_CMDLINE_LINUX_DEFAULT
grub::add_kernel_parameters() {
    local params_array=("$@")

    # Verifica se os parâmetros foram fornecidos
    if [[ ${#params_array[@]} -eq 0 ]]; then
        echo "No kernel parameters provided." >&2
        return 1
    fi

    # Verifica se o arquivo grub existe
    if [ ! -f "$GRUB_FILE" ]; then
        echo "Grub file not found: \"$GRUB_FILE\"." >&2
        return 1
    fi

    local tempfile="$(mktemp)"
    local changed=0

    # Filtra os parâmetros para evitar duplicatas
    while IFS= read -r line; do
        if [[ $line =~ ^GRUB_CMDLINE_LINUX_DEFAULT=\"([^\"]*)\" ]]; then
            read -ra existing_params <<< "${BASH_REMATCH[1]}"
            local new_params=()

            # Verifica se os parâmetros já existem
            for param in "${params_array[@]}"; do
                if [[ ! " ${existing_params[@]} " =~ " ${param} " ]]; then
                    new_params+=("$param")
                fi
            done

            # Adiciona os novos parâmetros ao GRUB_CMDLINE_LINUX_DEFAULT
            if [[ ${#new_params[@]} -gt 0 ]]; then
                echo "Added parameters: \"${new_params[*]}\" to GRUB_CMDLINE_LINUX_DEFAULT." >&2
                changed=1
                local new_params_str=$(IFS=' '; echo "${new_params[*]}")
                echo "$(echo "$line" | sed "s/^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"/GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $new_params_str\"/")" >> "$tempfile"
            else
                echo "$line" >> "$tempfile"
            fi
        else
            echo "$line" >> "$tempfile"
        fi
    done < "$GRUB_FILE"

    # Verifica se houve alterações
    if [[ "$changed" -eq 0 ]]; then
        echo "Nothing changed, all parameters already exist." >&2
        rm -f "$tempfile"
        return 0
    fi

    # Substitui o arquivo original pelo temporário
    echo "Changes made to $GRUB_FILE, updating file." >&2
    if ! mv "$tempfile" "$GRUB_FILE"; then
        echo "Failed to update grub file: \"$GRUB_FILE\"." >&2
        rm -f "$tempfile"
        return 1
    fi

    # Mantém as permissões e propriedade do arquivo grub
    chmod 644 "$GRUB_FILE"
    chown root:root "$GRUB_FILE"
    
    return 0
}

# Função para remover parâmetros do GRUB_CMDLINE_LINUX_DEFAULT
grub::remove_kernel_parameters() {
    local params_array=("$@")

    # Verifica se os parâmetros foram fornecidos
    if [[ ${#params_array[@]} -eq 0 ]]; then
        echo "No kernel parameters provided." >&2
        return 1
    fi

    # Verifica se o arquivo grub existe
    if [ ! -f "$GRUB_FILE" ]; then
        echo "Grub file not found: \"$GRUB_FILE\"." >&2
        return 1
    fi

    local tempfile="$(mktemp)"

    # Remove os parâmetros do GRUB_CMDLINE_LINUX_DEFAULT
    while IFS= read -r line; do
        if [[ $line =~ ^GRUB_CMDLINE_LINUX_DEFAULT=\"([^\"]*)\" ]]; then
            read -ra existing_params <<< "${BASH_REMATCH[1]}"

            local filtered_params=()
            local changed=0

            for param in "${existing_params[@]}"; do
                local keep=1
        
                for existing_param in "${params_array[@]}"; do                  
                    if [[ "$existing_param" == "$param" ]]; then
                        echo "Removing parameter: $param" >&2
                        keep=0
                        changed=1
                        break
                    fi
                done

                if (( keep )); then
                    filtered_params+=("$param")
                fi
            done

            local filtered_params_str="${filtered_params[*]}"
            local new_line
            new_line="$(sed "s/^GRUB_CMDLINE_LINUX_DEFAULT=\".*\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$filtered_params_str\"/" <<< "$line")"

            echo "$new_line" >> "$tempfile"
        else
            echo "$line" >> "$tempfile"
        fi

    done < "$GRUB_FILE"

    # Verifica se houve alterações
    if [[ "$changed" -eq 0 ]]; then
        echo "Nothing changed, all specified parameters were not found." >&2
        rm -f "$tempfile"
        return 0
    fi

    # Substitui o arquivo original pelo temporário
    echo "Changes made to $GRUB_FILE, updating file." >&2
    if ! mv "$tempfile" "$GRUB_FILE"; then
        echo "Failed to update grub file: \"$GRUB_FILE\"." >&2
        rm -f "$tempfile"
        return 1
    fi

    # Mantém as permissões e propriedade do arquivo grub
    chmod 644 "$GRUB_FILE"
    chown root:root "$GRUB_FILE"

    return 0
}

# Atualiza o GRUB
grub::update_grub() {
    update-grub | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}