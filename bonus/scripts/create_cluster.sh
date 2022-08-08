#!/bin/bash

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

CLUSTER_NAME='iot-bonus'

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
	local svcPatch=
	read -r -d '' svcPatch <<-EOF || true
	{
		"spec": {
			"type": "NodePort",
			"ports": [
				{
					"name": "http",
					"protocol": "TCP",
					"port": 80,
					"targetPort": 8080,
					"nodePort": 30008
				}
			]
		}
	}
	EOF
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	kubectl patch svc argocd-server -n argocd -p "$svcPatch"
}

wait_argocd_is_ready(){
	log_info 'Waiting argocd to be ready.\n'
	i=500 		# wait 500s maximum
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
		log_error 'Argocd failed to start in time.'
	fi
}


install_gitlab(){
	helm repo add gitlab https://charts.gitlab.io/
	helm repo update
	helm upgrade --install gitlab gitlab/gitlab \
		--timeout 600s \
		--namespace gitlab --create-namespace \
		--set global.hosts.domain=iot.com \
		--set certmanager-issuer.email=no@example.com \
		--set postgresql.image.tag=13.6.0

	local svcPatch=
	read -r -d '' svcPatch <<-EOF || true
	{
		"spec": {
			"type": "NodePort",
			"ports": [
				{
					"name": "https",
					"protocol": "TCP",
					"port": 443,
					"targetPort": "https",
					"nodePort": 30009
				}
			]
		}
	}
	EOF
	kubectl -n gitlab patch svc gitlab-nginx-ingress-controller -p "$svcPatch" 
}

gitlab_create_repo(){
	local password
	password="$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo)"


}

get_apps_info(){
	local password
	password="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)"
	echo 'ArgoCD URL : https://localhost:8080'
	echo 'ArgoCD username: admin'
	echo "ArgoCD password: $password"
	echo ''
	password="$(kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -ojsonpath='{.data.password}' | base64 --decode ; echo)"
	echo 'GitLab URL : https://gitlab.iot.com:8081'
	echo 'Gitlab username: root'
	echo "Gitlab password: $password"
	echo ''
	echo 'Playground api URL : https://localhost:8888'
}

main(){
	cd $(dirname $0)
	install_k3d
	k3d cluster delete "$CLUSTER_NAME"
	k3d cluster create "$CLUSTER_NAME" -p '8888:30007@server:0' -p '8080:30008@server:0' -p '8081:30009@server:0'
	install_argo_cd
	install_gitlab
	# wait for gitlab ?
	gitlab_create_repo

	# kubectl apply -f https://raw.githubusercontent.com/maxime-42/iot_p3/main/config_cd.yaml

	wait_argocd_is_ready
	get_apps_info
}

main "$@"
