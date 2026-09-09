# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Shape

This repo builds custom Universal Blue and bootc workstation images named
`bazzite-workstation`.

Primary files:

- `images/<id>/Containerfile` — bootc image definition for one image.
- `packages/image-common/build.sh` — shared image customization entrypoint.
- `packages/image-common/build.d/*.sh` — shared build scripts invoked by `build.sh`.
- `images/<id>/build.d/*.sh` — image-specific build scripts.
- `mise.toml`, `images/<id>/mise.toml`, and `.mise/tasks/` — monorepo build, VM, ISO, lint, and utility tasks.
- `.github/workflows/build.yml` — GHCR image build workflow.
- `.github/workflows/build-disk.yml` — disk image workflow.
- `images/<id>/disk/*.toml` — bootc image builder disk and ISO config.

## Hard Rules

- You MUST NOT commit `cosign.key` or any private key material.
- You MUST preserve bootc image validity; every image `Containerfile` must run `bootc container lint`.
- You MUST treat user-local machine assumptions carefully. This repo targets Fedora Atomic, Universal Blue, and bootc systems.
- You MUST use bootc conventions in deployment instructions. Prefer `bootc switch --transport registry IMAGE` for OCI image changes.
- You MUST use `bootc status` to inspect deployments and `bootc rollback` to return to the previous deployment.
- You MUST document `rpm-ostree rebase` only for compatibility workflows. Do not present it as the default for bootc systems.
- You MUST NOT rewrite base image, disk config, or workflow publishing targets unless explicitly asked.
- You MUST keep build-time changes in `packages/image-common/build.d/` or `images/<id>/build.d/` when they are logically separable.
- You SHOULD keep `packages/image-common/build.sh` as orchestration, not as a dumping ground.

## Build Script Conventions

- Scripts SHOULD use strict shell options, preferably `set -ouex pipefail` or stricter where compatible.
- Package installs SHOULD use `dnf5`.
- Temporary COPR or repo enables MUST be disabled before final image unless persistent enablement is intentional and documented.
- Build steps SHOULD be idempotent. Rebuilding an image should not depend on prior local state.
- Comments SHOULD explain why a package or repo config exists, not restate shell syntax.

## Validation

Before reporting build-related changes as done, run the cheapest relevant validation:

- `mise run //images/<id>:lint` for image-specific shell syntax changes.
- `podman build --pull=newer --tag bazzite-workstation:test --file images/bazzite-workstation/Containerfile .` for Containerfile or build script changes, if feasible.
- Workflow YAML changes SHOULD be reviewed for syntax and environment variable consistency.

If a full image build is too expensive or unavailable, state that validation was not run and why.

## Repository Hygiene

- Generated build outputs belong outside commits: `_build*`, `output/`, `previous.manifest.json`, `changelog.md`, and `output.env`.
- Do not overwrite user changes. Check `git status --short` before edits when the worktree may be dirty.
- Existing uncommitted changes may be intentional. Touch only files needed for the task.
