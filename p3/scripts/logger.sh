#!/bin/bash

LOGGER_RESET="\e[0m"
LOGGER_LIGHT_RED="\e[91m"
LOGGER_LIGHT_GREEN="\e[92m"

logging(){
	local type=$1; shift
	printf "${LOGGER_RESET}[%b] $0 : %b\n" "$type" "$*"
}

log_info(){
	logging "${LOGGER_LIGHT_GREEN}info${LOGGER_RESET}" "$@"
}

log_error(){
	logging "${LOGGER_LIGHT_RED}error${LOGGER_RESET}" "$@" >&2
	exit 1
}

log_clear_lastline() {
	tput cuu 1 && tput el
}