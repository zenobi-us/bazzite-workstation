# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project Shape

This repo builds a custom Universal Blue / bootc workstation image named `bazzite-workstation`.

Primary files:

- `Containerfile` — bootc image definition. Base currently derives from `ghcr.io/ublue-os/bazzite-dx-nvidia:stable`.
- `build_files/build.sh` — main image customization entrypoint called by `Containerfile`.
- `build_files/build.d/*.sh` — focused build scripts invoked from `build.sh`.
- `Justfile` — local build, VM, ISO, and utility commands.
- `.github/workflows/build.yml` — GHCR image build workflow.
- `.github/workflows/build-disk.yml` — disk image workflow.
- `disk_config/*.toml` — bootc image builder disk/ISO config.

## Hard Rules

- You MUST NOT commit `cosign.key` or any private key material.
- You MUST preserve bootc image validity; `bootc container lint` in `Containerfile` is not optional.
- You MUST treat user-local machine assumptions carefully. This repo targets Fedora Atomic / Universal Blue bootc systems.
- You MUST NOT rewrite base image, disk config, or workflow publishing targets unless explicitly asked.
- You MUST keep build-time changes in `build_files/build.d/` when they are logically separable.
- You SHOULD keep `build_files/build.sh` as orchestration, not as a dumping ground.

## Build Script Conventions

- Scripts SHOULD use strict shell options, preferably `set -ouex pipefail` or stricter where compatible.
- Package installs SHOULD use `dnf5`.
- Temporary COPR or repo enables MUST be disabled before final image unless persistent enablement is intentional and documented.
- Build steps SHOULD be idempotent. Rebuilding image should not depend on prior local state.
- Comments SHOULD explain why a package/repo/config exists, not restate shell syntax.

## Validation

Before reporting build-related changes as done, run cheapest relevant validation:

- `just check` for Justfile syntax changes.
- `podman build --pull=newer --tag bazzite-workstation:test .` for Containerfile or build script changes, if feasible.
- Workflow YAML changes SHOULD be reviewed for syntax and env var consistency.

If full image build is too expensive or unavailable, state that validation was not run and why.

## Repository Hygiene

- Generated build outputs belong outside commits: `_build*`, `output/`, `previous.manifest.json`, `changelog.md`, `output.env`.
- Do not overwrite user changes. Check `git status --short` before edits when worktree may be dirty.
- Existing uncommitted changes may be intentional. Touch only files needed for task.

## Current Dirty-Tree Note

At time of this file creation, repo had pre-existing modifications in:

- `Containerfile`
- `disk_config/iso-gnome.toml`
- `disk_config/iso-kde.toml`
- `disk_config/iso.toml`

Agents MUST NOT assume those edits are theirs.
