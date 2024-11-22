#!/usr/bin/env bash

# Ensure the function is defined or sourced
source "$SCRIPT_DIR/src/common/utils.sh"

STATE_DIR="${SCRIPT_DIR}/src/state"
INSTALL_STATE="${STATE_DIR}/install_state.json"
TOOL_STATE="${STATE_DIR}/tool_state.json"

init_state() {
    ensure_directory "$STATE_DIR"
    [ ! -f "$INSTALL_STATE" ] && echo "{}" > "$INSTALL_STATE"
    [ ! -f "$TOOL_STATE" ] && echo "{}" > "$TOOL_STATE"
}

set_install_state() {
    local key="$1"
    local value="$2"
    jq --arg k "$key" --arg v "$value" '.[$k] = $v' "$INSTALL_STATE" > "${INSTALL_STATE}.tmp"
    mv "${INSTALL_STATE}.tmp" "$INSTALL_STATE"
}

get_install_state() {
    local key="$1"
    jq -r --arg k "$key" '.[$k] // empty' "$INSTALL_STATE"
}

save_tool_state() {
    local tool="$1"
    local state="$2"
    jq --arg t "$tool" --arg s "$state" '.[$t] = $s' "$TOOL_STATE" > "${TOOL_STATE}.tmp"
    mv "${TOOL_STATE}.tmp" "$TOOL_STATE"
}

get_tool_state() {
    local tool="$1"
    jq -r --arg t "$tool" '.[$t] // empty' "$TOOL_STATE"
}

# State management functions

# Example state function
save_state() {
    echo "$1" > "$SCRIPT_DIR/src/state/$2"
}

load_state() {
    cat "$SCRIPT_DIR/src/state/$1"
}