# Getting Started

For cross-repository calls under a personal GitHub account, `velryn-platform` must be public. Personal accounts do not offer organization-style internal repository visibility or private reusable-workflow sharing controls. Product repositories may remain private; only this platform's generic workflows and scripts are public.

## 1. Prepare the VPS

Install Docker Engine with the Compose plugin. Create an unprivileged deployment user that can run Docker, then create one directory per SaaS:

```bash
sudo install -d -o deploy -g deploy -m 750 /opt/example-saas
```

Place `docker-compose.yml` and a permission-restricted runtime `.env` there. Runtime database passwords, JWT keys, and provider credentials should normally live in this server-side `.env`; do not commit it.

Log in to GHCR on the VPS once if images are private. Use a narrowly scoped classic PAT with `read:packages` as the password; the Actions-side publish uses `GITHUB_TOKEN` and needs no manually created PAT.

## 2. Configure SSH trust

From a trusted network, verify the VPS host fingerprint through your provider console, then collect it:

```bash
ssh-keyscan -p 22 your-vps.example.com
```

Store the verified output as `VPS_KNOWN_HOSTS`. Never accept an unverified scan merely because it was returned by the hostname.

## 3. Add repository secrets

In the SaaS repository, open **Settings → Secrets and variables → Actions** and add `VPS_HOST`, `VPS_USER`, `VPS_SSH_KEY`, `VPS_KNOWN_HOSTS`, and optionally `VPS_PORT`.

## 4. Add the caller

Copy the appropriate file from `examples/` to `.github/workflows/deploy.yml`, replace `YOUR_GITHUB_USERNAME`, application names, paths, and health URL. Grant `contents: read` and `packages: write` in the caller.

The Compose image should be immutable:

```yaml
services:
  app:
    image: ghcr.io/yourusername/example-saas:${IMAGE_TAG}
```

## 5. Push

```bash
git push origin main
```

The workflow validates source, builds and publishes the image once, deploys that exact tag, checks health, and retains the previous state for rollback.

For staging, create `staging` and `production` GitHub Environments and use [the two-environment example](../examples/staging-production-caller.yml). Environments are supported, not required.
