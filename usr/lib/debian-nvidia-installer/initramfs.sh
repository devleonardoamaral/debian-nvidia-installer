#!/usr/bin/env bash

# ============================================================================
# SPDX-License-Identifier:
#     GPL-3.0-or-later
#
# Module:
#     initramfs.sh
#
# Description:
#     Provides functions to manage the initramfs after system changes.
#     Supports both initramfs-tools and dracut.
# ============================================================================

# ----------------------------------------------------------------------------
# Function: initramfs::update
# Description:
#     Updates the system's initramfs.
# Params:
#     None
# Returns:
#     0 - On success.
#     >0 - If the update fails or no supported tool is found.
# ----------------------------------------------------------------------------
initramfs::update() {
    if packages::is_installed initramfs-tools; then
        log::capture_cmd update-initramfs -u
        return $?
    elif packages::is_installed dracut; then
        log::capture_cmd dracut --force
        return $?
    else
        log::error "No initramfs update tool found (neither initramfs-tools nor dracut)."
        return 1
    fi
}
