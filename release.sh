#!/bin/bash
set -e

echo "Compiling..."
swiftc Sources/main.swift -o Build/restart-reminder \
-framework Cocoa \
-framework UserNotifications

echo "Rebuilding bundle..."
rm -rf Build/RestartReminder.app || sudo rm -rf Build/RestartReminder.app
mkdir -p Build/RestartReminder.app/Contents/{MacOS,Resources}

cp Build/restart-reminder Build/RestartReminder.app/Contents/MacOS/
cp Resources/config.json Resources/com.tanzimk.restartreminder.plist Build/RestartReminder.app/Contents/Resources/

cat > Build/RestartReminder.app/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>restart-reminder</string>
    <key>CFBundleIdentifier</key>
    <string>com.tanzimk.restartreminder</string>
    <key>CFBundleName</key>
    <string>RestartReminder</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

[ -f Resources/AppIcon.icns ] && cp Resources/AppIcon.icns Build/RestartReminder.app/Contents/Resources/

echo "Signing bundle..."
codesign --force --deep -s - Build/RestartReminder.app

echo "Preparing pkgroot..."
rm -rf pkgroot || sudo rm -rf pkgroot
mkdir -p pkgroot/Applications
cp -R Build/RestartReminder.app pkgroot/Applications/

echo "Building pkg..."
rm -f RestartReminder.pkg
pkgbuild \
--root pkgroot \
--scripts Scripts \
--identifier com.tanzimk.restartreminder \
--version 1.0 \
RestartReminder.pkg

echo "Done → RestartReminder.pkg + Install.command"
echo "Share both files with colleagues."
