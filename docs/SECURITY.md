# Security Model

The trust boundary is the product repository: maintainers can select images, server paths, and privileged deployment hooks. Protect workflow changes with review and use a GitHub Environment with required reviewers for production where available.

Because Velryn currently uses a personal GitHub account, publish this generic platform repository as public for cross-repository reusable-workflow access. Keep every product secret in the private caller repository/environment or on its VPS; never add product-specific values here.

Controls in v1:

- Explicit `contents: read`; only image workflows request `packages: write`.
- Caller secrets are enumerated; `secrets: inherit` is not used.
- `VPS_KNOWN_HOSTS` is mandatory and SSH host checking remains enabled.
- SSH credentials/configuration are mode `600`; transferred configuration is base64 encoded, permission restricted, and removed after use.
- Identifiers, deployment paths, filenames, ports, image tags, and timeouts are validated.
- Production hosts pull prebuilt images and do not build source.
- Cleanup never prunes volumes or all tagged images.
- Third-party actions use maintained stable major versions and Dependabot monitors updates.

For a stronger supply-chain posture, replace major action tags with reviewed full commit SHAs, enable GitHub secret scanning and dependency review in each application repository, protect release tags, use branch protection/rulesets, and scan application dependencies/images in those repositories. Review Dependabot updates rather than auto-merging blindly.

The server deployment user should have no interactive password, use a dedicated SSH key, and receive only the filesystem/Docker permissions needed. Docker group membership is effectively root-equivalent; consider a tightly scoped rootless Docker installation when operationally practical.

See the root [security policy](../SECURITY.md) to report vulnerabilities privately.
