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

# ZeroTier Nameserver Daemon
ZT_SYSTEMD_MANAGER_RPM=/tmp/zerotier-systemd-manager_0.4.0_linux_amd64.rpm
curl -fL -o "$ZT_SYSTEMD_MANAGER_RPM" https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.4.0/zerotier-systemd-manager_0.4.0_linux_amd64.rpm
rpm -i --noscripts "$ZT_SYSTEMD_MANAGER_RPM"
systemctl enable zerotier-one.service
systemctl enable zerotier-systemd-manager.timer
rm "$ZT_SYSTEMD_MANAGER_RPM"
rm /etc/yum.repos.d/zerotier.repo

cp assets.d/zerotier/zt /usr/bin/zt
chmod +x /usr/bin/zt
