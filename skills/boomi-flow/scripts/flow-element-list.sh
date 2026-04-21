#!/usr/bin/env bash
# List elements of a given type
# Usage: bash scripts/flow-element-list.sh --type <element-type> [--filter "name"] [--page N]
#
# Element types: service, page, type, value, map, navigation, macro, theme, tag, group,
#                identityprovider, customPageComponent

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

element_type=""
filter=""
page=1
page_size=50

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) element_type="$2"; shift 2 ;;
    --filter) filter="$2"; shift 2 ;;
    --page) page="$2"; shift 2 ;;
    --page-size) page_size="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$element_type" ]]; then
  echo "Usage: flow-element-list.sh --type <type>" >&2
  echo "Types: service, page, type, value, map, navigation, macro, theme, tag, group, identityprovider, customPageComponent" >&2
  exit 1
fi

url="$(build_flow_url "draw/1/element/${element_type}")?page=${page}&pageSize=${page_size}"
[[ -n "$filter" ]] && url="${url}&filter=${filter}"

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" != "200" ]]; then
  echo "ERROR: Failed to list ${element_type} elements (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi

echo "$RESPONSE_BODY" | jq -r '
  if type == "array" then .[]
  else .
  end
  | "\(.id // "-")\t\(.developerName // .name // "-")"
' | column -t -s $'\t'

log_activity "element-list" "success" "$RESPONSE_CODE" "{\"type\":\"${element_type}\"}"
