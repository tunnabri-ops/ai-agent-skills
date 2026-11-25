#!/usr/bin/env bash
# check-stream.sh — check one stream URL and print LIVE / DEAD / UNKNOWN.
# Usage: ./check-stream.sh "https://example.com/live.m3u8"
# Output: STATUS | HTTP <code> | <content-type> | final: <final URL>
# Exit codes: 0 = LIVE, 1 = DEAD, 2 = UNKNOWN, 3 = usage error.
#
# IMPORTANT: a DEAD or UNKNOWN result here is a sandbox result only.
# A stream that fails this check can still play on a real device
# (notably mono.ts.m3u8 links). Never delete a link on this output
# alone — mark it needs-device-check and ask the user to test it.

set -u

if [ $# -ne 1 ] || [ -z "${1:-}" ]; then
  echo "Usage: $0 <url>" >&2
  echo "Example: $0 \"https://example.com/live.m3u8\"" >&2
  exit 3
fi

URL="$1"

# Basic URL shape check before any network call.
case "$URL" in
  http://*|https://*) ;;
  *)
    echo "UNKNOWN | HTTP --- | content-type: - | final: $URL"
    echo "Reason: not an http(s) URL" >&2
    exit 2
    ;;
esac

TMP_HEADERS="$(mktemp)"
TMP_BODY="$(mktemp)"
trap 'rm -f "$TMP_HEADERS" "$TMP_BODY"' EXIT

# HEAD first, follow redirects, 15 s cap. -D writes headers, -o discards body.
HTTP_CODE="$(curl -s -o /dev/null -D "$TMP_HEADERS" -w "%{http_code}" \
  -L --max-time 15 \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
  -H "Accept: */*" \
  "$URL" 2>/dev/null || true)"
[ -z "$HTTP_CODE" ] && HTTP_CODE="000"

FINAL_URL="$(curl -s -o /dev/null -w "%{url_effective}" \
  -L --max-time 15 \
  -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
  "$URL" 2>/dev/null || true)"
[ -z "$FINAL_URL" ] && FINAL_URL="$URL"

CONTENT_TYPE="$(grep -i '^content-type:' "$TMP_HEADERS" 2>/dev/null \
  | tail -n 1 | cut -d' ' -f2- | tr -d '\r' | xargs 2>/dev/null || true)"
[ -z "$CONTENT_TYPE" ] && CONTENT_TYPE="-"

# Redirect chain, for the operator to see where the URL went.
REDIRECTS="$(grep -i '^location:' "$TMP_HEADERS" 2>/dev/null \
  | cut -d' ' -f2- | tr -d '\r' | paste -sd' -> ' - || true)"

# If HEAD gave no usable answer, try a short ranged GET (first 2 KB).
if [ "$HTTP_CODE" = "000" ] || [ "$HTTP_CODE" = "405" ] || [ "$HTTP_CODE" = "501" ]; then
  HTTP_CODE="$(curl -s -o "$TMP_BODY" -D "$TMP_HEADERS" -w "%{http_code}" \
    -L --max-time 15 -r 0-2047 \
    -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    "$URL" 2>/dev/null || true)"
  [ -z "$HTTP_CODE" ] && HTTP_CODE="000"
  FINAL_URL="$(curl -s -o /dev/null -w "%{url_effective}" \
    -L --max-time 15 \
    -A "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
    "$URL" 2>/dev/null || true)"
  [ -z "$FINAL_URL" ] && FINAL_URL="$URL"
  CONTENT_TYPE="$(grep -i '^content-type:' "$TMP_HEADERS" 2>/dev/null \
    | tail -n 1 | cut -d' ' -f2- | tr -d '\r' | xargs 2>/dev/null || true)"
  [ -z "$CONTENT_TYPE" ] && CONTENT_TYPE="-"
fi

# Classify by HTTP code and content type.
STATUS="UNKNOWN"
EXIT_CODE=2
case "$HTTP_CODE" in
  200|201|206)
    case "$CONTENT_TYPE" in
      *mpegurl*|*x-mpegURL*|*dash+xml*|*MP2T*|*mp4*|*video/*|*audio/*|*octet-stream*)
        STATUS="LIVE"
        EXIT_CODE=0
        ;;
      *text/html*|*text/plain*)
        # A playlist body can still be plain text; check the body.
        if grep -qi '#EXTM3U\|#EXT-X-\|<?xml' "$TMP_BODY" 2>/dev/null; then
          STATUS="LIVE"
          EXIT_CODE=0
        else
          STATUS="UNKNOWN"
          EXIT_CODE=2
        fi
        ;;
      *)
        STATUS="UNKNOWN"
        EXIT_CODE=2
        ;;
    esac
    ;;
  301|302|303|307|308)
    STATUS="UNKNOWN"
    EXIT_CODE=2
    ;;
  401|403)
    STATUS="UNKNOWN"
    EXIT_CODE=2
    ;;
  404|410)
    STATUS="DEAD"
    EXIT_CODE=1
    ;;
  000)
    STATUS="UNKNOWN"
    EXIT_CODE=2
    ;;
  *)
    STATUS="UNKNOWN"
    EXIT_CODE=2
    ;;
esac

echo "$STATUS | HTTP $HTTP_CODE | $CONTENT_TYPE | final: $FINAL_URL"
if [ -n "$REDIRECTS" ]; then
  echo "Redirects: $REDIRECTS"
fi
case "$STATUS" in
  DEAD)
    echo "Note: sandbox result only — verify on a real device before removing this link." >&2
    ;;
  UNKNOWN)
    echo "Note: inconclusive in the sandbox (blocked, tokenized, geo-locked, or unreachable here) — needs-device-check, do not delete." >&2
    ;;
esac

exit "$EXIT_CODE"
