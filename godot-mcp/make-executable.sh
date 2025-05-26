#!/bin/bash

# Make all shell scripts executable
echo "Making all shell scripts executable..."

cd "$(dirname "$0")"

chmod +x setup.sh
chmod +x test.sh
chmod +x rebuild.sh
chmod +x rebuild-and-log.sh
chmod +x run-build-test.sh
chmod +x complete-rebuild.sh
chmod +x final-setup-verify.sh
chmod +x test-server.sh

echo "✅ All scripts are now executable"
echo ""
echo "You can now run:"
echo "./final-setup-verify.sh"
