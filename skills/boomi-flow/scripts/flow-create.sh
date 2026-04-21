#!/usr/bin/env bash
# Create or update a flow
# Usage: bash scripts/flow-create.sh --name "My Flow" [--description "..."]
#        bash scripts/flow-create.sh --file <json-file>   (full flow JSON body)
#        bash scripts/flow-create.sh --id <id> --file <json-file>  (update existing)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
flow_name=""
description=""
json_file=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) flow_id="$2"; shift 2 ;;
    --name) flow_name="$2"; shift 2 ;;
    --description) description="$2"; shift 2 ;;
    --file) json_file="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

url="$(build_flow_url "draw/1/flow")"

if [[ -n "$json_file" ]]; then
  [[ ! -f "$json_file" ]] && { echo "ERROR: File not found: $json_file" >&2; exit 1; }
  body=$(cat "$json_file")
else
  if [[ -z "$flow_name" ]]; then
    echo "ERROR: --name or --file is required" >&2
    exit 1
  fi
  body=$(jq -n \
    --arg name "$flow_name" \
    --arg desc "$description" \
    --arg id "$flow_id" \
    '{
      id: (if $id == "" then null else $id end),
      name: $name,
      description: (if $desc == "" then null else $desc end),
      allowJumping: false,
      enableHistoricalNavigation: false
    }')
fi

flow_api POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$body"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
  new_id=$(echo "$RESPONSE_BODY" | jq -r '.id // empty')
  echo ""
  echo "Flow ID: ${new_id}"
  log_activity "flow-create" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${new_id}\"}"
else
  echo "ERROR: Failed to create/update flow (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
