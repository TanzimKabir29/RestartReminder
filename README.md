# RestartReminder

A lightweight macOS menu bar app that tracks system uptime and reminds you to restart when your Mac has been running too long.

---

## What it does

- Shows live uptime (e.g. `3d 14h 22m`) in the menu bar
- Sends a notification when uptime exceeds your configured threshold (default: 14 days)
- Re-notifies once per day until you restart
- Starts automatically at login via a LaunchAgent
- Lets you adjust the reminder threshold without editing any files

---

## Install

### Requirements

- macOS 12 or later

### Steps

1. Download **`RestartReminder.pkg`** and **`Install.command`** from the [latest release](../../releases/latest) — keep both files in the same folder
2. Double-click **`Install.command`**
3. Confirm the dialog and enter your Mac password when prompted
4. Look for the uptime counter in your menu bar — it's running

> The installer copies the app to `/Applications`, registers a LaunchAgent so it starts at login, and copies the default config to `~/Library/Application Support/RestartReminder/`.

---

## Configure

Click the uptime display in the menu bar → **Set Reminder Threshold...**

Enter the number of days after which you want to be reminded. The change takes effect immediately and persists across reboots.

You can also edit the config file directly:

```
~/Library/Application Support/RestartReminder/config.json
```

```json
{ "days": 14 }
```

Fractional values are supported (e.g. `0.5` for 12 hours).

---

## Uninstall

Double-click **`Uninstall.command`** (included in the release download).

This stops the LaunchAgent, removes the app from `/Applications`, and cleans up all associated files.

---

## Notification permissions

On first launch, macOS will ask for notification permission. If you missed the prompt, go to:

**System Settings → Notifications → RestartReminder** and enable notifications there.

---

## Development

### Build and run (dev)

```bash
bash dev_rebuild_run.sh
```

Compiles, signs, and launches the dev app (`Build/Dev.app`). The dev build uses bundle ID `com.dev.restartreminder` and appears as **DevTest** in Notification settings.

### Create a release package

```bash
bash release.sh
```

Produces `RestartReminder.pkg` and uses the existing `Install.command`. Share both files with colleagues, or push to `main` to trigger an automated build via GitHub Actions.

### App icon

To update the icon, provide a 1024×1024 PNG and run:

```bash
./make_icon.sh path/to/icon.png
```

This generates `Resources/AppIcon.icns`, which is automatically picked up by both build scripts.

### Test notifications without waiting 14 days

```bash
# Lower the threshold temporarily
echo '{ "days": 0.001 }' > ~/Library/Application\ Support/RestartReminder/config.json

# Clear the last-notified state
defaults delete com.dev.restartreminder lastNotifiedDate 2>/dev/null; true

# Rebuild and launch
bash dev_rebuild_run.sh
```

Reset after testing:

```bash
echo '{ "days": 14 }' > ~/Library/Application\ Support/RestartReminder/config.json
```

---

## Project structure

```
Sources/main.swift                        — App source code
Resources/
  config.json                             — Default config (days threshold)
  com.tanzimk.restartreminder.plist       — LaunchAgent definition
  AppIcon.icns                            — App icon
Scripts/
  postinstall                             — Runs after pkg install
Build/
  Dev.app/Contents/Info.plist             — Dev app bundle config (tracked)
release.sh                                — Builds the release pkg
dev_rebuild_run.sh                        — Builds and launches the dev app
make_icon.sh                              — Converts a PNG to AppIcon.icns
Install.command                           — User-facing installer wrapper
Uninstall.command                         — Full uninstaller
```
