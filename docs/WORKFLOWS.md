# Workflow Reference

All inputs are `workflow_call` inputs. Paths are relative to the caller repository. Booleans use YAML booleans, not quoted strings.

## CI workflows

`ci-node.yml` accepts `node_version` (default `22`), `package_manager` (`npm`), `working_directory` (`.`), and `run_lint`, `run_typecheck`, `run_tests`, `run_build` (all `true`). The selected commands are the package scripts of the same name.

`ci-nextjs.yml` has the same inputs and caches `.next/cache`. It optionally accepts the `BUILD_ENV` secret containing newline-separated `KEY=value` entries. Values are masked and loaded only for later CI steps; prefer public build configuration and use this only when the framework truly embeds a secret-dependent value. Never expose server-only credentials to browser bundles.

`ci-python.yml` accepts `python_version` (`3.12`), `working_directory` (`.`), `dependency_file` (`requirements.txt` or `pyproject.toml`), `run_lint` (`true`), `run_tests` (`true`), and `run_typecheck` (`false`). Enabled stages expect Ruff, pytest, or mypy in the project dependencies.

## Docker build

`docker-build.yml` requires `image_name`; accepts `dockerfile`, `docker_context`, `platforms`, `push_image`, `image_tag`, and `tag_latest`; and optionally receives `GHCR_TOKEN`. It outputs `image`, `image_tag`, `image_digest`, and `commit_sha`. A blank tag becomes `sha-<short-sha>`.

## Deployment

`deploy-vps.yml` requires `app_name`, `deploy_path`, `image_tag`, and the four VPS secrets. Optional inputs are `compose_file`, `environment`, `image_env_vars`, `healthcheck_url`, `healthcheck_timeout`, `migration_command`, `pre_deploy_command`, `post_deploy_command`, and `commit_sha`; `VPS_PORT` is optional. Outputs are `deployment_status` and `deployed_tag`.

`image_env_vars` is a comma-separated list populated with the same immutable tag—for example `WEB_IMAGE_TAG,API_IMAGE_TAG,WORKER_IMAGE_TAG` when all images came from the same commit.

`docker-deploy-vps.yml` combines one Docker build with deployment and forwards the build/deployment outputs. `full-stack-deploy.yml` accepts independent web/API Dockerfile and context inputs plus an optional worker, builds them in parallel with one shared commit tag, and deploys once.

Every secret must be mapped explicitly from the caller. See the examples for exact syntax.
