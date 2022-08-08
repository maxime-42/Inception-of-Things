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

clear_lastline() {
	tput cuu 1 && tput el
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

install_argo_cd(){
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

	log_info 'Waiting argocd-server pod to be ready to forward tcp trafic.\n'
	i=300 		# wait 300s maximum
	while [ $i -gt 0 ]; do
		is_ready="$(kubectl -n argocd get pods -l app.kubernetes.io/name=argocd-server -o 'jsonpath={..status.conditions[?(.type=="Ready")].status}')"
		if [ "$is_ready" = 'True' ] ; then
			break
		fi
		clear_lastline
		log_info "Waiting... $i sec before timeout"
		sleep 5
		i=$((i - 5))
	done
	if [ "$i" = "0" ]; then
		log_error 'timeout, bye.'
	fi

	kubectl port-forward svc/argocd-server -n argocd 8080:443 1>/dev/null &
	log_info 'argocd port forwarded to localhost:8080'
}

get_default_argocd_creds(){
	local password="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)"
	echo 'Argo ui : https://localhost:8080'
	echo 'Argocd credentials'
	echo 'Username: admin'
	echo "Password: $password"
}

main(){ 
	install_k3d
	k3d cluster delete "$CLUSTER_NAME"
	k3d cluster create -p '8888:30007@loadbalancer' "$CLUSTER_NAME"
	install_argo_cd

	get_default_argocd_creds
	
	kubectl apply -f https://raw.githubusercontent.com/maxime-42/iot-p3-mkayumba/main/config_cd.yaml
}

main "$@"
