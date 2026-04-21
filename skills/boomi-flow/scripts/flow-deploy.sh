#!/usr/bin/env bash
# Deploy a release to an environment
# Usage: bash scripts/flow-deploy.sh --release-id <id> --env-id <id>
#        bash scripts/flow-deploy.sh --list-environments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env
require_env FLOW_API_KEY FLOW_TENANT_ID
require_tools curl jq

release_id=""
env_id=""
list_envs=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --release-id) release_id="$2"; shift 2 ;;
    --env-id) env_id="$2"; shift 2 ;;
    --list-environments) list_envs=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if [[ "$list_envs" == "true" ]]; then
  url="$(build_flow_url "environment/1/environment")"
  flow_api GET "$url" -H "Accept: application/json"
  if [[ "$RESPONSE_CODE" == "200" ]]; then
    echo "$RESPONSE_BODY" | jq -r '
      if type == "array" then .[]
      else .
      end
      | "\(.id // "-")\t\(.name // "-")\t\(.environmentType // "-")"
    ' | column -t -s $'\t'
  else
    echo "ERROR: Failed to list environments (HTTP ${RESPONSE_CODE})" >&2
    exit 1
  fi
  exit 0
fi

if [[ -z "$release_id" || -z "$env_id" ]]; then
  echo "Usage: flow-deploy.sh --release-id <id> --env-id <id>" >&2
  echo "       flow-deploy.sh --list-environments" >&2
  exit 1
fi

echo "Deploying release ${release_id} to environment ${env_id}..."

url="$(build_flow_url "release/1/release/${release_id}/deploy")"
body=$(jq -n --arg eid "$env_id" '{"environmentId":$eid}')

flow_api PUT "$url" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" \
  -d "$body"

if [[ "$RESPONSE_CODE" == "200" || "$RESPONSE_CODE" == "204" ]]; then
  echo "Deployed successfully"
  log_activity "deploy" "success" "$RESPONSE_CODE" "{\"release_id\":\"${release_id}\",\"env_id\":\"${env_id}\"}"
else
  echo "ERROR: Deploy failed (HTTP ${RESPONSE_CODE})" >&2
  echo "$RESPONSE_BODY" >&2
  exit 1
fi
