#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="${1:-}"
DEPLOY_PATH="${2:-}"
COMPOSE_FILE="${3:-docker-compose.yml}"
IMAGE_TAG="${4:-}"

[[ "$APP_NAME" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]] || { echo "[velryn] Invalid app_name." >&2; exit 2; }
[[ "$DEPLOY_PATH" =~ ^/opt/velryn/[a-zA-Z0-9._/-]+$ ]] || { echo "[velryn] deploy_path must be an absolute path below /opt/velryn/." >&2; exit 2; }
[[ "$DEPLOY_PATH" != *'..'* ]] || { echo "[velryn] deploy_path cannot contain '..'." >&2; exit 2; }
[[ "$COMPOSE_FILE" =~ ^[a-zA-Z0-9][a-zA-Z0-9._/-]*\.ya?ml$ ]] || { echo "[velryn] Invalid compose_file." >&2; exit 2; }
[[ "$COMPOSE_FILE" != /* && "$COMPOSE_FILE" != *'..'* ]] || { echo "[velryn] compose_file must be a relative path without '..'." >&2; exit 2; }
[[ "$IMAGE_TAG" =~ ^[a-zA-Z0-9_][a-zA-Z0-9_.-]{0,127}$ ]] || { echo "[velryn] Invalid image tag." >&2; exit 2; }

echo "[velryn] Configuration is valid for $APP_NAME."
