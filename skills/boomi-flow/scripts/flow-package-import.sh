#!/usr/bin/env bash
# Import a flow package from a local file
# Usage: bash scripts/flow-package-import.sh --file <package-file>
#        bash scripts/flow-package-import.sh --token <sharing-token>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

package_file=""
share_token=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --file) package_file="$2"; shift 2 ;;
    --token) share_token="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$package_file" && -z "$share_token" ]]; then
  echo "Usage: flow-package-import.sh --file <package.zip> | --token <sharing-token>" >&2
  exit 1
fi

if [[ -n "$share_token" ]]; then
  url="$(build_flow_url "package/1/flow/import/token")"
  body=$(jq -n --arg token "$share_token" '{"token":$token}')
  flow_api POST "$url" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$body"
else
  [[ ! -f "$package_file" ]] && { echo "ERROR: File not found: $package_file" >&2; exit 1; }
  url="$(build_flow_url "package/1/flow/import")"
  flow_api POST "$url" \
    -H "Accept: application/json" \
    -F "file=@${package_file}"
fi

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
  echo "Package imported successfully"
  log_activity "package-import" "success" "$RESPONSE_CODE"
else
  echo "ERROR: Import failed (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
