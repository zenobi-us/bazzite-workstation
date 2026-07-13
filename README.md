# bazzite-workstation images

Moonrepo workspace for building bootc images from shared customizations.

## Layout

- `images/<id>/` — image Containerfile, image-only build scripts, disk configs, and `moon.yml`
- `packages/image-common/` — build scripts and assets shared by every image
- `templates/image/` — scaffold used by `moon generate image`
- `.github/workflows/` — OCI and disk-image build matrices

## Build

```bash
moon query projects
moon run bazzite-workstation:build
moon run :lint
```

Podman builds use repository root as context so each Containerfile can copy its image project and `packages/image-common`.

Existing `just` commands target `bazzite-workstation` by default:

```bash
just build
just rebuild-qcow2
just rebuild-iso
```

Select another project with environment variables:

```bash
IMAGE_PROJECT=my-image IMAGE_NAME=my-image just build
```

## Add an image

```bash
moon generate image
```

Then:

1. Add image-specific scripts under `images/<id>/build.d/`.
2. Set registry owner in `images/<id>/disk/iso.toml`.
3. Add image entry to matrices in `.github/workflows/build.yml` and `.github/workflows/build-disk.yml`.
4. Run `moon run <id>:build`.

Every image Containerfile must retain `RUN bootc container lint`.

## Signing

Keep `cosign.key` local and ignored. Store private key in GitHub Actions secret `SIGNING_SECRET`; commit only `cosign.pub`.
