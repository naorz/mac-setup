#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/gist.sh"

IMPORT_DIR="$SCRIPT_DIR/src/state/imports"
IMPORT_FILE="$IMPORT_DIR/mac_settings.tar.gz"

import_settings() {
    ensure_directory "$IMPORT_DIR"

    # Handle gist import
    if [[ "${1:-}" =~ ^[a-f0-9]+$ ]]; then
        log_info "Fetching settings from gist..."
        fetch_gist "$1" "$IMPORT_FILE"
    elif [ -f "$1" ]; then
        cp "$1" "$IMPORT_FILE"
    else
        log_error "No valid import source provided"
        exit 1
    fi
    
    log_info "Importing Mac settings..."
    
    # Extract archive
    tar -xzf "$IMPORT_FILE" -C "$IMPORT_DIR"
    
    # Import system preferences
    [ -f "$IMPORT_DIR/system_prefs.json" ] && {
        while IFS= read -r pref; do
            defaults write $(echo "$pref" | cut -d' ' -f1-3)
        done < "$IMPORT_DIR/system_prefs.json"
    }
    
    # Import dev configs
    [ -f "$IMPORT_DIR/.gitconfig" ] && cp "$IMPORT_DIR/.gitconfig" "$HOME/"
    [ -f "$IMPORT_DIR/.zshrc" ] && cp "$IMPORT_DIR/.zshrc" "$HOME/"
    [ -d "$IMPORT_DIR/.config" ] && cp -r "$IMPORT_DIR/.config" "$HOME/"
    
    # Import VSCode settings
    local vscode_dir="$HOME/Library/Application Support/Code/User"
    if [ -d "$IMPORT_DIR/vscode" ]; then
        mkdir -p "$vscode_dir"
        cp "$IMPORT_DIR/vscode/"* "$vscode_dir/" 2>/dev/null || true
    fi
    
    log_success "Settings imported successfully"
}

import_macos_settings() {
    log_info "Importing macOS settings..."
    if [[ -f "$SCRIPT_DIR/src/state/macos_settings.plist" ]]; then
        defaults import "$SCRIPT_DIR/src/state/macos_settings.plist"
        log_success "macOS settings imported successfully."
    else
        log_error "No macOS settings file found to import."
    fi
}

main() {
    # WIP: Confirm before proceeding
    confirm_action "import"

    import_settings "$@"
    import_macos_settings
}

main "$@"