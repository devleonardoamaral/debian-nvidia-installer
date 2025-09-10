#!/usr/bin/env bash

# ============================================================================
# debian-nvidia-installer - NVIDIA Driver Installer for Debian (TUI)
# Copyright (C) 2025 Leonardo Amaral
#
# SPDX-License-Identifier:
#     GPL-3.0-or-later
#
# Module:
#     logging.sh
#
# Description:
#     Provides functions for terminal logging and writing messages to a log
#     file.
# ============================================================================




# ============================================================================
# Global Variables
# ============================================================================

# ----------------------------------------------------------------------------
# Variable: LOG_LEVEL
# Description:
#     Defines the minimum logging level that will be output.
#     Messages with a level lower than LOG_LEVEL are ignored.
#     Default value is 70 (Info).
# ----------------------------------------------------------------------------
: "${LOG_LEVEL:=70}"

# ----------------------------------------------------------------------------
# Variable: LOG_FD
# Description:
#     File descriptor used to write log messages to the log file.
#     Defaults to 3 if not already defined.
# ----------------------------------------------------------------------------
: "${LOG_FD:=3}"




# ============================================================================
# Constants (Color Escape Sequences)
# ============================================================================

# ----------------------------------------------------------------------------
# Constant: LOG_ESC_BOLD_RED
# Description:
#     Escape sequence for formatting log messages in bold red.
# ----------------------------------------------------------------------------
: "${LOG_ESC_BOLD_RED:=\033[1;31m}"
readonly LOG_ESC_BOLD_RED

# ----------------------------------------------------------------------------
# Constant: LOG_ESC_BOLD_YELLOW
# Description:
#     Escape sequence for formatting log messages in bold yellow.
# ----------------------------------------------------------------------------
: "${LOG_ESC_BOLD_YELLOW:=\033[1;33m}"
readonly LOG_ESC_BOLD_YELLOW

# ----------------------------------------------------------------------------
# Constant: LOG_ESC_BOLD_BLUE
# Description:
#     Escape sequence for formatting log messages in bold blue.
# ----------------------------------------------------------------------------
: "${LOG_ESC_BOLD_BLUE:=\033[1;34m}"
readonly LOG_ESC_BOLD_BLUE

# ----------------------------------------------------------------------------
# Constant: LOG_ESC_BOLD_MAGENTA
# Description:
#     Escape sequence for formatting log messages in bold magenta.
# ----------------------------------------------------------------------------
: "${LOG_ESC_BOLD_MAGENTA:=\033[1;35m}"
readonly LOG_ESC_BOLD_MAGENTA

# ----------------------------------------------------------------------------
# Constant: LOG_ESC_BOLD
# Description:
#     Escape sequence for formatting log messages in bold (default color).
# ----------------------------------------------------------------------------
: "${LOG_ESC_BOLD:=\033[1m}"
readonly LOG_ESC_BOLD

# ----------------------------------------------------------------------------
# Constant: LOG_ESC_RESET
# Description:
#     Escape sequence to reset all formatting to default.
# ----------------------------------------------------------------------------
: "${LOG_ESC_RESET:=\033[0m}"
readonly LOG_ESC_RESET




# ============================================================================
# Internal Associative Arrays
# ============================================================================

# ----------------------------------------------------------------------------
# Variable: log_level_to_name
# Description:
#     Maps numeric log levels to their string names.
#     Example: log_level_to_name[70]="Info"
# ----------------------------------------------------------------------------
declare -A log_level_to_name

# ----------------------------------------------------------------------------
# Variable: log_name_to_level
# Description:
#     Maps log level names to their numeric values.
#     Example: log_name_to_level["Info"]=70
# ----------------------------------------------------------------------------
declare -A log_name_to_level

# ----------------------------------------------------------------------------
# Variable: log_name_color
# Description:
#     Maps log level names to their associated color escape sequences.
#     Example: log_name_color["Error"]=$LOG_ESC_BOLD_RED
# ----------------------------------------------------------------------------
declare -A log_name_color




# ============================================================================
# Internal Functions
# ============================================================================

# ----------------------------------------------------------------------------
# Function: log::_set_log_level
# Description:
#     Registers a log level, its numeric value, and its color.
# Params:
#     string ($1): Log level name (e.g., "Info", "Error").
#     int ($2): Numeric log level.
#     string ($3): Color escape sequence for the log level.
# ----------------------------------------------------------------------------
log::_set_log_level() {
    local name="$1"
    local level="$2"
    local name_color="$3"

    log_name_to_level[$name]=$level
    log_level_to_name[$level]=$name
    log_name_color[$name]="$name_color"
}




# ----------------------------------------------------------------------------
# Function: log::_write_fd
# Description:
#     Writes a formatted log message to the log file using LOG_FD.
# Params:
#     string ($1): Log level name.
#     string ($2): Log message.
# ----------------------------------------------------------------------------
log::_write_fd() {
    local log_level_name="$1"
    local log_message="$2"
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] ${log_level_name}: ${log_message}" >&"${LOG_FD}"
}




# ----------------------------------------------------------------------------
# Function: log::_display
# Description:
#     Writes a formatted log message to stderr with color.
# Params:
#     string ($1): Log level name.
#     string ($2): Log message.
#     string ($3): Color escape sequence.
# ----------------------------------------------------------------------------
log::_display() {
    local log_level_name="$1"
    local log_message="$2"
    local log_color="$3"

    echo -e "${log_color}${log_level_name}:${LOG_ESC_RESET} $log_message" >&2
}




# ----------------------------------------------------------------------------
# Function: log::_write
# Description:
#     Writes a log message to both the log file and the terminal if
#     its level is >= LOG_LEVEL.
# Params:
#     int ($1): Numeric log level.
#     string ($2): Log message.
# ----------------------------------------------------------------------------
log::_write() {
    local log_level="$1"
    local log_message="$2"

    (( log_level < LOG_LEVEL )) && return 0

    local log_level_name="${log_level_to_name[$log_level]:-Notset}"
    local log_color="${log_name_color[$log_level_name]}"

    log::_write_fd "$log_level_name" "$log_message"
    log::_display "$log_level_name" "$log_message" "$log_color"
}




# ----------------------------------------------------------------------------
# Function: log::open_fd
# Description:
#     Opens a new file descriptor for appending logs to the specified file.
#     The file descriptor is stored in the global variable LOG_FD.
# Params:
#     string ($1): Path to the log file.
# Returns:
#     0 - On success.
#     1 - On failure.
# Globals:
#     LOG_FD - Assigned with the chosen file descriptor number.
# ----------------------------------------------------------------------------

log::_open_fd() {
    local log_path="$1"

    # Ask Bash to choose a free FD
    if exec {LOG_FD}>>"$log_path"; then
        return 0
    fi

    echo "Error: failed to open file descriptor for $log_path" >&2
    return 1
}




# ============================================================================
# Public Logging Functions
# ============================================================================

# ----------------------------------------------------------------------------
# Function: log::info
# Description:
#     Logs an informational message (level 70).
# Params:
#     string ($1): Log message.
# ----------------------------------------------------------------------------
log::info() { log::_write 70 "$1"; }




# ----------------------------------------------------------------------------
# Function: log::warn
# Description:
#     Logs a warning message (level 80).
# Params:
#     string ($1): Log message.
# ----------------------------------------------------------------------------
log::warn() { log::_write 80 "$1"; }




# ----------------------------------------------------------------------------
# Function: log::error
# Description:
#     Logs an error message (level 90).
# Params:
#     string ($1): Log message.
# ----------------------------------------------------------------------------
log::error() { log::_write 90 "$1"; }




# ----------------------------------------------------------------------------
# Function: log::critical
# Description:
#     Logs a critical error message (level 100).
# Params:
#     string ($1): Log message.
# ----------------------------------------------------------------------------
log::critical() { log::_write 100 "$1"; }




# ----------------------------------------------------------------------------
# Function: log::input
# Description:
#     Prompts the user for input and stores it in the variable name passed
#     as first parameter. Also logs the input to the log file.
# Params:
#     string ($1): Name of the variable to store user input.
#     string ($2+): Prompt message.
# ----------------------------------------------------------------------------
log::input() {
    local __varname=$1
    shift
    echo -ne "[$(date "+%Y-%m-%d %H:%M:%S")] >>> $1" >&3
    echo -ne "${LOG_ESC_BOLD_MAGENTA}>>>${LOG_ESC_RESET}${LOG_ESC_BOLD} $* ${LOG_ESC_RESET}"
    read -r user_input
    echo -e "$user_input" >&3
    printf -v "$__varname" '%s' "$user_input"
}




# ----------------------------------------------------------------------------
# Function: log::capture_cmd
# Description:
#     Runs a command and captures its output, writing it to the log file
#     if logging is enabled.
# Params:
#     array ($@): Command and its arguments.
# Returns:
#     Exit status of the command.
# ----------------------------------------------------------------------------
log::capture_cmd() {
    local cmd=("$@")

    if : >&"$LOG_FD" 2>/dev/null; then
        "${cmd[@]}" 2>&1 | tee -a "/dev/fd/$LOG_FD"
        return ${PIPESTATUS[0]}
    else
        "${cmd[@]}"
        return $?
    fi
}




# ============================================================================
# Setup Function
# ============================================================================

# ----------------------------------------------------------------------------
# Function: log::setup_logger
# Description:
#     Initializes the logging system by creating the log directory and file,
#     opening the log file descriptor, and registering default log levels with
#     their colors.
# Params:
#     string ($1): Path to the log file.
# Returns:
#     0 - On success.
#     1 - On failure.
# ----------------------------------------------------------------------------
log::setup_logger() {
    local log_path="$1"

    # Check the param
    if [[ -z "$log_path" ]]; then
        echo "Error: log file path not provided." >&2
        return 1
    fi

    local log_dir
    log_dir="$(dirname "$log_path")"

    # Create log directory if needed
    if [[ ! -d "$log_dir" ]]; then
        sudo mkdir -p "$log_dir" 2>/dev/null || {
            echo "Error: failed to create log directory '$log_dir'." >&2
            return 1
        }
        sudo chmod 755 "$log_dir" 2>/dev/null || {
            echo "Error: failed to set permissions on log directory '$log_dir'." >&2
            return 1
        }
    fi

    # Create or truncate the log file
    : > "$log_path" 2>/dev/null || {
        echo "Error: failed to create or truncate log file '$log_path'." >&2
        return 1
    }

    # Open file descriptor for logging
    log::_open_fd "$log_path" || return 1

    # Set log file permissions
    sudo chmod 744 "$log_path" 2>/dev/null || {
        echo "Error: failed to set permissions on log file '$log_path'." >&2
        return 1
    }

    # Set up default log levels
    log::_set_log_level "CRITICAL" 100 "$LOG_ESC_BOLD_RED"
    log::_set_log_level "ERROR" 90 "$LOG_ESC_BOLD_RED"
    log::_set_log_level "WARN" 80 "$LOG_ESC_BOLD_YELLOW"
    log::_set_log_level "INFO" 70 "$LOG_ESC_BOLD_BLUE"
    log::_set_log_level "DEBUG" 60 "$LOG_ESC_BOLD_MAGENTA"
    log::_set_log_level "NOTSET" 0 "$LOG_ESC_BOLD"

    return 0
}
