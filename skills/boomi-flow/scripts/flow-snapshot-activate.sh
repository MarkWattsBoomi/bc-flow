#!/usr/bin/env bash
# Activate a snapshot for a flow (makes it the current active version)
# Usage: bash scripts/flow-snapshot-activate.sh --flow-id <id> --snapshot-id <id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
snapshot_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --snapshot-id) snapshot_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$flow_id" || -z "$snapshot_id" ]]; then
  echo "Usage: flow-snapshot-activate.sh --flow-id <id> --snapshot-id <id>" >&2
  exit 1
fi

url="$(build_flow_url "draw/2/flow/snapshot/${snapshot_id}/activate")"
body=$(jq -n --arg fid "$flow_id" '{"flow":{"id":$fid}}')

flow_api POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$body"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
  echo "Snapshot ${snapshot_id} activated for flow ${flow_id}"
  log_activity "snapshot-activate" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\",\"snapshot_id\":\"${snapshot_id}\"}"
else
  echo "ERROR: Failed to activate snapshot (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
