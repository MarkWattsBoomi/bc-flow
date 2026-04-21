#!/usr/bin/env bash
# List Boomi Integrate processes available to Flow as service elements
# Requires the tenant to have an Integration Account configured
# Usage: bash scripts/flow-integration-list.sh [--account-id <integration-account-id>]
#        bash scripts/flow-integration-list.sh --properties --account-id <id> [--process-id <id>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

account_id=""
process_id=""
mode="list"

while [[ $# -gt 0 ]]; do
  case $1 in
    --account-id) account_id="$2"; shift 2 ;;
    --process-id) process_id="$2"; shift 2 ;;
    --properties) mode="properties"; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# If no account-id provided, try to retrieve the integration account from tenant
if [[ -z "$account_id" ]]; then
  url="$(build_flow_url "admin/1/tenant/integrationaccount")"
  flow_api GET "$url" -H "Accept: application/json"
  if [[ "$RESPONSE_CODE" == "200" ]]; then
    account_id=$(echo "$RESPONSE_BODY" | jq -r '.accountId // empty')
    [[ -z "$account_id" ]] && { echo "ERROR: No integration account configured for this tenant" >&2; exit 1; }
    echo "Using integration account: ${account_id}"
  else
    echo "ERROR: Could not retrieve integration account (HTTP ${RESPONSE_CODE})" >&2
    exit 1
  fi
fi

if [[ "$mode" == "properties" ]]; then
  if [[ -n "$process_id" ]]; then
    url="$(build_flow_url "draw/1/integration/${account_id}/processproperties/${process_id}")"
  else
    url="$(build_flow_url "draw/1/integration/${account_id}/processproperties")"
  fi
else
  url="$(build_flow_url "draw/1/integration/process")"
fi

flow_api GET "$url" -H "Accept: application/json"

if [[ "$RESPONSE_CODE" == "200" ]]; then
  echo "$RESPONSE_BODY" | jq '.'
else
  echo "ERROR: Request failed (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
