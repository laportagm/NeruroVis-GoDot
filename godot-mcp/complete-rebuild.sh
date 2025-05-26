#!/bin/bash

echo "Complete Godot MCP Rebuild"
echo "========================="
echo ""

cd "$(dirname "$0")/cli-server"

# Clean previous build
echo "1. Cleaning previous build..."
rm -rf build/
rm -f *.log

# Install/update dependencies
echo ""
echo "2. Installing dependencies..."
npm install

# Run TypeScript build
echo ""
echo "3. Building TypeScript..."
npm run build

# Check result
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Build successful!"
    echo ""
    
    if [ -f "build/index.js" ]; then
        echo "✅ Main output file created: build/index.js"
        echo ""
        echo "Build directory contents:"
        ls -la build/
    else
        echo "⚠️  Warning: build/index.js not found"
    fi
else
    echo ""
    echo "❌ Build failed!"
    exit 1
fi

echo ""
echo "Rebuild complete!"
