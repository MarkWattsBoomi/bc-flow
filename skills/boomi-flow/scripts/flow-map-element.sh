#!/usr/bin/env bash
# Create, update, get, or delete a flow-scoped map element.
# Map elements use a different endpoint than other elements — they are scoped to a flow
# and require the current editingToken in the URL path.
#
# Usage:
#   bash scripts/flow-map-element.sh --flow-id <id> --file <json-file>          # create/update
#   bash scripts/flow-map-element.sh --flow-id <id> --get --id <element-id>     # get
#   bash scripts/flow-map-element.sh --flow-id <id> --delete --id <element-id>  # delete
#
# The JSON file for create/update should contain the map element body:
#   - "elementType": lowercase type, e.g. "input", "message", "start", "step", "operator"
#   - "developerName", "x", "y" required
#   - "id": include when updating an existing element
#   - "outcomes": set after all referenced elements have been created
#
# Two-pass pattern (required):
#   Pass 1 — POST each element without outcomes, capture returned IDs
#   Pass 2 — POST each element again with "id" and "outcomes" filled in

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
json_file=""
element_id=""
action="create"

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --file)    json_file="$2"; shift 2 ;;
    --id)      element_id="$2"; shift 2 ;;
    --get)     action="get"; shift ;;
    --delete)  action="delete"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$flow_id" ]] && { echo "ERROR: --flow-id is required" >&2; exit 1; }

# Fetch fresh editingToken
flow_json=$(curl -s \
  -H "x-boomi-flow-api-key: $FLOW_API_KEY" \
  -H "manywhotenant: $FLOW_TENANT_ID" \
  "$(build_flow_url "draw/1/flow/${flow_id}")")
editing_token=$(echo "$flow_json" | jq -r '.editingToken // empty')
[[ -z "$editing_token" ]] && { echo "ERROR: Could not retrieve editingToken for flow ${flow_id}" >&2; exit 1; }

base_url="$(build_flow_url "draw/1/flow/${flow_id}/${editing_token}/element/map")"

case "$action" in
  create)
    [[ -z "$json_file" ]] && { echo "ERROR: --file is required for create/update" >&2; exit 1; }
    [[ ! -f "$json_file" ]] && { echo "ERROR: File not found: $json_file" >&2; exit 1; }

    flow_api POST "$base_url" \
      -H "Accept: application/json" \
      -H "Content-Type: application/json" \
      -d "@$json_file"

    if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
      echo "$RESPONSE_BODY" | jq '.'
      new_id=$(echo "$RESPONSE_BODY" | jq -r '.id // empty')
      echo ""
      echo "Map Element ID: ${new_id}"
      log_activity "map-element-create" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\",\"id\":\"${new_id}\"}"
    else
      echo "ERROR: Failed to create/update map element (HTTP ${RESPONSE_CODE})" >&2
      echo "$RESPONSE_BODY" >&2
      exit 1
    fi
    ;;

  get)
    [[ -z "$element_id" ]] && { echo "ERROR: --id is required for --get" >&2; exit 1; }
    flow_api GET "${base_url}/${element_id}" -H "Accept: application/json"
    if [[ "$RESPONSE_CODE" == "200" ]]; then
      echo "$RESPONSE_BODY" | jq '.'
    else
      echo "ERROR: Failed to get map element (HTTP ${RESPONSE_CODE})" >&2
      echo "$RESPONSE_BODY" >&2
      exit 1
    fi
    ;;

  delete)
    [[ -z "$element_id" ]] && { echo "ERROR: --id is required for --delete" >&2; exit 1; }
    flow_api DELETE "${base_url}/${element_id}"
    if [[ "$RESPONSE_CODE" == "204" || "$RESPONSE_CODE" == "200" ]]; then
      echo "Map element ${element_id} deleted."
      log_activity "map-element-delete" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\",\"id\":\"${element_id}\"}"
    else
      echo "ERROR: Failed to delete map element (HTTP ${RESPONSE_CODE})" >&2
      echo "$RESPONSE_BODY" >&2
      exit 1
    fi
    ;;
esac
