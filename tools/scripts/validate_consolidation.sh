#!/bin/bash
# NeuroVis Consolidation Validation Script
# Validates that consolidation was successful and project is functional

set -e

echo "🔍 NeuroVis Consolidation Validation"
echo "📅 $(date)"

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

success() { echo -e "${GREEN}[✓]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1"; }
warning() { echo -e "${YELLOW}[!]${NC} $1"; }
info() { echo -e "${BLUE}[i]${NC} $1"; }

VALIDATION_PASSED=true

echo ""
echo "=== PRIMARY FILE VALIDATION ==="

# Check primary implementations exist and are functional
PRIMARY_FILES=(
    "scenes/main/node_3d.gd:Main scene implementation"
    "scenes/main/node_3d.tscn:Main scene file"
    "core/interaction/BrainStructureSelectionManager.gd:Selection manager"
    "ui/panels/EnhancedInformationPanel.gd:Info panel"
    "core/knowledge/KnowledgeService.gd:Knowledge service"
    "ui/panels/UIThemeManager.gd:Theme manager"
    "core/ai/AIAssistantService.gd:AI assistant"
    "project.godot:Project configuration"
)

for entry in "${PRIMARY_FILES[@]}"; do
    file="${entry%:*}"
    desc="${entry#*:}"
    
    if [ -f "$file" ]; then
        size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        if [ "$size" -gt 100 ]; then
            success "$desc: $file (${size} bytes)"
        else
            error "$desc: $file exists but seems too small (${size} bytes)"
            VALIDATION_PASSED=false
        fi
    else
        error "$desc: Missing file $file"
        VALIDATION_PASSED=false
    fi
done

echo ""
echo "=== DUPLICATE REMOVAL VALIDATION ==="

# Check that duplicates were actually removed/archived
SHOULD_BE_GONE=(
    "scenes/main/node_3d_enhanced.gd"
    "scenes/main/node_3d_simple.gd" 
    "core/interaction/BrainStructureSelectionManagerEnhanced.gd"
    "scenes/ui_info_panel.gd"
    "ui/panels/minimal_info_panel.gd"
)

for file in "${SHOULD_BE_GONE[@]}"; do
    if [ -f "$file" ]; then
        warning "Duplicate still exists: $file"
    else
        success "Duplicate removed: $(basename $file)"
    fi
done

echo ""
echo "=== ARCHIVE VALIDATION ==="

# Check archive structure
ARCHIVE_DIRS=(
    "archive/main_scene_variants"
    "archive/selection_manager_variants"
    "archive/info_panel_variants"
    "archive/legacy_ui"
    "archive/legacy_knowledge"
    "archive/legacy_scenes"
)

for dir in "${ARCHIVE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        file_count=$(find "$dir" -name "*.gd" | wc -l)
        success "Archive directory: $dir ($file_count GD files)"
    else
        warning "Archive directory missing: $dir"
    fi
done

echo ""
echo "=== GODOT PROJECT VALIDATION ==="

# Check project.godot for autoloads
if [ -f "project.godot" ]; then
    autoloads=(
        "KnowledgeService"
        "AIAssistant" 
        "UIThemeManager"
        "ModelSwitcherGlobal"
        "DebugCmd"
    )
    
    for autoload in "${autoloads[@]}"; do
        if grep -q "$autoload" project.godot; then
            success "Autoload configured: $autoload"
        else
            error "Autoload missing: $autoload"
            VALIDATION_PASSED=false
        fi
    done
else
    error "project.godot missing!"
    VALIDATION_PASSED=false
fi

echo ""
echo "=== EDUCATIONAL CONTENT VALIDATION ==="

# Check educational assets
EDUCATIONAL_ASSETS=(
    "assets/data/anatomical_data.json"
    "assets/models/Half_Brain.glb"
    "assets/models/Internal_Structures.glb"
)

for asset in "${EDUCATIONAL_ASSETS[@]}"; do
    if [ -f "$asset" ]; then
        success "Educational asset: $(basename $asset)"
    else
        warning "Educational asset missing: $asset"
    fi
done

echo ""
echo "=== DOCUMENTATION VALIDATION ==="

# Check documentation files
DOCS=(
    "PROJECT_MAP.md"
    "REORGANIZATION_REPORT.md"
    "CLAUDE.md"
)

for doc in "${DOCS[@]}"; do
    if [ -f "$doc" ]; then
        success "Documentation: $doc"
    else
        warning "Documentation missing: $doc"
    fi
done

echo ""
echo "=== SUMMARY ==="

if [ "$VALIDATION_PASSED" = true ]; then
    success "🎉 All validation checks passed!"
    success "Project is ready for AI-assisted development"
    echo ""
    info "Quick start commands:"
    info "  godot --path . (launch project)"
    info "  F1 in-game (debug console)"
    info "  test autoloads (validate services)"
else
    error "❌ Validation failed!"
    error "Check the errors above and consider rollback if needed"
    echo ""
    info "Rollback command:"
    info "  ./rollback_consolidation.sh"
fi

# Generate validation report
cat > VALIDATION_REPORT.md << EOF
# Consolidation Validation Report

**Date**: $(date)
**Status**: $(if [ "$VALIDATION_PASSED" = true ]; then echo "✅ PASSED"; else echo "❌ FAILED"; fi)

## Files Validated
$(for entry in "${PRIMARY_FILES[@]}"; do
    file="${entry%:*}"
    desc="${entry#*:}"
    if [ -f "$file" ]; then
        echo "- ✅ $desc: \`$file\`"
    else
        echo "- ❌ $desc: \`$file\` (MISSING)"
    fi
done)

## Archive Structure
$(for dir in "${ARCHIVE_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        count=$(find "$dir" -name "*.gd" | wc -l)
        echo "- ✅ \`$dir\` ($count files)"
    else
        echo "- ❌ \`$dir\` (MISSING)"
    fi
done)

## Educational Assets
$(for asset in "${EDUCATIONAL_ASSETS[@]}"; do
    if [ -f "$asset" ]; then
        echo "- ✅ \`$(basename $asset)\`"
    else
        echo "- ❌ \`$(basename $asset)\` (MISSING)"
    fi
done)

---
Generated by validation script
EOF

success "📋 Validation report saved to VALIDATION_REPORT.md"