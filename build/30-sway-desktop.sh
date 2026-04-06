#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# Sway Desktop - i3-compatible Wayland Compositor
###############################################################################
# Sway is a drop-in replacement for i3 window manager using Wayland.
# This script installs Sway with greetd login manager.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Install Sway Desktop"

# Install Sway and related packages
dnf5 install -y \
    sway \
    swaylock \
    swaybg \
    foot \
    tuigreet \
    grim \
    slurp \
    wl-clipboard

echo "Sway desktop packages installed"
echo "::endgroup::"

echo "::group:: Configure Greetd Login Manager"

# Configure greetd for Sway session
mkdir -p /etc/greetd
cat > /etc/greetd/config.toml << 'GREETD'
[terminal]
vt = 1

[default_session]
command = "/usr/bin/sway"
user = "greeter"
GREETD

echo "Greetd configured for Sway"
echo "::endgroup::"

echo "::group:: Create Sway User"

# Create greeter user for greetd
useradd -r -s /usr/bin/nologin greeter || true
id greeter || echo "greeter user creation note"

echo "Greeter user configured"
echo "::endgroup::"

echo "::group:: Create Sway Session File"

# Create X11 session file for Sway (required by some login managers)
mkdir -p /etc/X11/sessions
cat > /etc/X11/sessions/sway.desktop << 'SWAYSESSION'
[Desktop Entry]
Name=Sway
Comment=i3-compatible Wayland Compositor
Exec=sway
Type=Application
DesktopNames=Sway
SWAYSESSION

echo "Sway session file created"
echo "::endgroup::"

echo "::group:: Enable Display Manager and Set Default Target"

# Enable greetd display manager
systemctl enable greetd

# Set graphical target for boot
systemctl set-default graphical.target

echo "Display manager enabled, graphical target set"
echo "::endgroup::"

echo "Sway desktop installation complete!"
echo "After booting, you will be greeted with tuigreet, then Sway will start"