#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/utils.sh"
source "$SCRIPT_DIR/src/common/installation_tracker.sh"

install_tools() {
    local tools_file="$SCRIPT_DIR/src/state/selected_tools.json"
    local total_tools=$(jq -r 'keys | length' "$tools_file")
    local current_tool=0

    jq -r 'keys[]' "$tools_file" | while IFS= read -r tool; do
        current_tool=$((current_tool + 1))
        show_progress "$current_tool" "$total_tools"

        if is_installed "$tool"; then
            log_warning "The tool '$tool' is already installed - Skip"
            continue
        fi

        log_info "Installing $tool..."
        if brew install "$tool"; then
            track_installation "$tool"
            log_success "$tool installed successfully."
        else
            log_error "Failed to install $tool."
        fi
    done

    show_progress "$total_tools" "$total_tools"
    echo ""
}

install_tools