#!/usr/bin/env bash
# Initialize (run) a flow and return the state ID
# Usage: bash scripts/flow-run.sh --flow-id <id> [--version-id <id>]
#        bash scripts/flow-run.sh --flow-name <name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
flow_name=""
version_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --flow-name) flow_name="$2"; shift 2 ;;
    --version-id) version_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$flow_id" && -z "$flow_name" ]]; then
  echo "Usage: flow-run.sh --flow-id <id> | --flow-name <name> [--version-id <id>]" >&2
  exit 1
fi

url="$(build_flow_url "run/1/state")"

body=$(jq -n \
  --arg fid "$flow_id" \
  --arg fname "$flow_name" \
  --arg vid "$version_id" \
  '{
    flow: {
      id: (if $fid == "" then null else $fid end),
      developerName: (if $fname == "" then null else $fname end),
      versionId: (if $vid == "" then null else $vid end)
    }
  }')

flow_api POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$body"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
  state_id=$(echo "$RESPONSE_BODY" | jq -r '.stateId // .id // empty')
  echo "Flow started"
  echo "State ID: ${state_id}"
  echo ""
  echo "$RESPONSE_BODY" | jq '.'
  log_activity "flow-run" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\",\"state_id\":\"${state_id}\"}"
else
  echo "ERROR: Failed to run flow (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
