#!/bin/bash

set -e

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi
# Source the helper script
source ./scripts/helper_funcs.sh


# Usage:
# Configure the control plane and worker nodes IPs which were assigned via DHCP
# when the OS was installed. Can be found in the VM screen
# Run the script from the root of this repository. It will fetch the final IPs from the config files

# --------------------------------CONFIG----------------------------------------
CURRENT_CONTROL_PLANE_IP=$(yq '.scriptConfigs.currentControlPlaneIp' secrets/values.yaml)
CURRENT_WORKER_1_IP=$(yq '.scriptConfigs.currentWorker1Ip' secrets/values.yaml)
CURRENT_WORKER_2_IP=$(yq '.scriptConfigs.currentWorker2Ip' secrets/values.yaml)
# --------------------------------CONFIG----------------------------------------


FINAL_CONTROL_PLANE_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' secrets/talos/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_1_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' secrets/talos/worker-1.yaml | cut -d'/' -f1)
FINAL_WORKER_2_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' secrets/talos/worker-2.yaml | cut -d'/' -f1)

gum confirm "Applying configs to the nodes...? $CURRENT_CONTROL_PLANE_IP, $CURRENT_WORKER_1_IP, $CURRENT_WORKER_2_IP ?" || exit 1

log_exec talosctl apply-config --nodes "$CURRENT_CONTROL_PLANE_IP" --file "secrets/talos/controlplane.yaml" --insecure
log_exec talosctl apply-config --nodes "$CURRENT_WORKER_1_IP" --file "secrets/talos/worker-1.yaml" --insecure
log_exec talosctl apply-config --nodes "$CURRENT_WORKER_2_IP" --file "secrets/talos/worker-2.yaml" --insecure

log_info "Waiting 2m for the control plane to be ready... Eventually you have to retrigger this script if 2m was not enough"
sleep 120

log_exec talosctl config endpoint "$FINAL_CONTROL_PLANE_IP"
log_exec talosctl config node "$FINAL_CONTROL_PLANE_IP"

log_info "Bootstrapping the cluster now"

log_exec talosctl bootstrap

log_info "Checking the health of the cluster..."

log_exec talosctl health

log_exec talosctl kubeconfig -f ./secrets/kubeconfig

talosctl dashboard --nodes "$FINAL_CONTROL_PLANE_IP","$FINAL_WORKER_1_IP","$FINAL_WORKER_2_IP"
