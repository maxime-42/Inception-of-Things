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

	kubectl -n gitlab exec -i "$pod_name_toolbox" -- mkdir -p $backups_pod_path
	kubectl cp $backups_local_path/"$newest_backup_file" gitlab/"$pod_name_toolbox":"$backups_pod_path"
	kubectl -n gitlab exec -i "$pod_name_toolbox" -- gitlab-rake gitlab:backup:restore force=yes
}

replace_secret(){
	if kubectl -n gitlab get secrets | grep -q gitlab-rails-secret ; then
		kubectl -n gitlab delete secret gitlab-rails-secret
		echo 'rail secret deleted'
		kubectl -n gitlab apply -f ../config/gitlab/gitlab-rails-secret.yaml
	else
		echo 'default secret not found ! should wait ?'
		exit 42
	fi
}

delete_gitlab_pods(){
	kubectl -n gitlab delete pods -lapp=sidekiq,release="$helm_release"
	kubectl -n gitlab delete pods -lapp=webservice,release="$helm_release"
	kubectl -n gitlab delete pods -lapp=toolbox,release="$helm_release"
}

main()
{
	replace_secret
	delete_gitlab_pods
	do_backup
}

main "$@"
