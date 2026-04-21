#!/usr/bin/env bash
# Manage flow translations and cultures
# Usage: bash scripts/flow-translate.sh --list-cultures
#        bash scripts/flow-translate.sh --get-flow --flow-id <id>
#        bash scripts/flow-translate.sh --export --flow-ids <id1,id2,...> [--output <file>]
#        bash scripts/flow-translate.sh --import --file <translations.json>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

mode=""
flow_id=""
flow_ids=""
json_file=""
output_file=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --list-cultures) mode="list-cultures"; shift ;;
    --get-flow) mode="get-flow"; shift ;;
    --export) mode="export"; shift ;;
    --import) mode="import"; shift ;;
    --flow-id) flow_id="$2"; shift 2 ;;
    --flow-ids) flow_ids="$2"; shift 2 ;;
    --file) json_file="$2"; shift 2 ;;
    --output) output_file="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$mode" ]] && { echo "Usage: flow-translate.sh --list-cultures | --get-flow --flow-id <id> | --export --flow-ids <ids> | --import --file <file>" >&2; exit 1; }

case "$mode" in
  list-cultures)
    url="$(build_flow_url "translate/1/culture")"
    flow_api GET "$url" -H "Accept: application/json"
    [[ "$RESPONSE_CODE" == "200" ]] && echo "$RESPONSE_BODY" | jq -r '.[] | "\(.id)\t\(.developerName // .name)"' | column -t -s $'\t' || { echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1; }
    ;;
  get-flow)
    [[ -z "$flow_id" ]] && { echo "ERROR: --flow-id required" >&2; exit 1; }
    url="$(build_flow_url "translate/1/flow/${flow_id}")"
    flow_api GET "$url" -H "Accept: application/json"
    [[ "$RESPONSE_CODE" == "200" ]] && echo "$RESPONSE_BODY" | jq '.' || { echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1; }
    ;;
  export)
    [[ -z "$flow_ids" ]] && { echo "ERROR: --flow-ids required" >&2; exit 1; }
    url="$(build_flow_url "translate/1/flows/export")"
    ids_json=$(echo "$flow_ids" | tr ',' '\n' | jq -R . | jq -s .)
    body=$(jq -n --argjson ids "$ids_json" '{"flowIds":$ids}')
    flow_api POST "$url" -H "Accept: application/json" -H "Content-Type: application/json" -d "$body"
    if [[ "$RESPONSE_CODE" == "200" ]]; then
      [[ -z "$output_file" ]] && output_file="translations-$(date +%Y%m%d).json"
      echo "$RESPONSE_BODY" > "$output_file"
      echo "Translations exported: ${output_file}"
    else
      echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1
    fi
    ;;
  import)
    [[ -z "$json_file" || ! -f "$json_file" ]] && { echo "ERROR: --file required and must exist" >&2; exit 1; }
    url="$(build_flow_url "translate/1/flows/import")"
    flow_api POST "$url" -H "Accept: application/json" -H "Content-Type: application/json" -d "@$json_file"
    [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]] && echo "Translations imported" || { echo "ERROR (HTTP ${RESPONSE_CODE}): $RESPONSE_BODY" >&2; exit 1; }
    ;;
esac
