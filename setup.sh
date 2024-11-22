#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/dependencies.sh"

# Ensure xcode-select is installed before proceeding
check_xcode_cli

# Continue with other imports
source "$SCRIPT_DIR/src/common/utils.sh"
source "$SCRIPT_DIR/src/common/state.sh"
source "$SCRIPT_DIR/src/common/installation_tracker.sh"

show_help() {
    echo -e "${BLUE}Mac Setup Tool - Help Menu${NC}"
    echo "Usage: macsetup [command]"
    echo ""
    echo "Commands:"
    echo "  select     - Select tools to install"
    echo "  install    - Install selected tools"
    echo "  export     - Export settings"
    echo "  import     - Import settings"
    echo "  tools      - List available tools"
    echo "  help       - Show this help message"
}

# Create state directory
mkdir -p "$SCRIPT_DIR/src/state"

if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

case "${1:-help}" in
    "select"|"install"|"export"|"import"|"tools")
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