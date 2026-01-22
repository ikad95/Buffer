#!/bin/bash

# Buffer Setup Script
# Builds, installs, and launches Buffer

set -e

echo "Building Buffer..."
xcodebuild -project Buffer.xcodeproj -scheme Buffer -configuration Release -derivedDataPath build build 2>&1 | grep -E "(error:|warning:|BUILD)" | tail -5

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Stopping existing Buffer instance..."
pkill -x Buffer 2>/dev/null || true
sleep 1

echo "Installing to /Applications..."
rm -rf /Applications/Buffer.app
cp -R build/Build/Products/Release/Buffer.app /Applications/

echo "Updating local .app..."
rm -rf Buffer.app
cp -R build/Build/Products/Release/Buffer.app .

echo "Launching Buffer..."
open /Applications/Buffer.app

echo "Done! Buffer is now running."
