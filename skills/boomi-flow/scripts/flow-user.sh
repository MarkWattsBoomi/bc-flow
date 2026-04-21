#!/usr/bin/env bash
# User management for the tenant
# Usage: bash scripts/flow-user.sh --list
#        bash scripts/flow-user.sh --me
#        bash scripts/flow-user.sh --add --email <email> [--role <role>]
#        bash scripts/flow-user.sh --remove --id <user-id>

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

mode=""
user_id=""
email=""
role=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --list) mode="list"; shift ;;
    --me) mode="me"; shift ;;
    --add) mode="add"; shift ;;
    --remove) mode="remove"; shift ;;
    --id) user_id="$2"; shift 2 ;;
    --email) email="$2"; shift 2 ;;
    --role) role="$2"; shift 2 ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

[[ -z "$mode" ]] && { echo "Usage: flow-user.sh --list | --me | --add --email <email> | --remove --id <id>" >&2; exit 1; }

case "$mode" in
  list)
    url="$(build_flow_url "admin/1/users")"
    flow_api GET "$url" -H "Accept: application/json"
    if [[ "$RESPONSE_CODE" == "200" ]]; then
      echo "$RESPONSE_BODY" | jq -r '
        if type == "array" then .[]
        else .
        end
        | "\(.id // "-")\t\(.email // "-")\t\(.firstName // "") \(.lastName // "")"
      ' | column -t -s $'\t'
    else
      echo "ERROR: Failed (HTTP ${RESPONSE_CODE})" >&2; exit 1
    fi
    ;;
  me)
    url="$(build_flow_url "admin/1/users/me")"
    flow_api GET "$url" -H "Accept: application/json"
    [[ "$RESPONSE_CODE" == "200" ]] && echo "$RESPONSE_BODY" | jq '.' || { echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1; }
    ;;
  add)
    [[ -z "$email" ]] && { echo "ERROR: --email required" >&2; exit 1; }
    url="$(build_flow_url "admin/1/users")"
    body=$(jq -n --arg email "$email" --arg role "$role" \
      '{"email":$email,"role":(if $role == "" then null else $role end)}')
    flow_api POST "$url" -H "Accept: application/json" -H "Content-Type: application/json" -d "$body"
    [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "201" ]] && echo "User added" || { echo "ERROR (HTTP ${RESPONSE_CODE}): $RESPONSE_BODY" >&2; exit 1; }
    ;;
  remove)
    [[ -z "$user_id" ]] && { echo "ERROR: --id required" >&2; exit 1; }
    url="$(build_flow_url "admin/1/users/${user_id}")"
    flow_api DELETE "$url" -H "Accept: application/json"
    [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]] && echo "User removed" || { echo "ERROR (HTTP ${RESPONSE_CODE})" >&2; exit 1; }
    ;;
esac
