# Contributing

Treat workflow inputs, outputs, defaults, secrets, and server state as a public API. Prefer backward-compatible optional additions; document and version breaking changes.

Before opening a pull request:

```bash
bash -n scripts/*.sh
yamllint .github examples templates
```

Also compare every example input/secret to its called workflow, search for credentials and obsolete branding, and test deployments against a non-production canary. Never add real hosts, usernames, tokens, private keys, or `.env` files.

Release changes require a changelog entry. Maintainers create immutable semantic tags and move a major alias only after canary validation.
