#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"

is_macos() {
    [[ "$(uname -s)" == "Darwin" ]]
}

ensure_directory() {
    local dir="$1"
    [ ! -d "$dir" ] && mkdir -p "$dir"
}

check_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
}

get_tool_name() {
    local tool="$1"
    jq -r --arg tool "$tool" '.[$tool].name // $tool' "$TOOLS_CONFIG"
}

backup_file() {
    local file="$1"
    [ -f "$file" ] && cp "$file" "$file.backup"
}

# Example utility function
is_command_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Example utility function
check_command() {
    if ! command -v "$1" &> /dev/null; then
        log_error "$1 could not be found"
        exit 1
    fi
}
