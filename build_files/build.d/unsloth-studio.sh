#!/bin/bash
set -ouex pipefail

# =============================================
# Install Unsloth Studio in Fedora Atomic Image
# =============================================

APP_DIR="${APPLICATIONS_DIR:-/var/opt}/unsloth"
UNSLOTH_HOME="${APPLICATIONS_DIR:-/var/opt}/unsloth-home"
SERVICE_NAME="unsloth-studio"
SERVICE_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

# Build dependencies for GGUF engine + general build
BUILD_DEPS=(
    cmake
    gcc
    gcc-c++
    make
    libcurl-devel
    python3-devel
    git
    # Recommended for better performance / CUDA if you have NVIDIA drivers layered
    # cuda-toolkit  # uncomment if you layer CUDA separately
)

function install_dependencies() {
    echo "Installing build dependencies with dnf5..."
    dnf5 install -y "${BUILD_DEPS[@]}"
    echo "✅ Build dependencies installed."
}

function install_unsloth() {
    export HOME="$UNSLOTH_HOME"
    mkdir -p "$HOME"
    echo "Cloning / updating Unsloth repository at $APP_DIR..."
    if [ -d "$APP_DIR" ]; then
        echo "Directory exists → pulling latest..."
        cd "$APP_DIR" && git pull --ff-only
    else
        git clone https://github.com/unslothai/unsloth "$APP_DIR"
        cd "$APP_DIR"
    fi

    echo "Running Unsloth local installation..."
    ./install.sh --local
    chown -R root:root "$APP_DIR" "$UNSLOTH_HOME"
}

function create_systemd_service() {
    echo "Creating systemd service..."

    cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Unsloth Studio Web UI
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=$APP_DIR
# Unsloth Studio installs the CLI into a HOME-local venv during image build.
ExecStart=$UNSLOTH_HOME/.unsloth/studio/unsloth_studio/bin/unsloth studio -H 0.0.0.0 -p 8888

Restart=always
RestartSec=5
Environment=HOME=$UNSLOTH_HOME
Environment=PATH=$UNSLOTH_HOME/.unsloth/studio/unsloth_studio/bin:/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

    echo "✅ Systemd service created: $SERVICE_NAME"
    echo "   After image boot, run:"
    echo "   systemctl enable --now $SERVICE_NAME"
}

function main() {
    install_dependencies
    install_unsloth
    create_systemd_service
}

main
