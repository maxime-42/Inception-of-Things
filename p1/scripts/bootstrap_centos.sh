#!/bin/sh

set -e

echo "Setting up mirrors and dnf update..."
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
dnf -y update

echo "Setting up aliases"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
echo "alias c='clear'" >> /home/vagrant/.bashrc
