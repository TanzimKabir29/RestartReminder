#!/bin/bash
# Usage: ./make_icon.sh path/to/icon.png
# Requires a 1024x1024 PNG source image.
set -e

SOURCE="$1"
if [ -z "$SOURCE" ] || [ ! -f "$SOURCE" ]; then
    echo "Usage: ./make_icon.sh path/to/icon.png"
    echo "Source image must be a 1024x1024 PNG."
    exit 1
fi

ICONSET="Build/AppIcon.iconset"
mkdir -p "$ICONSET"

sips -z 16   16   "$SOURCE" --out "$ICONSET/icon_16x16.png"    > /dev/null
sips -z 32   32   "$SOURCE" --out "$ICONSET/icon_16x16@2x.png" > /dev/null
sips -z 32   32   "$SOURCE" --out "$ICONSET/icon_32x32.png"    > /dev/null
sips -z 64   64   "$SOURCE" --out "$ICONSET/icon_32x32@2x.png" > /dev/null
sips -z 128  128  "$SOURCE" --out "$ICONSET/icon_128x128.png"      > /dev/null
sips -z 256  256  "$SOURCE" --out "$ICONSET/icon_128x128@2x.png"   > /dev/null
sips -z 256  256  "$SOURCE" --out "$ICONSET/icon_256x256.png"      > /dev/null
sips -z 512  512  "$SOURCE" --out "$ICONSET/icon_256x256@2x.png"   > /dev/null
sips -z 512  512  "$SOURCE" --out "$ICONSET/icon_512x512.png"      > /dev/null
cp "$SOURCE"                    "$ICONSET/icon_512x512@2x.png"

iconutil -c icns "$ICONSET" -o Resources/AppIcon.icns
rm -rf "$ICONSET"

echo "Done → Resources/AppIcon.icns"
