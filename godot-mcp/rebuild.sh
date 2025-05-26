#!/bin/bash

cd "$(dirname "$0")/cli-server"

echo "Building Godot MCP server..."
npm run build

if [ $? -eq 0 ]; then
    echo "Build successful!"
else
    echo "Build failed!"
    exit 1
fi
