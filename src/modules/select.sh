#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/state.sh"
source "$SCRIPT_DIR/src/common/dependencies.sh"
source "$SCRIPT_DIR/src/common/installation_tracker.sh"

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

run_installation() {
  "$SCRIPT_DIR/src/modules/install.sh"
}

continue_or_exit() {
  while true; do
    echo -e "${LIGHT_CYAN}[ACTION]${NC} ${CYAN}Do you want to proceed to installation? (y/n): ${NC}"
    read -n 1 yn
    echo ""
    case $yn in
      [Yy]* )
        log_info "Proceeding to installation..."
        run_installation
        exit 0;;
      [Nn]* )
        log_info "Run 'install' command to install the selected tools"
        exit 0;;
      * ) echo "Please answer [y]es or [n]o.";;
    esac
  done
}

show_selection_menu() {
  local tools=$(get_tool_list)
  local current_category=""
  local options=()
  local tmp_file
  tmp_file=$(mktemp)

  while IFS=$'\t' read -r category tool name desc; do
    if [ "$category" != "$current_category" ]; then
      current_category="$category"
      options+=("---${category}---" "=== ${category^} ===" "disabled")
    fi

    local status=$(get_tool_status "$tool")
    if [ "$status" != "installed" ]; then
      options+=("$tool" "$desc" "off")
    # else
    #  options+=("$tool" "[✓ Installed] - $desc" "off")
    fi
  done <<< "$tools"

  # dialog docs: https://invisible-island.net/dialog/dialog-1.3.html
  # https://www.geeksforgeeks.org/shell-scripting-dialog-boxes/
  dialog \
    --title "Tool Selector" \
    --colors \
    --cancel-label "Exit" \
    --checklist "Select tools to install:\n(Installed items not shown)" 35 80 30 \
    "${options[@]}" 2>"$tmp_file"
  local dialog_status=$?

  # Filter out category headers and save to selected file
  grep -v '^---.*---$' "$tmp_file" > "$SELECTED_FILE"
  rm -f "$tmp_file"

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
      # log_info "Last updated: $(jq -r 'to_entries[0].value.timestamp' "$INSTALLATION_STATUS_FILE")"
      local timestamp=$(jq -r 'to_entries[0].value.timestamp' "$INSTALLATION_STATUS_FILE")
      local formatted_timestamp
      formatted_timestamp=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" "+%Y-%m-%d %H:%M:%S")
      log_info "Last updated: $formatted_timestamp"

      while true; do
        echo -e "${LIGHT_CYAN}[ACTION]${NC} ${CYAN}Do you want to rescan installed tools (v = yes + verbose)? (y/v/n): ${NC}"
        read -n 1 yn
        echo ""
        case $yn in
          [Yy]* )
            log_info "Rescanning system (it can take a while - 40s~)..."
            return 1;;
          [Vv]* )
            log_info "Rescanning system + Verbose (it can take a while - 40s~)..."
            LOG_LEVEL="DEBUG"
            return 1;;
          [Nn]* )
            log_info "Using existing installation status..."
            return 0;;
          * ) echo "Please answer [y]es or [n]o or [v]erbose.";;
        esac
      done
    fi
  fi
  return 1
}

main() {
  check_and_install_dependencies "dialog" "jq"

  log_info "Starting tool selection process..."
  init_state

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
  # selected_tools=$(echo "$selected_tools" | grep -v "finish")

  if [ -z "$selected_tools" ]; then
    log_error "No tools selected"
    exit 1
  fi

  # Create JSON array from selected tools
  echo "$selected_tools" | jq -R . | jq -s . > "$STATE_DIR/selected_tools.json"

  log_success "Tools selected successfully"
  log_info "Selected tools are saved at $STATE_DIR/selected_tools.json"
  continue_or_exit
}

main
