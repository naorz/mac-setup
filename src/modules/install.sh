#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/utils.sh"
source "$SCRIPT_DIR/src/common/installation_tracker.sh"
source "$SCRIPT_DIR/src/common/dependencies.sh"

check_and_install_dependencies "jq"

install_tools() {
    local tools_file="$SCRIPT_DIR/src/state/selected_tools.json"
    
    # Validate selected tools file exists and has content
    if [ ! -f "$tools_file" ] || [ ! -s "$tools_file" ]; then
        log_error "No tools selected for installation"
        log_info "Please run 'select' command first to choose tools to install"
        exit 1
    fi
    
    # Show installation plan
    log_info "Planning to install the following tools:"
    echo ""
    jq -r '.[]' "$tools_file" | while IFS= read -r tool; do
        local name=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].name' "$SCRIPT_DIR/src/config/tools.json")
        local status=$(get_tool_status "$tool")
        
        if [ "$status" = "installed" ]; then
            printf "  • ${YELLOW}%s${NC} (already installed - will skip)\n" "$name"
        else
            printf "  • %s\n" "$name"
        fi
    done
    echo ""

    # Ask for confirmation
    read -p "Do you want to proceed with the installation? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_warning "Installation cancelled by user"
        exit 1
    fi

    local total_tools=$(jq -r '. | length' "$tools_file")
    local current_tool=0
    local skipped_count=0
    local success_count=0
    local failed_count=0

    jq -r '.[]' "$tools_file" | while IFS= read -r tool; do
        ((current_tool++))
        show_progress "$current_tool" "$total_tools"

        local name=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].name' "$SCRIPT_DIR/src/config/tools.json")
        local brew_name=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].brew // empty' "$SCRIPT_DIR/src/config/tools.json")
        local type=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].type // "formula"' "$SCRIPT_DIR/src/config/tools.json")

        # Check installation status from tracker
        if [ "$(get_tool_status "$tool")" = "installed" ]; then
            log_warning "$name is already installed - Skipping"
            ((skipped_count++))
            continue
        fi

        log_info "Installing $name..."
        if [ -n "$brew_name" ]; then
            if [ "$type" = "cask" ]; then
                if brew install --cask "$brew_name"; then
                    update_tool_status "$tool" "installed"
                    ((success_count++))
                    log_success "$name installed successfully"
                else
                    ((failed_count++))
                    log_error "Failed to install $name"
                fi
            else
                if brew install "$brew_name"; then
                    update_tool_status "$tool" "installed"
                    ((success_count++))
                    log_success "$name installed successfully"
                else
                    ((failed_count++))
                    log_error "Failed to install $name"
                fi
            fi
        fi
    done

    show_progress "$total_tools" "$total_tools"
    echo -e "\n"
    log_info "Installation Summary:"
    log_info "Total tools: $total_tools"
    log_success "Successfully installed: $success_count"
    [ $skipped_count -gt 0 ] && log_warning "Skipped (already installed): $skipped_count"
    [ $failed_count -gt 0 ] && log_error "Failed installations: $failed_count"
}

install_tools