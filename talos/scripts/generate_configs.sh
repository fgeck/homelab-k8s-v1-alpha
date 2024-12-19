#!/bin/bash

# Usage:
# 1. generate your secrets.yaml file: talosctl gen secrets -o ./secrets/secrets.yaml
# 2. set your static IP addresses and the gateway in the variables below
# 3. run this script from the root of this repository

CONTROL_PLANE_IP=""
WORKER_IP=""
GATEWAY=""

mkdir -p talos/_out

talosctl gen config fgeck-k8s https://${CONTROL_PLANE_IP}:6443 \
    --config-patch-control-plane "[{\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${CONTROL_PLANE_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}]" \
    --config-patch-worker "[{\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${WORKER_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}]" \
    --with-secrets ./secrets/secrets.yaml \
    -o talos/_out/

