#!/usr/bin/env bash

source "$SCRIPT_DIR/src/common/logging.sh"

check_gist_dependencies() {
    if ! command -v gh >/dev/null 2>&1; then
        log_error "GitHub CLI (gh) is not installed. Please install it to use Gist integration."
        exit 1
    fi
}

setup_gist() {
    if ! command -v gh >/dev/null 2>&1; then
        log_info "Installing GitHub CLI..."
        brew install gh
        gh auth login
    fi
}

create_gist() {
    local file="$1"
    local desc="${2:-"Mac Setup Configuration"}"
    
    setup_gist
    gh gist create "$file" --desc "$desc" --public
}

fetch_gist() {
    local gist_id="$1"
    local output="$2"
    
    setup_gist
    gh gist view "$gist_id" --raw > "$output"
}

update_gist() {
    local gist_id="$1"
    local file="$2"
    
    setup_gist
    gh gist edit "$gist_id" "$file"
}

upload_to_gist() {
    local file=$1
    check_gist_dependencies
    gh gist create "$file" --public
}

download_from_gist() {
    local gist_id=$1
    local output_file=$2
    check_gist_dependencies
    gh gist view "$gist_id" --files | grep -o 'https://gist.githubusercontent.com/[^"]*' | xargs curl -o "$output_file"
}