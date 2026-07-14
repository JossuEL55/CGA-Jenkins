#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:-${TARGET_URL:-}}"
if [[ -z "$BASE_URL" ]]; then
  echo "Usage: $0 <base-url> (or set TARGET_URL)" >&2
  exit 2
fi

BASE_URL="${BASE_URL%/}"

check_status() {
  local path="$1"
  local expected="$2"
  local status
  status="$(curl --silent --show-error --location --output /tmp/cga-smoke-body --write-out '%{http_code}' "${BASE_URL}${path}")"
  if [[ "$status" != "$expected" ]]; then
    echo "FAIL: ${BASE_URL}${path} returned HTTP ${status}; expected ${expected}." >&2
    exit 1
  fi
  echo "OK: ${BASE_URL}${path} returned HTTP ${status}."
}

check_status "/health" "200"
check_status "/" "200"

if ! grep --fixed-strings --quiet "CGA Metrology System" /tmp/cga-smoke-body; then
  echo "FAIL: the home page does not contain 'CGA Metrology System'." >&2
  exit 1
fi

echo "OK: the home page contains 'CGA Metrology System'."
echo "Smoke test completed successfully."
