#!/usr/bin/env bash

# Add permission constants
PERMISSION_R="644"
PERMISSION_RW="666"
PERMISSION_X="755"
PERMISSION_RWX="777"


is_temp_dir() {
  local dir="$1"
  if [[ "$dir" == *"/tmp."* ]]; then
    return 1
  else
    return 0
  fi
}


ensure_permissions() {
  # ensure with default of 644
  local perms="${2:-$PERMISSION_RW}"  # Default to read-write
  if is_temp_dir "$SCRIPT_DIR"; then
    # Read/Write permissions for state files for temporary directory
    chmod -R "$perms" "$STATE_DIR"
  fi
}


# New function to ensure file permissions
ensure_file_permissions() {
    local file="$1"
    local perms="${2:-$PERMISSION_RW}"  # Default to read-write

    # Make permissions changes only for files in temporary directory
    if ! is_temp_dir "$(dirname "$file")"; then
      return
    fi

    if [ -f "$file" ]; then
        chmod "$perms" "$file"
    fi

    # Ensure parent directory is accessible
    chmod "$PERMISSION_RW" "$(dirname "$file")"
}
