#!/usr/bin/env bash

set -Eeuo pipefail

echo "[velryn] Removing dangling images older than 24 hours."
docker image prune --force --filter 'dangling=true' --filter 'until=24h'

if docker buildx version >/dev/null 2>&1; then
  echo "[velryn] Removing Buildx cache older than 168 hours."
  docker buildx prune --force --filter 'until=168h' || true
fi

echo "[velryn] Cleanup complete. Volumes and tagged images were not removed."
