#!/usr/bin/env bash
# Get a flow by ID or name
# Usage: bash scripts/flow-get.sh --id <flow-id>
#        bash scripts/flow-get.sh --name <flow-name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
flow_name=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) flow_id="$2"; shift 2 ;;
    --name) flow_name="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$flow_id" && -z "$flow_name" ]]; then
  echo "Usage: flow-get.sh --id <id> | --name <name>" >&2
  exit 1
fi

if [[ -n "$flow_name" ]]; then
  # Search design-time flows by developerName (paginate until found)
  page=1
  found=""
  while true; do
    url="$(build_flow_url "draw/1/flow")?page=${page}&pageSize=50"
    flow_api GET "$url" -H "Accept: application/json"
    if [[ "$RESPONSE_CODE" != "200" ]]; then
      echo "ERROR: Failed to list flows (HTTP ${RESPONSE_CODE})" >&2
      echo "$RESPONSE_BODY" >&2
      exit 1
    fi
    count=$(echo "$RESPONSE_BODY" | jq 'if type == "array" then length else 0 end')
    found=$(echo "$RESPONSE_BODY" | jq --arg name "$flow_name" '
      if type == "array" then .[] else . end
      | select(.developerName == $name)
    ')
    [[ -n "$found" ]] && break
    [[ "$count" -lt 50 ]] && break
    page=$((page + 1))
  done
  if [[ -z "$found" ]]; then
    echo "ERROR: Flow not found: ${flow_name}" >&2
    exit 1
  fi
  echo "$found" | jq '.'
  flow_id=$(echo "$found" | jq -r '.id.id // empty')
  log_activity "flow-get" "success" "200" "{\"flow_id\":\"${flow_id}\",\"flow_name\":\"${flow_name}\"}"
elif [[ -n "$flow_id" ]]; then
  url="$(build_flow_url "draw/1/flow/${flow_id}")"
  flow_api GET "$url" -H "Accept: application/json"
  if [[ "$RESPONSE_CODE" == "200" ]]; then
    echo "$RESPONSE_BODY" | jq '.'
    log_activity "flow-get" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\"}"
  else
    echo "ERROR: Failed to get flow (HTTP ${RESPONSE_CODE})" >&2
    echo "$RESPONSE_BODY" >&2
    exit 1
  fi
fi
