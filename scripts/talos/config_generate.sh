#!/bin/bash

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository${COLOR_RESET}" >&2
  exit 1
fi
# Source the helper script
source ./scripts/helper_funcs.sh
assert_tools_installed talosctl
if [[ "$OSTYPE" == "darwin"* ]]; then
    assert_tools_installed gsed
fi

# Usage:
# 1. generate your secrets.yaml file: talosctl gen secrets -o ./secrets/secrets.yaml
# 2. set your static IP addresses and the gateway in the variables below
# 3. run this script from the root of this repository

# --------------------------------CONFIG----------------------------------------
CLUSTER_NAME=$(yq eval '.scriptConfigs.clusterName' secrets/values.yaml)
CONTROL_PLANE_IP=$(yq eval '.scriptConfigs.finalControlPlaneIp' secrets/values.yaml)
WORKER1_IP=$(yq eval '.scriptConfigs.finalWorker1Ip' secrets/values.yaml)
WORKER2_IP=$(yq eval '.scriptConfigs.finalWorker2Ip' secrets/values.yaml)
GATEWAY=$(yq eval '.scriptConfigs.gateway' secrets/values.yaml)

# v1.9.0 Contains qemu-guest-agent, iscsi-tools, util-linux-tools
IMAGE="factory.talos.dev/installer/88d1f7a5c4f1d3aba7df787c448c1d3d008ed29cfb34af53fa0df4336a56040b:v1.9.0"
# --------------------------------CONFIG----------------------------------------

talosctl gen config --force "$CLUSTER_NAME" https://${CONTROL_PLANE_IP}:6443 \
    --config-patch-control-plane "[ \
        {\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${CONTROL_PLANE_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}, \
        {\"op\": \"add\", \"path\": \"/machine/install/image\", \"value\": \"${IMAGE}\"}, \
        {\"op\": \"add\", \"path\": \"/cluster/apiServer/admissionControl/0/configuration/exemptions/namespaces/-\", \"value\": \"longhorn-system\"}, \
        {\"op\": \"add\", \"path\": \"/machine/kubelet/extraMounts\", \"value\": [{\"destination\": \"/var/lib/longhorn\", \"type\": \"bind\", \"source\": \"/var/lib/longhorn\", \"options\": [\"bind\", \"rshared\", \"rw\"]}]} \
    ]" \
    --config-patch-worker "[ \
        {\"op\": \"add\", \"path\": \"/machine/network/interfaces\", \"value\": [{\"interface\": \"eth0\", \"addresses\": [\"${WORKER1_IP}/24\"], \"routes\": [{\"network\": \"0.0.0.0/0\", \"gateway\": \"${GATEWAY}\"}]}]}, \
        {\"op\": \"add\", \"path\": \"/machine/install/image\", \"value\": \"${IMAGE}\"}, \
        {\"op\": \"add\", \"path\": \"/machine/kubelet/extraMounts\", \"value\": [{\"destination\": \"/var/lib/longhorn\", \"type\": \"bind\", \"source\": \"/var/lib/longhorn\", \"options\": [\"bind\", \"rshared\", \"rw\"]}]} \
    ]" \
    --with-secrets ./secrets/secrets.yaml \
    -o ./test/talos/


mv ./test/talos/worker.yaml ./test/talos/worker-1.yaml
cp ./test/talos/worker-1.yaml ./test/talos/worker-2.yaml


if [[ "$OSTYPE" == "darwin"* ]]; then
    gsed -i "s/${WORKER1_IP}\/24/${WORKER2_IP}\/24/g" ./test/talos/worker-2.yaml
else
    sed -i "s/${WORKER1_IP}\/24/${WORKER2_IP}\/24/g" ./test/talos/worker-2.yaml
fi
