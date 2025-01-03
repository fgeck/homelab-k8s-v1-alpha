#!/bin/bash

set -e

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi

source ./scripts/helper_funcs.sh
assert_tools_installed kubectl


log_info "Restarting edge layer: kube-vip, kube-vip-cloudprovider, traefik"
log_exec kubectl -n kube-system rollout restart daemonset kube-vip 
log_exec kubectl -n kube-system rollout restart deployment kube-vip-cloud-provider
log_exec kubectl -n edge rollout restart daemonset traefik
