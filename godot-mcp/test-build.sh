#!/bin/bash

# Test Build Script for Godot MCP
echo "Testing Godot MCP Build..."
echo "========================="

cd "$(dirname "$0")/cli-server"

# Clear previous build
rm -rf build/
rm -f build.log

# Run the build
echo "Running TypeScript build..."
npm run build > build.log 2>&1

# Check result
if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    echo ""
    echo "Files created:"
    ls -la build/
else
    echo "❌ Build failed!"
    echo ""
    echo "Error output:"
    cat build.log
fi

echo ""
echo "Build log saved to: cli-server/build.log"
