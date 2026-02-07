#!/bin/bash

# Kill any existing AppPad processes
echo "Stopping any existing AppPad process..."
pkill -f "AppPad" || true
sleep 1

# Build the app
echo "Building AppPad..."
cd /Users/yingbin/Downloads/Projects/AppPad
swift build

if [ $? -eq 0 ]; then
    echo "✓ Build successful"
    echo ""
    echo "Starting AppPad..."
    echo "Please use your hotkey to open the launcher and test:"
    echo "  1. Click search field and try typing"
    echo "  2. Create a folder by merging apps and try to edit its name"
    echo ""
    ./.build/debug/AppPad
else
    echo "✗ Build failed"
    exit 1
fi
