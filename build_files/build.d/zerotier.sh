#!/bin/bash

set -ouex pipefail

# ZeroTier Service
cat > /etc/yum.repos.d/zerotier.repo <<'EOF'
[zerotier]
name=ZeroTier, Inc. RPM Release Repository
baseurl=https://download.zerotier.com/redhat/fc/$releasever
enabled=1
gpgcheck=1
gpgkey=https://download.zerotier.com/contact@zerotier.com.gpg
EOF
dnf5 -y install zerotier-one

# ZeroTier DNS client integration for systemd-resolved
install -Dm755 assets.d/zerotier/zerotier-resolved/zerotier-resolved.py /usr/libexec/zerotier-resolved/zerotier-resolved.py
install -Dm644 assets.d/zerotier/zerotier-resolved/zerotier-resolved@.service /usr/lib/systemd/system/zerotier-resolved@.service
systemctl enable zerotier-one.service
rm /etc/yum.repos.d/zerotier.repo

cp assets.d/zerotier/zt /usr/bin/zt
chmod +x /usr/bin/zt
