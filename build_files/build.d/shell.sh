#!/bin/bash

set -ouex pipefail

# Bazzite already includes zsh; set the shell used by future useradd-created accounts.
useradd -D --shell /usr/bin/zsh
