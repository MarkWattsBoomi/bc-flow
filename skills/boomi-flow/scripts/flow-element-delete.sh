#!/usr/bin/env bash
# Delete an element by type and ID
# Usage: bash scripts/flow-element-delete.sh --type <element-type> --id <element-id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

element_type=""
element_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) element_type="$2"; shift 2 ;;
    --id) element_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$element_type" || -z "$element_id" ]]; then
  echo "Usage: flow-element-delete.sh --type <type> --id <id>" >&2
  exit 1
fi

url="$(build_flow_url "draw/1/element/${element_type}/${element_id}")"
flow_api DELETE "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
  echo "Element ${element_type}/${element_id} deleted successfully"
  log_activity "element-delete" "success" "$RESPONSE_CODE" "{\"type\":\"${element_type}\",\"id\":\"${element_id}\"}"
else
  echo "ERROR: Failed to delete ${element_type} element ${element_id} (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
