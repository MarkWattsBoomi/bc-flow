#!/usr/bin/env bash
# Export a flow package to a local file
# Usage: bash scripts/flow-package-export.sh --flow-id <id> [--output <file>]
#        bash scripts/flow-package-export.sh --flow-id <id> --env-id <env-id> [--output <file>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

flow_id=""
env_id=""
output_file=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --flow-id) flow_id="$2"; shift 2 ;;
    --env-id) env_id="$2"; shift 2 ;;
    --output) output_file="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$flow_id" ]] && { echo "Usage: flow-package-export.sh --flow-id <id> [--env-id <id>] [--output <file>]" >&2; exit 1; }

if [[ -n "$env_id" ]]; then
  url="$(build_flow_url "package/1/flow/${flow_id}/environment/${env_id}")"
else
  url="$(build_flow_url "package/1/flow/${flow_id}")"
fi

[[ -z "$output_file" ]] && output_file="flow-package-${flow_id}.zip"

echo "Exporting flow package to ${output_file}..."

local ssl_flag=""
[[ "${FLOW_VERIFY_SSL:-true}" == "false" ]] && ssl_flag="-k"

http_code=$(flow_curl -X GET "$url" \
  -H "Accept: application/zip" \
  -o "$output_file" \
  -w "%{http_code}")

if [[ "$http_code" == "200" ]]; then
  echo "Package exported: ${output_file}"
  echo "Size: $(du -sh "$output_file" | cut -f1)"
  log_activity "package-export" "success" "$http_code" "{\"flow_id\":\"${flow_id}\",\"output\":\"${output_file}\"}"
else
  echo "ERROR: Export failed (HTTP ${http_code})" >&2
  cat "$output_file" >&2
  rm -f "$output_file"
  exit 1
fi
