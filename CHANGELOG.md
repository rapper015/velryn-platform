# Changelog

All notable changes follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and Semantic Versioning.

## [Unreleased]

### Changed

- Allow isolated deployment directories directly below `/opt`, such as `/opt/inventory`, instead of requiring the additional `/opt/velryn` parent directory.

## [1.0.0] - 2026-10-05

### Added

- Reusable Node.js, Next.js, and Python CI workflows.
- Buildx/GHCR image publishing with immutable SHA tags and cache support.
- Verified-SSH Docker Compose deployment with concurrency control.
- Health checking, safe cleanup, automatic/manual rollback, migrations, and hooks.
- Single-image and full-stack composition workflows, templates, examples, and operations documentation.
