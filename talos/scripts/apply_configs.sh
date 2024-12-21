#!/bin/bash

set -e

# Usage:
# Configure the control plane and worker nodes IPs which were assigned via DHCP
# when the OS was installed. Can be found in the VM screen
# Run the script from the root of this repository. It will fetch the final IPs from the config files

CURRENT_CONTROL_PLANE_IP=
CURRENT_WORKER_IP=

FINAL_CONTROL_PLANE_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker.yaml | cut -d'/' -f1)

check_ip_reachability() {
  local ip="$1"
  local fallback_ip="$2"

  
  # Run curl and capture the response
  response=$(curl -s -o /dev/null --connect-timeout 3 -w "%{http_code}" "http://$ip:50000")
  
  # Check if the response indicates an empty reply
  if [[ $response == "000" ]]; then
    #echo "Final $role IP is reachable: $ip"
    echo "$ip"
  else
    #echo "Final $role IP is not reachable, falling back to current IP: $fallback_ip"
    echo "$fallback_ip"
  fi
}

# Determine the Control Plane IP
CONTROL_PLANE_IP=$(check_ip_reachability "$FINAL_CONTROL_PLANE_IP" "$CURRENT_CONTROL_PLANE_IP")
# Determine the Worker IP
WORKER_IP=$(check_ip_reachability "$FINAL_WORKER_IP" "$CURRENT_WORKER_IP")


echo "Applying the final configs to the nodes..."
echo "  Control Plane: $CONTROL_PLANE_IP"
echo "  Worker: $WORKER_IP"

talosctl apply-config --insecure --nodes "$CONTROL_PLANE_IP" --file talos/_out/controlplane.yaml
talosctl apply-config --insecure --nodes "$WORKER_IP" --file talos/_out/worker.yaml

echo "Waiting 2m for the control plane to be ready... Eventually you have to retrigger this script if 1m was not enough"
sleep 120

talosctl config endpoint "$FINAL_CONTROL_PLANE_IP"
talosctl config node "$FINAL_CONTROL_PLANE_IP"

echo "Bootstrapping the cluster now"

talosctl bootstrap

echo "Checking the health of the cluster..."

talosctl health

talosctl kubeconfig .

talosctl dashboard --nodes "$FINAL_CONTROL_PLANE_IP","$FINAL_WORKER_IP"
