#!/bin/bash

set -e

# --------------------------------CONFIG----------------------------------------
VAULTWARDEN_SERVER=$(yq '.scriptConfigs.vaultwardenURL' secrets/values.yaml)
FOLDER_NAME="Homelab"
SECRET_NAME="KubernetesOnTalos"
# --------------------------------CONFIG----------------------------------------

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi

# Source the helper script
source ./scripts/helper_funcs.sh

log_info "Setting your server in config and logging in"
log_exec bw config server "$VAULTWARDEN_SERVER"
SESSION=$(bw login --raw)
trap bw_logout EXIT

# Check if the folder exists
FOLDER_ID=$(bw list folders --session "$SESSION" | jq -r --arg name "$FOLDER_NAME" '.[] | select(.name==$name) | .id')

if [[ -z "$FOLDER_ID" ]]; then
  log_error "Folder '$FOLDER_NAME' not found."
  exit 1
else
  log_info "Found folder '$FOLDER_NAME' with ID '$FOLDER_ID'."
fi

# Check if the secret exists in the folder
ITEM_ID=$(bw list items --session "$SESSION" | jq -r --arg folderId "$FOLDER_ID" --arg name "$SECRET_NAME" '.[] | select(.folderId==$folderId and .name==$name) | .id')

if [[ -z "$ITEM_ID" ]]; then
  log_error "Item '$SECRET_NAME' not found in folder '$FOLDER_NAME'."
  exit 1
fi

log_info "Getting secret '$SECRET_NAME' from folder '$FOLDER_NAME'"
JSON_RESPONSE=$(bw get item "$ITEM_ID" --session "$SESSION" --response)

log_info "Parsing fields"
VALUES_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "values.yaml") | .value')
SECRETS_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "secrets.yaml") | .value')
TALOSCONFIG_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "talosconfig") | .value')
CONTROLPLANECONFIG_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "controlplane.yaml") | .value')
WORKER1CONFIG_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "worker-1.yaml") | .value')
WORKER2CONFIG_BASE64=$(echo "$JSON_RESPONSE" | jq -r '.data.fields[] | select(.name == "worker-2.yaml") | .value')

log_info "Writing secrets to files"
echo "$VALUES_BASE64" | base64 -d > secrets/values.yaml
echo "$SECRETS_BASE64" | base64 -d > secrets/secrets.yaml
echo "$TALOSCONFIG_BASE64" | base64 -d > secrets/talos/talosconfig
echo "$CONTROLPLANECONFIG_BASE64" | base64 -d > secrets/talos/controlplane.yaml
echo "$WORKER1CONFIG_BASE64" | base64 -d > secrets/talos/worker-1.yaml
echo "$WORKER2CONFIG_BASE64" | base64 -d > secrets/talos/worker-2.yaml

log_success "Successfully wrote all secrets from '$SECRET_NAME' in folder '$FOLDER_NAME' to local files"
