#!/bin/bash

set -e

# --------------------------------CONFIG----------------------------------------
VAULTWARDEN_SERVER=
SECRET_NAME=Kubernetes # expect secrets.yaml and values.yaml here
# --------------------------------CONFIG----------------------------------------

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi
# Source the helper script
source ./scripts/helper_funcs.sh

log_debug "Setting your server in config and logging in"
bw config server "$VAULTWARDEN_SERVER"
SESSION=$(bw login --raw)
trap bw_logout EXIT

log_info "Getting secret Kubernetes"
JSON_RESPONSE=$(bw get item "$SECRET_NAME" --session "$SESSION" --response)

log_info "Parsing fields"
VALUES_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "values.yaml") | .value')
SECRETS_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "secrets.yaml") | .value')

echo "$VALUES_BASE64" | base64 -d > secrets/values.yaml
echo "$SECRETS_BASE64" | base64 -d > secrets/secrets.yaml

log_success "Successfully wrote secrets/values.yaml and secrets/secrets.yaml"
