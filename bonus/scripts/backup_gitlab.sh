#!/bin/sh

# doc: https://docs.gitlab.com/charts/architecture/backup-restore.html
# backup-utility source: https://gitlab.com/gitlab-org/build/CNG/-/blob/master/gitlab-toolbox/scripts/bin/backup-utility
# https://www.youtube.com/watch?v=G-KZzn1f-i8&ab_channel=LinuxHelp

set -eu

cd $(dirname $0)

gitlab_backups_path='/srv/gitlab/tmp/backups/'
pod_name_toolbox="$(kubectl get pod -n gitlab | grep toolbox | awk '{print $1;}')"

rm -rf ../config/gitlab/
mkdir -p ../config/gitlab/backup

kubectl -n gitlab exec -i "$pod_name_toolbox" -- bash -c \
	"rm -rf $gitlab_backups_path \
	&& gitlab-rake gitlab:backup:create"
kubectl cp gitlab/"$pod_name_toolbox":"$gitlab_backups_path" ../config/gitlab/backup && \
kubectl -n gitlab exec -i "$pod_name_toolbox" -- bash -c \
	"rm -rf $gitlab_backups_path \
	&& mkdir -p $gitlab_backups_path"

kubectl -n gitlab get secrets gitlab-rails-secret -o yaml > ../config/gitlab/gitlab-rails-secret.yaml
