#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable jdxcode/mise
dnf5 -y install mise
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
