#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/state.sh"
source "$SCRIPT_DIR/src/common/logging.sh"

TRACKER_FILE="$SCRIPT_DIR/src/state/installation_progress.json"
INSTALLATION_STATUS_FILE="$STATE_DIR/installation_status.json"

init_tracker() {
    echo "{}" > "$TRACKER_FILE"
}

update_progress() {
    local tool="$1"
    local status="$2"
    local message="${3:-}"
    
    jq --arg t "$tool" \
       --arg s "$status" \
       --arg m "$message" \
       --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.[$t] = {"status": $s, "message": $m, "timestamp": $ts}' \
       "$TRACKER_FILE" > "${TRACKER_FILE}.tmp"
    mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
}

get_progress() {
    local total=$(jq -r 'keys | length' "$SELECTED_FILE")
    local completed=$(jq -r '[.[] | select(.status == "completed")] | length' "$TRACKER_FILE")
    echo $((completed * 100 / total))
}

is_completed() {
    local tool="$1"
    [ "$(jq -r --arg t "$tool" '.[$t].status' "$TRACKER_FILE")" = "completed" ]
}

track_installation() {
    echo "$1 installed" >> "$SCRIPT_DIR/src/state/installations.log"
}

is_installed() {
    local tool=$1
    grep -q "^$tool$" "$SCRIPT_DIR/src/state/installed_tools"
}

show_progress() {
    local current=$1
    local total=$2
    local percentage=$((current * 100 / total))
    printf "\rProgress: [%-50s] %d%%" $(printf "#%.0s" $(seq 1 $((percentage/2)))) $percentage
}

# Initialize installation status file if it doesn't exist
init_installation_status() {
    if [ ! -f "$INSTALLATION_STATUS_FILE" ]; then
        echo "{}" > "$INSTALLATION_STATUS_FILE"
    fi
}

# Check if a tool is installed using its check command or default command check
check_tool_installed() {
    local tool="$1"
    local check_cmd=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].check_cmd // ""' "$SCRIPT_DIR/src/config/tools.json")
    
    if [ -n "$check_cmd" ]; then
        eval "$check_cmd" >/dev/null 2>&1
        return $?
    else
        command -v "$tool" >/dev/null 2>&1
        return $?
    fi
}

# Get current installation status of a tool
get_tool_status() {
    local tool="$1"
    if [ -f "$INSTALLATION_STATUS_FILE" ]; then
        jq -r --arg t "$tool" '.[$t].status // "not_installed"' "$INSTALLATION_STATUS_FILE"
    else
        echo "not_installed"
    fi
}

# Update tool installation status
update_tool_status() {
    local tool="$1"
    local status="$2"
    
    if [ ! -f "$INSTALLATION_STATUS_FILE" ]; then
        init_installation_status
    fi
    
    jq --arg t "$tool" \
       --arg s "$status" \
       --arg ts "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
       '.[$t] = {"status": $s, "timestamp": $ts}' \
       "$INSTALLATION_STATUS_FILE" > "${INSTALLATION_STATUS_FILE}.tmp"
    mv "${INSTALLATION_STATUS_FILE}.tmp" "$INSTALLATION_STATUS_FILE"
}

# Add helper function to check brew installations
check_brew_installation() {
    local tool="$1"
    # Check both brew formulae and casks
    brew list "$tool" >/dev/null 2>&1 || brew list --cask "$tool" >/dev/null 2>&1
}

# Add helper function to check Mac Applications case-insensitively
check_mac_app() {
    local app_name="$1"
    local app_name_lower=$(echo "$app_name" | tr '[:upper:]' '[:lower:]')
    
    # Get all .app directories and check case-insensitively
    local found=false
    for dir in "/Applications" "$HOME/Applications"; do
        if [ -d "$dir" ]; then
            while IFS= read -r app; do
                local basename_lower=$(basename "$app" .app | tr '[:upper:]' '[:lower:]')
                if [ "$basename_lower" = "$app_name_lower" ]; then
                    found=true
                    break 2
                fi
            done < <(find "$dir" -maxdepth 1 -name "*.app")
        fi
    done
    
    $found
}

check_tool_installation() {
    local tool="$1"
    local tool_info=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t]' "$SCRIPT_DIR/src/config/tools.json")
    local brew_name=$(echo "$tool_info" | jq -r '.brew // empty')
    local install_type=$(echo "$tool_info" | jq -r '.type // "formula"')
    local app_name=$(echo "$tool_info" | jq -r '.app_name // empty')
    
    # 1. Check brew installation first (preferred method)
    if [ -n "$brew_name" ]; then
        if [ "$install_type" = "cask" ]; then
            brew list --cask "$brew_name" >/dev/null 2>&1 && return 0
        else
            brew list "$brew_name" >/dev/null 2>&1 && return 0
        fi
    fi

    # 2. Check system-wide command/binary
    command -v "$tool" >/dev/null 2>&1 && return 0

    # 3. Check Applications folder if app_name is specified
    if [ -n "$app_name" ]; then
        check_mac_app "$app_name" && return 0
    fi

    return 1
}

scan_installed_tools() {
    log_info "Scanning system for installed tools..."
    init_installation_status
    
    local tool_count=0
    local installed_count=0
    declare -a installed_tools=()
    declare -a not_installed_tools=()
    
    while IFS= read -r tool; do
        ((tool_count++))
        local name=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].name' "$TOOLS_JSON")
        local install_type=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t].type // "formula"' "$TOOLS_JSON")
        
        log_debug "Checking $name..."
        if check_tool_installation "$tool"; then
            ((installed_count++))
            update_tool_status "$tool" "installed"
            installed_tools+=("$name ($tool) [$(detect_install_source "$tool")]")
        else
            update_tool_status "$tool" "not_installed"
            not_installed_tools+=("$name ($tool)")
        fi
    done < <(jq -r 'paths | select(length==2) | .[1]' "$TOOLS_JSON")
    
    # Print summary
    log_info "Installation scan complete:"
    log_info "Found $installed_count of $tool_count tools installed\n"
    
    if [ ${#installed_tools[@]} -gt 0 ]; then
        log_info "Installed tools:"
        printf '%s\n' "${installed_tools[@]}" | sort | sed 's/^/  ✓ /'
    fi
    
    if [ ${#not_installed_tools[@]} -gt 0 ]; then
        echo ""
        log_info "Not installed tools:"
        printf '%s\n' "${not_installed_tools[@]}" | sort | sed 's/^/  ✗ /'
    fi
    
    echo ""
}

detect_install_source() {
    local tool="$1"
    local tool_info=$(jq -r --arg t "$tool" '.. | select(.[$t]?) | .[$t]' "$SCRIPT_DIR/src/config/tools.json")
    local brew_name=$(echo "$tool_info" | jq -r '.brew // empty')
    local install_type=$(echo "$tool_info" | jq -r '.type // "formula"')
    local app_name=$(echo "$tool_info" | jq -r '.app_name // empty')

    # Check in same order as installation check
    if [ -n "$brew_name" ]; then
        if [ "$install_type" = "cask" ] && brew list --cask "$brew_name" >/dev/null 2>&1; then
            echo "brew-cask"
            return
        elif brew list "$brew_name" >/dev/null 2>&1; then
            echo "brew"
            return
        fi
    fi

    if command -v "$tool" >/dev/null 2>&1; then
        echo "system"
        return
    fi

    if [ -n "$app_name" ] && check_mac_app "$app_name"; then
        echo "manual"
        return
    fi

    echo "not-found"
}
