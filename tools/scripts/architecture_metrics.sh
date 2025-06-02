#!/bin/bash

# NeuroVis Architecture Metrics
# Provides insights into project health and structure

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

# Get project root
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}NeuroVis Architecture Metrics${NC}"
echo -e "${BLUE}Generated: $(date)${NC}"
echo -e "${BLUE}================================================${NC}"

# Function to count files
count_files() {
    find "$1" -name "$2" -type f 2>/dev/null | wc -l | tr -d ' '
}

# Function to calculate percentage
calc_percentage() {
    if [ "$2" -eq 0 ]; then
        echo "0"
    else
        echo "scale=1; $1 * 100 / $2" | bc
    fi
}

echo ""
echo -e "${YELLOW}1. Code Distribution${NC}"
echo "========================"

# Count source files
gd_files=$(count_files "src" "*.gd")
tscn_files=$(count_files "src" "*.tscn")
total_source=$((gd_files + tscn_files))

echo "GDScript files: $gd_files"
echo "Scene files: $tscn_files"
echo "Total source files: $total_source"

# Distribution by directory
echo ""
echo "Distribution by module:"
for dir in core ui scenes scripts; do
    if [ -d "src/$dir" ]; then
        count=$(count_files "src/$dir" "*.gd")
        percent=$(calc_percentage "$count" "$gd_files")
        printf "  %-12s %3d files (%4s%%)\n" "$dir:" "$count" "$percent"
    fi
done

echo ""
echo -e "${YELLOW}2. Test Coverage${NC}"
echo "================"

# Count test files
test_files=$(count_files "tests" "*.gd")
test_ratio=$(calc_percentage "$test_files" "$gd_files")

echo "Test files: $test_files"
echo "Source files: $gd_files"
echo -e "Test ratio: ${test_ratio}%"

if (( $(echo "$test_ratio < 20" | bc -l) )); then
    echo -e "${RED}⚠ Low test coverage!${NC}"
elif (( $(echo "$test_ratio < 50" | bc -l) )); then
    echo -e "${YELLOW}⚠ Moderate test coverage${NC}"
else
    echo -e "${GREEN}✓ Good test coverage${NC}"
fi

echo ""
echo -e "${YELLOW}3. Documentation${NC}"
echo "================"

# Count documentation
docs_count=$(count_files "docs" "*.md")
ai_docs=$(count_files "ai/context" "*.md")
total_docs=$((docs_count + ai_docs))

echo "User documentation: $docs_count files"
echo "AI context docs: $ai_docs files"
echo "Total documentation: $total_docs files"

# Code to documentation ratio
code_doc_ratio=$(echo "scale=2; $total_source / $total_docs" | bc)
echo "Code/Doc ratio: ${code_doc_ratio}:1"

echo ""
echo -e "${YELLOW}4. Architecture Compliance${NC}"
echo "=========================="

# Check for violations
src_violations=$(find . -name "*.gd" -o -name "*.tscn" | grep -v "^./src/" | grep -v "^./.godot/" | grep -v "^./tests/" | grep -v "^./archive/" | grep -v "^./tools/" | wc -l | tr -d ' ')
doc_violations=$(find src -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
uid_files=$(count_files "." "*.uid")

echo -n "Source files outside src/: "
if [ "$src_violations" -eq 0 ]; then
    echo -e "${GREEN}0 ✓${NC}"
else
    echo -e "${RED}$src_violations ✗${NC}"
fi

echo -n "Docs in source directories: "
if [ "$doc_violations" -eq 0 ]; then
    echo -e "${GREEN}0 ✓${NC}"
else
    echo -e "${RED}$doc_violations ✗${NC}"
fi

echo -n ".uid files tracked: "
if [ "$uid_files" -eq 0 ]; then
    echo -e "${GREEN}0 ✓${NC}"
else
    echo -e "${YELLOW}$uid_files ⚠${NC}"
fi

echo ""
echo -e "${YELLOW}5. Complexity Metrics${NC}"
echo "===================="

# Average file size
avg_size=$(find src -name "*.gd" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{if($2>0) print int($1/$2); else print 0}')
echo "Average GDScript file size: $avg_size lines"

# Large files (>500 lines)
large_files=$(find src -name "*.gd" -exec wc -l {} + 2>/dev/null | awk '$1 > 500 {print $2}' | wc -l | tr -d ' ')
echo -n "Large files (>500 lines): "
if [ "$large_files" -eq 0 ]; then
    echo -e "${GREEN}$large_files ✓${NC}"
else
    echo -e "${YELLOW}$large_files ⚠${NC}"
fi

# Very large files (>1000 lines)
xlarge_files=$(find src -name "*.gd" -exec wc -l {} + 2>/dev/null | awk '$1 > 1000 {print $2}' | wc -l | tr -d ' ')
if [ "$xlarge_files" -gt 0 ]; then
    echo -e "${RED}Very large files (>1000 lines): $xlarge_files ✗${NC}"
    echo "Consider refactoring these files:"
    find src -name "*.gd" -exec wc -l {} + 2>/dev/null | awk '$1 > 1000 {print "  " $2 " (" $1 " lines)"}'
fi

echo ""
echo -e "${YELLOW}6. Dependency Analysis${NC}"
echo "====================="

# Count autoloads
autoload_count=$(grep -c "^\[autoload\]" -A 50 project.godot | grep -c "^[A-Za-z]" || echo "0")
echo "Autoload services: $autoload_count"

# Count unique imports
unique_imports=$(grep -h "^extends\|^preload\|^load" src/**/*.gd 2>/dev/null | sort -u | wc -l | tr -d ' ')
echo "Unique dependencies: $unique_imports"

echo ""
echo -e "${YELLOW}7. Asset Usage${NC}"
echo "=============="

# Count assets
models=$(count_files "assets/models" "*.glb")
shaders=$(count_files "assets/shaders" "*.gdshader")
materials=$(count_files "assets/materials" "*")
data_files=$(count_files "assets/data" "*.json")

echo "3D Models: $models"
echo "Shaders: $shaders"
echo "Materials: $materials"
echo "Data files: $data_files"

echo ""
echo -e "${YELLOW}8. Health Score${NC}"
echo "=============="

# Calculate health score (out of 100)
score=100

# Deduct points for issues
[ "$src_violations" -gt 0 ] && score=$((score - 10))
[ "$doc_violations" -gt 0 ] && score=$((score - 10))
[ "$uid_files" -gt 0 ] && score=$((score - 5))
[ "$large_files" -gt 5 ] && score=$((score - 5))
[ "$xlarge_files" -gt 0 ] && score=$((score - 10))
(( $(echo "$test_ratio < 20" | bc -l) )) && score=$((score - 10))
(( $(echo "$code_doc_ratio > 10" | bc -l) )) && score=$((score - 5))

echo -n "Overall Health Score: "
if [ $score -ge 90 ]; then
    echo -e "${GREEN}$score/100 ✓ Excellent${NC}"
elif [ $score -ge 70 ]; then
    echo -e "${GREEN}$score/100 ✓ Good${NC}"
elif [ $score -ge 50 ]; then
    echo -e "${YELLOW}$score/100 ⚠ Fair${NC}"
else
    echo -e "${RED}$score/100 ✗ Needs Attention${NC}"
fi

echo ""
echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}Recommendations:${NC}"

# Generate recommendations based on metrics
if [ "$test_files" -lt 50 ]; then
    echo "• Increase test coverage - aim for 1 test per 2 source files"
fi
if [ "$large_files" -gt 0 ]; then
    echo "• Refactor large files to improve maintainability"
fi
if [ "$src_violations" -gt 0 ]; then
    echo "• Move source files to proper src/ directories"
fi
if (( $(echo "$code_doc_ratio > 10" | bc -l) )); then
    echo "• Add more documentation for complex features"
fi

echo -e "${BLUE}================================================${NC}"