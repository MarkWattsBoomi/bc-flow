#!/usr/bin/env bash
# Delete a flow state or multiple states
# Usage: bash scripts/flow-state-delete.sh --id <state-id>
#        bash scripts/flow-state-delete.sh --flow-id <flow-id>  (deletes all states for a flow)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

state_id=""
flow_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) state_id="$2"; shift 2 ;;
    --flow-id) flow_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$state_id" && -z "$flow_id" ]]; then
  echo "Usage: flow-state-delete.sh --id <state-id> | --flow-id <flow-id>" >&2
  exit 1
fi

if [[ -n "$state_id" ]]; then
  url="$(build_flow_url "admin/1/states/${state_id}")"
  flow_api DELETE "$url" -H "Accept: application/json"
  if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
    echo "State ${state_id} deleted"
    log_activity "state-delete" "success" "$RESPONSE_CODE" "{\"state_id\":\"${state_id}\"}"
  else
    echo "ERROR: Failed to delete state (HTTP ${RESPONSE_CODE})" >&2; exit 1
  fi
elif [[ -n "$flow_id" ]]; then
  url="$(build_flow_url "admin/1/states")"
  body=$(jq -n --arg fid "$flow_id" '{"filter":{"flowId":$fid}}')
  flow_api DELETE "$url" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$body"
  if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
    echo "States deleted for flow ${flow_id}"
    log_activity "state-delete-bulk" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\"}"
  else
    echo "ERROR: Failed to delete states (HTTP ${RESPONSE_CODE})" >&2; exit 1
  fi
fi
