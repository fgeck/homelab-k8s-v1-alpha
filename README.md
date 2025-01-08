# Homelab-K8s

This repository contains scripts and mostly yaml files to spin up and deploy services in a Kubernetes cluster running in Proxmox using TalOS as the foundation.

## How To

1. Create you secret values: `cp secrets/values_template.yaml secrets/values.yaml`
1. Add all secrets you need. Especially start with the `scriptConfigs` section
     - ⚠️ ATTENTION ⚠️
     As the secrets are stored in plain text it is highly recommended to use the scripts in `scripts/secrets/` to push and pull all secrets (stored in `secrets/` directory) to/from a vaultwarden or bitwarden instance. After you have successfully deployed everything delete the contents of secrets directory. **Use at your own risk!**
1. Generate secrets `talosctl gen secrets -o secrets/secret.yaml`
1. Generate the TalOS config with [scripts/talos/config_generate.sh](/scripts/talos/config_generate.sh). The bash script is implemented to create 2 worker configs, each using the configured static IP from `secrets/values.yaml`
1. If you have not setup your VMs for TalOS follow this [guide](https://www.talos.dev/v1.8/talos-guides/install/virtualized-platforms/proxmox/). Stop at generating/applying any config and come back to this README
1. Deploy the config with the help of [nodes_setup.sh](/scripts/talos/nodes_setup.sh)
1. Once the cluster is ready to use, set the kubeconfig `export KUBECONFIG=$(pwd)/secrets/kubeconfig` and deploy all services using [scripts/cluster/setup.sh](/scripts/cluster/setup.sh)
1. Nodes can be reset using [scripts/talos/nodes_reset.sh](/scripts/talos/nodes_reset.sh)
1. Config of nodes can be updated using [scripts/talos/nodes_update.sh](/scripts/talos/nodes_update.sh)

## Todos

- [x] Successfully create K8s cluster in Proxmox VMs using TalOS
- [ ] Multi Controlplane Cluster using 2 Controlplane TalOS VMs
- [x] Successfully deploy Cert-Manager which creates valid certificates
- [x] Successfully deploy Kube-Vip
- [x] Successfully deploy Traefik
- [x] A Traefik pod runs on every node to have some kind of HA setup. --> Configure as Daemsonset
- [x] Deploy an app and it is reachable in local network via external IP
- [x] Deploy an app and it is reachable in local network via some dummy dns + modification of /etc/hosts on a client machine
- [x] Deploy an app end to end with dedicated certificates (whoami-external)
- [x] Decide about storage provider. Requirements:
  - The node that hosts Proxmox has a dedicated 2TB SSD where data will be stored. This must be available to many pods
  - A multi VM multi Node setup must be possible
  - Some PVs that will be used for database and backed up on a daily basis.
  - Some PVs that just store some 'not so important data'. Can be used from the VMs storage itself, but must be checked against how TalOS behaves on reset/upgrade etc.
  - **Decision: [Longhorn](https://longhorn.io)** --> Use PV+PVCs backed by longhorn volumes for everything except of media files (movies, music, books etc.), those will be stored and accessed to/from a NFS
- [x] Testing of Longhorn + TalOS
  - Add a second disk to VM
  - Configure it in TalOS (adapt config scripts)
  - Verify `talosctl reset` does not delete contents of the disk
  - Create PV + PVC; write some data to it using a Deployment; configure and do backup of disk to another disk; check for files on disk; do a disaster recovery once
- [x] The 2 TB Data SSD must be exposed in the cluster to read/write data as well as via SMB share to be able to access the files via Windows and Mac. According to [official K8s documentation](https://github.com/kubernetes-csi/csi-driver-smb/blob/master/deploy/example/smb-provisioner/README.md) it is possible to deploy a Samba Deployments. Current idea: Mount Data SSD in a worker VM, make the Samba Server Deployment stick to that Node. But how will other Pods be able to write to that Disk?
--> New Idea: Longhorn use RWX for the data disk. This exposes the disk via NFS according to their [documentation](https://longhorn.io/docs/1.7.2/nodes-and-volumes/volumes/rwx-volumes/#configuring-volume-locality-for-rwx-volumes)
---> Final implementation: VM which only acts as NFS share
- [ ] Expose USB HDDs in network as backup drives. Currently the Fritzbox exposes them as Samba Shares. Requirements:
  - Longhorn can use the disks; according to [Longhorn docs](https://longhorn.io/docs/1.7.2/snapshots-and-backups/backup-and-restore/set-backup-target/) it should be possible to use a Samba Share
  - Final Setup for backups: Use RPI to host [Openmediavault](https://www.openmediavault.org/)
- [x] successfully deploy storage provider
- [x] TalOS extract secrets and use templating mechanism
- [x] Proper scripts for setup of cluster and cluster installation
- [x] Script to uninstall everything from the cluster
- [x] Minimal README
- [x] Write a script that fills in `secrets/values.yaml` and `secrets/secrets.yaml` from defined vaultwarden
- [x] Script that stores current `secrets/values.yaml` and `secrets/secrets.yaml` in vaultwarden
- [x] Use traefik ingress objects instead of standard ingress
- [x] Use a single wildcard certificate instead of a certificate for each service
- [ ] Successfully deploy [Crowdsec](https://github.com/crowdsecurity/helm-charts)
- [x] ~~Successfully deploy Keel~~
- [x] Configure Renovate
- [x] Successfully deploy [Vaultwarden](https://github.com/dani-garcia/vaultwarden) incl. postgres communication
- [x] Successfully deploy [Authentik](https://docs.goauthentik.io/docs/install-config/install/kubernetes) incl. postgres communication
- [x] Successfully deploy [Uptime-Kuma](https://github.com/dirsigler/uptime-kuma-helm/tree/main)
- [ ] Successfully deploy [Signoz](https://signoz.io/docs/install/kubernetes/others/)
- [x] Successfully deploy [Portainer](https://github.com/portainer/k8s/tree/master/deploy/helm/charts/portainer)
- [x] Successfully deploy Mediastack incl. postgres communication
- [ ] Successfully deploy [Immich](https://github.com/immich-app/immich-charts)
- [ ] Successfully deploy [Spoolman](https://github.com/Donkie/Spoolman)
- [ ] Successfully deploy [Homepage](https://gethomepage.dev/installation/k8s/#install-with-helm)
- [ ] Successfully deploy [Wallabag](https://github.com/wallabag/wallabag)
- [x] Default [Postgres](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) deployment to be used by many services
- [x] Security [Postgres](https://github.com/bitnami/charts/tree/main/bitnami/postgresql) deployment to be used by important services
- [ ] Networkpolicies for security postgres
- [ ] Migrate stack from docker-compose to K8s
- [ ] Once migrated, test End2End and configure:
  - [ ] Crowdsec
  - [ ] Keel
  - [ ] Vaultwarden
  - [ ] Authentik
  - [ ] Uptime-Kuma
  - [ ] Signoz
  - [ ] Mediastack
  - [ ] Immich
  - [ ] Spoolman
  - [ ] Homepage
- [ ] configure backups for PVs
- [ ] Enhanced security using RBAC
- [ ] (Fun project) Write a golang cli to be able to remove the bash scripts. Especially for secrets pushing/pulling
