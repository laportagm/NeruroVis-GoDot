#!/bin/bash

echo "Testing Godot MCP Server..."
echo "=========================="
echo ""

# Check if build exists
if [ ! -f "cli-server/build/index.js" ]; then
    echo "❌ Error: Server not built yet. Run ./final-setup-verify.sh first"
    exit 1
fi

# Test server startup
echo "Testing server startup (5 second timeout)..."
echo "Press Ctrl+C to stop"
echo ""

cd cli-server

# Start server with timeout
timeout 5 node build/index.js << 'EOF' 2>&1 | tee test-output.log &
{
  "jsonrpc": "2.0",
  "method": "initialize",
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {},
    "clientInfo": {
      "name": "test-client",
      "version": "1.0.0"
    }
  },
  "id": 1
}
EOF

# Wait for timeout
sleep 5

echo ""
echo "Test complete. Check test-output.log for any errors."
echo ""

# Check if log contains expected output
if grep -q "Godot MCP" test-output.log; then
    echo "✅ Server appears to be starting correctly"
else
    echo "⚠️  Server may not be starting correctly"
    echo "Check test-output.log for details"
fi

cd ..
