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

## Testing image

`bazzite-workstation-testing` is a separate Fedora 45 NVIDIA GNOME image.
It follows `ghcr.io/ublue-os/bazzite-gnome-nvidia:testing-45`; the stable image keeps its existing base.
The testing image reuses `packages/image-common`, including the shared workstation scripts.
It does not inherit the upstream DX developer tool bundle.

Build and lint the testing project:

```bash
mise run //images/bazzite-workstation-testing:lint
mise run //images/bazzite-workstation-testing:build
```

The container workflow publishes it separately as `ghcr.io/zenobi-us/bazzite-workstation-testing:latest`.
Disk builds use its own installer target, artifact names, and S3 prefix.
The existing stable image and installer target remain unchanged.

After the workflow publishes the image, switch an existing workstation:

```bash
sudo bootc switch --transport registry ghcr.io/zenobi-us/bazzite-workstation-testing:latest
systemctl reboot
```

Testing updates can break graphics, login, or other desktop features. Keep a working rollback deployment.
To return to the previous deployment, run `sudo bootc rollback` and reboot.
To select the stable image explicitly, run `sudo bootc switch --transport registry ghcr.io/zenobi-us/bazzite-workstation:latest` and reboot.

### Deskflow clipboard support

The image build requires GNOME Shell, Mutter, and the GNOME portal to be version 51 or newer.
The Fedora 45 base supplies the coordinated compositor and portal changes that GNOME 50 lacks.
See the [GNOME portal 51 implementation](https://github.com/GNOME/xdg-desktop-portal-gnome/blob/51.0/src/inputcapture.c).

After booting the testing image, check the active portal:

```bash
gdbus call --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.DBus.Properties.Get \
  org.freedesktop.portal.InputCapture version
```

Expect version 2 or higher; upstream GNOME portal 51 advertises version 3.
Restart Deskflow, approve clipboard access if prompted, and test text copy/paste in both directions.
An image build cannot verify clipboard transfer in a live GNOME session.

The shared scripts install `zsh` explicitly before selecting it as the default shell.
The full build passes `bootc container lint` with warnings from the existing customizations: `/run/dnf`, the ZeroTier account, and files under `/var`.
In particular, application files baked into `/var` do not replace existing deployment state automatically.
Review these warnings before deployment; this variant does not change the shared application storage layout.
