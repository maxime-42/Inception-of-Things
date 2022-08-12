#!/bin/bash

set -eu

# lib
source $(dirname "$0")/logger.sh

do_backup(){
	local backups_local_path="../config/gitlab/backup/"
	local backups_pod_path="/srv/gitlab/tmp/backups/"
	local pod_name_toolbox
		pod_name_toolbox="$(kubectl get pod -n gitlab | grep toolbox | awk '{print $1;}')"
	local newest_backup_file=
		newest_backup_file="$(ls -Art $backups_local_path | tail -n 1)"

	log_info 'Restoring backup...'
	kubectl -n gitlab exec -i "$pod_name_toolbox" -- mkdir -p $backups_pod_path
	kubectl cp $backups_local_path/"$newest_backup_file" gitlab/"$pod_name_toolbox":"$backups_pod_path"
	kubectl -n gitlab exec -i "$pod_name_toolbox" -- gitlab-rake gitlab:backup:restore force=yes || true
	log_info 'Restoration done.'
}

replace_secret(){
	if kubectl -n gitlab get secrets | grep -q gitlab-rails-secret ; then
		kubectl -n gitlab delete secret gitlab-rails-secret
		log_info 'rail secret deleted'
		kubectl -n gitlab apply -f ../config/gitlab/gitlab-rails-secret.yaml
		log_info 'rail secret from backup applied.'
	else
		log_error 'default rail secret not found ! should wait ?'
	fi

	if kubectl -n gitlab get secrets | grep -q  gitlab-gitlab-initial-root-password ; then
		kubectl -n gitlab delete secret gitlab-gitlab-initial-root-password
		log_info 'root secret deleted'
		kubectl -n gitlab apply -f ../config/gitlab/gitlab-initial-root-password.yaml
	else
		log_error 'default rail secret not found ! should wait ?'
	fi
}

delete_gitlab_pods(){
	local helm_release='gitlab'
	log_info 'Deleting some pods to make them use the secrets from the backup'
	kubectl -n gitlab delete pods -lapp=sidekiq,release="$helm_release"
	kubectl -n gitlab delete pods -lapp=webservice,release="$helm_release"
	kubectl -n gitlab delete pods -lapp=toolbox,release="$helm_release"
}

main()
{
	cd $(dirname $0)

	replace_secret
	delete_gitlab_pods
	log_info 'Waiting gitlab webservice to be ready...'
	kubectl -n gitlab wait --timeout=-1s --for=condition=available deployments.apps gitlab-webservice-default	
	do_backup
	log_info 'Waiting again...'
	kubectl -n gitlab wait --timeout=-1s --for=condition=available deployments.apps gitlab-webservice-default	
}

main "$@"
