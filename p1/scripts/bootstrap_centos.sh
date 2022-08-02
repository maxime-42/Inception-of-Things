#!/bin/sh

set -e

dnf -y update

echo "Disabling firewall..."
sudo systemctl disable firewalld --now # https://rancher.com/docs/k3s/latest/en/advanced/#additional-preparation-for-red-hat-centos-enterprise-linux

echo "Setting up aliases"
echo "alias k='kubectl'" >> /home/vagrant/.bashrc
echo "alias c='clear'" >> /home/vagrant/.bashrc
