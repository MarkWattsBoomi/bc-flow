#!/usr/bin/env bash
# List snapshots for a flow
# Usage: bash scripts/flow-snapshot-list.sh --flow-id <id> [--page N]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
page=1
page_size=25

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --page) page="$2"; shift 2 ;;
    --page-size) page_size="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$flow_id" ]] && { echo "Usage: flow-snapshot-list.sh --flow-id <id>" >&2; exit 1; }

url="$(build_flow_url "draw/2/flow/snapshot")?flow=${flow_id}&page=${page}&pageSize=${page_size}"
flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" != "200" ]]; then
  echo "ERROR: Failed to list snapshots (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi

echo "$RESPONSE_BODY" | jq -r '
  if type == "array" then .[]
  else .
  end
  | "\(.id // "-")\t\(.name // "-")\t\(.dateCommitted // "-")"
' | column -t -s $'\t'
