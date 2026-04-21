#!/usr/bin/env bash
# List releases
# Usage: bash scripts/flow-release-list.sh [--flow-id <id>] [--env-id <id>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
env_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --env-id) env_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

url="$(build_flow_url "release/1/releases")"

body="{}"
if [[ -n "$flow_id" || -n "$env_id" ]]; then
  body=$(jq -n \
    --arg fid "$flow_id" \
    --arg eid "$env_id" \
    '{
      filter: {
        flowId: (if $fid == "" then null else $fid end),
        environmentId: (if $eid == "" then null else $eid end)
      }
    }')
fi

flow_api POST "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$body"

if [[ "$RESPONSE_CODE" != "200" ]]; then
  echo "ERROR: Failed to list releases (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi

echo "$RESPONSE_BODY" | jq -r '
  if type == "array" then .[]
  else if .releases then .releases[] else . end
  end
  | "\(.id // "-")\t\(.environmentName // "-")\t\(.dateDeployed // "-")"
' | column -t -s $'\t'
