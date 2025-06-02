#!/bin/bash

# NeuroVis Architecture Refactoring Script
# This script executes the complete architectural transformation
# Author: AI Software Architect
# Date: 2025-01-02

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Project root
PROJECT_ROOT="$(cd "$(dirname "$0")" && pwd)"

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}NeuroVis Architecture Refactoring${NC}"
echo -e "${BLUE}================================================${NC}"

# Function to create directory structure
create_directory_structure() {
    echo -e "${YELLOW}Creating new directory structure...${NC}"
    
    # Create main directories
    mkdir -p "$PROJECT_ROOT/src/core"/{ai,knowledge,models,state,systems,events,features,interaction,resources,services,visualization}
    mkdir -p "$PROJECT_ROOT/src/features"/{visualization,interaction,selection,camera,educational}
    mkdir -p "$PROJECT_ROOT/src/ui"/{components,panels,theme,layouts}
    mkdir -p "$PROJECT_ROOT/src/scenes"/{main,debug,test}
    
    # Create other top-level directories
    mkdir -p "$PROJECT_ROOT/tests"/{unit,integration,performance,fixtures}
    mkdir -p "$PROJECT_ROOT/docs"/{setup,architecture,api,tutorials}
    mkdir -p "$PROJECT_ROOT/ai"/{context,prompts,config,templates}
    mkdir -p "$PROJECT_ROOT/tools"/{build,quality,hooks,scripts}
    mkdir -p "$PROJECT_ROOT/config"/{godot,development,production}
    mkdir -p "$PROJECT_ROOT/archive"/{legacy,experiments,documentation}
    
    # Create AI subdirectories
    mkdir -p "$PROJECT_ROOT/ai/prompts"/{refactoring,feature_development,bug_fixing,documentation}
    mkdir -p "$PROJECT_ROOT/ai/templates"/{gdscript,scenes,documentation}
    
    echo -e "${GREEN}✓ Directory structure created${NC}"
}

# Function to move core files
move_core_files() {
    echo -e "${YELLOW}Moving core system files...${NC}"
    
    # Move existing core directory contents
    if [ -d "$PROJECT_ROOT/core" ]; then
        cp -r "$PROJECT_ROOT/core/"* "$PROJECT_ROOT/src/core/" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Core files moved${NC}"
}

# Function to move UI files
move_ui_files() {
    echo -e "${YELLOW}Moving UI files...${NC}"
    
    # Move existing UI directory contents
    if [ -d "$PROJECT_ROOT/ui" ]; then
        cp -r "$PROJECT_ROOT/ui/"* "$PROJECT_ROOT/src/ui/" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ UI files moved${NC}"
}

# Function to organize feature files
organize_features() {
    echo -e "${YELLOW}Organizing feature modules...${NC}"
    
    # Visualization feature
    mkdir -p "$PROJECT_ROOT/src/features/visualization"
    [ -f "$PROJECT_ROOT/core/visualization/BrainVisualizationCore.gd" ] && cp "$PROJECT_ROOT/core/visualization/BrainVisualizationCore.gd" "$PROJECT_ROOT/src/features/visualization/"
    [ -f "$PROJECT_ROOT/core/visualization/MedicalLighting.gd" ] && cp "$PROJECT_ROOT/core/visualization/MedicalLighting.gd" "$PROJECT_ROOT/src/features/visualization/"
    [ -f "$PROJECT_ROOT/core/visualization/RenderingOptimizer.gd" ] && cp "$PROJECT_ROOT/core/visualization/RenderingOptimizer.gd" "$PROJECT_ROOT/src/features/visualization/"
    [ -f "$PROJECT_ROOT/core/visualization/SelectionVisualizer.gd" ] && cp "$PROJECT_ROOT/core/visualization/SelectionVisualizer.gd" "$PROJECT_ROOT/src/features/visualization/"
    
    # Interaction feature
    mkdir -p "$PROJECT_ROOT/src/features/interaction"
    [ -f "$PROJECT_ROOT/core/interaction/InputRouter.gd" ] && cp "$PROJECT_ROOT/core/interaction/InputRouter.gd" "$PROJECT_ROOT/src/features/interaction/"
    [ -f "$PROJECT_ROOT/core/interaction/KeyInputHandler.gd" ] && cp "$PROJECT_ROOT/core/interaction/KeyInputHandler.gd" "$PROJECT_ROOT/src/features/interaction/"
    
    # Selection feature
    mkdir -p "$PROJECT_ROOT/src/features/selection"
    [ -f "$PROJECT_ROOT/core/interaction/BrainStructureSelectionManager.gd" ] && cp "$PROJECT_ROOT/core/interaction/BrainStructureSelectionManager.gd" "$PROJECT_ROOT/src/features/selection/"
    
    # Camera feature
    mkdir -p "$PROJECT_ROOT/src/features/camera"
    [ -f "$PROJECT_ROOT/core/interaction/CameraBehaviorController.gd" ] && cp "$PROJECT_ROOT/core/interaction/CameraBehaviorController.gd" "$PROJECT_ROOT/src/features/camera/"
    [ -f "$PROJECT_ROOT/core/interaction/MedicalCameraController.gd" ] && cp "$PROJECT_ROOT/core/interaction/MedicalCameraController.gd" "$PROJECT_ROOT/src/features/camera/"
    
    echo -e "${GREEN}✓ Features organized${NC}"
}

# Function to move scenes
move_scenes() {
    echo -e "${YELLOW}Moving scene files...${NC}"
    
    # Move main scenes
    if [ -d "$PROJECT_ROOT/scenes/main" ]; then
        cp -r "$PROJECT_ROOT/scenes/main/"* "$PROJECT_ROOT/src/scenes/main/" 2>/dev/null || true
    fi
    
    # Move debug scenes
    if [ -d "$PROJECT_ROOT/scenes/debug" ]; then
        cp -r "$PROJECT_ROOT/scenes/debug/"* "$PROJECT_ROOT/src/scenes/debug/" 2>/dev/null || true
    fi
    
    # Move test scenes from various locations
    mkdir -p "$PROJECT_ROOT/src/scenes/test"
    find "$PROJECT_ROOT/scenes" -name "test_*.tscn" -exec cp {} "$PROJECT_ROOT/src/scenes/test/" \; 2>/dev/null || true
    find "$PROJECT_ROOT/tests/scenes" -name "*.tscn" -exec cp {} "$PROJECT_ROOT/src/scenes/test/" \; 2>/dev/null || true
    
    echo -e "${GREEN}✓ Scene files moved${NC}"
}

# Function to archive files
archive_files() {
    echo -e "${YELLOW}Archiving historical files...${NC}"
    
    # Move existing archive
    if [ -d "$PROJECT_ROOT/archive" ]; then
        cp -r "$PROJECT_ROOT/archive/"* "$PROJECT_ROOT/archive/legacy/" 2>/dev/null || true
    fi
    
    # Archive implementation reports and summaries
    mkdir -p "$PROJECT_ROOT/archive/documentation/implementation_reports"
    find "$PROJECT_ROOT" -maxdepth 1 -name "*_IMPLEMENTATION_SUMMARY.md" -exec mv {} "$PROJECT_ROOT/archive/documentation/implementation_reports/" \; 2>/dev/null || true
    find "$PROJECT_ROOT" -maxdepth 1 -name "*_REPORT.md" -exec mv {} "$PROJECT_ROOT/archive/documentation/implementation_reports/" \; 2>/dev/null || true
    find "$PROJECT_ROOT" -maxdepth 1 -name "*_SUMMARY.md" -exec mv {} "$PROJECT_ROOT/archive/documentation/implementation_reports/" \; 2>/dev/null || true
    
    # Archive patches
    if [ -d "$PROJECT_ROOT/patches" ]; then
        mv "$PROJECT_ROOT/patches" "$PROJECT_ROOT/archive/" 2>/dev/null || true
    fi
    
    echo -e "${GREEN}✓ Files archived${NC}"
}

# Function to clean up noise files
cleanup_noise() {
    echo -e "${YELLOW}Removing noise files...${NC}"
    
    # Remove test files from root
    rm -f "$PROJECT_ROOT"/test_*.gd
    rm -f "$PROJECT_ROOT"/test_*.tscn
    
    # Remove one-time scripts
    rm -f "$PROJECT_ROOT"/run_*_test.sh
    rm -f "$PROJECT_ROOT"/final_cleanup.sh
    rm -f "$PROJECT_ROOT"/phase2_consolidation.sh
    rm -f "$PROJECT_ROOT"/rollback_consolidation.sh
    
    # Remove temporary directories
    rm -rf "$PROJECT_ROOT/tmp"
    rm -rf "$PROJECT_ROOT/logs"
    rm -rf "$PROJECT_ROOT/test_logs"
    rm -rf "$PROJECT_ROOT/test_reports"
    rm -rf "$PROJECT_ROOT/path_fix_backup"
    
    # Remove .uid files
    find "$PROJECT_ROOT" -name "*.uid" -type f -delete 2>/dev/null || true
    
    # Remove duplicate workspace
    rm -f "$PROJECT_ROOT/neurovis-enhanced.code-workspace"
    
    echo -e "${GREEN}✓ Noise files removed${NC}"
}

# Function to update project.godot paths
update_project_config() {
    echo -e "${YELLOW}Updating project.godot paths...${NC}"
    
    # Create backup
    cp "$PROJECT_ROOT/project.godot" "$PROJECT_ROOT/project.godot.backup"
    
    # Update autoload paths
    sed -i.bak 's|res://core/|res://src/core/|g' "$PROJECT_ROOT/project.godot"
    sed -i.bak 's|res://ui/|res://src/ui/|g' "$PROJECT_ROOT/project.godot"
    sed -i.bak 's|res://scenes/|res://src/scenes/|g' "$PROJECT_ROOT/project.godot"
    
    # Clean up backup files
    rm -f "$PROJECT_ROOT/project.godot.bak"
    
    echo -e "${GREEN}✓ Project configuration updated${NC}"
}

# Function to create .gitignore
create_gitignore() {
    echo -e "${YELLOW}Creating .gitignore...${NC}"
    
    cat > "$PROJECT_ROOT/.gitignore" << 'EOF'
# Godot-specific ignores
.godot/
*.tmp
*.uid

# Temporary directories
.tmp/
tmp/
logs/
test_logs/
test_reports/

# Build artifacts
exports/
build/
dist/

# IDE files
.vscode/
.idea/
*.code-workspace

# OS files
.DS_Store
Thumbs.db

# Backup files
*.backup
*.bak
*~

# Python cache
__pycache__/
*.pyc

# Environment files
.env
.env.local
EOF
    
    echo -e "${GREEN}✓ .gitignore created${NC}"
}

# Function to create initial AI context files
create_ai_context() {
    echo -e "${YELLOW}Creating AI context files...${NC}"
    
    # Feature inventory
    cat > "$PROJECT_ROOT/ai/context/feature_inventory.md" << 'EOF'
# NeuroVis Feature Inventory

## Visualization Feature
- Brain 3D rendering with medical-grade lighting
- Real-time performance optimization
- Selection highlighting and feedback

## Interaction Feature
- Mouse and keyboard input handling
- Context-sensitive controls
- Accessibility support

## Selection Feature
- 3D structure selection via raycasting
- Multi-selection support
- Visual and audio feedback

## Camera Feature
- Medical viewing presets
- Smooth transitions
- Focus-on-structure functionality

## Educational Feature
- Learning path management
- Progress tracking
- AI-assisted explanations
EOF
    
    # Development rules
    cat > "$PROJECT_ROOT/ai/context/development_rules.md" << 'EOF'
# NeuroVis Development Rules

## Code Standards
1. All GDScript files use class_name declaration
2. Functions are documented with purpose and parameters
3. Private members start with underscore
4. Constants are UPPER_SNAKE_CASE

## Git Workflow
1. Feature branches: feature/description
2. Commit format: type(scope): message
3. All commits must pass pre-commit hooks
4. PR requires code review

## Testing Requirements
1. New features require unit tests
2. UI changes require integration tests
3. Performance-critical code requires benchmarks
4. All tests must pass before merge
EOF
    
    echo -e "${GREEN}✓ AI context created${NC}"
}

# Main execution
main() {
    echo -e "${BLUE}Starting architecture refactoring...${NC}"
    echo -e "${YELLOW}This will transform the project structure. Continue? (y/n)${NC}"
    read -r response
    
    if [[ "$response" != "y" ]]; then
        echo -e "${RED}Refactoring cancelled${NC}"
        exit 0
    fi
    
    # Create backup
    echo -e "${YELLOW}Creating project backup...${NC}"
    tar -czf "$PROJECT_ROOT/../neurovis_backup_$(date +%Y%m%d_%H%M%S).tar.gz" "$PROJECT_ROOT"
    echo -e "${GREEN}✓ Backup created${NC}"
    
    # Execute refactoring steps
    create_directory_structure
    move_core_files
    move_ui_files
    organize_features
    move_scenes
    archive_files
    cleanup_noise
    update_project_config
    create_gitignore
    create_ai_context
    
    echo -e "${GREEN}================================================${NC}"
    echo -e "${GREEN}✓ Architecture refactoring complete!${NC}"
    echo -e "${GREEN}================================================${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Review the new structure in src/"
    echo "2. Update any broken import paths"
    echo "3. Run tests to verify functionality"
    echo "4. Commit the new architecture"
    echo ""
    echo -e "${YELLOW}Important files:${NC}"
    echo "- Architecture guide: ai/context/project_architecture.md"
    echo "- Refactoring plan: NEUROVIS_ARCHITECTURE_REFACTOR_PLAN.md"
    echo "- Project backup: ../neurovis_backup_*.tar.gz"
}

# Run main function
main