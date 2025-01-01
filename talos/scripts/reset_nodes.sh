#!/bin/bash

FINAL_CONTROL_PLANE_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/controlplane.yaml | cut -d'/' -f1)
FINAL_WORKER_1_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker-1.yaml | cut -d'/' -f1)
FINAL_WORKER_2_IP=$(yq eval '.machine.network.interfaces[0].addresses[0]' talos/_out/worker-2.yaml | cut -d'/' -f1)

gum confirm "Are you sure you want to reset nodes: $FINAL_CONTROL_PLANE_IP, $FINAL_WORKER_1_IP, $FINAL_WORKER_2_IP ?" || exit 1

talosctl reset --reboot --graceful=false -n "$FINAL_WORKER_2_IP" > talos/_out/reset_worker2.log 2>&1 &
talosctl reset --reboot --graceful=false -n "$FINAL_WORKER_1_IP" > talos/_out/reset_worker1.log 2>&1 &
talosctl reset --reboot --graceful=false -n "$FINAL_CONTROL_PLANE_IP" > talos/_out/reset_controlplane.log 2>&1 &

echo "Node reset commands have been fired"
