#!/bin/bash

# Usage:
# 1. generate your secrets.yaml file: talosctl gen secrets -o ./secrets/secrets.yaml
# 2. set your static IP addresses and the gateway in the variables below
# 3. run this script from the root of this repository

# --------------------------------CONFIG----------------------------------------
CLUSTER_NAME=""
CONTROL_PLANE_IP=""
WORKER_IP=""
GATEWAY=""
# v1.9.0 Contains qemu-guest-agent, iscsi-tools 
IMAGE="factory.talos.dev/installer/dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586:v1.9.0"
# --------------------------------CONFIG----------------------------------------

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository${COLOR_RESET}" >&2
  exit 1
fi
# Source the helper script
source ./scripts/helper_funcs.sh

mkdir -p talos/_out

talosctl gen config $CLUSTER_NAME https://${CONTROL_PLANE_IP}:6443 \
    --config-patch-control-plane "[{\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${CONTROL_PLANE_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}, {\"op\": \"add\", \"path\": \"/machine/install/image\", \"value\": \"${IMAGE}\"}]" \
    --config-patch-worker "[{\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${WORKER_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}, {\"op\": \"add\", \"path\": \"/machine/install/image\", \"value\": \"${IMAGE}\"}]" \
    --with-secrets ./secrets/secrets.yaml \
    -o talos/_out/

