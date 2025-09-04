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

# Check whether each source entry in a sources list file includes all the specified components.
# sources_file ($1): path to the sources list file (e.g., /etc/apt/sources.list)
# components ($@): list of components to check for each source entry
#                   (e.g., "contrib", "non-free", "non-free-firmware")
# Returns:
#   0 - every source entry contains all the specified components
#   1 - any source entry is missing a component
#   2 - the file does not exist or is invalid
packages::check_sources_components() {
    local sources_file="$1"
    shift
    local required_components=("$@")

    # Check that the sources file exists and is a regular file or symlink
    if [ -z "$sources_file" ] || { [ ! -f "$sources_file" ] && [ ! -h "$sources_file" ]; }; then
        echo "Invalid source file: $source_file" >&2
        return 2
    fi

    # If no components are specified, consider the sources list valid
    if [ "${#required_components[@]}" -eq 0 ]; then
        echo "No components suppied to check" >&2
        return 0
    fi

    # Read the sources file line by line
    while IFS= read -r line; do
        # Ignore lines that are not source entries (deb or deb-src)
        [[ "$line" =~ ^(deb|deb-src)[[:space:]] ]] || continue

        # Extract the components from the line (fields 5 and onward)
        read -ra line_components <<< "$line"
        line_components=("${line_components[@]:4}")

        # Check that all required components are present in the line
        for req in "${required_components[@]}"; do
            local found=0
            for comp in "${line_components[@]}"; do
                if [ "$comp" = "$req" ]; then
                    found=1
                    break
                fi
            done

            # If a required component is missing, return 1 immediately
            if [ "$found" -eq 0 ]; then
                return 1
            fi
        done
    done < "$sources_file"

    # All source entries have the required components
    return 0
}

# Add new components to the provided sources.list file, and update the apt sources list afterwards.
# sources_file ($1): path to the sources.list file (e.g., /etc/apt/sources.list)
# components ($@): list of components to add to each source entry
#                   (e.g., "contrib", "non-free", "non-free-firmware")
# Returns:
#   0 - all components were added successfully to the provided sources.list file
#   1 - an error occurred while trying to add the components to the file
#   2 - the file does not exist or is invalid
#   3 - failed to update the apt sources list after successfully adding all components
packages::add_sources_components() {
    local sources_file="$1"
    shift
    local components=("$@")

    # Check if the sources file exists and if is a regular file or symlink
    if [ -z "$sources_file" ] || { [ ! -f "$sources_file" ] && [ ! -h "$sources_file" ]; }; then
        echo "Invalid source file: $source_file" >&2
        return 2
    fi

    # If no components are specified, consider that all the components are successfuly added
    if [ "${#components[@]}" -eq 0 ]; then
        echo "No components suppied to add" >&2
        return 0
    fi

    # Copy sources file to temp dir preserving it metadata
    local tempfile="/tmp/$(basename "$sources_file").bak"
    if ! cp -p "$sources_file" "$tempfile"; then
        echo "Failed to copy source list" >&2
        return 1
    fi

    # Ensure cleanup when the funcion return
    trap 'rm -f "$tempfile"' RETURN

    # Clear all content of the tempfile
    echo -n > "$tempfile"

    # Read the sources file line by line
    local changed=0
    while IFS= read -r line; do
        # If the line is a source entry do...
        if [[ "$line" =~ ^(deb|deb-src)[[:space:]] ]]; then
            # Extract the components from the line
            read -ra line_components <<< "$line"

            # Get base line components
            local base_components=("${line_components[@]:0:4}")

            # Get current line components
            line_components=("${line_components[@]:4}")

            # Get missing components of the line
            local missing_components=()
            for comp in "${components[@]}"; do
                local found=0
                for linecomp in "${line_components[@]}"; do
                    if [ "$comp" = "$linecomp" ]; then
                        found=1
                        break
                    fi
                done

                if [ "$found" -eq 0 ]; then
                    missing_components+=("$comp")
                fi
            done

            # Add missing components at the end of the line and write changes to the tempfile
            if [ "${#missing_components[@]}" -gt 0 ]; then
                new_line="${base_components[@]} ${line_components[@]} ${missing_components[@]}"
                echo "$new_line" >> "$tempfile"
                changed=1
                continue
            fi
        fi

        # Write not changed lines to the tempfile
        echo "$line" >> "$tempfile"
    done < "$sources_file"

    # Apply changes to the original file
    if [ "$changed" -eq 1 ]; then
        if ! cp -p "$tempfile" "$sources_file"; then
            echo "Failed to apply changes to the original source list" >&2
            return 1
        fi

        if ! packages::update; then
            echo "Failed to update apt sources list" >&2
            return 3
        fi
    fi

    return 0
}

# Atualiza a lista de pacotes
packages::update() {
    apt-get update | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Verifica se um pacote está instalado.
packages::is_installed() {
    local pkg="$1"
    [[ -z "$pkg" ]] && return 1
    dpkg -s "$pkg" &>/dev/null
}

# Verifica se um ou mais pacotes estão instalados através de um regex
packages::is_installed_regex() {
    local regex_include="$1"
    local regex_exclude="$2"  # opcional
    [[ -z "$regex_include" ]] && return 1

    if [[ -n "$regex_exclude" ]]; then
        dpkg -l | grep -E "$regex_include" | grep -vE "$regex_exclude" &>/dev/null
    else
        dpkg -l | grep -E "$regex_include" &>/dev/null
    fi
}

# Instala um ou mais pacotes no sistema
packages::install() {
    apt-get install -y "$@" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Instala um ou mais pacotes no sistema sem pacotes recomendados
packages::install_no_recommends() {
    apt-get install --no-install-recommends -y "$@" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Desinstala um ou mais pacotes do sistema
packages::remove() {
    apt-get remove --autoremove -y "$@" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Desinstala um ou mais pacotes do sistema com purge
packages::purge() {
    apt-get purge --autoremove -y "$@" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}

# Reinstala um ou mais pacotes do sistema
packages::reinstall() {
    apt-get install --reinstall -y "$@" | tee -a /dev/fd/3
    return ${PIPESTATUS[0]}
}