#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/dependencies.sh"

TOOLS_JSON="$SCRIPT_DIR/src/config/tools.json"


# Ensure tools.json exists
if [ ! -f "$TOOLS_JSON" ]; then
  log_error "Could not find tools.json at $TOOLS_JSON"
  exit 1
fi

print_tool_list() {
  local current_category=""

  log_info "Supported tools to install via mac-setup script:"
  echo ""

  # Create a temporary file for storing the formatted output
  local tmp_file=$(mktemp)

  # Add headers for each new category
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
      # Add extra newline between categories (except for first category)
      [ -n "$current_category" ] && echo "" >> "$tmp_file"
      current_category="$category"
      echo -e "${BLUE}\n\n===== ${category^} =====\n${NC}" >> "$tmp_file"
      echo "" >> "$tmp_file"  # Add space after category name
      printf "%-15s\t%-15s\t%-40s\t%-10s\n" "NAME" "BREW ID" "DESCRIPTION" "TYPE" >> "$tmp_file"
      printf "%-15s\t%-15s\t%-40s\t%-10s\n" "----" "-------" "-----------" "----" >> "$tmp_file"
    fi

    # Format the row with proper spacing
    printf "%-15s\t%-15s\t%-40s\t%-10s\n" \
      "$name" \
      "$tool" \
      "$desc" \
      "$type" >> "$tmp_file"
  done

  # Display using column for proper alignment
  column -t -s $'\t' "$tmp_file"
  rm "$tmp_file"

  echo ""
}


main() {
  # Check required dependencies before proceeding
  check_and_install_dependencies "jq" "column"

  print_tool_list
}

main "$@"
