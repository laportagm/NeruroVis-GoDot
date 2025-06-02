#!/bin/bash

# NeuroVis Architecture Validation Script
# Validates project structure, naming conventions, and autoload compliance

echo "🔍 NeuroVis Architecture Validation"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
violations=0
warnings=0

echo -e "\n📁 Checking Directory Structure..."

# Check for required directories
required_dirs=(
    "core/ai"
    "core/interaction"
    "core/knowledge"
    "core/models"
    "core/systems"
    "core/visualization"
    "ui/components"
    "ui/panels"
    "ui/theme"
    "scenes/main"
    "assets/data"
    "assets/models"
    "tests"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅ $dir exists${NC}"
    else
        echo -e "${RED}❌ Missing directory: $dir${NC}"
        ((violations++))
    fi
done

echo -e "\n📝 Checking for misplaced files..."

# Check for test files in root
root_tests=$(find . -maxdepth 1 -name "test_*.gd" -o -name "*_test.gd" | wc -l)
if [ $root_tests -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $root_tests test files in root directory (should be in tests/)${NC}"
    find . -maxdepth 1 -name "test_*.gd" -o -name "*_test.gd" | while read file; do
        echo "   - $file"
    done
    ((warnings++))
fi

echo -e "\n🏷️  Checking naming conventions..."

# Check for snake_case class files (excluding tests and scripts directories)
snake_case_violations=$(find core ui scenes -name "*_*.gd" -type f | grep -v ".uid$" | grep -v "test_" | grep -v "/tests/" | wc -l)
if [ $snake_case_violations -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Found $snake_case_violations files with snake_case names that might need PascalCase:${NC}"
    find core ui scenes -name "*_*.gd" -type f | grep -v ".uid$" | grep -v "test_" | grep -v "/tests/" | head -10 | while read file; do
        echo "   - $file"
    done
    ((warnings++))
fi

echo -e "\n🔧 Checking autoload configuration..."

# Check if project.godot exists
if [ -f "project.godot" ]; then
    # Check for required autoloads
    required_autoloads=(
        "KnowledgeService"
        "AIAssistant"
        "UIThemeManager"
        "ModelSwitcherGlobal"
    )
    
    for autoload in "${required_autoloads[@]}"; do
        if grep -q "^$autoload=" project.godot; then
            echo -e "${GREEN}✅ $autoload autoload configured${NC}"
        else
            echo -e "${RED}❌ Missing autoload: $autoload${NC}"
            ((violations++))
        fi
    done
    
    # Check for legacy KB autoload path
    if grep -q "KB=\"\*res://core/knowledge/AnatomicalKnowledgeDatabase.gd\"" project.godot; then
        if [ ! -f "core/knowledge/AnatomicalKnowledgeDatabase.gd" ]; then
            echo -e "${YELLOW}⚠️  KB autoload references non-existent file (file is in archive/)${NC}"
            ((warnings++))
        fi
    fi
else
    echo -e "${RED}❌ project.godot not found!${NC}"
    ((violations++))
fi

echo -e "\n🎯 Checking for duplicate class names..."

# Check for duplicate class_name declarations
duplicates=$(grep -r "^class_name" --include="*.gd" . | awk '{print $2}' | sort | uniq -d | wc -l)
if [ $duplicates -gt 0 ]; then
    echo -e "${RED}❌ Found duplicate class_name declarations:${NC}"
    grep -r "^class_name" --include="*.gd" . | awk '{print $2}' | sort | uniq -d
    ((violations++))
else
    echo -e "${GREEN}✅ No duplicate class names found${NC}"
fi

echo -e "\n📊 Validation Summary"
echo "===================="
echo -e "Violations: ${violations}"
echo -e "Warnings: ${warnings}"

if [ $violations -eq 0 ] && [ $warnings -eq 0 ]; then
    echo -e "\n${GREEN}✅ Perfect! No architecture violations found.${NC}"
    exit 0
elif [ $violations -eq 0 ]; then
    echo -e "\n${YELLOW}⚠️  Some warnings found but no critical violations.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Critical violations found. Please fix before committing.${NC}"
    exit 1
fi