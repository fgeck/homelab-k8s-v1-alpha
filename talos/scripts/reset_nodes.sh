#!/bin/bash

# Check for correct arguments
if [ $# -lt 2 ]; then
  echo "Usage: $0 <CONTROL_PLANE_IP> <WORKER_IP> [--force]"
  exit 1
fi

# Handle --force argument
if [ "$3" == "--force" ]; then
  FORCE=true
  CONTROL_PLANE_IP=$1
  WORKER_IP=$2
else
  FORCE=false
  CONTROL_PLANE_IP=$1
  WORKER_IP=$2
fi

# Execute commands based on force flag
if [ "$FORCE" == true ]; then
  echo "Force option enabled. Using non-graceful reset."
  talosctl reset --reboot --graceful=false -n "$WORKER_IP"
  talosctl reset --reboot --graceful=false -n "$CONTROL_PLANE_IP"
else
  echo "Performing graceful reset."
  talosctl reset --reboot -n "$WORKER_IP"
  talosctl reset --reboot -n "$CONTROL_PLANE_IP"
fi
