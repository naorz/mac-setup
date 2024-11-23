#!/usr/bin/env bash

source "${SCRIPT_DIR}/src/common/colors.sh"

# Set default log level if not set
LOG_LEVEL=${LOG_LEVEL:-"INFO"}

set_log_level() {
  LOG_LEVEL="$1"
  export LOG_LEVEL
}

log_debug() {
  if [ "${LOG_LEVEL}" = "DEBUG" ]; then
    echo -e "${LOGGING_DEBUG_COLOR}[DEBUG]${NC} $*" >&2
  fi
}

log_info() {
  echo -e "${LOGGING_INFO_COLOR}[INFO]${NC} $1"
}

log_warning() {
  echo -e "${LOGGING_WARNING_COLOR}[WARNING]${NC} $1";
}

log_success() {
  echo -e "${LOGGING_SUCCESS_COLOR}[SUCCESS]${NC} $1";
}

log_error() {
  echo -e "${LOGGING_ERROR_COLOR}[ERROR]${NC} $1"
}

confirm_action() {
  local action="$1"
  echo -e "${LOGGING_ACTION_COLOR}[Action required]${NC}${CYAN}Do you want to proceed with ${action}? (y/n): ${NC}"
  read -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_warning "${action} cancelled by user"
      exit 1
  fi
}

confirm_wip_action() {
  local action="$1"
  echo -e "${LOGGING_ACTION_WARN_COLOR}[Warning]:${NC} 🚧 ${YELLOW}WIP: The '$action' action is not tested yet 🚧, do you want to continue? (y/n): ${NC}"
  read -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      log_warning "Action cancelled by user"
      exit 1
  fi
}
