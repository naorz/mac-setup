#!/usr/bin/env bash

source "${SCRIPT_DIR}/src/common/colors.sh"

# Set default log level if not set
LOG_LEVEL=${LOG_LEVEL:-"INFO"}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }

log_debug() {
    if [ "${LOG_LEVEL}" = "DEBUG" ]; then
        echo -e "${GRAY}[DEBUG] $*${NC}" >&2
    fi
}

confirm_action() {
    local action="$1"
    echo -e "${YELLOW}[Warning]:${NC} 🚧 WIP: The '$action' action is not tested yet 🚧, do you want to continue? (y/n): "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Action cancelled by user"
        exit 1
    fi
}

# Function to set log level
set_log_level() {
    LOG_LEVEL="$1"
    export LOG_LEVEL
}