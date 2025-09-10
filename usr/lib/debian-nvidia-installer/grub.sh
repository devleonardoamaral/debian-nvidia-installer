#!/usr/bin/env bash

# ============================================================================
# debian-nvidia-installer - NVIDIA Driver Installer for Debian (TUI)
# Copyright (C) 2025 Leonardo Amaral
#
# SPDX-License-Identifier:
#     GPL-3.0-or-later
#
# Module:
#     grub.sh
#
# Description:
#     Provides functions to manipulate GRUB kernel parameters and update GRUB
#     configuration. Supports adding, updating, and removing kernel parameters
#     safely, including automatic backups.
# ============================================================================




# ----------------------------------------------------------------------------
# Constant: GRUB_FILE
# Description:
#     Path to the main GRUB configuration file.
#     Defaults to /etc/default/grub.
# ----------------------------------------------------------------------------
: "${GRUB_FILE:="/etc/default/grub"}"
readonly GRUB_FILE




# ----------------------------------------------------------------------------
# Function: grub::add_kernel_parameter
# Description:
#     Adds or updates a kernel parameter in the GRUB_CMDLINE_LINUX_DEFAULT line.
#     Automatically creates a backup of the GRUB file before modifying it.
# Params:
#     string ($1): Parameter name.
#     string ($2): Separator (e.g., = or space) to separate name and value.
#     string ($3): Parameter value.
# Returns:
#     0 - Parameter successfully added or updated.
#     1 - Failed to add or update the parameter.
# ----------------------------------------------------------------------------
grub::add_kernel_parameter() {
    local file="$GRUB_FILE"
    local param_name sep param_value ret

    param_name="$(utils::escape_chars "$1")"
    sep="$(utils::escape_chars "$2")"
    param_value="$(utils::escape_chars "$3")"
    ret=0

    if [[ ! -f "$file" ]]; then
        log::error "File $file does not exist."
        return 1
    fi

    # Create a backup of the GRUB file
    cp "$file" "$file.bak"

    # Check if parameter already exists
    if grep -E "^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*${param_name}${sep}[^\"]*\"" "$file" | \
        grep -qE "(\"|[[:space:]])${param_name}${sep}"; then
        # Update existing parameter with new value
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/([\" ])(${param_name}${sep})([^\" ]*)?/\1\2${param_value}/g" "$file"
        ret="$?"
    else
        # Append the parameter at the end
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/(^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*)/\1 ${param_name}${sep}${param_value}/" "$file"
        ret="$?"
        # Remove spaces after the opening quote
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/=\"[[:space:]]+/=\"/" "$file"
    fi

    if [[ "$ret" -ne 0 ]]; then
        log::error "Failed to add/update kernel parameter in GRUB file: $file"
        return 1
    fi

    return 0
}




# ----------------------------------------------------------------------------
# Function: grub::remove_kernel_parameter
# Description:
#     Removes a kernel parameter from the GRUB_CMDLINE_LINUX_DEFAULT line.
#     Automatically creates a backup of the GRUB file before modifying it.
# Params:
#     string ($1): Parameter name.
#     string ($2): Separator used (e.g., = or space).
#     string ($3): Parameter value (optional, remove exact match if provided).
# Returns:
#     0 - Parameter removed successfully.
#     1 - Parameter not found in GRUB file.
#     2 - GRUB file not found.
# ----------------------------------------------------------------------------
grub::remove_kernel_parameter() {
    local file="$GRUB_FILE"
    local param_name sep param_value

    param_name="$(utils::escape_chars "$1")"
    sep="$(utils::escape_chars "$2")"
    param_value="$3"

    if [[ ! -f "$file" ]]; then
        log::error "GRUB file $file not found."
        return 2
    fi

    # Create a backup of the GRUB file
    cp "$file" "$file.bak"

    # Check if the parameter exists before attempting removal
    if grep -E "^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=\"[^\"]*${param_name}${sep}${param_value}[^\"]*\"" "$file" | \
            grep -qE "(\"|[[:space:]])${param_name}${sep}${param_value}(\"|[[:space:]])"; then

        # Remove the parameter (including optional value)
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/([\" ])${param_name}${sep}${param_value}([\" ])/\1\2/g" "$file"

        # Cleanup extra spaces
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/  +/ /g"
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/[[:space:]]+\"/\"/"
        sed -i -E "/^[[:space:]]*GRUB_CMDLINE_LINUX_DEFAULT=/s/=\"[[:space:]]+/=\"/"

        log::error "Changes have been applied to the GRUB file: $file"
        return 0
    else
        log::error "There were no changes to the GRUB file: $file"
        return 1
    fi
}




# ----------------------------------------------------------------------------
# Function: grub::update
# Description:
#     Updates GRUB configuration by running `update-grub`.
#     Checks if the optional dependency `grub2-common` is installed.
# Returns:
#     0 - On success (GRUB updated or optional dependency missing).
#     >0 - If `update-grub` failed.
# ----------------------------------------------------------------------------
grub::update() {
    if ! packages::is_installed "grub2-common"; then
        log::warn "Optional dependency 'grub2-common' is not installed. Automatic updating of kernel parameters requires this package."
        log::warn "Please update GRUB manually for changes to take effect."
    else
        log::capture_cmd update-grub
        return $?
    fi

    return 0
}
