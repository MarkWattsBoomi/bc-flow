#!/usr/bin/env bash
# Check which .env variables are set without revealing values
# Usage: bash scripts/flow-env-check.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/flow-common.sh"

load_env

echo "=== Boomi Flow .env Variable Status ==="
grep -v '^\s*#' .env | grep -v '^\s*$' | while IFS='=' read -r name _rest; do
  name=$(echo "$name" | xargs)
  if [[ -n "${!name:-}" ]]; then
    echo "  $name=SET"
  else
    echo "  $name=UNSET"
  fi
done

echo ""
echo "Run 'bash <skill-path>/scripts/flow-tenant.sh' to verify platform connectivity."
