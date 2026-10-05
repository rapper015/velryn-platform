#!/usr/bin/env bash

set -Eeuo pipefail

: "${APP_NAME:?APP_NAME is required}"
: "${DEPLOY_PATH:?DEPLOY_PATH is required}"
: "${COMPOSE_FILE:=docker-compose.yml}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"
: "${IMAGE_ENV_VARS:=IMAGE_TAG}"
: "${HEALTHCHECK_URL:=}"
: "${HEALTHCHECK_ATTEMPTS:=20}"
: "${HEALTHCHECK_INTERVAL:=5}"
: "${PRE_DEPLOY_COMMAND:=}"
: "${MIGRATION_COMMAND:=}"
: "${POST_DEPLOY_COMMAND:=}"
: "${DEPLOYMENT_ENVIRONMENT:=production}"
: "${COMMIT_SHA:=unknown}"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_DIR="$DEPLOY_PATH/deployment"
CURRENT_ENV="$STATE_DIR/current.env"
PREVIOUS_ENV="$STATE_DIR/previous.env"
CANDIDATE_ENV="$STATE_DIR/candidate.env"
METADATA_FILE="$STATE_DIR/metadata.json"

"$SCRIPT_DIR/validate-config.sh" "$APP_NAME" "$DEPLOY_PATH" "$COMPOSE_FILE" "$IMAGE_TAG"
[[ "$HEALTHCHECK_ATTEMPTS" =~ ^[1-9][0-9]*$ ]] || { echo "[velryn] Invalid health-check attempt count." >&2; exit 2; }
[[ "$HEALTHCHECK_INTERVAL" =~ ^[0-9]+$ ]] || { echo "[velryn] Invalid health-check interval." >&2; exit 2; }
[[ "$DEPLOYMENT_ENVIRONMENT" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]*$ ]] || { echo "[velryn] Invalid environment name." >&2; exit 2; }
[[ "$COMMIT_SHA" =~ ^[a-fA-F0-9]{7,64}$ || "$COMMIT_SHA" == unknown ]] || { echo "[velryn] Invalid commit SHA." >&2; exit 2; }

mkdir -p -- "$STATE_DIR"
chmod 700 "$STATE_DIR"
install -d -m 700 "$STATE_DIR/scripts"
install -m 700 "$SCRIPT_DIR/deploy.sh" "$SCRIPT_DIR/rollback.sh" "$SCRIPT_DIR/health-check.sh" \
  "$SCRIPT_DIR/docker-cleanup.sh" "$SCRIPT_DIR/validate-config.sh" "$STATE_DIR/scripts/"
if [[ -s "$CURRENT_ENV" ]]; then cp -- "$CURRENT_ENV" "$PREVIOUS_ENV"; fi

: > "$CANDIDATE_ENV"
IFS=',' read -r -a env_vars <<< "$IMAGE_ENV_VARS"
for env_var in "${env_vars[@]}"; do
  env_var="${env_var//[[:space:]]/}"
  [[ "$env_var" =~ ^[A-Z][A-Z0-9_]*$ ]] || { echo "[velryn] Invalid image env variable: $env_var" >&2; exit 2; }
  printf '%s=%s\n' "$env_var" "$IMAGE_TAG" >> "$CANDIDATE_ENV"
done
chmod 600 "$CANDIDATE_ENV"
mv -- "$CANDIDATE_ENV" "$CURRENT_ENV"

run_hook() {
  local label="$1" command="$2"
  if [[ -n "$command" ]]; then
    echo "[velryn] Running $label."
    # Hooks are trusted caller inputs. A shell is explicit; eval and interpolation into this script are avoided.
    bash -Eeuo pipefail -c "$command"
  fi
}

rollback_on_error() {
  local exit_code=$?
  trap - ERR
  echo "[velryn] Deployment failed; attempting rollback." >&2
  if [[ -s "$PREVIOUS_ENV" ]]; then
    "$SCRIPT_DIR/rollback.sh" "$DEPLOY_PATH" "$COMPOSE_FILE" "$HEALTHCHECK_URL" "$HEALTHCHECK_ATTEMPTS" "$HEALTHCHECK_INTERVAL" || \
      echo "[velryn] Automatic rollback also failed; manual intervention is required." >&2
  else
    echo "[velryn] No previous successful state exists; automatic rollback was skipped." >&2
  fi
  exit "$exit_code"
}
trap rollback_on_error ERR

cd -- "$DEPLOY_PATH"
compose_env_args=()
if [[ -f .env ]]; then compose_env_args+=(--env-file .env); fi
compose_env_args+=(--env-file "$CURRENT_ENV")
run_hook "pre-deploy hook" "$PRE_DEPLOY_COMMAND"
docker compose "${compose_env_args[@]}" -f "$COMPOSE_FILE" pull
run_hook "database migration" "$MIGRATION_COMMAND"
docker compose "${compose_env_args[@]}" -f "$COMPOSE_FILE" up -d --remove-orphans

if [[ -n "$HEALTHCHECK_URL" ]]; then
  "$SCRIPT_DIR/health-check.sh" "$HEALTHCHECK_URL" "$HEALTHCHECK_ATTEMPTS" "$HEALTHCHECK_INTERVAL"
fi

run_hook "post-deploy hook" "$POST_DEPLOY_COMMAND"
trap - ERR

deployed_at="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
printf '{\n  "application": "%s",\n  "environment": "%s",\n  "commit_sha": "%s",\n  "image_tag": "%s",\n  "deployed_at": "%s"\n}\n' \
  "$APP_NAME" "$DEPLOYMENT_ENVIRONMENT" "$COMMIT_SHA" "$IMAGE_TAG" "$deployed_at" > "$METADATA_FILE"
chmod 600 "$METADATA_FILE"

"$SCRIPT_DIR/docker-cleanup.sh"
echo "[velryn] Deployment of $APP_NAME:$IMAGE_TAG succeeded."
