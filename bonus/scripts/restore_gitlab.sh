#!/bin/sh

# https://forum.gitlab.com/t/unable-to-login-as-root-after-backup-restore/46341
# https://docs.gitlab.com/ee/raketasks/restore_gitlab.html
# https://docs.gitlab.com/ee/raketasks/restore_gitlab.html#restore-for-docker-image-and-gitlab-helm-chart-installations

set -eux


cd $(dirname $0)

gitlab_backups_local_path="../config/gitlab/backup/"
gitlab_backups_path="/srv/gitlab/tmp/backups/"
newest_backup_file="$(ls -Art $gitlab_backups_local_path | tail -n 1)"
pod_name_toolbox="$(kubectl get pod -n gitlab | grep toolbox | awk '{print $1;}')"

kubectl -n gitlab exec -i "$pod_name_toolbox" -- mkdir -p $gitlab_backups_path
kubectl cp $gitlab_backups_local_path/"$newest_backup_file" gitlab/"$pod_name_toolbox":"$gitlab_backups_path"
kubectl -n gitlab exec -i "$pod_name_toolbox" -- gitlab-rake gitlab:backup:restore force=yes

# kubectl -n gitlab exec -i "$pod_name_toolbox" -- bash -c \
# 	"gitlab-ctl stop unicron \
# 	&& gitlab-ctl stop sidekiq \
# 	&& gitlab-ctl stop\
# 	&& gitlab-rake gitlab:backup:restore BACKUP=${newest_backup_file} force=yes
# 	&& gitlab-ctl start"
