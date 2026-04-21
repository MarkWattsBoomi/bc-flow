#!/usr/bin/env bash
# Get details of a specific flow state
# Usage: bash scripts/flow-state-get.sh --id <state-id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

state_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) state_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$state_id" ]] && { echo "Usage: flow-state-get.sh --id <state-id>" >&2; exit 1; }

url="$(build_flow_url "admin/1/states/${state_id}")"
flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
else
  echo "ERROR: Failed to get state (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
