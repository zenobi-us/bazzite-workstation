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

# Join a configured network and apply its ZeroTier DNS settings after the daemon starts.
install -Dm755 assets.d/zerotier/zerotier-join /usr/bin/zerotier-join
install -Dm644 assets.d/zerotier/zerotier-join@.service /usr/lib/systemd/system/zerotier-join@.service
systemctl enable zerotier-one.service
rm /etc/yum.repos.d/zerotier.repo

cp assets.d/zerotier/zt /usr/bin/zt
chmod +x /usr/bin/zt
