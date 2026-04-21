#!/usr/bin/env bash
# Search audit logs
# Usage: bash scripts/flow-audit.sh [--type <event-type>] [--from <ISO-date>] [--to <ISO-date>] [--limit N]
#        bash scripts/flow-audit.sh --csv [--output <file>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

event_type=""
from_date=""
to_date=""
limit=50
csv_mode=false
output_file=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) event_type="$2"; shift 2 ;;
    --from) from_date="$2"; shift 2 ;;
    --to) to_date="$2"; shift 2 ;;
    --limit) limit="$2"; shift 2 ;;
    --csv) csv_mode=true; shift ;;
    --output) output_file="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ "$csv_mode" == "true" ]]; then
  url="$(build_flow_url "audit/1/csv")"
  [[ -n "$from_date" ]] && url="${url}?from=${from_date}"
  [[ -z "$output_file" ]] && output_file="audit-$(date +%Y%m%d).csv"

  http_code=$(flow_curl -X GET "$url" \
    -H "Accept: text/csv" \
    -o "$output_file" \
    -w "%{http_code}")

  if [[ "$http_code" == "200" ]]; then
    echo "Audit log exported: ${output_file}"
  else
    echo "ERROR: CSV export failed (HTTP ${http_code})" >&2; exit 1
  fi
  exit 0
fi

url="$(build_flow_url "audit/1/search")?pageSize=${limit}"
[[ -n "$event_type" ]] && url="${url}&type=${event_type}"
[[ -n "$from_date" ]] && url="${url}&from=${from_date}"
[[ -n "$to_date" ]] && url="${url}&to=${to_date}"

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" ]]; then
  echo "$RESPONSE_BODY" | jq -r '
    if type == "array" then .[]
    else if .results then .results[] else . end
    end
    | "\(.occurredAt // "-")\t\(.type // "-")\t\(.user // "-")\t\(.description // "-")"
  ' | column -t -s $'\t'
else
  echo "ERROR: Audit search failed (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
