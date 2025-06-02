#!/bin/bash

# Install Git Hooks for NeuroVis Project

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Get script directory
HOOKS_DIR="$(cd "$(dirname "$0")" && pwd)"
GIT_HOOKS_DIR="$(git rev-parse --show-toplevel)/.git/hooks"

echo "Installing NeuroVis Git hooks..."

# Install pre-commit hook
if [ -f "$HOOKS_DIR/pre-commit" ]; then
    cp "$HOOKS_DIR/pre-commit" "$GIT_HOOKS_DIR/pre-commit"
    chmod +x "$GIT_HOOKS_DIR/pre-commit"
    echo -e "${GREEN}✓${NC} Installed pre-commit hook"
else
    echo -e "${YELLOW}⚠${NC} pre-commit hook not found"
fi

# Install commit-msg hook (if exists)
if [ -f "$HOOKS_DIR/commit-msg" ]; then
    cp "$HOOKS_DIR/commit-msg" "$GIT_HOOKS_DIR/commit-msg"
    chmod +x "$GIT_HOOKS_DIR/commit-msg"
    echo -e "${GREEN}✓${NC} Installed commit-msg hook"
fi

# Install pre-push hook (if exists)
if [ -f "$HOOKS_DIR/pre-push" ]; then
    cp "$HOOKS_DIR/pre-push" "$GIT_HOOKS_DIR/pre-push"
    chmod +x "$GIT_HOOKS_DIR/pre-push"
    echo -e "${GREEN}✓${NC} Installed pre-push hook"
fi

echo ""
echo -e "${GREEN}Git hooks installed successfully!${NC}"
echo ""
echo "The pre-commit hook will:"
echo "  • Validate architecture compliance"
echo "  • Check for .uid files"
echo "  • Ensure proper file placement"
echo "  • Verify naming conventions"
echo ""
echo "To skip hooks temporarily, use: git commit --no-verify"