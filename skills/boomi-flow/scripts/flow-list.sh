#!/usr/bin/env bash
# List flows in the tenant
# Usage: bash scripts/flow-list.sh [--filter "name"] [--page N] [--page-size N] [--active]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

filter=""
page=1
page_size=25
active_only=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --filter) filter="$2"; shift 2 ;;
    --page) page="$2"; shift 2 ;;
    --page-size) page_size="$2"; shift 2 ;;
    --active) active_only=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ "$active_only" == "true" ]]; then
  url="$(build_flow_url "draw/1/flow/active")"
else
  url="$(build_flow_url "draw/1/flow")?page=${page}&pageSize=${page_size}"
  [[ -n "$filter" ]] && url="${url}&filter=${filter}"
fi

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" != "200" ]]; then
  echo "ERROR: Failed to list flows (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi

echo "$RESPONSE_BODY" | jq -r '
  if type == "array" then .[]
  else .
  end
  | "\(.id.id // "-")\t\(.developerName // "-")"
' | column -t -s $'\t'

log_activity "flow-list" "success" "$RESPONSE_CODE"
