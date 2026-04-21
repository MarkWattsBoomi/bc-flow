#!/usr/bin/env bash
# Get a flow by ID or name
# Usage: bash scripts/flow-get.sh --id <flow-id>
#        bash scripts/flow-get.sh --name <flow-name>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
flow_name=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --id) flow_id="$2"; shift 2 ;;
    --name) flow_name="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$flow_id" && -z "$flow_name" ]]; then
  echo "Usage: flow-get.sh --id <id> | --name <name>" >&2
  exit 1
fi

if [[ -n "$flow_name" ]]; then
  encoded_name=$(python3 -c "import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))" "$flow_name" 2>/dev/null || printf '%s' "$flow_name" | sed 's/ /%20/g')
  url="$(build_flow_url "draw/1/flow/active/name/${encoded_name}")"
elif [[ -n "$flow_id" ]]; then
  url="$(build_flow_url "draw/1/flow/active/${flow_id}")"
fi

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
  log_activity "flow-get" "success" "$RESPONSE_CODE" "{\"flow_id\":\"${flow_id}\",\"flow_name\":\"${flow_name}\"}"
else
  echo "ERROR: Failed to get flow (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
