#!/usr/bin/env bash
# Manage API keys for the current user
# Usage: bash scripts/flow-apikey.sh --list
#        bash scripts/flow-apikey.sh --create --name <key-name>
#        bash scripts/flow-apikey.sh --delete --name <key-name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

mode=""
key_name=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --list) mode="list"; shift ;;
    --create) mode="create"; shift ;;
    --delete) mode="delete"; shift ;;
    --name) key_name="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$mode" ]] && { echo "Usage: flow-apikey.sh --list | --create --name <name> | --delete --name <name>" >&2; exit 1; }

case "$mode" in
  list)
    url="$(build_flow_url "admin/1/users/me/keys")"
    flow_api GET "$url" -H "Accept: application/json"
    [[ "$RESPONSE_CODE" == "200" ]] && echo "$RESPONSE_BODY" | jq '.' || { echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1; }
    ;;
  create)
    [[ -z "$key_name" ]] && { echo "ERROR: --name required" >&2; exit 1; }
    url="$(build_flow_url "admin/1/users/me/keys")"
    body=$(jq -n --arg name "$key_name" '{"name":$name}')
    flow_api POST "$url" -H "Accept: application/json" -H "Content-Type: application/json" -d "$body"
    if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
      echo "API key created:"
      echo "$RESPONSE_BODY" | jq '.'
      echo ""
      echo "IMPORTANT: Copy the key value now — it will not be shown again."
    else
      echo "ERROR (HTTP ${RESPONSE_CODE}): $RESPONSE_BODY" >&2; exit 1
    fi
    ;;
  delete)
    [[ -z "$key_name" ]] && { echo "ERROR: --name required" >&2; exit 1; }
    url="$(build_flow_url "admin/1/users/me/keys/${key_name}")"
    flow_api DELETE "$url" -H "Accept: application/json"
    [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]] && echo "API key '${key_name}' deleted" || { echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1; }
    ;;
esac
