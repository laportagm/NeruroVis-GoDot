#!/bin/bash

# NeuroVis Architecture Validation Script
# Validates compliance with the new architecture standards
# Author: AI Software Architect
# Date: 2025-01-02

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Counters
VIOLATIONS=0
WARNINGS=0
PASSES=0

# Project root
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}NeuroVis Architecture Validation${NC}"
echo -e "${BLUE}================================================${NC}"

# Check function
check() {
    local test_name=$1
    local condition=$2
    local message=$3
    
    if eval "$condition"; then
        echo -e "${GREEN}✓${NC} $test_name"
        ((PASSES++))
    else
        echo -e "${RED}✗${NC} $test_name: $message"
        ((VIOLATIONS++))
    fi
}

# Warning function
warn() {
    local test_name=$1
    local condition=$2
    local message=$3
    
    if eval "$condition"; then
        echo -e "${YELLOW}⚠${NC} $test_name: $message"
        ((WARNINGS++))
    fi
}

echo -e "\n${YELLOW}1. Directory Structure Validation${NC}"
echo "=================================="

# Check core directories exist
check "Source directory" "[ -d '$PROJECT_ROOT/src' ]" "src/ directory missing"
check "Core systems" "[ -d '$PROJECT_ROOT/src/core' ]" "src/core/ missing"
check "Features" "[ -d '$PROJECT_ROOT/src/features' ]" "src/features/ missing"
check "UI layer" "[ -d '$PROJECT_ROOT/src/ui' ]" "src/ui/ missing"
check "Scenes" "[ -d '$PROJECT_ROOT/src/scenes' ]" "src/scenes/ missing"
check "Assets" "[ -d '$PROJECT_ROOT/assets' ]" "assets/ missing"
check "Tests" "[ -d '$PROJECT_ROOT/tests' ]" "tests/ missing"
check "Documentation" "[ -d '$PROJECT_ROOT/docs' ]" "docs/ missing"
check "AI workspace" "[ -d '$PROJECT_ROOT/ai' ]" "ai/ missing"
check "Tools" "[ -d '$PROJECT_ROOT/tools' ]" "tools/ missing"

echo -e "\n${YELLOW}2. AI Hub Validation${NC}"
echo "===================="

# Check AI structure
check "AI context" "[ -d '$PROJECT_ROOT/ai/context' ]" "ai/context/ missing"
check "Brain document" "[ -f '$PROJECT_ROOT/ai/context/project_architecture.md' ]" "Brain document missing"
check "AI prompts" "[ -d '$PROJECT_ROOT/ai/prompts' ]" "ai/prompts/ missing"
check "AI config" "[ -d '$PROJECT_ROOT/ai/config' ]" "ai/config/ missing"
check "AI templates" "[ -d '$PROJECT_ROOT/ai/templates' ]" "ai/templates/ missing"

echo -e "\n${YELLOW}3. Separation of Concerns${NC}"
echo "========================="

# Check for misplaced files
DOCS_IN_SRC=$(find "$PROJECT_ROOT/src" -name "*.md" 2>/dev/null | wc -l)
check "No docs in src/" "[ $DOCS_IN_SRC -eq 0 ]" "Found $DOCS_IN_SRC .md files in src/"

CODE_IN_DOCS=$(find "$PROJECT_ROOT/docs" -name "*.gd" 2>/dev/null | wc -l)
check "No code in docs/" "[ $CODE_IN_DOCS -eq 0 ]" "Found $CODE_IN_DOCS .gd files in docs/"

CODE_IN_ASSETS=$(find "$PROJECT_ROOT/assets" -name "*.gd" 2>/dev/null | wc -l)
check "No code in assets/" "[ $CODE_IN_ASSETS -eq 0 ]" "Found $CODE_IN_ASSETS .gd files in assets/"

echo -e "\n${YELLOW}4. Noise Detection${NC}"
echo "=================="

# Check for noise files
ROOT_TEST_FILES=$(find "$PROJECT_ROOT" -maxdepth 1 -name "test_*.gd" 2>/dev/null | wc -l)
check "No test files in root" "[ $ROOT_TEST_FILES -eq 0 ]" "Found $ROOT_TEST_FILES test files in root"

UID_FILES=$(find "$PROJECT_ROOT" -name "*.uid" 2>/dev/null | wc -l)
warn "UID files" "[ $UID_FILES -gt 0 ]" "Found $UID_FILES .uid files (should be gitignored)"

PATCH_FILES=$(find "$PROJECT_ROOT" -name "*.patch" 2>/dev/null | wc -l)
check "No patch files" "[ $PATCH_FILES -eq 0 ]" "Found $PATCH_FILES patch files"

BACKUP_FILES=$(find "$PROJECT_ROOT" -name "*_backup*" -o -name "*.bak" 2>/dev/null | wc -l)
check "No backup files" "[ $BACKUP_FILES -eq 0 ]" "Found $BACKUP_FILES backup files"

echo -e "\n${YELLOW}5. Feature Module Structure${NC}"
echo "==========================="

# Check feature directories
for feature in visualization interaction selection camera educational; do
    check "Feature: $feature" "[ -d '$PROJECT_ROOT/src/features/$feature' ]" "Missing feature directory"
done

echo -e "\n${YELLOW}6. Naming Convention Compliance${NC}"
echo "==============================="

# Check for naming violations
SNAKE_CASE_CLASSES=$(find "$PROJECT_ROOT/src" -name "*.gd" -exec grep -l "^class_name [a-z]" {} \; 2>/dev/null | wc -l)
check "Class naming (PascalCase)" "[ $SNAKE_CASE_CLASSES -eq 0 ]" "Found $SNAKE_CASE_CLASSES files with snake_case class names"

echo -e "\n${YELLOW}7. Architecture Documentation${NC}"
echo "============================="

# Check key documentation
check "README exists" "[ -f '$PROJECT_ROOT/README.md' ]" "No README.md in root"
check "Architecture docs" "[ -d '$PROJECT_ROOT/docs/architecture' ]" "Missing architecture documentation"
check "Setup docs" "[ -d '$PROJECT_ROOT/docs/setup' ]" "Missing setup documentation"

echo -e "\n${YELLOW}8. Test Organization${NC}"
echo "===================="

# Check test structure
check "Unit tests" "[ -d '$PROJECT_ROOT/tests/unit' ]" "Missing unit test directory"
check "Integration tests" "[ -d '$PROJECT_ROOT/tests/integration' ]" "Missing integration test directory"
check "Performance tests" "[ -d '$PROJECT_ROOT/tests/performance' ]" "Missing performance test directory"

echo -e "\n${YELLOW}9. Configuration Management${NC}"
echo "==========================="

# Check configuration
check "Config directory" "[ -d '$PROJECT_ROOT/config' ]" "Missing config directory"
check "Project.godot" "[ -f '$PROJECT_ROOT/project.godot' ]" "Missing project.godot"
check "Gitignore" "[ -f '$PROJECT_ROOT/.gitignore' ]" "Missing .gitignore"

echo -e "\n${YELLOW}10. Build and Tools${NC}"
echo "==================="

# Check tools
check "Build tools" "[ -d '$PROJECT_ROOT/tools/build' ]" "Missing build tools"
check "Quality tools" "[ -d '$PROJECT_ROOT/tools/quality' ]" "Missing quality tools"
check "Git hooks" "[ -d '$PROJECT_ROOT/tools/hooks' ]" "Missing git hooks"

# Summary
echo -e "\n${BLUE}================================================${NC}"
echo -e "${BLUE}Validation Summary${NC}"
echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Passed:${NC} $PASSES"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS"
echo -e "${RED}Violations:${NC} $VIOLATIONS"

if [ $VIOLATIONS -eq 0 ]; then
    echo -e "\n${GREEN}✓ Architecture is compliant!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Architecture has violations that need fixing${NC}"
    exit 1
fi