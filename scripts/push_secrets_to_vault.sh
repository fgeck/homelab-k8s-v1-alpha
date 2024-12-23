#!/bin/bash

# --------------------------------CONFIG----------------------------------------
VAULTWARDEN_SERVER=
SECRET_NAME=KubernetesOnTalos # expect secrets.yaml and values.yaml here
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

SECRETS_BASE64=$(cat secrets/secrets.yaml | base64)
VALUES_BASE64=$(cat secrets/values.yaml | base64)

bw get item "$SECRET_NAME" --session "$SESSION" --response | jq '.data.id'

GET_RESPONSE=$(bw get item "$SECRET_NAME" --session "$SESSION" --response)
SUCCESS=$(echo $GET_RESPONSE | jq -r '.success')

if [[ "$SUCCESS" == "false" ]]; then
    ITEM_ID=$(echo "$GET_RESPONSE" | jq -r '.data.id')
    log_debug "Item with name '$SECRET_NAME' not found."
    log_info "Creating new item with name '$SECRET_NAME'"
    bw get template item --session $SESSION | jq ".name=\"$SECRET_NAME\" | .type = 2 | .secureNote.type = 0 | .notes=\"Base64 encoded Kubernetes values and TalOS secrets\" | .fields += [{\"name\": \"values.yaml\", \"value\": \"$VALUES_BASE64\", \"type\": 1}, {\"name\": \"secrets.yaml\", \"value\": \"$SECRETS_BASE64\", \"type\": 1}]" | bw encode | bw create item --session "$SESSION" > /dev/null
else
    ITEM_ID=$(echo "$GET_RESPONSE" | jq -r '.data.id')
    log_debug "Item with name '$SECRET_NAME' and ID '$ITEM_ID' found."
    log_info "Updating existing item with name '$SECRET_NAME'"
    bw get item "$ITEM_ID" --session "$SESSION" | jq ".fields = [{\"name\": \"values.yaml\", \"value\": \"$VALUES_BASE64\"}, {\"name\": \"secrets.yaml\", \"value\": \"$SECRETS_BASE64\"}]" | bw encode | bw edit item "$ITEM_ID" --session "$SESSION" > /dev/null
fi

log_success "Successfully pushed secrets/values.yaml and secrets/secrets.yaml to $VAULTWARDEN_SERVER"
