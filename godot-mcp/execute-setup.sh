#!/bin/bash

echo "Godot MCP - Permission Fix and Final Setup"
echo "=========================================="
echo ""

cd "$(dirname "$0")"

# Run the Node.js setup script
echo "Running setup via Node.js..."
node run-setup.js

# Check exit status
if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Setup completed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Restart Claude Desktop"
    echo "2. Test with Godot commands"
else
    echo ""
    echo "❌ Setup failed. Check setup-error.log for details."
    exit 1
fi
