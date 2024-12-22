# Homelab-K8s

This repository contains scripts and mostly yaml files to spin up and deploy services in a Kubernetes cluster running in Proxmox using TalOS as the foundation.

## How To

1. Check the `talos/scripts` directory. Generate secrets `talosctl gen secrets -o secrets/secret.yaml`, configure static IPs in [generate_config.sh](./talos/scripts/generate_configs.sh) and run the script.
1. Deploy the config with the help of [apply_config.sh](./talos/scripts/apply_configs.sh)
1. Create `secrets/values.yaml` via `cp secrets/values_template.yaml secrets/values.yaml` and configure required secrets
1. Once the cluster is ready to use, set the kubeconfig `export KUBECONFIG=$(pwd)/kubeconfig` and deploy all services using [setup_cluster.sh](./scripts/setup_cluster.sh)

## Todos

- [x] Successfully create K8s cluster in Proxmox VMs using TalOS
- [ ] Multi Controlplane Cluster using 2 Controlplane TalOS VMs
- [x] Successfully deploy Cert-Manager which creates valid certificates
- [x] Successfully deploy Kube-Vip
- [x] Successfully deploy Traefik
- [ ] A Traefik pod runs on every node to have some kind of HA setup
- [x] Deploy an app and it is reachable in local network via external IP
- [x] Deploy an app and it is reachable in local network via some dummy dns + modification of /etc/hosts on a client machine
- [x] Deploy an app end to end with dedicated certificates (whoami-external)
- [x] Decide about storage provider. Requirements:
  - The node that hosts proxmox has a dediqated 2TB SSD where data will be stored. This must be available to many pods
  - A multi VM multi Node setup must be possible
  - Some PVs that will be used for database and backed up on a daily basis.
  - Some PVs that just store some 'not so important data'. Can be used from the VMs storage itself, but must be checked against how TalOS behaves on reset/upgrade etc.
  - **Decision: [Longhorn](https://longhorn.io)**
- [ ] Testing of Longhorn + TalOS
  - Add a second disk to VM
  - Configure it in TalOS (adapt config scripts)
  - Verify `talosctl reset` does not delete contents of the disk
  - Create PV + PVC; write some data to it using a Deployment; configure and do backup of disk to another disk; check for files on disk; do a disaster recovery once
- [x] successfully deploy storage provider
- [x] TalOS extract secrets and use templating mechanism
- [x] Proper scripts for setup of cluster and cluster installation (ongoing WIP)
- [ ] Script to uninstall everything from the cluster
- [x] Minimal README (ongoing WIP)
- [x] Write a script that fills in `secrets/values.yaml` and `secrets/secrets.yaml` from defined vaultwarden
- [ ] Script that stores current `secrets/values.yaml` and `secrets/secrets.yaml` in vaultwarden
- [x] Use traefik ingress objects instead of standard ingress
- [x] Use a single wildcard certificate instead of a certificate for each service
- [ ] Successfully deploy crowdsec
- [ ] Successfully deploy keel
- [ ] Single postgres deployment to be used by many services
- [ ] Successfully deploy signoz
- [ ] Migrate stack from docker-compose to K8s
- [ ] Expose USB HDDs in network as backup drives. Currently the Fritzbox exposes them as Samba Shares. Requirements:
  - Longhorn can use the disks; according to [Longhorn docs](https://longhorn.io/docs/1.7.2/snapshots-and-backups/backup-and-restore/set-backup-target/) it should be possible to use a Samba Share
- [ ] configure backups for important PVs
- [ ] Enhanced security using RBAC
