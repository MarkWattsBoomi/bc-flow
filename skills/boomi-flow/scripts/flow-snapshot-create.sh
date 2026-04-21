#!/usr/bin/env bash
# Create a snapshot of a flow (saves current design state as a named version)
# Usage: bash scripts/flow-snapshot-create.sh --flow-id <id> [--name "My Snapshot"] [--comment "..."]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
snapshot_name=""
comment=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --name) snapshot_name="$2"; shift 2 ;;
    --comment) comment="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$flow_id" ]] && { echo "Usage: flow-snapshot-create.sh --flow-id <id> [--name ...] [--comment ...]" >&2; exit 1; }

url="$(build_flow_url "draw/2/flow/snapshot")"

body=$(jq -n \
  --arg fid "$flow_id" \
  --arg name "$snapshot_name" \
  --arg comment "$comment" \
  '{
    flow: { id: $fid },
    name: (if $name == "" then null else $name end),
    comment: (if $comment == "" then null else $comment end)
  }')

flow_api POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$body"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
  snapshot_id=$(echo "$RESPONSE_BODY" | jq -r '.id // empty')
  echo ""
  echo "Snapshot ID: ${snapshot_id}"
  log_activity "snapshot-create" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\",\"snapshot_id\":\"${snapshot_id}\"}"
else
  echo "ERROR: Failed to create snapshot (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
