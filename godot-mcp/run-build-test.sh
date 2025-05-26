#!/bin/bash

cd "$(dirname "$0")"

echo "Running automated build test..."
echo "=============================="
echo ""

# Run the test and save output
node test-build.js 2>&1 | tee automated-build-test.log

echo ""
echo "Test complete. Output saved to automated-build-test.log"

# Check if build directory was created
if [ -d "cli-server/build" ]; then
    echo ""
    echo "Build directory contents:"
    ls -la cli-server/build/
fi

# Check for error log
if [ -f "cli-server/build-error.log" ]; then
    echo ""
    echo "Build error log found. Contents:"
    echo "================================"
    cat cli-server/build-error.log
fi
