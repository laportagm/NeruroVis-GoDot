#!/bin/bash

echo "Fixing permissions for Godot MCP scripts..."
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# Make all shell scripts executable
echo "Making scripts executable..."
chmod +x make-executable.sh
chmod +x setup.sh
chmod +x test.sh
chmod +x rebuild.sh
chmod +x rebuild-and-log.sh
chmod +x run-build-test.sh
chmod +x complete-rebuild.sh
chmod +x final-setup-verify.sh
chmod +x test-server.sh
chmod +x test-build.sh

echo "✅ All scripts are now executable"
echo ""

# Now run the final setup
echo "Running final setup..."
echo "====================="
./final-setup-verify.sh
