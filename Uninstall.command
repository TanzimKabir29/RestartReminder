#!/bin/bash

echo "Stopping service..."
launchctl bootout "gui/$(id -u)" ~/Library/LaunchAgents/com.tanzimk.restartreminder.plist 2>/dev/null || \
launchctl unload ~/Library/LaunchAgents/com.tanzimk.restartreminder.plist 2>/dev/null || true

echo "Killing running app..."
killall restart-reminder 2>/dev/null

echo "Removing files..."
rm -f ~/Library/LaunchAgents/com.tanzimk.restartreminder.plist
rm -rf "/Applications/RestartReminder.app"
rm -rf ~/Library/Application\ Support/RestartReminder
rm -f ~/Library/Preferences/com.tanzimk.restartreminder.plist

echo "Refreshing system caches..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u /Applications/RestartReminder.app 2>/dev/null

echo "Done. Fully uninstalled."
