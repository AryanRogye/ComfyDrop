#!/bin/bash

BUILD_DIR="/tmp/comfydrop-build"
APP_NAME="ComfyDrop.app"

xcodebuild \
  -scheme ComfyDrop \
  -configuration Release \
  -derivedDataPath "$BUILD_DIR"

SRC="$BUILD_DIR/Build/Products/Release/$APP_NAME"
DEST="./$APP_NAME"

# Remove old app only if it exists
if [ -d "$DEST" ]; then
    rm -rf "$DEST"
fi

# Move new build
mv "$SRC" "$DEST"

open .
