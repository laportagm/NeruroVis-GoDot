#!/bin/bash

# Godot MCP Setup Script
echo "Setting up Godot MCP integration..."

# Navigate to server directory
cd "$(dirname "$0")/cli-server" || exit

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "Error: npm is not installed. Please install Node.js and npm first."
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
npm install

# Build the TypeScript server
echo "Building server..."
npm run build

# Check if Godot is installed
GODOT_PATH="${GODOT_PATH:-/Applications/Godot.app/Contents/MacOS/Godot}"
if [ ! -f "$GODOT_PATH" ]; then
    echo "Warning: Godot not found at $GODOT_PATH"
    echo "Please set GODOT_PATH environment variable to your Godot executable"
fi

echo ""
echo "Setup complete!"
echo ""
echo "To use with Claude Desktop:"
echo "1. Copy the configuration from claude_desktop_config.json to:"
echo "   ~/Library/Application Support/Claude/claude_desktop_config.json"
echo ""
echo "2. Restart Claude Desktop"
echo ""
echo "To use with VS Code:"
echo "The configuration has been added to .vscode/godot-mcp.json"
echo ""
echo "Available commands:"
echo "- Launch editor: 'Launch Godot editor for my project'"
echo "- Run project: 'Run my Godot project'"
echo "- Create scene: 'Create a player scene with CharacterBody2D'"
echo "- Add node: 'Add a Sprite2D node to the player scene'"
echo "- Create script: 'Create a movement script for the player'"
