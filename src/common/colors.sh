#!/usr/bin/env bash

# Define color variables
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
GRAY='\033[0;37m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
NC='\033[0m' # No Color

# All color variables are defined here
BLACK='\033[0;30m'
DARK_GRAY='\033[1;30m'
LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
LIGHT_YELLOW='\033[1;33m'
LIGHT_BLUE='\033[1;34m'
LIGHT_PURPLE='\033[1;35m'
LIGHT_GRAY='\033[0;37m'
WHITE='\033[1;37m'
PURPLE='\033[0;35m'

LOGGING_DEBUG_COLOR="${DARK_GRAY}"
LOGGING_INFO_COLOR="${LIGHT_PURPLE}"
LOGGING_WARNING_COLOR="${LIGHT_YELLOW}"
LOGGING_ERROR_COLOR="${LIGHT_RED}"
LOGGING_SUCCESS_COLOR="${LIGHT_GREEN}"
LOGGING_ACTION_COLOR="${LIGHT_CYAN}"
LOGGING_ACTION_WARN_COLOR="${LIGHT_YELLOW}"

see_all_colors() {
  echo -e "${BLACK}This is BLACK${NC}"
  echo -e "${DARK_GRAY}This is DARK_GRAY${NC}"

  echo -e "${RED}This is RED${NC}"
  echo -e "${LIGHT_RED}This is LIGHT_RED${NC}"

  echo -e "${GREEN}This is GREEN${NC}"
  echo -e "${LIGHT_GREEN}This is LIGHT_GREEN${NC}"

  echo -e "${YELLOW}This is YELLOW${NC}"
  echo -e "${LIGHT_YELLOW}This is LIGHT_YELLOW${NC}"

  echo -e "${BLUE}This is BLUE${NC}"
  echo -e "${LIGHT_BLUE}This is LIGHT_BLUE${NC}"

  echo -e "${PURPLE}This is PURPLE${NC}"
  echo -e "${LIGHT_PURPLE}This is LIGHT_PURPLE${NC}"

  echo -e "${CYAN}This is CYAN${NC}"
  echo -e "${LIGHT_CYAN}This is LIGHT_CYAN${NC}"

  echo -e "${GRAY}This is GRAY${NC}"
  echo -e "${LIGHT_GRAY}This is LIGHT_GRAY${NC}"

  echo -e "${WHITE}This is WHITE${NC}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  see_all_colors
fi
