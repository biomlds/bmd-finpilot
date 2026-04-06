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
    wl-clipboard \
    dmenu

echo "Sway desktop packages installed"
echo "::endgroup::"

echo "::group:: Configure Greetd Login Manager"

# Configure greetd for Sway session with login prompt
mkdir -p /etc/greetd
cat > /etc/greetd/config.toml << 'GREETD'
[terminal]
vt = 1

[default_session]
command = "tuigreet -- cmd /usr/bin/sway -c /etc/sway/config"
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

echo "::group:: Create Sway Configuration"

# Create Sway configuration directory
mkdir -p /etc/sway

# Create Sway config with basic keybindings
cat > /etc/sway/config << 'SWAYCONFIG'
# Default terminal
set $term foot

# Mod key (Windows key)
set $mod Mod4

# Start dmenu
bindsym $mod+d exec dmenu_run

# Keybindings
bindsym $mod+Return exec $term
bindsym $mod+q kill
bindsym $mod+space floating toggle
bindsym $mod+f fullscreen toggle
bindsym $mod+Shift+c reload
bindsym $mod+Shift+e exit

# Focus keybindings
bindsym $mod+h focus left
bindsym $mod+j focus down
bindsym $mod+k focus up
bindsym $mod+l focus right

# Move keybindings
bindsym $mod+Shift+h move left
bindsym $mod+Shift+j move down
bindsym $mod+Shift+k move up
bindsym $mod+Shift+l move right

# Tag keybindings (Super+1 through Super+9)
bindsym $mod+1 workspace 1
bindsym $mod+2 workspace 2
bindsym $mod+3 workspace 3
bindsym $mod+4 workspace 4
bindsym $mod+5 workspace 5
bindsym $mod+6 workspace 6
bindsym $mod+7 workspace 7
bindsym $mod+8 workspace 8
bindsym $mod+9 workspace 9

# Move container to tag
bindsym $mod+Shift+1 move container to workspace 1
bindsym $mod+Shift+2 move container to workspace 2
bindsym $mod+Shift+3 move container to workspace 3
bindsym $mod+Shift+4 move container to workspace 4
bindsym $mod+Shift+5 move container to workspace 5
bindsym $mod+Shift+6 move container to workspace 6
bindsym $mod+Shift+7 move container to workspace 7
bindsym $mod+Shift+8 move container to workspace 8
bindsym $mod+Shift+9 move container to workspace 9

# Screenshot keybinding (Super+Shift+S)
bindsym $mod+Shift+s exec grim -g "$(slurp)" -

# Input configuration
input * {
    xkb_layout us
    xkb_variant altgr-intl
}

# Output configuration
output * bg #1a1a2e solid_color
SWAYCONFIG

echo "Sway configuration created"
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