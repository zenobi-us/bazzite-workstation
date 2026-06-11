#!/bin/bash

set -ouex pipefail

# ZeroTier Service
sudo tee >/dev/null /etc/yum.repos.d/zerotier.repo <<'EOF'
[zerotier]
name=ZeroTier, Inc. RPM Release Repository
baseurl=https://download.zerotier.com/redhat/fc/$releasever
enabled=1
gpgcheck=1
gpgkey=https://download.zerotier.com/contact@zerotier.com.gpg
EOF
dnf5 -y install zerotier-one
systemctl enable zerotier-systemd-manager.timer

# ZeroTier Nameserver Daemon
curl -fLO https://github.com/zerotier/zerotier-systemd-manager/releases/download/v0.4.0/zerotier-systemd-manager_0.4.0_linux_amd64.rpm
dnf5 -y install ./zerotier-systemd-manager_0.4.0_linux_amd64.rpm
systemctl enable zerotier-one
rm ./zerotier-systemd-manager_0.4.0_linux_amd64.rpm

cp assets.d/zerotier/zt /usr/local/bin/zt
chmod +x /usr/local/bin/zt
