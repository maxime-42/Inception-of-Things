#!/bin/sh

RESET="\e[0m"
LIGHT_RED="\e[91m"
LIGHT_GREEN="\e[92m"

set -eu

logging(){
	local type=$1; shift
	printf "${RESET}[%b] $0 : %b\n" "$type" "$*"
}

log_info(){
	logging "${LIGHT_GREEN}info${RESET}" "$@"
}

log_error(){
	logging "${LIGHT_RED}error${RESET}" "$@" >&2
	exit 1
}

CLUSTER_NAME='iot-p3'

install_k3d(){
	if ! [ -x "$(command -v k3d)" ]; then
    log_info "k3d not found, installing it..."
		curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | sudo bash -
    log_info "k3d installed."
	else
    log_info "k3d already installed."
	fi
	local current_shell="$(basename "$SHELL")"
	local rc_path="$HOME/.${current_shell}rc"
	if ! grep -q 'k3d completion' "$rc_path" ; then
		log_info "Adding k3d completion in $rc_path"
		echo '' >> "$rc_path"
		echo "# add k3d completion" >> "$rc_path"
		echo "source <(k3d completion $current_shell)" >> "$rc_path"
	else
		log_info "k3d completion already in $rc_path"
	fi

}

main(){ 
	install_k3d
	k3d cluster delete "$CLUSTER_NAME"
	k3d cluster create "$CLUSTER_NAME"

}

main "$@"
