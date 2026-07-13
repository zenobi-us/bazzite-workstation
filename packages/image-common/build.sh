#!/usr/bin/bash

set -ouex pipefail

common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
image_dir="${1:?image customization directory required}"

export APPLICATIONS_DIR=/var/opt
mkdir -p "$APPLICATIONS_DIR"

cd "$common_dir"
for script in build.d/*.sh; do
    bash "$script"
done

if compgen -G "$image_dir/build.d/*.sh" >/dev/null; then
    cd "$image_dir"
    for script in build.d/*.sh; do
        bash "$script"
    done
fi