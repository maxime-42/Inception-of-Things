#!/bin/sh

set -e

cd /tmp
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh  >> install_k3d.sh
chmod +x install_k3d.sh
K3D_INSTALL_DIR=$HOME/bin ./install_k3d.sh --no-sudo
cd -