# Velryn Platform v1.0.0 Implementation Plan

## Architecture

`velryn-platform` is a versioned library of reusable GitHub Actions workflows for repositories owned by a personal GitHub account. Product repositories retain their own credentials and call a tagged platform workflow. CI validates source code, Docker Buildx produces an immutable image once, GHCR stores it, and an Ubuntu VPS pulls that exact image through Docker Compose.

The platform is deliberately limited to GitHub Actions, GHCR, SSH, Docker Compose, and small auditable Bash scripts. It does not require GitHub Organization or enterprise features.

## Reusable workflows

| Workflow | Responsibility |
| --- | --- |
| `ci-node.yml` | Configurable JavaScript/TypeScript/Express CI |
| `ci-nextjs.yml` | Next.js CI with dependency and `.next/cache` caching |
| `ci-python.yml` | Configurable requirements/pyproject Python CI |
| `docker-build.yml` | Buildx build, immutable tagging, optional GHCR publish |
| `deploy-vps.yml` | Secure SSH deployment, hooks, migrations, health check, rollback, cleanup |
| `docker-deploy-vps.yml` | Compose `docker-build` and `deploy-vps` for a single image |
| `full-stack-deploy.yml` | Build web/API and optional worker images, then deploy together |

## Inputs and outputs

Names are consistent across workflows: `working_directory`, runtime version, `package_manager`, stage booleans, `dockerfile`, `docker_context`, `image_name`, `image_tag`, `app_name`, `environment`, `deploy_path`, `compose_file`, `healthcheck_url`, and deployment hook commands. Defaults preserve a low-friction caller experience.

Build outputs expose `image`, `image_tag`, `image_digest`, and `commit_sha`. Deployment exposes `deployment_status` and `deployed_tag`. Combined workflows forward the useful outputs.

## Secrets

Each `workflow_call` explicitly declares its secrets. Product repositories pass `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, and `VPS_KNOWN_HOSTS`; `VPS_PORT` is optional. `GITHUB_TOKEN` remains the preferred GHCR credential and is passed explicitly by combined workflows. No application or infrastructure secrets are stored here.

## Deployment lifecycle

1. CI completes in the caller repository.
2. Buildx builds once and pushes an immutable `sha-<short-sha>` image plus requested release/channel tags.
3. Deployment records the currently deployed tag from a server-side deployment state file.
4. The deployment workflow writes only image-tag variables to a generated Compose env file, then runs optional pre-deploy and migration hooks.
5. Docker Compose pulls the prebuilt image and recreates services.
6. The health endpoint is retried until healthy, optional post-deploy runs, safe image/cache cleanup follows, and deployment metadata is recorded.

## Rollback strategy

Each application directory has a `deployment/` state directory. Before mutation, the current successful env/tag state is copied to `previous.env`; the candidate is written to `current.env`. If deployment or health checking fails, `rollback.sh` restores `previous.env`, runs `docker compose pull` and `up -d`, then checks the prior version. Volumes and databases are never modified. Database migrations are not automatically reversed.

## Security model

- Explicit least-privilege workflow permissions.
- SSH host verification is mandatory through `VPS_KNOWN_HOSTS`; `StrictHostKeyChecking=no` is never used.
- No builds occur on production hosts.
- Hooks are caller-controlled privileged inputs, are never evaluated with `eval`, and execute through an explicit shell on the trusted server.
- Secrets are written only to permission-restricted temporary files and are removed by traps.
- Deployment paths, Compose filenames, ports, identifiers, tags, and numeric limits are validated before use.
- Third-party actions use stable major versions; production maintainers should upgrade to immutable commit pins where their threat model requires it.

## Folder structure

```text
.github/workflows/       reusable workflow APIs
.github/dependabot.yml   Actions dependency updates
scripts/                 auditable VPS deployment primitives
templates/               starter caller workflows by stack
examples/                complete callers and production Compose example
docs/                    operations and platform documentation
```

## Delivery order

1. Implement and validate shell primitives.
2. Implement CI, build, deployment, combined, and full-stack workflows.
3. Add examples and templates that consume the exact workflow interface.
4. Write operational, security, onboarding, and versioning documentation.
5. Validate YAML, Bash syntax, executable bits, interface consistency, secret hygiene, branding, and Git diff.
