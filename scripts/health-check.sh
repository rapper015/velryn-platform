#!/usr/bin/env bash

set -Eeuo pipefail

URL="${1:-}"
MAX_ATTEMPTS="${2:-20}"
INTERVAL="${3:-5}"
SUCCESS_CODES="${4:-200-399}"

if [[ -z "$URL" ]]; then
  echo "Usage: $0 URL [MAX_ATTEMPTS] [INTERVAL] [SUCCESS_CODES]" >&2
  exit 2
fi

[[ "$MAX_ATTEMPTS" =~ ^[1-9][0-9]*$ ]] || { echo "[velryn] MAX_ATTEMPTS must be a positive integer." >&2; exit 2; }
[[ "$INTERVAL" =~ ^[0-9]+$ ]] || { echo "[velryn] INTERVAL must be a non-negative integer." >&2; exit 2; }

case "$SUCCESS_CODES" in
  200-399) code_pattern='^[23][0-9]{2}$' ;;
  200-299) code_pattern='^2[0-9]{2}$' ;;
  *) echo "[velryn] SUCCESS_CODES must be 200-399 or 200-299." >&2; exit 2 ;;
esac

for ((attempt = 1; attempt <= MAX_ATTEMPTS; attempt++)); do
  status="$(curl --silent --show-error --location --output /dev/null --write-out '%{http_code}' \
    --connect-timeout 5 --max-time 15 "$URL" 2>/dev/null || true)"

  if [[ "$status" =~ $code_pattern ]]; then
    echo "[velryn] Health check passed ($status) on attempt $attempt/$MAX_ATTEMPTS."
    exit 0
  fi

  echo "[velryn] Health check attempt $attempt/$MAX_ATTEMPTS returned ${status:-no response}."
  if (( attempt < MAX_ATTEMPTS )); then sleep "$INTERVAL"; fi
done

echo "[velryn] Health check failed after $MAX_ATTEMPTS attempts: $URL" >&2
exit 1
