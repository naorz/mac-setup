#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/colors.sh"
source "$SCRIPT_DIR/src/common/logging.sh"
source "$SCRIPT_DIR/src/common/gist.sh"

EXPORT_DIR="$SCRIPT_DIR/src/state/exports"
EXPORT_FILE="$EXPORT_DIR/mac_settings.tar.gz"

export_settings() {
    ensure_directory "$EXPORT_DIR"
    
    log_info "Exporting Mac settings..."
    
    # Export system preferences
    defaults read > "$EXPORT_DIR/system_prefs.json"
    
    # Export dev tools configs
    [ -f "$HOME/.gitconfig" ] && cp "$HOME/.gitconfig" "$EXPORT_DIR/"
    [ -f "$HOME/.zshrc" ] && cp "$HOME/.zshrc" "$EXPORT_DIR/"
    [ -d "$HOME/.config" ] && cp -r "$HOME/.config" "$EXPORT_DIR/"
    
    # Export VSCode settings if exists
    local vscode_dir="$HOME/Library/Application Support/Code/User"
    if [ -d "$vscode_dir" ]; then
        mkdir -p "$EXPORT_DIR/vscode"
        cp "$vscode_dir/settings.json" "$EXPORT_DIR/vscode/" 2>/dev/null || true
        cp "$vscode_dir/keybindings.json" "$EXPORT_DIR/vscode/" 2>/dev/null || true
    fi
    
    # Create archive
    tar -czf "$EXPORT_FILE" -C "$EXPORT_DIR" .
    
    # Upload to gist if requested
    if [ "${1:-}" = "--gist" ]; then
        create_gist "$EXPORT_FILE" "Mac Development Environment Settings"
    fi
    
    log_success "Settings exported successfully to $EXPORT_FILE"
}

export_macos_settings() {
    log_info "Exporting macOS settings..."
    defaults read > "$SCRIPT_DIR/src/state/macos_settings.plist"
    log_success "macOS settings exported successfully."
}

main() {
    # WIP: Confirm before proceeding
    confirm_action "exporting settings"

    export_settings "$@"
    export_macos_settings
}

main "$@"