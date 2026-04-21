#!/usr/bin/env bash
# Rollback a release deployment
# Usage: bash scripts/flow-rollback.sh --release-id <id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

release_id=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --release-id) release_id="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$release_id" ]] && { echo "Usage: flow-rollback.sh --release-id <id>" >&2; exit 1; }

echo "Rolling back release ${release_id}..."

url="$(build_flow_url "release/1/release/${release_id}/rollback")"
flow_api PUT "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
  echo "Rollback successful"
  log_activity "rollback" "success" "$RESPONSE_CODE" "{\"release_id\":\"${release_id}\"}"
else
  echo "ERROR: Rollback failed (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
