#!/bin/bash

set -e

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi
script_dir="$(pwd)"

# Source the helper script
source ./scripts/helper_funcs.sh

log_info "-------------------------------------------------------------------------------------------"
log_info "-------------------------START-HELM-REPO-ADD/UPDATE-DEPDENCY-BUILD-------------------------"
log_info "-------------------------------------------------------------------------------------------"

log_exec helm repo add kube-vip https://kube-vip.github.io/helm-charts
log_exec helm repo add longhorn https://charts.longhorn.io
log_exec helm repo add traefik https://traefik.github.io/charts
# certmanager
log_exec helm repo add jetstack https://charts.jetstack.io
log_exec helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
# postgres
log_exec helm repo add bitnami https://charts.bitnami.com/bitnami
log_exec helm repo add signoz https://charts.signoz.io
log_exec helm repo add keel https://charts.keel.sh 
log_exec helm repo add vaultwarden https://guerzon.github.io/vaultwarden
log_exec helm repo add uptime-kuma https://dirsigler.github.io/uptime-kuma-helm

log_exec helm repo update

chart_dir="$script_dir/helm"
build_helm_dependencies "$chart_dir"

log_success "------------------------------------------------------------------------------------------"
log_success "-------------------------DONE-HELM-REPO-ADD/UPDATE-DEPDENCY-BUILD-------------------------"
log_success "------------------------------------------------------------------------------------------"

echo ""
log_info "------------------------------------------------------------------------------------------"
log_info "-------------------------START-HELM-UPGRADE/INSTALL---------------------------------------"
log_info "------------------------------------------------------------------------------------------"
echo ""

log_info "------------------------------------------------------------------------------------------"
log_info "START --> Bootstrapping Cluster. Installing: Kube-Vip, Traefik, Cert-Manager, Longhorn, Namespaces, Storageclasses, Credentials etc....."
log_info "------------------------------------------------------------------------------------------"
# kube-vip must be installed in kube-system ns and does not offer namespaceOverride option. Chart will use the current ns
log_exec kubectl config set-context --current --namespace=kube-system
log_exec helm upgrade bootstrap "$script_dir/helm/1-bootstrap" --install -f $script_dir/helm/1-bootstrap/values.yaml -f $script_dir/secrets/values.yaml
# This is a workaround  because cert-manager CRs need to be deployed after cert-manager webhook is ready
# https://cert-manager.io/docs/concepts/webhook/#webhook-connection-problems-shortly-after-cert-manager-installation
log_exec helm upgrade certs "$script_dir/helm/1a-certificates" --install -f $script_dir/secrets/values.yaml
log_success "------------------------------------------------------------------------------------------"
log_success "DONE -> Bootstrapping Cluster. Installing: Kube-Vip, Traefik, Cert-Manager, Longhorn, Namespaces, Storageclasses, Credentials etc....."
log_success "------------------------------------------------------------------------------------------"
echo ""

log_info "------------------------------------------------------------------------------------------"
log_info "START --> Deploying Databases                                                            |"
log_info "------------------------------------------------------------------------------------------"
echo ""
log_exec kubectl config set-context --current --namespace=default
log_exec helm upgrade persistence "$script_dir/helm/2-persistence" --install  -f $script_dir/helm/2-persistence/values.yaml -f $script_dir/secrets/values.yaml
log_success "------------------------------------------------------------------------------------------"
log_success "DONE --> Deploying Databases                                                             |"
log_success "------------------------------------------------------------------------------------------"
echo ""

log_info "------------------------------------------------------------------------------------------"
log_info "START --> Deploying Monitoring: Uptime-Kuma, Signoz                                      |"
log_info "------------------------------------------------------------------------------------------"
echo ""
log_exec kubectl config set-context --current --namespace=monitoring
# namespace needed until https://github.com/dirsigler/uptime-kuma-helm/pull/181 is merged
log_exec helm upgrade monitoring "$script_dir/helm/3-monitoring" --namespace monitoring --install -f $script_dir/helm/3-monitoring/values.yaml -f $script_dir/secrets/values.yaml
log_success "------------------------------------------------------------------------------------------"
log_success "DONE --> Deploying Monitoring: Uptime-Kuma, Signoz                                       |"
log_success "------------------------------------------------------------------------------------------"
echo ""

log_info "------------------------------------------------------------------------------------------"
log_info "START --> Deploying Media: Sabnzbd, *arr, Jellyseerr, Jellyfin, Calibre-Web-Automated... |"
log_info "------------------------------------------------------------------------------------------"
echo ""
log_exec kubectl config set-context --current --namespace=media
log_exec helm upgrade media "$script_dir/helm/4-media" --install -f $script_dir/helm/4-media/values.yaml -f $script_dir/secrets/values.yaml
log_success "------------------------------------------------------------------------------------------"
log_success "DONE --> Deploying Media: Sabnzbd, *arr, Jellyseerr, Jellyfin, Calibre-Web-Automated...  |"
log_success "------------------------------------------------------------------------------------------"
echo ""

# log_info "START --> Deploying All other Apps"
# echo ""
# log_exec helm upgrade media "$script_dir/helm/5-apps" --install -f $script_dir/helm/5-apps/values.yaml -f $script_dir/secrets/values.yaml
# log_success "DONE --> Deploying All other Apps"
# echo ""

# Workaround as Kube-Vip/Kube-Vip-Cloudprovider seems to be stuck sometimes after install/upgrade
log_exec kubectl rollout restart deployment kube-vip-cloud-provider -n kube-system
log_exec kubectl rollout restart daemonset kube-vip -n kube-system
# log_exec kubectl rollout restart  deployment traefik -n edge

log_success "------------------------------------------------------------------------------------------"
log_success "-----------------------------------DONE-HELM-UPGRADE--------------------------------------"
log_success "------------------------------------------------------------------------------------------"
