#!/bin/sh

set -e

CLUSTER_NAME='iot-p3'

k3d cluster delete "$CLUSTER_NAME"
