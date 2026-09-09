#!/bin/bash

set -ouex pipefail

# Install zsh explicitly because the contents of the Bazzite base image can
# change independently of this image.
dnf5 install -y zsh

# Use zsh for accounts created after the image is built.
useradd -D --shell /usr/bin/zsh
