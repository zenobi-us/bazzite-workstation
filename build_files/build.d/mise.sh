#!/bin/bash

set -ouex pipefail

dnf5 -y copr enable jdxcode/mise
dnf5 -y install mise
dnf5 -y copr disable jdxcode/mise

cat > /etc/profile.d/mise.sh <<'EOF'
# Enable mise for interactive bash shells.
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
EOF
