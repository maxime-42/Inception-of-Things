#!/bin/sh

# https://forum.gitlab.com/t/unable-to-login-as-root-after-backup-restore/46341
# https://docs.gitlab.com/ee/raketasks/restore_gitlab.html
# https://docs.gitlab.com/ee/raketasks/restore_gitlab.html#restore-for-docker-image-and-gitlab-helm-chart-installations
# secrets: https://docs.gitlab.com/charts/backup-restore/restore.html

set -eux

cd $(dirname $0)

helm_release='gitlab'

do_backup(){
	local pod_name_toolbox="$(kubectl get pod -n gitlab | grep toolbox | awk '{print $1;}')"
	local backups_local_path="../config/gitlab/backup/"
	local backups_pod_path="/srv/gitlab/tmp/backups/"
	local newest_backup_file="$(ls -Art $backups_local_path | tail -n 1)"

	echo 'Restoring backup...'
	kubectl -n gitlab exec -i "$pod_name_toolbox" -- mkdir -p $backups_pod_path
	kubectl cp $backups_local_path/"$newest_backup_file" gitlab/"$pod_name_toolbox":"$backups_pod_path"
	kubectl -n gitlab exec -i "$pod_name_toolbox" -- gitlab-rake gitlab:backup:restore force=yes || true
	echo 'Restoration done.'
}

replace_secret(){
	if kubectl -n gitlab get secrets | grep -q gitlab-rails-secret ; then
		kubectl -n gitlab delete secret gitlab-rails-secret
		echo 'rail secret deleted'
		kubectl -n gitlab apply -f ../config/gitlab/gitlab-rails-secret.yaml
		echo 'rail secret from backup applied.'
	else
		echo 'default rail secret not found ! should wait ?'
		exit 42
	fi

	if kubectl -n gitlab get secrets | grep -q  gitlab-gitlab-initial-root-password ; then
		kubectl -n gitlab delete secret gitlab-gitlab-initial-root-password
		echo 'root secret deleted'
		kubectl -n gitlab apply -f ../config/gitlab/gitlab-initial-root-password.yaml
	else
		echo 'default rail secret not found ! should wait ?'
		exit 42
	fi
}

delete_gitlab_pods(){
	echo 'Deleting some pods to make them use the secrets from the backup'
	kubectl -n gitlab delete pods -lapp=sidekiq,release="$helm_release"
	kubectl -n gitlab delete pods -lapp=webservice,release="$helm_release"
	kubectl -n gitlab delete pods -lapp=toolbox,release="$helm_release"
}

main()
{
	replace_secret
	delete_gitlab_pods
	echo 'Waiting gitlab webservice to be ready...'
	kubectl -n gitlab wait --timeout=-1s --for=condition=available deployments.apps gitlab-webservice-default	
	do_backup
	echo 'Waiting again...'
	kubectl -n gitlab wait --timeout=-1s --for=condition=available deployments.apps gitlab-webservice-default	
}

main "$@"
