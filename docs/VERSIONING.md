# Versioning

Reusable workflows are APIs. Velryn Platform uses semantic versioning:

- PATCH: fixes with no intended caller change.
- MINOR: backward-compatible optional inputs, outputs, or workflows.
- MAJOR: removed/renamed inputs, changed defaults with breaking behavior, or incompatible deployment contracts.

Release process:

1. Update `CHANGELOG.md` and `docs/IMPLEMENTATION_STATUS.md`.
2. Validate all YAML, Bash, examples, and a canary SaaS.
3. Create an annotated release tag such as `v1.0.0`.
4. Move the major alias `v1` to that tested commit and publish the GitHub release.
5. Notify callers before deprecations and retain compatibility through the current major.

Production callers should select `@v1` for managed compatible upgrades, `@v1.0.0` for fixed releases, or a commit SHA for immutability. Do not permanently use `@main`.
