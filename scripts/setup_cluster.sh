#!/bin/bash

set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi
# Source the helper script
source ./scripts/helper_funcs.sh

log_info "-------------------------START-HELM-REPO-ADD/UPDATE-DEPDENCY-BUILD-------------------------"

log_exec helm repo add kube-vip https://kube-vip.github.io/helm-charts
log_exec helm repo add longhorn https://charts.longhorn.io
log_exec helm repo add traefik https://traefik.github.io/charts
# certmanager
log_exec helm repo add jetstack https://charts.jetstack.io
log_exec helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
log_exec helm repo add bitnami https://charts.bitnami.com/bitnami
log_exec helm repo add signoz https://charts.signoz.io
log_exec helm repo add keel https://charts.keel.sh 
log_exec helm repo add vaultwarden https://guerzon.github.io/vaultwarden
log_exec helm repo add uptime-kuma https://dirsigler.github.io/uptime-kuma-helm

log_exec helm repo update

chart_dir="$script_dir/helm"
build_helm_dependencies "$chart_dir"

log_success "-------------------------DONE-HELM-REPO-ADD/UPDATE-DEPDENCY-BUILD-------------------------"
echo ""
log_info "-------------------------START-HELM-UPGRADE/INSTALL-------------------------"
echo ""

log_info "START --> Bootstrapping Cluster. Installing: Kube-Vip, Traefik, Cert-Manager, Longhorn, Namespaces, Storageclasses, Credentials etc....."
# kube-vip must be installed in kube-system ns and does not offer namespaceOverride option. Chart will use the current ns
log_exec kubectl config set-context --current --namespace=kube-system
log_exec helm upgrade bootstrap "$script_dir/helm/1-bootstrap" --install -f $script_dir/helm/1-bootstrap/values.yaml -f $script_dir/secrets/values.yaml
log_success "DONE -> Bootstrapping Cluster. Installing: Kube-Vip, Traefik, Cert-Manager, Longhorn, Namespaces, Storageclasses, Credentials etc....."
echo ""

log_info "START --> Deploying Routes, Middlewares, Certificates, Databases"
echo ""
log_exec kubectl config set-context --current --namespace=default
log_exec helm upgrade db "$script_dir/helm/2-edge-persistence-setup" --install  -f $script_dir/helm/2-edge-persistence-setup/values.yaml -f $script_dir/secrets/values.yaml
log_success "DONE --> Deploying Routes, Middlewares, Certificates, Databases"
echo ""

exit 0

log_exec helm upgrade monitoring "$script_dir/helm/3-monitoring" --install -f $script_dir/helm/3-monitoring/values.yaml -f $script_dir/secrets/values.yaml
log_exec helm upgrade media "$script_dir/helm/4-media" --install -f $script_dir/helm/4-media/values.yaml -f $script_dir/secrets/values.yaml

log_success "-------------------------DONE-HELM-UPGRADE-------------------------"
