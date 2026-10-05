# Troubleshooting

## SSH permission denied

Confirm `VPS_USER`, key format, authorized key permissions, and SSH port. Test the same key locally. Do not disable host checking.

## Host key verification failed

Compare the server fingerprint through the provider console, regenerate `VPS_KNOWN_HOSTS` with `ssh-keyscan -p <port> <host>`, verify it out of band, then replace the secret.

## GHCR unauthorized

The caller needs `permissions: packages: write`. For a private image, the VPS also needs `docker login ghcr.io` using an identity with `read:packages`; verify package access and lowercase image paths.

## Docker pull or bad image tag

Inspect `deployment/current.env`, confirm the tag exists in GHCR, and run `docker compose --env-file deployment/current.env config` followed by `pull`.

## Health check failed

Check `docker compose ps`, service logs, the loopback URL from the VPS, startup time, and port mapping. Increase `healthcheck_timeout` for legitimately slow starts; do not hide unhealthy applications by removing the check.

## Port occupied

Use `ss -ltnp` and `docker ps` to identify the owner. Give staging and production distinct host ports.

## Disk full

Use `docker system df` and filesystem tools. `docker-cleanup.sh` removes dangling images and old Buildx cache only. Never delete volumes without identifying their data and backup status.

## Compose failure

Run `docker compose config`, verify `.env` exists with correct permissions, ensure the Compose plugin is current, and inspect service logs. Each application must have an independent project directory.

## Missing secret

GitHub reports a required `workflow_call` secret before the job starts. Add it to the caller repository or selected environment and explicitly map it in the caller job.

## Rollback failed

Inspect `deployment/previous.env`, verify those tags still exist, and run the command in [Rollback](ROLLBACK.md). Database compatibility and external dependency changes may still require manual recovery.
