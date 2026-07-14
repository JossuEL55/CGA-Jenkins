#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${1:-${TARGET_URL:-}}"
REPORT_DIR="${REPORT_DIR:-$(pwd)/zap-reports}"
if [[ -z "$TARGET_URL" ]]; then
  echo "Usage: $0 <target-url> (or set TARGET_URL)" >&2
  exit 2
fi

mkdir -p "$REPORT_DIR"
echo "Running OWASP ZAP Baseline against ${TARGET_URL}"
echo "Reports will be written to ${REPORT_DIR}"

docker run --rm \
  --volume "${REPORT_DIR}:/zap/wrk:rw" \
  ghcr.io/zaproxy/zaproxy:stable \
  zap-baseline.py -t "$TARGET_URL" -I -r zap-report.html -J zap-report.json

echo "ZAP Baseline completed. Review zap-report.html and zap-report.json."
