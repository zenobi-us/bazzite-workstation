# bazzite-workstation-legacy-nvidia

A Bazzite workstation image using the proprietary NVIDIA image variant for
legacy NVIDIA hardware such as the Pascal/GP107 GeForce GTX 1050 Mobile.

This image is separate from `bazzite-workstation` so the driver/base-image
choice can be validated without changing an existing deployment.

## Before building

The Containerfile currently uses:

```text
ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
```

This is the proprietary NVIDIA variant, not the NVIDIA Open variant. The
resolved driver and akmods must still be checked because Bazzite's `stable`
tag moves over time and not every current NVIDIA driver branch supports
Pascal hardware.

Inspect the candidate base image before building:

```bash
podman pull ghcr.io/ublue-os/bazzite-gnome-nvidia:stable
podman run --rm ghcr.io/ublue-os/bazzite-gnome-nvidia:stable \
  rpm -qa | grep -E '^nvidia|^akmod'
```

Do not deploy this image unless the reported NVIDIA driver branch supports
GP107/Pascal and the matching kernel modules are present.

## Build and lint

From the repository root:

```bash
mise run //images/bazzite-workstation-legacy-nvidia:build
mise run //images/bazzite-workstation-legacy-nvidia:lint
```

Or with the root convenience task:

```bash
IMAGE_PROJECT=bazzite-workstation-legacy-nvidia \
IMAGE_NAME=bazzite-workstation-legacy-nvidia \
mise run build
```

Every build must pass the `bootc container lint` step in the Containerfile.

## Validation after booting the image

After installing or switching to the image, confirm that the laptop's
integrated Intel GPU and NVIDIA Optimus GPU are detected correctly:

```bash
nvidia-smi
/usr/libexec/nvidia-legacy-hardware; echo $?
uname -r
rpm -qa | grep -E '^nvidia|^akmod'
journalctl -b -k | grep -iE 'nvidia|nouveau|firmware' | tail -100
```

Expected results:

- `nvidia-smi` succeeds and reports the GTX 1050 Mobile.
- `/usr/libexec/nvidia-legacy-hardware` exits with status `0`.
- The NVIDIA packages and kernel modules match the running kernel.
- `nouveau` is not unexpectedly active alongside the proprietary driver.
- Kernel logs do not show NVIDIA module, firmware, or initialization failures.

For this Optimus system, check the GPU layout as well:

```bash
lspci -nn | grep -E 'VGA compatible|3D controller'
lsmod | grep -E '^nvidia|^i915'
```

Then test PRIME Render Offload with the application that needs the NVIDIA
GPU. For FjordLauncher:

```bash
env \
  __NV_PRIME_RENDER_OFFLOAD=1 \
  __GLX_VENDOR_LIBRARY_NAME=nvidia \
  __VK_LAYER_NV_optimus=NVIDIA_only \
  flatpak run org.unmojang.FjordLauncher
```

If the application starts but still uses Intel graphics, inspect the
application's GPU information and verify the NVIDIA renderer with:

```bash
nvidia-smi
```

Do not add the Flatpak environment overrides permanently until the host
NVIDIA driver works and `nvidia-smi` succeeds.

## Failure criteria

Treat the image as incompatible with this hardware if any of the following
occur:

- `nvidia-smi` cannot communicate with the driver.
- The legacy detector does not return `0` for the GP107 GPU.
- The NVIDIA kernel module fails to load for the running kernel.
- Kernel logs report unsupported hardware or module/driver mismatches.
- PRIME Render Offload cannot start a known-good NVIDIA application.

If this happens, do not replace the existing `bazzite-workstation`
deployment. Record the driver package versions and kernel log output first;
the base image may need a different proprietary legacy-driver/akmods source.
