#!/bin/bash

echo "=== NeuroVis Architecture Quick Validation ==="
echo ""

# Check core directories
echo "✓ Checking directory structure..."
for dir in src assets tests docs ai tools config archive; do
    if [ -d "$dir" ]; then
        echo "  ✓ $dir/ exists"
    else
        echo "  ✗ $dir/ missing"
    fi
done

echo ""
echo "✓ Checking src/ subdirectories..."
for dir in core ui scenes scripts; do
    if [ -d "src/$dir" ]; then
        echo "  ✓ src/$dir/ exists"
    else
        echo "  ✗ src/$dir/ missing"
    fi
done

echo ""
echo "✓ Checking AI workspace..."
if [ -f "ai/context/BRAIN.md" ]; then
    echo "  ✓ BRAIN.md exists"
else
    echo "  ✗ BRAIN.md missing"
fi

echo ""
echo "✓ Checking for noise in root..."
noise_count=$(ls -1 *.md 2>/dev/null | grep -v README.md | wc -l)
if [ $noise_count -eq 0 ]; then
    echo "  ✓ Root is clean of noise .md files"
else
    echo "  ⚠ Found $noise_count .md files in root (should only be README.md)"
fi

echo ""
echo "✓ Checking for .uid files..."
uid_count=$(find . -name "*.uid" 2>/dev/null | wc -l)
if [ $uid_count -eq 0 ]; then
    echo "  ✓ No .uid files found"
else
    echo "  ⚠ Found $uid_count .uid files (should be gitignored)"
fi

echo ""
echo "=== Validation Complete ==="