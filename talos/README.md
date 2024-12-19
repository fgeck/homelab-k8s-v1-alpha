# Install TalOS

Documentation can be found [here](https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/).

```bash
mkdir -p _out/
curl -L https://factory.talos.dev/image/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515/v1.9.0/nocloud-amd64.iso  -o talos_1.9.0_qemu.iso

# upload to proxmox, or download directly in proxmox
# create VMs

export CONTROL_PLANE_IP=
talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out --install-image  factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.9.0

# Set static IPs in config

#     network:
#       interfaces:
#         - interface: eth0 # The interface name.
#           addresses:
#             - 192.168.178.130/24
#           routes:
#             - network: 0.0.0.0/0 # The route's network (destination).
#               gateway: 192.168.178.1 # The route's gateway (if empty, creates link scope route).
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml

export WORKER_IP=
# Set static IPs in config
talosctl apply-config --insecure --nodes $WORKER_IP --file _out/worker.yaml

export TALOSCONFIG="_out/talosconfig"
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
talosctl bootstrap
talosctl kubeconfig .

export KUBECONFIG=$(pwd)/kubeconfig
```
