#!/bin/bash

# Usage:
# 1. generate your secrets.yaml file: talosctl gen secrets -o ./secrets/secrets.yaml
# 2. set your static IP addresses and the gateway in the variables below
# 3. run this script from the root of this repository

CLUSTER_NAME=""
CONTROL_PLANE_IP=""
WORKER_IP=""
GATEWAY=""
# v1.9.0 Contains qemu-guest-agent, iscsi-tools 
IMAGE="factory.talos.dev/installer/dc7b152cb3ea99b821fcb7340ce7168313ce393d663740b791c36f6e95fc8586:v1.9.0"

mkdir -p talos/_out

talosctl gen config $CLUSTER_NAME https://${CONTROL_PLANE_IP}:6443 \
    --config-patch-control-plane "[{\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${CONTROL_PLANE_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}, {\"op\": \"add\", \"path\": \"/machine/install/image\", \"value\": \"${IMAGE}\"}]" \
    --config-patch-worker "[{\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${WORKER_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}, {\"op\": \"add\", \"path\": \"/machine/install/image\", \"value\": \"${IMAGE}\"}]" \
    --with-secrets ./secrets/secrets.yaml \
    -o talos/_out/

