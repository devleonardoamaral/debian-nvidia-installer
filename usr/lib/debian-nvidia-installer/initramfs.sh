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

# Update initramfs
initramfs::update() {
    if command -v update-initramfs >/dev/null 2>&1; then
        update-initramfs -u | tee -a /dev/fd/3
        return ${PIPESTATUS[0]}
    elif command -v dracut >/dev/null 2>&1; then
        dracut --force | tee -a /dev/fd/3
        return ${PIPESTATUS[0]}
    else
        echo "No initramfs update tool found (neither initramfs-tools nor dracut)." | tee -a /dev/fd/3
        return 1
    fi
}