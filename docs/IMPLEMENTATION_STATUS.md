# Implementation Status

Status for the v1.0.0 baseline.

## Completed

- Reusable Node.js, Next.js, and Python CI with selectable stages and dependency caching.
- Buildx image build, GHA layer cache, GHCR authentication, immutable SHA tag default, optional latest/release tags, and build outputs.
- Verified-host SSH deployment of prebuilt images with app/environment concurrency, Compose pull/up, optional hooks/migrations, health retry, metadata, and safe cleanup.
- Automatic and manual state-file rollback to the previous image tags without volume deletion.
- Composed single-image and web/API/optional-worker full-stack workflows.
- Personal-account-compatible explicit secret passing; no organization features or application secrets required.
- Next.js, Express, MERN, Python/Next/Celery, staging/production examples and stack templates.
- Architecture, onboarding, secrets, deployment, rollback, versioning, security, troubleshooting, contribution, and release documentation.
- Dependabot configuration for GitHub Actions.
- YAML parse validation, actionlint 1.7.12 validation for all workflow/example/template files, and Bash syntax validation for all scripts.
- Static scans for forbidden branding, private-key markers, unsafe SSH bypass, broad permissions, inherited secrets, and destructive Docker volume cleanup.

## Partially completed

- Third-party actions use stable major tags and Dependabot. Full commit-SHA pinning is recommended but requires an ongoing reviewed-update process.
- Notification and observability interfaces are documented through workflow outputs, logs, and server metadata; vendor integrations are intentionally not implemented.
- Artifact promotion is supported by calling `deploy-vps.yml` with an existing immutable tag. The convenience combined workflow builds for each invocation, so strict staging-to-production promotion needs a small caller orchestration workflow.
- YAML was parsed locally, but a live GitHub Actions canary run is still required after publishing because GitHub expression/context validation is service-side.

## Future work

- Add a generic opt-in webhook notification adapter with signed payloads.
- Add image provenance/SBOM and vulnerability scanning after selecting a maintained policy/tool.
- Add canary integration fixtures that deploy to a disposable VPS.
- Build `velryn-cli` separately around the stable workflow/template/state contracts.
- Consider digest-pinned Compose deployment in a backward-compatible v1 minor release.
