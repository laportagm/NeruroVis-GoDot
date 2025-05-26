#!/bin/bash

cd "$(dirname "$0")/cli-server"

echo "Rebuilding Godot MCP server..."
echo "=========================="

# Run the build and capture output
npm run build 2>&1 | tee build.log

# Check exit status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "Build successful!"
    echo ""
    
    # Test if the build output exists
    if [ -f "build/index.js" ]; then
        echo "Output file created successfully: build/index.js"
    else
        echo "Warning: build/index.js not found"
    fi
else
    echo ""
    echo "Build failed! Check build.log for details"
    exit 1
fi
