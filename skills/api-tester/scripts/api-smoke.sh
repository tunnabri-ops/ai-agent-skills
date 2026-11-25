#!/usr/bin/env bash
# api-smoke.sh — smoke-test health endpoints of a REST API.
# Usage: ./api-smoke.sh <base-url>
# Example: ./api-smoke.sh https://api.example.com
# Prints PASS/FAIL per endpoint with the HTTP code.
# Exit code: 0 when every endpoint returns 2xx, 1 otherwise.
set -uo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <base-url>" >&2
  echo "Example: $0 https://api.example.com" >&2
  exit 2
fi

# Strip a trailing slash so paths join cleanly.
BASE_URL="${1%/}"
ENDPOINTS=("/health" "/" "/api/health")

failures=0
checked=0

for path in "${ENDPOINTS[@]}"; do
  url="${BASE_URL}${path}"
  # -s silent, -o discard body, -w print only the HTTP code.
  # --max-time keeps a hung server from hanging the script.
  code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 "$url" 2>/dev/null || echo "000")
  checked=$((checked + 1))
  if [[ "$code" =~ ^2[0-9][0-9]$ ]]; then
    echo "PASS  $path  HTTP $code  ($url)"
  else
    echo "FAIL  $path  HTTP $code  ($url)"
    failures=$((failures + 1))
  fi
done

echo "---"
echo "Checked $checked endpoint(s), $failures failure(s)."

if [ "$failures" -gt 0 ]; then
  exit 1
fi
exit 0
