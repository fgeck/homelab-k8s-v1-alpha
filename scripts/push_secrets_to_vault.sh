#!/bin/bash

set -e

# TODO: Implement the script to push secrets to Vaultwarden. Item creation and update are placeholders.

# --------------------------------CONFIG----------------------------------------
VAULTWARDEN_SERVER=
SECRET_NAME=KubernetesTEST # expect secrets.yaml and values.yaml here
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

ITEM_ID=$(bw list items --search "$SECRET_NAME" --session "$SESSION"| jq -r '.[0].id')
echo $ITEM_ID
if [[ "$ITEM_ID" == "null" ]]; then
    log_debug "Item with name '$SECRET_NAME' not found."
    log_info "Creating new item with name '$SECRET_NAME'"
    # Todo create item with BW
else
    log_debug "Item with name '$SECRET_NAME' found."
    log_info "Updating existing item with name '$SECRET_NAME'"
    # Todo update item with BW
fi

log_success "Successfully pushed secrets/values.yaml and secrets/secrets.yaml to $VAULTWARDEN_SERVER"
