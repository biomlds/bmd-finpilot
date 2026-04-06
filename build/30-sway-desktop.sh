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
    wofi \
    waybar

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

# Create Sway config with Catppuccin Frappé theme
cat > /etc/sway/config << 'SWAYCONFIG'
# Catppuccin Frappé Theme Colors
set $base     #303030
set $mantle   #323232  
set $crust    #262626
set $text     #CBD5E1
set $subtext  #A6ADC8
set $blue     #89B4FA
set $red      #F38BA8
set $green    #A6E3A1
set $yellow   #F9E2AF
set $peach    #FAB387
set $mauve    #CBA6F7
set $sky      #89DCEB

# Default terminal
set $term foot

# Mod key (Windows key)
set $mod Mod4

# Gaps
smart_gaps on
gaps inner 8
gaps outer 4

# Window borders
default_border normal 2
default_floating_border normal 2
hide_edge_borders smart

# Colors
client.focused           $blue    $mantle  $text   $mauve
client.focused_inactive $mantle  $mantle  $subtext $crust
client.unfocused        $crust   $crust   $subtext $crust
client.urgent           $red     $red     $text   $red

# Start wofi launcher
bindsym $mod+d exec wofi --show drun
bindsym $mod+Shift+d exec wofi --show run

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

# Screenshot to clipboard
bindsym Print exec grim -o - | wl-copy

# Input configuration
input * {
    xkb_layout us
    xkb_variant altgr-intl
}

# Output configuration
output * bg #303030 solid_color

# Autostart
exec_always waybar

# Startup
exec foot
SWAYCONFIG

echo "Sway configuration created"
echo "::endgroup::"

echo "::group:: Configure Waybar"

# Create waybar configuration directory
mkdir -p /etc/waybar

# Create waybar config
cat > /etc/waybar/config << 'WAYBARCONFIG'
{
    "layer": "top",
    "modules-left": ["sway/workspaces"],
    "modules-right": ["clock", "cpu", "memory", "network"],
    "sway/workspaces": {
        "disable-scroll": false,
        "all-outputs": true
    },
    "clock": {
        "format": "{:%H:%M}",
        "format-alt": "{:%Y-%m-%d}"
    },
    "cpu": {
        "interval": 10,
        "format": " {}%"
    },
    "memory": {
        "interval": 30,
        "format": " {}%"
    },
    "network": {
        "format-wifi": " {}%",
        "format-ethernet": "有线"
    }
}
WAYBARCONFIG

# Create waybar style - Catppuccin Frappé
cat > /etc/waybar/style.css << 'WAYBARSTYLE'
* {
    font-family: "JetBrainsMono Nerd Font", monospace;
    font-size: 12px;
}

window#waybar {
    background: #323232;
    color: #CBD5E1;
}

#workspaces {
    padding: 0 8px;
}

#workspaces button {
    color: #A6ADC8;
    padding: 0 4px;
}

#workspaces button.focused {
    color: #89B4FA;
}

#workspaces button.urgent {
    color: #F38BA8;
}

#clock, #cpu, #memory, #network {
    color: #CBD5E1;
    padding: 0 12px;
}

#cpu.warning {
    color: #F9E2AF;
}

#memory.warning {
    color: #FAB387;
}

#network.disconnected {
    color: #F38BA8;
}
WAYBARSTYLE

echo "Waybar configured"
echo "::endgroup::"

echo "::group:: Configure Foot Terminal"

# Create foot configuration directory
mkdir -p /etc/foot

# Create foot config with Catppuccin Frappé theme
cat > /etc/foot/foot.ini << 'FOOTCONFIG'
[main]
font=JetBrainsMono Nerd Font:size=11
pad=8x8

[colors]
background=303030
foreground=CBD5E1
regular0=6C7086  # gray
regular1=F38BA8  # red
regular2=A6E3A1  # green
regular3=F9E2AF  # yellow
regular4=89B4FA  # blue
regular5=CBA6F7  # mauve
regular6=94E2D5  # teal
regular7=CBD5E1  # text
bright0=585B70
bright1=F38BA8
bright2=A6E3A1
bright3=F9E2AF
bright4=89B4FA
bright5=CBA6F7
bright6=89DCEB
bright7=CCD5E1

[colors-selection]
background=45475A
foreground=CBD5E1

[colors-search-box-no-match]
background=F38BA8
foreground=303030

[colors-search-box-match]
background=A6E3A1
foreground=303030

[colors-scrollbar]
background=323232
foreground=585B70

[cursor]
style=beam

[csd]
button-width=32
button-height=32
button-spacing=4
button-padding-left=4
button-padding-right=4
button-background=323232
button-active-background=45475A
button-hover-background=45475A
button-minimize-icon=#A6ADC8
button-maximize-icon=#A6ADC8
close-icon=#F38BA8
title-font=JetBrainsMono Nerd Font:size=11
title-background=323232
title-foreground=CBD5E1

[scrollback]
lines=10000
FOOTCONFIG

echo "Foot terminal configured"
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