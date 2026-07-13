#!/bin/bash

set -ouex pipefail

#### Enable Podman
systemctl enable podman.socket
