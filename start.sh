#!/usr/bin/env bash

set -eo pipefail

# Safely check for BASH_SOURCE
{ BASH_SOURCE_CHECK="$BASH_SOURCE"; } 2>/dev/null || BASH_SOURCE_CHECK=""

# Now enable -u after the check
set -u

# Create temporary directory for downloaded files
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

# Helper function for setting up directory permissions
setup_directory_permissions() {
    local dir="$1"
    local perms="$2"
    mkdir -p "$dir"
    chmod "$perms" "$dir"
}

# Determine script location regardless of execution method
if [[ -n "${BASH_SOURCE_CHECK}" ]]; then
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
else
    SCRIPT_DIR="$TEMP_DIR"

    # Set permissions for downloaded files
    PERMISSION_R="644"
    PERMISSION_R_W="666"
    PERMISSION_X="755"
    PERMISSION_RWX="777"

    # Setup directory structure with correct permissions
    setup_directory_permissions "$SCRIPT_DIR/src/common" "$PERMISSION_X"
    setup_directory_permissions "$SCRIPT_DIR/src/modules" "$PERMISSION_X"
    setup_directory_permissions "$SCRIPT_DIR/src/config" "$PERMISSION_X"
    setup_directory_permissions "$SCRIPT_DIR/src/state" "$PERMISSION_RWX"

    # Download files...
    BASE_URL="https://raw.githubusercontent.com/naorz/mac-setup/main"

    # Function to download and set permissions
    download_and_set_perms() {
        local file_name="$1"
        local folder="$2"
        local perms="$3"
        local file_path="src/$folder/$file_name"
        local download_url="$BASE_URL/$file_path"
        local dest_path="$SCRIPT_DIR/$file_path"
        curl -sSL "$download_url" -o "$dest_path"
        chmod "$perms" "$dest_path"
    }

    # Download common files with execute permissions
    for file in colors logging dependencies utils state installation_tracker files-handler; do
        download_and_set_perms "$file.sh" "common" "$PERMISSION_X"
    done

    # Download module files with execute permissions
    for file in select install list; do
        download_and_set_perms "$file.sh" "modules" "$PERMISSION_X"
    done

    # Download config files with read permissions
    download_and_set_perms "tools.json" "config" "$PERMISSION_R"

    # Ensure state directory is writable
    touch "$SCRIPT_DIR/src/state/.keep"
    chmod 666 "$SCRIPT_DIR/src/state/.keep"
    rm "$SCRIPT_DIR/src/state/.keep"
fi

export SCRIPT_DIR

# Source common utilities
source "${SCRIPT_DIR}/src/common/files-handler.sh"
source "${SCRIPT_DIR}/src/common/colors.sh"
source "${SCRIPT_DIR}/src/common/logging.sh"
source "${SCRIPT_DIR}/src/common/dependencies.sh"
source "${SCRIPT_DIR}/src/common/utils.sh"
source "${SCRIPT_DIR}/src/common/state.sh"
source "${SCRIPT_DIR}/src/common/installation_tracker.sh"

# Ensure xcode-select is installed before proceeding
check_xcode_cli

show_help() {
    echo -e "${BLUE}Mac Setup Tool - Help Menu${NC}"
    echo "Usage: macsetup [command]"
    echo ""
    echo "Commands:"
    echo "  select     - Select tools to install"
    echo "  install    - Install selected tools"
    echo "  export     - Export settings"
    echo "  import     - Import settings"
    echo "  list       - List available tools"
    echo "  help       - Show this help message"
}

# Create state directory
mkdir -p "$SCRIPT_DIR/src/state"

if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

case "${1:-help}" in
    "select"|"install"|"export"|"import"|"list")
        "$SCRIPT_DIR/src/modules/$1.sh" "${@:2}"
        ;;
    "help")
        show_help
        ;;
    *)
        echo -e "${RED}Error: Invalid command${NC}"
        show_help
        exit 1
        ;;
esac
