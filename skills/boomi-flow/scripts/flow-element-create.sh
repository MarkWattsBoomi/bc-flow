#!/usr/bin/env bash
# Create or update an element
# Usage: bash scripts/flow-element-create.sh --type <element-type> --file <json-file>
#
# Element types: service, page, type, value, map, navigation, macro, theme, tag, group,
#                identityprovider, customPageComponent
# The JSON file should contain the full element body per the Boomi Flow Draw API spec.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

element_type=""
json_file=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) element_type="$2"; shift 2 ;;
    --file) json_file="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$element_type" || -z "$json_file" ]]; then
  echo "Usage: flow-element-create.sh --type <type> --file <json-file>" >&2
  exit 1
fi

[[ ! -f "$json_file" ]] && { echo "ERROR: File not found: $json_file" >&2; exit 1; }

url="$(build_flow_url "draw/1/element/${element_type}")"
flow_api POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "@$json_file"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
  new_id=$(echo "$RESPONSE_BODY" | jq -r '.id // empty')
  echo ""
  echo "Element ID: ${new_id}"
  log_activity "element-create" "success" "$RESPONSE_CODE" "{\"type\":\"${element_type}\",\"id\":\"${new_id}\"}"
else
  echo "ERROR: Failed to create/update ${element_type} element (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
