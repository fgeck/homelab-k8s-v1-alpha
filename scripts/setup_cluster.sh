#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"

helm repo add kube-vip https://kube-vip.github.io/helm-charts
helm repo add traefik https://traefik.github.io/charts
# certmanager
helm repo add jetstack https://charts.jetstack.io
helm repo add crowdsec https://crowdsecurity.github.io/helm-charts

helm repo update

function build_dependencies() {
  start_dir="$1"

  # Find all directories containing a Chart.yaml file
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS: use the `-exec` method
    chart_dirs=($(find "$start_dir" -name "Chart.yaml" -type f -exec dirname {} \;))
  else
    # Linux: use the `-printf` method
    chart_dirs=($(find "$start_dir" -name "Chart.yaml" -type f -printf '%h\n'))
  fi

  # Sort directories based on depth (deepest first)
  IFS=$'\n' sorted_chart_dirs=($(sort -r <<<"${chart_dirs[*]}"))
  unset IFS

  # Build dependencies for each sorted directory
  for dir in "${sorted_chart_dirs[@]}"; do
    echo "Building dependencies in: $dir"
    helm dependency build "$dir" --skip-refresh
  done
}

chart_dir="$script_dir/helm"
build_dependencies $chart_dir

helm upgrade bootstrap "$script_dir/helm/bootstrap" --install -f $script_dir/helm/bootstrap/values.yaml -f $script_dir/secrets/values.yaml --namespace kube-system

helm upgrade edge "$script_dir/helm/edge" --install --create-namespace -f $script_dir/helm/edge/values.yaml -f $script_dir/secrets/values.yaml --namespace edge
helm upgrade edge-custom "$script_dir/helm/edge-custom" --install -f $script_dir/secrets/values.yaml --namespace edge

# kubectl apply -f "$script_dir/helm/apps/nginx.yaml"
# kubectl apply -f "$script_dir/helm/apps/whoami-local.yaml"
# kubectl apply -f "$script_dir/helm/apps/whoami-external.yaml"
