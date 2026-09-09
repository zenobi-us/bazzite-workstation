# bazzite-workstation images

Mise monorepo for building bootc images from shared customizations.

## Layout

- `images/<id>/` — image Containerfile, image-only build scripts, disk configs, and `mise.toml`
- `packages/image-common/` — build scripts and assets shared by every image
- `templates/image/` — scaffold for new image projects
- `.mise/tasks/image/` — shared image build, disk-image, VM, and utility task implementations
- `.mise/tasks/repo/` — repository validation task implementations
- `mise.toml` task definitions — per-image task wiring to the shared task files
- `.github/workflows/` — OCI and disk-image build matrices

## Build

Mise uses `//`-prefixed paths for monorepo tasks:

```bash
mise tasks
mise run //images/bazzite-workstation:build
mise run //images/bazzite-workstation:lint
mise run //packages/image-common:lint
```

Convenience tasks target `bazzite-workstation` by default:

```bash
mise run build
mise run build-qcow2
mise run build-iso
mise run lint
```

Select another image with environment variables:

```bash
IMAGE_PROJECT=bazzite-workstation-legacy-nvidia \
IMAGE_NAME=bazzite-workstation-legacy-nvidia mise run build
```

Podman builds use repository root as context so each Containerfile can copy its image project and `packages/image-common`.

## Bootc deployment

These images are bootc container images. Use bootc commands for host deployment
and inspection:

```bash
sudo bootc switch --transport registry ghcr.io/zenobi-us/bazzite-workstation:latest
bootc status
sudo bootc rollback
```

`bootc switch` stages a new image deployment. Reboot to boot into it. Use
`bootc status` before and after a switch. Use `bootc rollback` when the new
deployment does not work. Use `rpm-ostree rebase` only for systems that still
require the rpm-ostree compatibility workflow; it is not the default for these
bootc images.

## Available images

- `bazzite-workstation` — the standard customized workstation image.
- `bazzite-workstation-legacy-nvidia` — a proprietary NVIDIA variant intended
  for legacy Pascal/GP107 hardware. See its
  [`README.md`](images/bazzite-workstation-legacy-nvidia/README.md) for driver
  checks and post-boot validation.

## Add an image

Create a new `images/<id>/` project with a `mise.toml` and image-specific build files,
using `templates/image/` as the scaffold. The image `mise.toml` wires its tasks to
`.mise/tasks/image/` and overrides `IMAGE_NAME` and `IMAGE_PROJECT` for the image.
Then:

1. Add image-specific scripts under `images/<id>/build.d/`.
2. Set registry owner in `images/<id>/disk/iso.toml`.
3. Add the image entry to matrices in `.github/workflows/build.yml` and `.github/workflows/build-disk.yml`.
4. Run `mise run //images/<id>:build`.

Every image Containerfile must retain `RUN bootc container lint`.

## Signing

Keep `cosign.key` local and ignored. Store private key in GitHub Actions secret `SIGNING_SECRET`; commit only `cosign.pub`.
