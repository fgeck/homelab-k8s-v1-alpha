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
assert_tools_installed talosctl

FINAL_CONTROL_PLANE_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' secrets/talos/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_1_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' secrets/talos/worker-1.yaml | cut -d'/' -f1)
FINAL_WORKER_2_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' secrets/talos/worker-2.yaml | cut -d'/' -f1)

gum confirm "Are you sure you want to reset nodes: $FINAL_CONTROL_PLANE_IP, $FINAL_WORKER_1_IP, $FINAL_WORKER_2_IP ?" || exit 1

LOG_TMP_CONTROLPLANE=$(mktemp)
log_info "Resetting node: $FINAL_CONTROL_PLANE_IP logs will be saved to $LOG_TMP_CONTROLPLANE"
log_exec talosctl reset --reboot --graceful=false -n "$FINAL_WORKER_2_IP" > "$LOG_TMP_CONTROLPLANE" 2>&1 &

LOG_TMP_WORKER1=$(mktemp)
log_info "Resetting node: $FINAL_WORKER_1_IP logs will be saved to $LOG_TMP_WORKER1"
log_exec talosctl reset --reboot --graceful=false -n "$FINAL_WORKER_1_IP" > "$LOG_TMP_WORKER1" 2>&1 &

LOG_TMP_WORKER2=$(mktemp)
log_info "Resetting node: $FINAL_WORKER_2_IP logs will be saved to $LOG_TMP_WORKER2"
log_exec talosctl reset --reboot --graceful=false -n "$FINAL_CONTROL_PLANE_IP" > "$LOG_TMP_WORKER2" 2>&1 &

log_success "Node reset commands have been fired"
