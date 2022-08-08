#!/bin/sh

set -e

CLUSTER_NAME='iot-bonus'

k3d cluster delete "$CLUSTER_NAME"
