#!/usr/bin/env bash
# Shared utilities for Boomi Flow CLI tools
# Sourced by all tool scripts — not executed directly

set -euo pipefail

# --- Environment ---

load_env() {
  local env_file=".env"
  if [[ -f "$env_file" ]]; then
    set -a
    source "$env_file"
    set +a
  else
    echo "ERROR: .env file not found in $(pwd)" >&2
    exit 1
  fi
}

require_env() {
  local missing=()
  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      missing+=("$var")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing required environment variables: ${missing[*]}" >&2
    echo "Check your .env file." >&2
    exit 1
  fi
}

require_tools() {
  local missing=()
  for tool in "$@"; do
    if ! command -v "$tool" &>/dev/null; then
      missing+=("$tool")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    echo "ERROR: Missing required tools: ${missing[*]}" >&2
    exit 1
  fi
}

# --- Constants ---

FLOW_USER_AGENT="Boomi Flow Companion"

# --- API helpers ---

# Low-level curl with Flow auth headers
flow_curl() {
  local ssl_flag=""
  [[ "${FLOW_VERIFY_SSL:-true}" == "false" ]] && ssl_flag="-k"

  local base_url="${FLOW_BASE_URL:-https://flow.boomi.com}"

  curl -s $ssl_flag \
    --max-time "${FLOW_TIMEOUT:-60}" \
    -A "$FLOW_USER_AGENT" \
    -H "x-boomi-flow-api-key: ${FLOW_API_KEY}" \
    -H "manywhotenant: ${FLOW_TENANT_ID}" \
    "$@"
}

# High-level API call: sets global RESPONSE_BODY and RESPONSE_CODE.
# Usage: flow_api METHOD URL [extra curl args...]
RESPONSE_BODY=""
RESPONSE_CODE=""
flow_api() {
  local method="$1"; shift
  local url="$1"; shift
  local tmpfile
  tmpfile=$(mktemp)
  RESPONSE_CODE=$(flow_curl -X "$method" -o "$tmpfile" -w "%{http_code}" "$@" "$url")
  RESPONSE_BODY=$(cat "$tmpfile")
  rm -f "$tmpfile"
}

# Build a full Flow API URL from a path fragment
# Usage: build_flow_url "draw/1/flow"
build_flow_url() {
  local path="$1"
  local base="${FLOW_BASE_URL:-https://flow.boomi.com}"
  echo "${base}/api/${path}"
}

# --- Activity logging ---

_activity_log_dir() {
  echo "$(pwd)/.activity-log"
}

_plugin_version() {
  local plugin_json
  plugin_json="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd ../../../ && pwd)/.claude-plugin/plugin.json"
  jq -r '.version // "unknown"' "$plugin_json" 2>/dev/null || echo "unknown"
}

log_activity() {
  local operation="$1"
  local result="$2"
  local http_code="${3:-}"
  local details="${4:-\{\}}"

  {
    local log_dir
    log_dir="$(_activity_log_dir)"
    mkdir -p "$log_dir" 2>/dev/null || return 0

    local log_file="${log_dir}/activity.jsonl"
    local timestamp
    timestamp="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    local script_name
    script_name="$(basename "${BASH_SOURCE[1]:-unknown}" .sh)"

    jq -cn \
      --arg ts "$timestamp" \
      --arg ver "$(_plugin_version)" \
      --arg ws "$(basename "$(pwd)")" \
      --arg op "$operation" \
      --arg script "$script_name" \
      --arg user "${USER:-}" \
      --arg tenant "${FLOW_TENANT_ID:-}" \
      --arg result "$result" \
      --arg http "$http_code" \
      --argjson details "$details" \
      '{
        timestamp: $ts,
        plugin_version: $ver,
        workspace: $ws,
        operation: $op,
        script: $script,
        user: $user,
        tenant_id: (if $tenant == "" then null else $tenant end),
        result: $result,
        http_code: (if $http == "" then null else ($http | tonumber? // $http) end),
        details: $details
      }' >> "$log_file"
  } 2>/dev/null || true
}

# --- Connection test ---

test_connection() {
  echo "Testing connection to Boomi Flow platform..."
  local url
  url="$(build_flow_url "admin/1/tenant")"

  flow_api GET "$url" -H "Accept: application/json"

  if [[ "$RESPONSE_CODE" == "200" ]]; then
    local tenant_name
    tenant_name=$(echo "$RESPONSE_BODY" | jq -r '.developerName // .name // "unknown"')
    echo "Connection successful"
    echo "Tenant: ${tenant_name}"
    echo "Tenant ID: ${FLOW_TENANT_ID}"
  else
    echo "ERROR: Connection failed (HTTP ${RESPONSE_CODE})" >&2
    echo "$RESPONSE_BODY" >&2
    exit 1
  fi
}

# --- Pagination helper ---

# Print a paginated result set, handling page/pageSize automatically
# Usage: paginate_all METHOD url_template [--max N]
# Calls the URL with page=1,2,... until no more results
paginate_all() {
  local method="$1"
  local url_base="$2"
  local max_items=1000

  local page=1
  local page_size=50
  local count=0

  while true; do
    local sep="?"
    [[ "$url_base" == *"?"* ]] && sep="&"
    local url="${url_base}${sep}page=${page}&pageSize=${page_size}"

    flow_api "$method" "$url" -H "Accept: application/json"

    if [[ "$RESPONSE_CODE" != "200" ]]; then
      echo "ERROR: Request failed (HTTP ${RESPONSE_CODE})" >&2
      echo "$RESPONSE_BODY" >&2
      exit 1
    fi

    local batch_count
    batch_count=$(echo "$RESPONSE_BODY" | jq -r 'if type == "array" then length else 0 end')

    echo "$RESPONSE_BODY"

    (( count += batch_count ))
    [[ "$batch_count" -lt "$page_size" ]] && break
    [[ "$count" -ge "$max_items" ]] && break
    (( page++ ))
  done
}

# Portable in-place sed (macOS vs GNU)
sedi() {
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i "$@"
  else
    sed -i '' "$@"
  fi
}
