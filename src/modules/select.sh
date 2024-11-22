#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/state.sh"
source "$SCRIPT_DIR/src/common/dependencies.sh"
source "$SCRIPT_DIR/src/common/installation_tracker.sh"

# Check required dependencies
check_and_install_dependencies "dialog" "jq"

# Ensure the tools.json file is accessed correctly
TOOLS_JSON="$SCRIPT_DIR/src/config/tools.json"
if [ ! -f "$TOOLS_JSON" ]; then
    log_error "Could not find tools.json at $TOOLS_JSON"
    exit 1
fi

SELECTED_FILE="$STATE_DIR/selected_tools.json"

# Parse categories and tools from config
get_tool_list() {
    jq -r 'to_entries[] | .key as $category | .value | to_entries[] | [$category, .key, .value.name, .value.desc // ""] | @tsv' "$TOOLS_JSON"
}

show_selection_menu() {
    local tools=$(get_tool_list)
    local current_category=""
    local options=()
    
    while IFS=$'\t' read -r category tool name desc; do
        if [ "$category" != "$current_category" ]; then
            current_category="$category"
            options+=("---${category}---" "=== ${category^} ===" "off")
        fi
        
        local status=$(get_tool_status "$tool")
        if [ "$status" = "installed" ]; then
            options+=("$tool" "[✓ Installed] - $desc" "off")
        else
            options+=("$tool" "$desc" "off")
        fi
    done <<< "$tools"

    options+=("finish" "Finish selection" "on")

    dialog --title "Tool Selection" \
           --colors \
           --checklist "Select tools to install:\n(Gray items are already installed)" 25 78 15 \
           "${options[@]}" 2>"$SELECTED_FILE"
    local dialog_status=$?

    # Check if user cancelled or there was an error
    if [ $dialog_status -ne 0 ]; then
        log_error "Selection cancelled"
        exit 1
    fi
}

check_existing_status() {
    if [ -f "$INSTALLATION_STATUS_FILE" ] && [ -s "$INSTALLATION_STATUS_FILE" ]; then
        local count=$(jq -r 'keys | length' "$INSTALLATION_STATUS_FILE")
        if [ "$count" -gt 0 ]; then
            log_info "Found existing installation status with $count tools."
            log_info "Last updated: $(jq -r 'to_entries[0].value.timestamp' "$INSTALLATION_STATUS_FILE")"
            
            while true; do
                read -p "Do you want to rescan installed tools? (y/n): " yn
                case $yn in
                    [Yy]* ) 
                        log_info "Rescanning system..."
                        return 1;;
                    [Nn]* ) 
                        log_info "Using existing installation status..."
                        return 0;;
                    * ) echo "Please answer yes or no.";;
                esac
            done
        fi
    fi
    return 1
}

main() {
    log_info "Starting tool selection process..."
    init_state
    
    log_info "Preparing selection menu..."
    check_and_install_dependencies "dialog" "jq"
    
    # Check existing installation status
    if ! check_existing_status; then
        scan_installed_tools
        log_info "Press any key to continue..."
        read -n 1 -s
    fi
    
    show_selection_menu

    # Check if selection file exists and is not empty
    if [ ! -f "$SELECTED_FILE" ] || [ ! -s "$SELECTED_FILE" ]; then
        log_error "No tools were selected"
        exit 1
    fi

    # Remove quotes and create proper JSON array
    local selected_tools=$(cat "$SELECTED_FILE" | tr -d '"' | tr ' ' '\n' | grep -v '^$' | grep -v '^---.*---$')
    
    # Remove "finish" if present
    selected_tools=$(echo "$selected_tools" | grep -v "finish")

    if [ -z "$selected_tools" ]; then
        log_error "No tools selected"
        exit 1
    fi

    # Create JSON array from selected tools
    echo "$selected_tools" | jq -R . | jq -s . > "$STATE_DIR/selected_tools.json"
    
    log_success "Tools selected successfully"
    exit 0
}

main