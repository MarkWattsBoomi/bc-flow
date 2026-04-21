#!/usr/bin/env bash
# Get or set environment variables for a deployment environment
# Usage: bash scripts/flow-environment-vars.sh --env-id <id>
#        bash scripts/flow-environment-vars.sh --env-id <id> --set --name <var-name> --value <value> [--is-secret]
#        bash scripts/flow-environment-vars.sh --env-id <id> --delete --name <var-name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

env_id=""
mode="get"
var_name=""
var_value=""
is_secret=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --env-id) env_id="$2"; shift 2 ;;
    --set) mode="set"; shift ;;
    --delete) mode="delete"; shift ;;
    --name) var_name="$2"; shift 2 ;;
    --value) var_value="$2"; shift 2 ;;
    --is-secret) is_secret=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$env_id" ]] && { echo "Usage: flow-environment-vars.sh --env-id <id> [--set --name N --value V | --delete --name N]" >&2; exit 1; }

if [[ "$mode" == "get" ]]; then
  url="$(build_flow_url "environment/1/environment/${env_id}/variables")"
  body='{"page":1,"pageSize":100}'
  flow_api POST "$url" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$body"
  if [[ "$RESPONSE_CODE" == "200" ]]; then
    echo "$RESPONSE_BODY" | jq '.'
  else
    echo "ERROR: Failed to get variables (HTTP ${RESPONSE_CODE})" >&2; exit 1
  fi

elif [[ "$mode" == "set" ]]; then
  [[ -z "$var_name" || -z "$var_value" ]] && { echo "ERROR: --name and --value required for --set" >&2; exit 1; }
  url="$(build_flow_url "environment/1/environment/${env_id}/variable")"
  body=$(jq -n \
    --arg name "$var_name" \
    --arg value "$var_value" \
    --argjson secret "$is_secret" \
    '{"name":$name,"value":$value,"isEncrypted":$secret}')
  flow_api POST "$url" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$body"
  if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
    echo "Variable '${var_name}' saved"
  else
    echo "ERROR: Failed to save variable (HTTP ${RESPONSE_CODE})" >&2; exit 1
  fi

elif [[ "$mode" == "delete" ]]; then
  [[ -z "$var_name" ]] && { echo "ERROR: --name required for --delete" >&2; exit 1; }
  url="$(build_flow_url "environment/1/environment/${env_id}/variable/${var_name}")"
  flow_api DELETE "$url" -H "Accept: application/json"
  if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
    echo "Variable '${var_name}' deleted"
  else
    echo "ERROR: Failed to delete variable (HTTP ${RESPONSE_CODE})" >&2; exit 1
  fi
fi
