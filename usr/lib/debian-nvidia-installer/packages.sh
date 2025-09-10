#!/usr/bin/env bash

# ============================================================================
# debian-nvidia-installer - NVIDIA Driver Installer for Debian (TUI)
# Copyright (C) 2025 Leonardo Amaral
#
# SPDX-License-Identifier:
#     GPL-3.0-or-later
#
# Module:
#     packages.sh
#
# Description:
#     Provides functions for managing APT packages and editing sources list
#     files. This script is intended to be sourced, not executed directly.
# ============================================================================




# ----------------------------------------------------------------------------
# Function: packages::check_sources_components
# Description:
#     Check whether each source entry [One-Line-Style] in a sources list file
#     includes all the specified components.
# Params:
#     string ($1): path to the sources list file (e.g., /etc/apt/sources.list)
#     string[] ($@): list of components to check for each source entry
#                    (e.g., "contrib", "non-free", "non-free-firmware")
# Returns:
#     0 - All sources have all required components.
#     1 - One or more sources have missing components.
#     2 - Source file does not exist or is invalid.
# ----------------------------------------------------------------------------
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
        echo "No components supplied to check" >&2
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





# ----------------------------------------------------------------------------
# Function: packages::add_sources_components
# Description:
#     Add new source components to all entries [One-Line-Style] of the
#     specified sources list file.
# Params:
#     string ($1): path to the sources list file (e.g., /etc/apt/sources.list)
#     string[] ($@): list of components to add for each source entry
#                    (e.g., "contrib", "non-free", "non-free-firmware")
# Returns:
#     0 - All components were added successfully to the provided sources .list file.
#     1 - An error occurred while trying to add the components to the file.
#     2 - The file does not exist or is invalid.
#     3 - Failed to update the APT sources list after successfully adding components.
# ----------------------------------------------------------------------------
packages::add_sources_components() {
    local sources_file="$1"
    shift
    local components=("$@")

    # Check if the sources file exists and if is a regular file or symlink
    if [ -z "$sources_file" ] || { [ ! -f "$sources_file" ] && [ ! -h "$sources_file" ]; }; then
        log::error "Invalid source file: $source_file"
        return 2
    fi

    # If no components are specified, consider that all the components are successfuly added
    if [ "${#components[@]}" -eq 0 ]; then
        log::error "No components supplied to add"
        return 0
    fi

    # Copy sources file to temp dir preserving it metadata
    local tempfile="/tmp/$(basename "$sources_file").bak"
    if ! cp -p "$sources_file" "$tempfile"; then
        log::error "Failed to copy source list"
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
            log::error "Failed to apply changes to the original source list"
            return 1
        fi

        if ! packages::update; then
            log::error "Failed to update apt sources list"
            return 3
        fi
    fi

    return 0
}




# ----------------------------------------------------------------------------
# Function: packages::update
# Description:
#     Update the APT package index from all configured sources.
# Params:
#     None
# Returns:
#     0 - Update completed successfully.
#     >0 - Update failed.
# ----------------------------------------------------------------------------
packages::update() {
    log::capture_cmd apt-get update
}




# ----------------------------------------------------------------------------
# Function: packages::is_installed
# Description:
#     Check if a package is installed on the system.
# Params:
#     string ($1): name of the package (e.g., "curl")
# Returns:
#     0 - The package is installed.
#     1 - The package is not installed or the argument is empty.
# ----------------------------------------------------------------------------
packages::is_installed() {
    local pkg="$1"
    [[ -z "$pkg" ]] && return 1
    dpkg -s "$pkg" &>/dev/null
}




# ----------------------------------------------------------------------------
# Function: packages::install
# Description:
#     Install one or more APT packages with recommended dependencies.
# Params:
#     string[] ($@): list of package names to install.
# Returns:
#     0 - All packages installed successfully.
#     >0 - Installation failed for one or more packages.
# ----------------------------------------------------------------------------
packages::install() {
    log::capture_cmd apt-get install -y "$@"
}




# ----------------------------------------------------------------------------
# Function: packages::reinstall
# Description:
#     Reinstall one or more APT packages, forcing reinstallation even if they
#     are already installed. Recommended dependencies will also be installed.
# Params:
#     string[] ($@): list of package names to reinstall.
# Returns:
#     0 - All packages reinstalled successfully.
#     >0 - Reinstallation failed for one or more packages.
# ----------------------------------------------------------------------------
packages::reinstall() {
    log::capture_cmd apt-get install --reinstall -y "$@"
}





# ----------------------------------------------------------------------------
# Function: packages::remove
# Description:
#     Remove one or more installed APT packages, along with automatically
#     installed dependencies that are no longer required.
# Params:
#     string[] ($@): list of package names to remove.
# Returns:
#     0 - All packages removed successfully.
#     >0 - Removal failed for one or more packages.
# ----------------------------------------------------------------------------
packages::remove() {
    log::capture_cmd apt-get remove --autoremove -y "$@"
}




# ----------------------------------------------------------------------------
# Function: packages::purge
# Description:
#     Remove one or more installed APT packages and purge their configuration
#     files, along with automatically installed dependencies that are no longer
#     required.
# Params:
#     string[] ($@): list of package names to purge.
# Returns:
#     0 - All packages purged successfully.
#     >0 - Purge failed for one or more packages.
# ----------------------------------------------------------------------------
packages::purge() {
    log::capture_cmd apt-get purge --autoremove -y "$@"
}
