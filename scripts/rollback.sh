#!/usr/bin/env bash

set -Eeuo pipefail

DEPLOY_PATH="${1:-}"
COMPOSE_FILE="${2:-docker-compose.yml}"
HEALTHCHECK_URL="${3:-}"
MAX_ATTEMPTS="${4:-20}"
INTERVAL="${5:-5}"
STATE_DIR="$DEPLOY_PATH/deployment"
CURRENT_ENV="$STATE_DIR/current.env"
PREVIOUS_ENV="$STATE_DIR/previous.env"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -s "$PREVIOUS_ENV" ]]; then
  echo "[velryn] Rollback unavailable: $PREVIOUS_ENV does not exist or is empty." >&2
  exit 1
fi

echo "[velryn] Restoring the previous deployment state."
cp -- "$PREVIOUS_ENV" "$CURRENT_ENV"
chmod 600 "$CURRENT_ENV"

cd -- "$DEPLOY_PATH"
compose_env_args=()
if [[ -f .env ]]; then compose_env_args+=(--env-file .env); fi
compose_env_args+=(--env-file "$CURRENT_ENV")
docker compose "${compose_env_args[@]}" -f "$COMPOSE_FILE" pull
docker compose "${compose_env_args[@]}" -f "$COMPOSE_FILE" up -d --remove-orphans

if [[ -n "$HEALTHCHECK_URL" ]]; then
  "$SCRIPT_DIR/health-check.sh" "$HEALTHCHECK_URL" "$MAX_ATTEMPTS" "$INTERVAL"
fi

echo "[velryn] Rollback completed successfully."
