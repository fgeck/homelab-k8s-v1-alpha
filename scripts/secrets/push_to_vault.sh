#!/bin/bash

# Check if the script is executed at the root of the repository
if [[ ! -d ".git" ]]; then
  COLOR_RED="\033[1;31m"
  echo -e "${COLOR_RED}[ERROR] This script must be run from the root of the repository.${COLOR_RESET}" >&2
  exit 1
fi
# Source the helper script
source ./scripts/helper_funcs.sh
assert_tools_installed bw yq

# --------------------------------CONFIG----------------------------------------
VAULTWARDEN_SERVER=$(yq '.scriptConfigs.vaultwardenURL' secrets/values.yaml)
FOLDER_NAME="Homelab"
SECRET_NAME="KubernetesOnTalos"
# --------------------------------CONFIG----------------------------------------

log_info "Setting your server in config and logging in"
log_exec bw config server "$VAULTWARDEN_SERVER"
SESSION=$(bw login --raw)
trap bw_logout EXIT

SECRETS_BASE64=$(cat secrets/secrets.yaml | base64)
VALUES_BASE64=$(cat secrets/values.yaml | base64)
TALOSCONFIG_BASE64=$(cat secrets/talos/talosconfig | base64)
CONTROLPLANECONFIG_BASE64=$(cat secrets/talos/controlplane.yaml | base64)
WORKER1CONFIG_BASE64=$(cat secrets/talos/worker-1.yaml | base64)
WORKER2CONFIG_BASE64=$(cat secrets/talos/worker-2.yaml | base64)

# Check if the folder exists or create it
FOLDER_ID=$(bw list folders --session "$SESSION" | jq -r --arg name "$FOLDER_NAME" '.[] | select(.name==$name) | .id')

if [[ -z "$FOLDER_ID" ]]; then
    FOLDER_ID=$(bw get template folder | jq ".name=\"$FOLDER_NAME\"" | bw encode | bw create folder --session "$SESSION" | jq -r '.id')
    log_info "Created folder '$FOLDER_NAME' with ID '$FOLDER_ID'."
else
    log_info "Found folder '$FOLDER_NAME' with ID '$FOLDER_ID'."
fi

# Check if the item exists within the folder
ITEM_ID=$(bw list items --session "$SESSION" | jq -r --arg folderId "$FOLDER_ID" --arg name "$SECRET_NAME" '.[] | select(.folderId==$folderId and .name==$name) | .id')

if [[ -z "$ITEM_ID" ]]; then
    log_info "Item with name '$SECRET_NAME' not found in folder '$FOLDER_NAME'."
    log_info "Creating new item with name '$SECRET_NAME' in folder '$FOLDER_NAME'"

    bw get template item --session "$SESSION" | \
    jq ".name=\"$SECRET_NAME\" |
        .type = 2 |
        .folderId=\"$FOLDER_ID\" |
        .secureNote.type = 0 |
        .notes=\"Base64 encoded Kubernetes on TalOS secrets\" |
        .fields += [
            {\"name\": \"values.yaml\", \"value\": \"$VALUES_BASE64\", \"type\": 1},
            {\"name\": \"secrets.yaml\", \"value\": \"$SECRETS_BASE64\", \"type\": 1},
            {\"name\": \"talosconfig\", \"value\": \"$TALOSCONFIG_BASE64\", \"type\": 1},
            {\"name\": \"controlplane.yaml\", \"value\": \"$CONTROLPLANECONFIG_BASE64\", \"type\": 1},
            {\"name\": \"worker-1.yaml\", \"value\": \"$WORKER1CONFIG_BASE64\", \"type\": 1},
            {\"name\": \"worker-2.yaml\", \"value\": \"$WORKER2CONFIG_BASE64\", \"type\": 1}
        ]" | \
    bw encode | \
    bw create item --session "$SESSION" > /dev/null
else
    log_info "Item with name '$SECRET_NAME' and ID '$ITEM_ID' found in folder '$FOLDER_NAME'."
    log_info "Updating existing item with name '$SECRET_NAME' in folder '$FOLDER_NAME'"

    bw get item "$ITEM_ID" --session "$SESSION" | \
    jq ".fields = [
            {\"name\": \"values.yaml\", \"value\": \"$VALUES_BASE64\", \"type\": 1},
            {\"name\": \"secrets.yaml\", \"value\": \"$SECRETS_BASE64\", \"type\": 1},
            {\"name\": \"talosconfig\", \"value\": \"$TALOSCONFIG_BASE64\", \"type\": 1},
            {\"name\": \"controlplane.yaml\", \"value\": \"$CONTROLPLANECONFIG_BASE64\", \"type\": 1},
            {\"name\": \"worker-1.yaml\", \"value\": \"$WORKER1CONFIG_BASE64\", \"type\": 1},
            {\"name\": \"worker-2.yaml\", \"value\": \"$WORKER2CONFIG_BASE64\", \"type\": 1}
        ]" | \
    bw encode | \
    bw edit item "$ITEM_ID" --session "$SESSION" > /dev/null
fi

log_success "Successfully pushed all TalOS and Kubernetes secrets to $VAULTWARDEN_SERVER in folder '$FOLDER_NAME'"
