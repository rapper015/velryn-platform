# Architecture

Product repositories call tagged reusable workflows and explicitly pass repository/environment secrets. CI and deployment are separate capabilities. `docker-deploy-vps.yml` composes the image builder and deployer; `full-stack-deploy.yml` builds web, API, and optional worker images in parallel before one deployment.

```text
PR -> lint / typecheck / test / build
merge -> Buildx -> GHCR sha tag -> SSH -> Compose pull/up -> health
                                                        \-> rollback on failure
```

The artifact promoted is the registry image, not source code. The production host never runs `docker build`. Each product owns an isolated `/opt/velryn/<app>` directory and may point to any VPS.

The server-side contract consists of the product-maintained Compose/runtime `.env` and platform-maintained `deployment/current.env`, `previous.env`, and `metadata.json`. A future `velryn` CLI can generate callers and Compose files, invoke workflow dispatches, and read this stable metadata contract without changing the deployment model.

Observability integrations can consume `application`, `environment`, `commit_sha`, `image_tag`, and `deployed_at` from `metadata.json`, plus workflow image digests. Future notification adapters can map job start/success/failure and rollback logs to generic webhook events without coupling the core workflow to Slack or Discord.
