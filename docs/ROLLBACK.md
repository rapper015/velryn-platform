# Rollback

Before a candidate is installed, `deploy.sh` copies `deployment/current.env` to `previous.env`. If pull, migration, Compose start, health check, or a post-deploy hook fails, the error trap calls `rollback.sh`. It restores `previous.env`, pulls those image tags, runs `docker compose up -d --remove-orphans`, and checks the same health endpoint.

The first deployment has no prior state and therefore cannot roll back automatically. A rollback failure is reported loudly and requires manual intervention.

Manual rollback on the VPS:

```bash
cd /opt/velryn/example-saas
deployment/scripts/rollback.sh "$PWD" docker-compose.yml http://localhost:3000/health 20 5
```

The platform retains the matching scripts in the protected `deployment/scripts/` directory during every deployment, so the manual command uses the same implementation as automatic rollback.

Rollback changes only image-tag environment values. It never deletes Docker volumes and never reverses database migrations. Design production migrations to remain compatible with both the new and previous application versions.
