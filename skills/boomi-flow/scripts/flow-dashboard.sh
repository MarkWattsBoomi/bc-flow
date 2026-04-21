#!/usr/bin/env bash
# Get flow launch metrics and state error summaries
# Usage: bash scripts/flow-dashboard.sh --flow-id <id>
#        bash scripts/flow-dashboard.sh --tenant   (tenant-wide metrics)
#        bash scripts/flow-dashboard.sh --errors   (state error summary)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
mode="flow"

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --tenant) mode="tenant"; shift ;;
    --errors) mode="errors"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

case "$mode" in
  flow)
    [[ -z "$flow_id" ]] && { echo "Usage: flow-dashboard.sh --flow-id <id> | --tenant | --errors" >&2; exit 1; }
    url="$(build_flow_url "dashboard/1/flow/${flow_id}")"
    ;;
  tenant)
    url="$(build_flow_url "dashboard/1/flows")"
    ;;
  errors)
    url="$(build_flow_url "dashboard/1/stateErrors")"
    ;;
esac

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
else
  echo "ERROR: Dashboard request failed (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
