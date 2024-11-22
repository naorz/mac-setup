#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/logging.sh"

check_xcode_cli() {
    if ! xcode-select -p &>/dev/null; then
        log_info "Xcode Command Line Tools not found. Installing..."
        xcode-select --install
        
        log_warning "Waiting for Xcode Command Line Tools installation..."
        log_warning "Please complete the installation prompt that has opened."
        log_warning "Press any key after installation completes..."
        read -n 1 -s
        
        # Verify installation
        if ! xcode-select -p &>/dev/null; then
            log_error "Xcode Command Line Tools installation failed."
            log_error "Please install manually using: xcode-select --install"
            exit 1
        fi
        log_success "Xcode Command Line Tools installed successfully"
    else
        log_debug "Xcode Command Line Tools already installed"
    fi
}

check_and_install_dependencies() {
    local deps=("$@")
    
    log_info "Checking required dependencies..."

    # Check xcode-select first
    check_xcode_cli

    # Check if brew is installed first
    if ! command -v brew >/dev/null 2>&1; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        log_success "Homebrew installed successfully"
    fi

    # Install missing dependencies automatically
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_info "Installing $dep..."
            brew install "$dep" >/dev/null 2>&1
            log_success "$dep installed"
        fi
    done

    log_info "All dependencies are ready"
}
