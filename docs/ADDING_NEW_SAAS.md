# Adding a New SaaS

1. Create the application repository with a deterministic lockfile and appropriate CI scripts/tools.
2. Add production Dockerfile(s). Keep builds reproducible and run as a non-root container user where practical.
3. Add a Compose file using `${IMAGE_TAG}` for one image or `${WEB_IMAGE_TAG}`, `${API_IMAGE_TAG}`, and `${WORKER_IMAGE_TAG}` for a full stack.
4. Create `/opt/<app>` on the chosen VPS. Add Compose and a mode-`600` runtime `.env`; do not mix applications.
5. Add the four required VPS secrets and optional port to the repository or its staging/production environments.
6. Copy the closest template into `.github/workflows/deploy.yml`, replace placeholders, and point at `@v1` or an immutable release.
7. Open a pull request. Confirm lint, typecheck, tests, and build pass without exposing deployment secrets.
8. Merge to the deployment branch and observe image publication, Compose deployment, and health checking.
9. Verify `docker compose ps`, logs, the public endpoint, and `deployment/metadata.json`.
10. Exercise rollback in staging before relying on it in production.

For `develop → staging` and `main → production`, use separate jobs/environments like `examples/staging-production-caller.yml`. The workflow does not require that branching model.

For a new stack, prefer composing existing workflows over adding product-specific logic here. Add optional inputs with safe defaults when a capability is broadly reusable. A future `velryn create` command can automate steps 2–6 from these templates without changing the workflow APIs.
