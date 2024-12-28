#!/bin/bash

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

helm repo add kube-vip https://kube-vip.github.io/helm-charts
helm repo add longhorn https://charts.longhorn.io
helm repo add traefik https://traefik.github.io/charts
# certmanager
helm repo add jetstack https://charts.jetstack.io
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add signoz https://charts.signoz.io
helm repo add keel https://charts.keel.sh 
helm repo add vaultwarden https://guerzon.github.io/vaultwarden
helm repo add uptime-kuma https://helm.irsigler.cloud

helm repo update
helm dependency update

chart_dir="$script_dir/helm"
build_helm_dependencies "$chart_dir"

log_success "-------------------------DONE-HELM-REPO-ADD/UPDATE-DEPDENCY-BUILD-------------------------"
echo ""
log_info "-------------------------START-HELM-UPGRADE-------------------------"

helm upgrade bootstrap "$script_dir/helm/1-bootstrap" --install --namespace kube-system -f $script_dir/helm/1-bootstrap/values.yaml -f $script_dir/secrets/values.yaml
helm upgrade edge "$script_dir/helm/2-edge" --install  --namespace edge --create-namespace -f $script_dir/helm/2-edge/values.yaml -f $script_dir/secrets/values.yaml
helm upgrade edge-custom "$script_dir/helm/3-edge-custom" --install --namespace edge -f $script_dir/secrets/values.yaml
helm upgrade storage "$script_dir/helm/4-storage" --install --namespace longhorn-system --create-namespace -f $script_dir/helm/4-storage/values.yaml -f $script_dir/secrets/values.yaml
helm upgrade monitoring "$script_dir/helm/5-monitoring" --install --namespace monitoring --create-namespace -f $script_dir/helm/5-monitoring/values.yaml -f $script_dir/secrets/values.yaml
helm upgrade media "$script_dir/helm/6-media" --install --namespace media --create-namespace -f $script_dir/helm/6-media/values.yaml -f $script_dir/secrets/values.yaml

# helm upgrade apps "$script_dir/helm/7-apps" --install -f $script_dir/helm/7-apps/values.yaml -f $script_dir/secrets/values.yaml
# kubectl apply -f "$script_dir/helm/apps/nginx.yaml"
# kubectl apply -f "$script_dir/helm/apps/whoami-local.yaml"
# kubectl apply -f "$script_dir/helm/apps/whoami-external.yaml"

log_success "-------------------------DONE-HELM-UPGRADE-------------------------"