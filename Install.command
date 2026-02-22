#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PKG="$SCRIPT_DIR/RestartReminder.pkg"

if [ ! -f "$PKG" ]; then
    osascript -e 'display alert "Install failed" message "RestartReminder.pkg not found next to this script."'
    exit 1
fi

# Remove quarantine so macOS does not block the installer
xattr -d com.apple.quarantine "$PKG" 2>/dev/null || true

osascript -e 'display dialog "This will install RestartReminder on your Mac. It adds a menu bar item showing your system uptime and reminds you to restart after 14 days.\n\nClick Install to continue." buttons {"Cancel", "Install"} default button "Install" with title "RestartReminder Installer"' || exit 0

sudo installer -pkg "$PKG" -target / && \
    osascript -e 'display alert "Installed successfully" message "RestartReminder is now running. Look for it in your menu bar." as informational' || \
    osascript -e 'display alert "Install failed" message "Check that you entered the correct password." as critical'
