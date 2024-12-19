# Homelab-K8s

This repository contains scripts and mostly yaml files to spin up and deploy services in a Kubernetes cluster running in Proxmox using TalOS as the foundation.

## How To

1. Check the `talos/scripts` directory. Generate secrets `talosctl gen secrets -o secrets/secret.yaml`, configure static IPs in [generate_config.sh](./talos/scripts/generate_configs.sh) and run the script.
1. Deploy the config with the help of [apply_config.sh](./talos/scripts/apply_configs.sh)
1. Create `secrets/values.yaml` via `cp secrets/values_template.yaml secrets/values.yaml` and configure required secrets
1. Once the cluster is ready to use, set the kubeconfig `export KUBECONFIG=$(pwd)/kubeconfig` and deploy all services using [setup_cluster.sh](./scripts/setup_cluster.sh)

## Todos

- [x] successfully create K8s cluster in Proxmox VMs using TalOS
- [x] successfully deploy cert-manager which creates valid certificates
- [x] successfully deploy kube-vip
- [x] deploy an app and it is reachable in local network via external IP
- [x] deploy an app and it is reachable in local network via some dummy dns + modification of /etc/hosts on a client machine
- [x] deploy an app end to end with dedicated certificates (whoami-external)
- [ ] decide about storage provider. Requirements:
  - The node that hosts proxmox has a dediqated 2TB SSD where data will be stored. This must be available to many pods
  - A multi VM multi Node setup must be possible
  - Some PVs that will be used for database and backed up on a daily basis.
  - Some PVs that just store some 'not so important data'. Can be used from the VMs storage itself, but must be checked against how TalOS behaves on reset/upgrade etc.
- [ ] successfully deploy storage provider
- [x] talos extract secrets and use templating mechanism
- [x] proper scripts for setup/teardown of cluster and cluster installation
- [x] minimal README
- [ ] Use traefik ingress objects instead of standard ingress
- [ ] successfully deploy crowdsec
- [ ] successfully deploy keel
- [ ] single postgres deployment to be used by many services
- [ ] backup for selected PVs
- [ ] successfully deploy signoz
- [ ] enhanced security using RBAC
