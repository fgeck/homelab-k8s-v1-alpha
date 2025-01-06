#!/bin/bash

set -e

# Color codes
COLOR_RESET="\033[0m"
COLOR_GREY="\033[1;30m"
COLOR_GREEN="\033[1;32m"
COLOR_RED="\033[1;31m"

get_timestamp() {
  date +"%Y-%m-%d %H:%M:%S"
}

# Log functions
log_debug() {
  echo -e "${COLOR_GREY}[DEBUG] $(get_timestamp) $*${COLOR_RESET}"
}

log_info() {
  echo "[INFO] $(get_timestamp) $*"
}

log_error() {
  echo -e "${COLOR_RED}[ERROR] $(get_timestamp) $*${COLOR_RESET}"
}

log_success() {
  echo -e "${COLOR_GREEN}[SUCCESS] $(get_timestamp) $*${COLOR_RESET}"
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

# Function to execute Helm commands and log output in grey
log_exec() {
  COLOR_GREY="\033[1;30m"
  COLOR_RESET="\033[0m"
  command="$*"
  echo -e "${COLOR_GREY}[DEBUG] Running: $command${COLOR_RESET}"
  $command 2>&1 | while IFS= read -r line; do
    echo -e "${COLOR_GREY}$line${COLOR_RESET}"
  done
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
    log_debug "Building dependencies in: $dir"
    log_exec helm dependency build "$dir" --skip-refresh
  done
}

# Function to check if tools are installed
assert_tools_installed() {
    for TOOL in "$@"; do
        if ! command -v "$TOOL" &> /dev/null; then
            log_error "Required tool '$TOOL' is not installed. Aborting script." >&2
            exit 1
        fi
    done
}
