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


FINAL_CONTROL_PLANE_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_1_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker-1.yaml | cut -d'/' -f1)
FINAL_WORKER_2_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker-2.yaml | cut -d'/' -f1)

log_info "Applying configs to the nodes..."
log_info "  Control Plane: $FINAL_CONTROL_PLANE_IP"
log_info "  Worker-1: $FINAL_WORKER_1_IP"
log_info "  Worker-2: $FINAL_WORKER_2_IP"

log_exec talosctl apply-config --nodes "$FINAL_CONTROL_PLANE_IP" --file "talos/_out/controlplane.yaml"
log_exec talosctl apply-config --nodes "$FINAL_WORKER_1_IP" --file "talos/_out/worker-1.yaml"
log_exec talosctl apply-config --nodes "$FINAL_WORKER_2_IP" --file "talos/_out/worker-2.yaml"

talosctl dashboard --nodes "$FINAL_CONTROL_PLANE_IP","$FINAL_WORKER_1_IP","$FINAL_WORKER_2_IP"
