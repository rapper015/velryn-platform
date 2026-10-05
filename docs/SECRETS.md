# Secrets

| Secret | Required | Purpose |
| --- | --- | --- |
| `VPS_HOST` | Yes | DNS name or IP of this SaaS's server |
| `VPS_USER` | Yes | Unprivileged SSH deployment user |
| `VPS_SSH_KEY` | Yes | Private key for that user |
| `VPS_KNOWN_HOSTS` | Yes | Verified SSH host-key entry |
| `VPS_PORT` | No | SSH port; defaults to 22 |

`GITHUB_TOKEN` is supplied automatically by GitHub and is passed explicitly to the nested image workflow. The caller must grant `packages: write`. No organization secret or `secrets: inherit` is required.

Prefer keeping runtime application secrets in `/opt/<app>/.env` with mode `600` and owner `deploy`. Alternatively, callers may manage environment-specific secrets in GitHub Environments, but this platform intentionally does not copy arbitrary runtime secrets over SSH.

Never store database credentials, JWT/signing secrets, API keys, payment credentials, private SSH keys, or production `.env` files in this repository. Avoid debug commands that print the environment. Rotate a secret immediately if it appears in a log or commit history.

Repository environments may contain different VPS secrets for staging and production. On plans that support them, add required reviewers and deployment branch restrictions to `production`.
