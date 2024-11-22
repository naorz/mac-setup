#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/dependencies.sh"

TOOLS_JSON="$SCRIPT_DIR/src/config/tools.json"

# Check required dependencies before proceeding
check_and_install_dependencies "jq"

# Ensure tools.json exists
if [ ! -f "$TOOLS_JSON" ]; then
    log_error "Could not find tools.json at $TOOLS_JSON"
    exit 1
fi

print_tools() {
    local current_category=""
    
    log_info "Available tools:"
    echo ""
    
    jq -r '
        to_entries[] | 
        .key as $category |
        .value | 
        to_entries[] |
        [$category, .key, .value.name, .value.desc // "", .value.type // "formula"] | 
        @tsv
    ' "$TOOLS_JSON" | \
    while IFS=$'\t' read -r category tool name desc type; do
        if [ "$category" != "$current_category" ]; then
            current_category="$category"
            echo -e "\n${BLUE}${category^}:${NC}"
        fi
        
        # Print tool info with proper formatting
        printf "  ${GREEN}%-15s${NC} - %s\n" "$tool" "$name"
        printf "    %-15s %s\n" "" "$desc"
        if [ "$type" = "cask" ]; then
            printf "    %-15s %s\n" "" "(GUI Application)"
        fi
    done
    
    echo ""
}

print_tools