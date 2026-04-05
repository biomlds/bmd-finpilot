#!/usr/bin/bash

set -eoux pipefail

###############################################################################
# River Desktop - Lightweight Wayland Compositor
###############################################################################
# River is a dynamic tiling Wayland compositor written in Zig.
# This script installs River with greetd login manager and foot terminal.
###############################################################################

# Source helper functions
# shellcheck source=/dev/null
source /ctx/build/copr-helpers.sh

echo "::group:: Install River Desktop"

# Install River (compositor), greetd (login manager), foot (terminal), tuigreet (greeter UI)
dnf5 install -y \
    river \
    greetd \
    foot \
    tuigreet

echo "River desktop packages installed"
echo "::endgroup::"

echo "::group:: Configure Greetd Login Manager"

# Configure greetd for River session
mkdir -p /etc/greetd
cat > /etc/greetd/config.toml << 'GREETD'
[terminal]
vt = 1

[default_session]
command = "/usr/bin/river"
user = "greeter"
GREETD

echo "Greetd configured for River"
echo "::endgroup::"

echo "::group:: Create River Session File"

# Create X11 session file for River (required by some login managers)
mkdir -p /etc/X11/sessions
cat > /etc/X11/sessions/river.desktop << 'RIVERSESSION'
[Desktop Entry]
Name=River
Comment=Dynamic Tiling Wayland Compositor
Exec=river
Type=Application
DesktopNames=River
RIVERSESSION

echo "River session file created"
echo "::endgroup::"

echo "::group:: Enable Display Manager and Set Default Target"

# Enable greetd display manager
systemctl enable greetd

# Set graphical target for boot
systemctl set-default graphical.target

echo "Display manager enabled, graphical target set"
echo "::endgroup::"

echo "River desktop installation complete!"
echo "After booting, you will be greeted with tuigreet, then River will start"