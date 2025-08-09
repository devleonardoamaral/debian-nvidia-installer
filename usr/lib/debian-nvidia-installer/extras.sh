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

extra::install_cuda() {
    local PACKAGES=("nvidia-cuda-dev" "nvidia-cuda-toolkit")
    local INSTALLED=()

    for pkg in "${PACKAGES[@]}"; do
        if packages::is_installed "$pkg"; then
            INSTALLED+=("$pkg")
        fi
    done

    if [[ ${#INSTALLED[@]} -gt 0 ]]; then
        local MSG="$(tr::t "tui.yesno.installcuda.installlist")"
        MSG+=$(printf "%s\n" "${INSTALLED[@]}")
        MSG+="$(tr::t "tui.yesno.installcuda.installlist.confirm")"

        if tui::show_yesno "$(tr::t "tui.title.warn")" "$MSG" "$(tr::t "tui.button.remove")"; then
            for pkg in "${INSTALLED[@]}"; do
                if ! installer::remove_package "$pkg"; then
                    log::critical "$(tr::t "log.operation.canceled.byfailure")"
                    log::input _ "$(tr::t "log.script.pause")"
                    return 1
                fi
            done
            return 0
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            return 0
        fi
    fi

    if ! tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.installcuda.confirm")"; then
        log::info "$(tr::t "log.operation.canceled.byuser")"
        return 1
    fi

    for pkg in "${PACKAGES[@]}"; do
        if ! installer::install_package "$pkg"; then
            log::critical "$(tr::t "log.operation.canceled.byfailure")"
            log::input _ "$(tr::t "log.script.pause")"
            return 1
        fi
    done

    log::info "$(tr::t "log.install.success")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
    return 0
}

extra::install_optix() {
    local PACKAGE="libnvoptix1"

    if packages::is_installed "$PACKAGE"; then
        if tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t_args "log.installer.installpackage.alreadyinstalled" "$PACKAGE")\n\n$(tr::t_args "tui.yesno.uninstalloptix.confirm")" "$(tr::t "tui.button.remove")"; then

            if ! installer::remove_package "$PACKAGE"; then
                log::critical "$(tr::t "log.operation.canceled.byfailure")"
                log::input _ "$(tr::t "log.script.pause")"
                return 1
            fi

            return 0
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            return 0
        fi
    fi

    if ! tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.installoptix.confirm")"; then
        log::info log::info "$(tr::t "log.operation.canceled.byuser")"
        return 1
    fi

    if ! installer::install_package "$PACKAGE"; then
        log::critical "$(tr::t "log.operation.canceled.byfailure")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    log::info "$(tr::t "log.install.success")"
    tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
    return 0
}

extra::switch_nvidia_drm() {
    local drm_file="/sys/module/nvidia_drm/parameters/modeset"
    local conf_file="/etc/modprobe.d/nvidia-options.conf"
    local modeset_line="options nvidia-drm modeset=1"
    local current_state

    if [[ ! -f "$drm_file" ]]; then
        log::error "$(tr::t_args "log.extra.drm.failure.notfound" "$drm_file")"
        log::input _ "$(tr::t "log.script.pause")"
        return 1
    fi

    current_state=$(cat "$drm_file")

    if [[ "$current_state" == "Y" ]]; then
        log::info "$(tr::t "log.extra.drm.status.on")"
        
        if tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.extra.drm.deactivate.confirm")"; then
            if [[ -f "$conf_file" ]] && grep -qF "$modeset_line" "$conf_file"; then
                sed -i "\|^$modeset_line$|d" "$conf_file"
                log::info "$(tr::t_args "log.config.write.remove" "$modeset_line" "$conf_file")"
            fi
            log::info "$(tr::t "log.extra.drm.action.off")"
            tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
            log::input _ "$(tr::t "log.script.pause")"
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            return 0
        fi

    elif [[ "$current_state" == "N" ]]; then
        log::info "$(tr::t "log.extra.drm.status.off")"

        if tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.extra.drm.activate.confirm")"; then
            if ! grep -qF "$modeset_line" "$conf_file"; then
                echo "$modeset_line" >> "$conf_file"
                log::info "$(tr::t_args "log.config.write.add" "$modeset_line" "$conf_file")"
            fi
            log::info "$(tr::t "log.extra.drm.action.on")"
            tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
            log::input _ "$(tr::t "log.script.pause")"
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            return 0
        fi
    fi

    return 0
}

extra::switch_nvidia_pvma() {
    local conf_file="/etc/modprobe.d/nvidia-options.conf"
    local pvma_line="options nvidia NVreg_PreserveVideoMemoryAllocations=1"

    if [[ -f "$conf_file" ]] && grep -qF "$pvma_line" "$conf_file"; then
        log::info "$(tr::t "log.extra.pvma.status.on")"

        if tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.extra.pvma.deactivate.confirm")"; then
            if grep -qF "$pvma_line" "$conf_file"; then
                sed -i "\|^$pvma_line$|d" "$conf_file"
                log::info "$(tr::t_args "log.config.write.remove" "$modeset_line" "$conf_file")"
            fi
            log::info "$(tr::t "log.extra.pvma.action.off")"
            tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
            log::input _ "$(tr::t "log.script.pause")"
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            return 0
        fi
    else
        log::info "$(tr::t "log.extra.pvma.status.off")"

        if tui::show_yesno "$(tr::t "tui.title.warn")" "$(tr::t "tui.yesno.extra.pvma.activate.confirm")"; then
            echo "$pvma_line" >> "$conf_file"
            log::info "$(tr::t_args "log.config.write.add" "$modeset_line" "$conf_file")"
            log::info "$(tr::t "log.extra.pvma.action.on")"
            tui::show_msgbox "$(tr::t "tui.title.warn")" "$(tr::t "tui.msgbox.restartrequired")"
            log::input _ "$(tr::t "log.script.pause")"
        else
            log::info "$(tr::t "log.operation.canceled.byuser")"
            return 0
        fi
    fi

    return 0
}