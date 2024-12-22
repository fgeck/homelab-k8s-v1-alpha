#!/bin/bash

# Color codes
COLOR_RESET="\033[0m"
COLOR_GREY="\033[1;30m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"

# Log functions
log_debug() {
  echo -e "${COLOR_GREY}[DEBUG] $*${COLOR_RESET}"
}

log_info() {
  echo "[INFO] $*"
}

log_error() {
  echo -e "${COLOR_RED}[ERROR] $*${COLOR_RESET}"
}

log_success() {
  echo -e "${COLOR_GREEN}[SUCCESS] $*${COLOR_RESET}"
}

file_exists() {
    local file_path="$1"
    if [ -e "$file_path" ]; then
        echo "true"
    else
        echo "false"
    fi
}

bw_logout() {
    bw logout
}

build_helm_dependencies() {
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
    log_info "Building dependencies in: $dir"
    helm dependency build "$dir" --skip-refresh
  done
}