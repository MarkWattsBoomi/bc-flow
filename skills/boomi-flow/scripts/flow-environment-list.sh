#!/usr/bin/env bash
# List deployment environments
# Usage: bash scripts/flow-environment-list.sh [--id <env-id>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

env_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) env_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -n "$env_id" ]]; then
  url="$(build_flow_url "environment/1/environment/${env_id}")"
else
  url="$(build_flow_url "environment/1/environment")"
fi

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" != "200" ]]; then
  echo "ERROR: Failed to list environments (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi

if [[ -n "$env_id" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
else
  echo "$RESPONSE_BODY" | jq -r '
    if type == "array" then .[]
    else .
    end
    | "\(.id // "-")\t\(.name // "-")\t\(.environmentType // "-")"
  ' | column -t -s $'\t'
fi
