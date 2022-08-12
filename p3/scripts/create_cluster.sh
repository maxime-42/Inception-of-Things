#!/bin/bash

set -eu

# lib
. $(dirname "$0")/logger.sh

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
		log_clear_lastline
		log_info "Waiting... $i sec before timeout"
		sleep 5
		i=$((i - 5))
	done
	if [ "$i" = "0" ]; then
		log_error 'Argocd failed to start in time.'
	fi
}

get_default_argocd_creds(){
	local password="$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo)"
	echo 'ArgoCD:'
	echo '  - URL : https://localhost:8080'
	echo '  - Username: admin'
	echo "  - Password: $password"
	echo 'Playground:'
	echo '  - URL : http://localhost:8888'
}

main(){ 
	install_k3d
	k3d cluster delete "$CLUSTER_NAME"
	k3d cluster create -p '8888:30007@loadbalancer' -p '8080:30008@loadbalancer' "$CLUSTER_NAME"
	install_argo_cd

	kubectl apply -f https://raw.githubusercontent.com/maxime-42/iot-p3-mkayumba/main/config_cd.yaml
	wait_argocd_is_ready
	get_default_argocd_creds
}

main "$@"
