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

if [ -z "$NODE_IP" ]; then
   log_error "No variable NODE_IP specified. Please specify it."
fi

log_info "Disabling firewall..."
sudo systemctl disable firewalld --now # https://rancher.com/docs/k3s/latest/en/advanced/#additional-preparation-for-red-hat-centos-enterprise-linux

log_info "Installing server k3S with ${NODE_IP} as node ip..."
curl -sfL https://get.k3s.io | sh -s - server --node-ip="${NODE_IP}" --flannel-iface=eth1 --write-kubeconfig-mode 644
log_info "k3S server node installed."

log_info "Setting up kubectl completion..."
/usr/local/bin/kubectl completion bash >> /etc/bash_completion.d/kubectl
log_info "All done !"
