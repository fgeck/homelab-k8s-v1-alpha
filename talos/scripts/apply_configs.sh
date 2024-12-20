#!/bin/bash

set -e

# Usage:
# Configure the control plane and worker nodes IPs which were assigned via DHCP
# when the OS was installed. Can be found in the VM screen
# Run the script from the root of this repository. It will fetch the final IPs from the config files

CURRENT_CONTROL_PLANE_IP=192.168.178.192
CURRENT_WORKER_IP=192.168.178.131

FINAL_CONTROL_PLANE_IP=$(yq '.machine.network.interfaces[0].addresses[0]' talos/_out/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_IP=$(yq '.machine.network.interfaces[0].addresses[0]' talos/_out/worker.yaml | cut -d'/' -f1)

# Caution this needs to be verified!
if curl -s --connect-timeout 3 "https://$FINAL_CONTROL_PLANE_IP:50000" >/dev/null 2>&1; then
  echo "Final Control Plane IP is reachable: $FINAL_CONTROL_PLANE_IP"
  CONTROL_PLANE_IP=$FINAL_CONTROL_PLANE_IP
else
  echo "Final Control Plane IP is not reachable, falling back to current IP: $CURRENT_CONTROL_PLANE_IP"
  CONTROL_PLANE_IP=$CURRENT_CONTROL_PLANE_IP
fi

if curl -s --connect-timeout 3 "https://$FINAL_WORKER_IP:50000" >/dev/null 2>&1; then
  echo "Final Worker IP is reachable: $FINAL_WORKER_IP"
  WORKER_IP=$FINAL_WORKER_IP
else
  echo "Final Worker IP is not reachable, falling back to current IP: $CURRENT_WORKER_IP"
  WORKER_IP=$CURRENT_WORKER_IP
fi

echo "Applying the final configs to the nodes..."
echo "  Control Plane: $CURRENT_CONTROL_PLANE_IP"
echo "  Worker: $CURRENT_WORKER_IP"

talosctl apply-config --insecure --nodes "$CONTROL_PLANE_IP" --file talos/_out/controlplane.yaml
talosctl apply-config --insecure --nodes "$WORKER_IP" --file talos/_out/worker.yaml

echo "Waiting 2m for the control plane to be ready... Eventually you have to retrigger this script if 1m was not enough"
sleep 120

talosctl config endpoint "$FINAL_CONTROL_PLANE_IP"
talosctl config node "$FINAL_CONTROL_PLANE_IP"

talosctl bootstrap

echo "Checking the health of the cluster..."

talosctl health

talosctl kubeconfig .

talosctl dashboard --nodes "$FINAL_CONTROL_PLANE_IP","$FINAL_WORKER_IP"
