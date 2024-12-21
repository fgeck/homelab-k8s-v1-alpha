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

# --------------------------------START-DEPLOYMENT----------------------------------------

helm repo add kube-vip https://kube-vip.github.io/helm-charts
helm repo add longhorn https://charts.longhorn.io
helm repo add traefik https://traefik.github.io/charts
# certmanager
helm repo add jetstack https://charts.jetstack.io
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts

helm repo update

chart_dir="$script_dir/helm"
build_dependencies $chart_dir

helm upgrade bootstrap "$script_dir/helm/bootstrap" --install -f $script_dir/helm/bootstrap/values.yaml -f $script_dir/secrets/values.yaml --namespace kube-system

helm upgrade edge "$script_dir/helm/edge" --install --create-namespace -f $script_dir/helm/edge/values.yaml -f $script_dir/secrets/values.yaml --namespace edge
helm upgrade edge-custom "$script_dir/helm/edge-custom" --install -f $script_dir/secrets/values.yaml --namespace edge

# kubectl apply -f "$script_dir/helm/apps/nginx.yaml"
# kubectl apply -f "$script_dir/helm/apps/whoami-local.yaml"
# kubectl apply -f "$script_dir/helm/apps/whoami-external.yaml"
