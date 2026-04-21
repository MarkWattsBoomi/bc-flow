#!/usr/bin/env bash
# Get tenant info and optionally test connection
# Usage: bash scripts/flow-tenant.sh [--test-connection] [--update <json-file>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

mode="get"
update_file=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --test-connection) mode="test"; shift ;;
    --update) update_file="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ "$mode" == "test" ]]; then
  test_connection
  exit 0
fi

if [[ -n "$update_file" ]]; then
  [[ ! -f "$update_file" ]] && { echo "ERROR: File not found: $update_file" >&2; exit 1; }
  url="$(build_flow_url "admin/1/tenant")"
  flow_api POST "$url" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "@$update_file"
  if [[ "$RESPONSE_CODE" == "200" ]]; then
    echo "Tenant updated successfully"
    echo "$RESPONSE_BODY" | jq '.'
  else
    echo "ERROR: Failed to update tenant (HTTP ${RESPONSE_CODE})" >&2
    echo "$RESPONSE_BODY" >&2
    exit 1
  fi
  exit 0
fi

# Default: get tenant info
url="$(build_flow_url "admin/1/tenant")"
flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
else
  echo "ERROR: Failed to get tenant (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
