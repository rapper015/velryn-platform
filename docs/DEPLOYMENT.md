# Deployment

## Lifecycle

1. CI runs without deployment credentials on pull requests.
2. Buildx creates one image and publishes an immutable `sha-xxxxxxx` tag to GHCR.
3. The deploy job queues behind the same `app_name`/`environment` concurrency group.
4. Verified SSH transfers the scripts selected by the platform version.
5. The server snapshots `current.env` to `previous.env`, writes the candidate tag, layers it after the server's runtime `.env`, then pulls and starts Compose.
6. HTTP 200–399 must be observed within `healthcheck_timeout` when a URL is configured.
7. Metadata is recorded and only dangling images/old Buildx cache are pruned.

Active deployments are queued rather than canceled because interrupting a remote Compose mutation is unsafe. A newer queued run follows immediately.

## Server layout

```text
/opt/
├── inventory/
│   ├── docker-compose.yml
│   ├── .env                 # runtime secrets, mode 600
│   └── deployment/          # platform state, mode 700
├── finance/
└── crm/
```

Use a dedicated `deploy` account, group-readable application directories only when necessary, and no shared Compose project across products.

## Hooks and migrations

`pre_deploy_command`, `migration_command`, and `post_deploy_command` are blank by default. They are trusted shell commands supplied by repository maintainers and execute as the deployment user in `deploy_path`; restrict who can edit production workflows. Inputs are base64-transported rather than interpolated into SSH commands, and `eval` is not used.

Migration examples include `docker compose --env-file .env --env-file deployment/current.env run --rm api python manage.py migrate` and `docker compose --env-file .env --env-file deployment/current.env run --rm api npx prisma migrate deploy`. The second file overrides only image tags. This deliberately starts a one-off candidate-image container instead of executing in the old running service. Schema migrations may be irreversible and container rollback does not reverse them; use backward-compatible expand/migrate/contract changes.

## Logs

GitHub Actions stores deployment output, not application logs. On the VPS use:

```bash
docker compose ps
docker compose logs
docker compose logs -f
docker compose logs -f api
```

Promote the same digest from staging to production when strict promotion is required by calling `deploy-vps.yml` with an already built tag. The combined convenience workflow builds per invocation.
