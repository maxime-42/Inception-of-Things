#!/bin/sh
set -e

echo "Setting up mirrors and dnf update..."
#cd /etc/yum.repos.d/

sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
dnf -y update

echo "Setting up kubectl completion..."
# dnf install bash-completion
echo 'source <(kubectl completion bash)' >>~/.bashrc
#aiase
echo "Setting up aliases"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
echo "alias c='clear'" >> /home/vagrant/.bashrc
