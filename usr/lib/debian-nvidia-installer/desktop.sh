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

# Global system-wide desktop directories
SYSTEM_DESKTOP_PATHS=(
    "/usr/local/share/applications"                      # Locally installed apps for all users
    "/usr/share/applications"                            # System-wide applications (main directory)
    "/var/lib/snapd/desktop/applications"                # Snap apps installed globally
    "/var/lib/flatpak/exports/share/applications"        # Flatpak apps installed globally
)

# User-specific desktop subdirectories
USER_DESKTOP_SUBPATHS=(
    ".local/share/applications"                          # User-installed apps (highest priority)
    ".local/share/flatpak/exports/share/applications"    # User Flatpak apps
    ".local/share/snap/desktop"                          # User Snap apps
    ".local/share/gnome/apps"                            # Older GNOME user apps (rare)
)

# List all available .desktop files for all users and system
desktop::get_all_desktops() {
    local dir userdir

    # .desktop from all users
    for user_home in /home/*; do
        [[ -d "$user_home" ]] || continue
        for subpath in "${USER_DESKTOP_SUBPATHS[@]}"; do
            userdir="$user_home/$subpath"
            [[ -d "$userdir" ]] && find "$userdir" \( -type f -o -type l \) -name "*.desktop" 2>/dev/null
        done
    done

    # .desktop from system-wide directories
    for dir in "${SYSTEM_DESKTOP_PATHS[@]}"; do
        [[ -d "$dir" ]] && find "$dir" \( -type f -o -type l \) -name "*.desktop" 2>/dev/null
    done
}

# List all .desktop backup files (.desktop.bak) for all users and system
desktop::get_all_backups() {
    local dir userdir

    # Backups from all users
    for user_home in /home/*; do
        [[ -d "$user_home" ]] || continue

        for subpath in "${USER_DESKTOP_SUBPATHS[@]}"; do
            userdir="$user_home/$subpath"
            [[ -d "$userdir" ]] && find "$userdir" -type f -name "*.desktop.bak" 2>/dev/null
        done
    done

    # Backups from system-wide directories
    for dir in "${SYSTEM_DESKTOP_PATHS[@]}"; do
        [[ -d "$dir" ]] && find "$dir" -type f -name "*.desktop.bak" 2>/dev/null
    done
}

# Restore all existing .desktop backups
# Optionally returns non-zero if any restoration failed
desktop::restore_backups() {
    local backup_file
    local ret=0

    while IFS= read -r backup_file; do
        if ! desktop::restore_backup "$backup_file"; then
            ret=1
        fi
    done < <(desktop::get_all_backups)

    return "$ret"
}

# Restore a .desktop file to its original state using a backup
# Return 0 if successful, 127 if no backup exists
desktop::restore_backup() {
    local backup_file="$1"

    if [[ ! -f "$backup_file" ]]; then
        echo "Backup file not found: $backup_file" >&2
        return 127
    fi

    # Derive original .desktop file path by removing .bak suffix
    local desktop_file="${backup_file%.bak}"

    if [[ -L "$desktop_file" ]]; then
        # Original is a symlink, restore backup to target
        local target_file
        target_file="$(readlink -f "$desktop_file")"
        if ! cp -p "$backup_file" "$target_file"; then
            echo "Restoration failed for target of $desktop_file ($target_file)" >&2
            return 1
        fi
    else
        # Original is a regular file, restore backup directly
        if ! cp -p "$backup_file" "$desktop_file"; then
            echo "Restoration failed for $desktop_file" >&2
            return 1
        fi
    fi

    # Remove backup after successful restoration
    rm -f "$backup_file"
    echo "Restored backup for $desktop_file" >&2
    return 0
}

# Check if a given option in a .desktop file matches a specific value
# Return 0 if match, 1 otherwise
desktop::check_option() {
    local desktop_file="$1"
    local option="$2"
    local value="$3"

    grep -q "^${option}=${value}" "$desktop_file"
}

# Change or add an option inside a .desktop file
# Creates a backup before editing
desktop::change_option() {
    local desktop_file="$1"
    local option="$2"
    local value="$3"

    local target_file="$desktop_file"
    if [[ -L "$desktop_file" ]]; then
        target_file="$(readlink -f "$desktop_file")"
    fi

    local backup_file="${desktop_file}.bak"
    [[ ! -f "$backup_file" ]] && cp -p "$target_file" "$backup_file"

    if desktop::exists_option "$target_file" "$option"; then
        sed -i "s/^${option}=.*/${option}=${value}/" "$target_file"
    else
        sed -i "/^\[Desktop Entry\]/a ${option}=${value}" "$target_file"
    fi
}

# Check if an option exists in a .desktop file
# Return 0 if found, 1 otherwise
desktop::exists_option() {
    local desktop_file="$1"
    local option="$2"
    
    grep -q "^${option}=" "$desktop_file"
}

# Get the value of an option inside a .desktop file
# Returns first matching value (stdout), empty string if not found
desktop::get_option() {
    local desktop_file="$1"
    local option="$2"
    
    grep "^${option}=" "$desktop_file" | cut -d'=' -f2 | head -n1
}

# Check if the .desktop file requests discrete GPU usage
# Return 0 if true, 1 otherwise
desktop::is_using_discrete_gpu() {
    local desktop_file="$1"

    local PrefersNonDefaultGPU="$(desktop::get_option "$desktop_file" "PrefersNonDefaultGPU")"
    local XKDERunOnDiscreteGpu="$(desktop::get_option "$desktop_file" "X-KDE-RunOnDiscreteGpu")"

    [ "$PrefersNonDefaultGPU" = "true" ] || [ "$XKDERunOnDiscreteGpu" = "true" ]
}

# Toggle GPU preferences for a .desktop file
# Switches between using discrete GPU or integrated GPU
desktop::switch_gpu_preferences() {
    local desktop_file="$1"

    if desktop::is_using_discrete_gpu "$desktop_file"; then
        log::info "$(tr::t_args "desktop::switch_gpu_preferences.disable" "$desktop_file")"
        desktop::change_option "$desktop_file" "PrefersNonDefaultGPU" "false"
        desktop::change_option "$desktop_file" "X-KDE-RunOnDiscreteGpu" "false"
    else
        log::info "$(tr::t_args "desktop::switch_gpu_preferences.enable" "$desktop_file")"
        desktop::change_option "$desktop_file" "PrefersNonDefaultGPU" "true"
        desktop::change_option "$desktop_file" "X-KDE-RunOnDiscreteGpu" "true"
    fi
}

tr::add "pt_BR" "desktop::switch_gpu_preferences.enable" "Definindo GPU dedicada para aplicativo %1"
tr::add "pt_BR" "desktop::switch_gpu_preferences.disable" "Definindo GPU integrada para aplicativo %1"

tr::add "en_US" "desktop::switch_gpu_preferences.enable" "Setting discrete GPU for application %1"
tr::add "en_US" "desktop::switch_gpu_preferences.disable" "Setting integrated GPU for application %1"
