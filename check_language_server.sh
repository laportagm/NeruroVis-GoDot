#!/bin/bash
# Godot Language Server Connection Test
# Run this while Godot Editor is open

echo "🔍 Checking Godot Language Server Status..."
echo "==========================================="

# Check if port 6005 is in use
if lsof -i :6005 > /dev/null 2>&1; then
    echo "✅ Port 6005 is active!"
    echo "   Language Server appears to be running"
    lsof -i :6005
else
    echo "❌ Port 6005 is not active"
    echo "   Please ensure:"
    echo "   1. Godot Editor is open"
    echo "   2. Language Server is enabled in Editor Settings"
fi

echo ""
echo "📝 Quick Setup Instructions:"
echo "1. Open Godot Editor"
echo "2. Go to: Editor → Editor Settings"
echo "3. Navigate to: Network → Language Server"
echo "4. Enable: ✅ Enable Language Server"
echo "5. Set Port: 6005"
echo "6. Enable: ✅ Use Thread"
echo ""
echo "Then restart VS Code and open a .gd file"
