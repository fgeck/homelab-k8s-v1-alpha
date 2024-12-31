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


FINAL_CONTROL_PLANE_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_1_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker-1.yaml | cut -d'/' -f1)
FINAL_WORKER_2_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker-2.yaml | cut -d'/' -f1)

check_ip_reachability() {
  local ip="$1"
  local fallback_ip="$2"

  
  # Run curl and capture the response
  response=$(curl -s -o /dev/null --connect-timeout 3 -w "%{http_code}" "http://$ip:50000")
  
  # Check if the response indicates an empty reply
  if [[ $response == "000" ]]; then
    #log_debug "Final $role IP is reachable: $ip"
    echo "$ip"
  else
    #log_debug "Final $role IP is not reachable, falling back to current IP: $fallback_ip"
    echo "$fallback_ip"
  fi
}

apply_talos_config() {
  local node_ip="$1"
  local config_file="$2"
  local insecure_flag=""

  log_info "Attempting to apply Talos config to node: $node_ip using $config_file"

  # Try without --insecure
  if ! talosctl apply-config --nodes "$node_ip" --file "$config_file" $insecure_flag; then
    log_debug "First attempt failed, retrying with --insecure..."
    # Retry with --insecure
    insecure_flag="--insecure"
    if talosctl apply-config --nodes "$node_ip" --file "$config_file" $insecure_flag; then
      log_success "Successfully applied Talos config to $node_ip with --insecure"
    else
      log_error "Failed to apply Talos config to $node_ip with --insecure"
      exit 1
    fi
  else
    log_success "Successfully applied Talos config to $node_ip"
  fi
}

# Determine the Control Plane IP
CONTROL_PLANE_IP=$(check_ip_reachability "$FINAL_CONTROL_PLANE_IP" "$CURRENT_CONTROL_PLANE_IP")
# Determine the Worker IP
WORKER_1_IP=$(check_ip_reachability "$FINAL_WORKER_1_IP" "$CURRENT_WORKER_1_IP")
WORKER_2_IP=$(check_ip_reachability "$FINAL_WORKER_2_IP" "$CURRENT_WORKER_2_IP")


log_info "Applying the final configs to the nodes..."
log_info "  Control Plane: $CONTROL_PLANE_IP"
log_info "  Worker-1: $WORKER_1_IP"
log_info "  Worker-2: $WORKER_2_IP"

log_exec talosctl apply-config --nodes "$CONTROL_PLANE_IP" --file "talos/_out/controlplane.yaml" --insecure
log_exec talosctl apply-config --nodes "$WORKER_1_IP" --file "talos/_out/worker-1.yaml" --insecure
log_exec talosctl apply-config --nodes "$WORKER_2_IP" --file "talos/_out/worker-2.yaml" --insecure

log_info "Waiting 2m for the control plane to be ready... Eventually you have to retrigger this script if 1m was not enough"
sleep 120

log_exec talosctl config endpoint "$FINAL_CONTROL_PLANE_IP"
log_exec talosctl config node "$FINAL_CONTROL_PLANE_IP"

log_info "Bootstrapping the cluster now"

log_exec talosctl bootstrap

log_info "Checking the health of the cluster..."

log_exec talosctl health

log_exec talosctl kubeconfig -f .

talosctl dashboard --nodes "$FINAL_CONTROL_PLANE_IP","$FINAL_WORKER_1_IP","$FINAL_WORKER_2_IP"
