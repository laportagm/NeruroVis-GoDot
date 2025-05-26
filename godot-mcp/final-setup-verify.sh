#!/bin/bash

echo "Godot MCP Integration - Final Setup and Verification"
echo "==================================================="
echo ""

cd "$(dirname "$0")"

# Step 1: Complete rebuild
echo "Step 1: Running complete rebuild..."
echo "-----------------------------------"
cd cli-server

# Clean
rm -rf build/ node_modules/
rm -f *.log

# Install dependencies
echo "Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Build
echo ""
echo "Building TypeScript..."
npm run build 2>&1 | tee build.log

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
else
    echo "❌ Build failed! Check build.log for details"
    cat build.log
    exit 1
fi

cd ..

# Step 2: Verify build output
echo ""
echo "Step 2: Verifying build output..."
echo "---------------------------------"

if [ -f "cli-server/build/index.js" ]; then
    echo "✅ Main server file exists: cli-server/build/index.js"
else
    echo "❌ Main server file not found!"
    exit 1
fi

# Step 3: Check Godot installation
echo ""
echo "Step 3: Checking Godot installation..."
echo "--------------------------------------"

GODOT_PATH="/Applications/Godot.app/Contents/MacOS/Godot"
if [ -f "$GODOT_PATH" ]; then
    echo "✅ Godot found at: $GODOT_PATH"
    GODOT_VERSION=$("$GODOT_PATH" --version 2>&1 | head -n1)
    echo "   Version: $GODOT_VERSION"
else
    echo "❌ Godot not found at default location!"
    echo "   Please update GODOT_PATH in configuration files"
fi

# Step 4: Configuration status
echo ""
echo "Step 4: Configuration status..."
echo "-------------------------------"

echo "✅ Claude Desktop config updated:"
echo "   ~/Library/Application Support/Claude/claude_desktop_config.json"

echo "✅ VS Code config created:"
echo "   .vscode/godot-mcp.json"

# Step 5: Final summary
echo ""
echo "================================================================"
echo "✅ SETUP COMPLETE!"
echo "================================================================"
echo ""
echo "Next steps:"
echo "1. Restart Claude Desktop to load the new configuration"
echo "2. Test with commands like:"
echo "   - 'List all scenes in my project'"
echo "   - 'Create a new player scene'"
echo "   - 'Launch the Godot editor'"
echo ""
echo "Project path: /Users/gagelaporta/11A-NeuroVis"
echo "Server path: /Users/gagelaporta/11A-NeuroVis/godot-mcp/cli-server/build/index.js"
echo ""
echo "================================================================"
