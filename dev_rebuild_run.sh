#!/bin/bash
killall devtest 2>/dev/null; sleep 0.5

swiftc Sources/main.swift -o Build/Dev.app/Contents/MacOS/devtest \
  -framework Cocoa \
  -framework UserNotifications

[ -f Resources/AppIcon.icns ] && cp Resources/AppIcon.icns Build/Dev.app/Contents/Resources/

codesign --force --deep -s - Build/Dev.app

open Build/Dev.app
