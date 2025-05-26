#!/bin/bash

# Test script for Godot MCP integration
echo "Testing Godot MCP Integration..."
echo "================================"

# Check if server is built
if [ ! -f "cli-server/build/index.js" ]; then
    echo "Error: Server not built. Run ./setup.sh first"
    exit 1
fi

# Test basic operations
echo ""
echo "Testing project info..."
node cli-server/build/index.js << 'EOF'
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "get_project_info",
    "arguments": {
      "projectPath": "/Users/gagelaporta/11A-NeuroVis"
    }
  },
  "id": 1
}
EOF

echo ""
echo "Test complete!"
echo ""
echo "If you see project information above, the integration is working correctly."
echo "You can now use it with Claude Desktop or other MCP clients."
