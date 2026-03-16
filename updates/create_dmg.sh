#!/bin/bash

set -e

APP="ComfyDrop.app"
APPCAST="appcast.xml"
DMG="ComfyDrop-Installer.dmg"
BUILD_TEMP="BUILD-TEMP"
DERIVED_DATA_DIR="${HOME}/Library/Developer/Xcode/DerivedData"

if ! [ -d "$APP" ]; then
    echo "$APP Not Found"
    exit 1
fi

if [ -f "$DMG" ]; then
    rm -rf "$DMG"
fi

cleanup() {
    current_dir=$(basename "$(pwd)")

    if [ "$current_dir" = "$BUILD_TEMP" ]; then
        cd ..
    fi

    if [ -d "$BUILD_TEMP" ]; then
        echo "Cleaning up temp files..."
        rm -rf "$BUILD_TEMP"
    fi
}
trap cleanup EXIT

generate_appcast=$(find "$DERIVED_DATA_DIR" -path '*ComfyDrop-*/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast' -print -quit)

if ! [ -x "$generate_appcast" ]; then
    echo "generate_appcast Not Found"
    exit 1
fi


codesign --verify --deep --strict "$APP"
spctl --assess --type exec "$APP"


mkdir -p "$BUILD_TEMP"
ditto "$APP" "$BUILD_TEMP/$APP"

cd "$BUILD_TEMP"

create-dmg \
    --volname "ComfyDrop Installer" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "$APP" 200 190 \
    --hide-extension "$APP" \
    --app-drop-link 600 185 \
    "$DMG" \
    "./"

"$generate_appcast" "$(pwd)"

mv "$APPCAST" ../
mv "$DMG" ../
cd ..

echo "Built Successfuly"

echo "Verifying Signature"
codesign --verify --deep --strict /Volumes/ComfyDrop\ Installer/ComfyDrop.app

