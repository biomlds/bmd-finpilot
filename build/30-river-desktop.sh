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
    tuigreet \
    grim \
    slurp

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

echo "::group:: Create River User and Config"

# Create greeter user for greetd
useradd -r -s /sbin/nologin greeter || true

# Create River configuration directory
mkdir -p /etc/river

# Create River init script with basic keybindings and auto-start
cat > /etc/river/init << 'RIVERINIT'
#!/bin/sh
# Start rivertile layout generator
rivertile -view-padding 10 -outer-padding 10 &

# Custom keybindings
riverctl map normal Super Return spawn 'foot'
riverctl map normal Super Q close
riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous
riverctl map normal Super Space toggle-float
riverctl map normal Super F toggle-fullscreen

# Mod+number to switch tags
riverctl map normal Super 1 set-focused-tag 1
riverctl map normal Super 2 set-focused-tag 2
riverctl map normal Super 3 set-focused-tag 3
riverctl map normal Super 4 set-focused-tag 4
riverctl map normal Super 5 set-focused-tag 5
riverctl map normal Super 6 set-focused-tag 6
riverctl map normal Super 7 set-focused-tag 7
riverctl map normal Super 8 set-focused-tag 8
riverctl map normal Super 9 set-focused-tag 9

# Mod+Shift+number to move window to tag
riverctl map normal Super+Shift 1 send-to-tag 1
riverctl map normal Super+Shift 2 send-to-tag 2
riverctl map normal Super+Shift 3 send-to-tag 3
riverctl map normal Super+Shift 4 send-to-tag 4
riverctl map normal Super+Shift 5 send-to-tag 5
riverctl map normal Super+Shift 6 send-to-tag 6
riverctl map normal Super+Shift 7 send-to-tag 7
riverctl map normal Super+Shift 8 send-to-tag 8
riverctl map normal Super+Shift 9 send-to-tag 9

# Start foot terminal immediately
foot &
RIVERINIT

chmod +x /etc/river/init

echo "River configuration created"
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