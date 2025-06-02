#!/bin/bash

# NeuroVis Scenes Folder Reorganization Script
# This script implements the reorganization plan for the scenes directory
# to improve educational organization and remove redundant files

# Create timestamp for backup
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="./scenes_backup_$TIMESTAMP"

echo "=== NeuroVis Scene Reorganization ==="
echo "Creating backup at $BACKUP_DIR"

# Create backup of the entire scenes directory
mkdir -p "$BACKUP_DIR"
cp -r ./scenes/* "$BACKUP_DIR"

echo "Backup complete. Starting reorganization..."

# Create new directory structure
mkdir -p ./scenes/core
mkdir -p ./scenes/ui/panels
mkdir -p ./scenes/ui/dialogs
mkdir -p ./scenes/debug/test_scenes
mkdir -p ./scenes/educational

echo "New directory structure created."

# 1. Core Scene Reorganization
echo "Moving main scene files..."
cp ./scenes/main/node_3d.tscn ./scenes/core/main.tscn
cp ./scenes/main/node_3d.gd ./scenes/core/main.gd

# 2. UI Panel Consolidation
echo "Moving UI panel files..."
cp ./scenes/model_control_panel_enhanced.tscn ./scenes/ui/panels/model_control.tscn
cp ./scenes/model_control_panel_enhanced.gd ./scenes/ui/panels/model_control.gd
cp ./scenes/ui_info_panel_enhanced.tscn ./scenes/ui/panels/info_panel.tscn
cp ./scenes/ui_info_panel_enhanced.gd ./scenes/ui/panels/info_panel.gd
cp ./scenes/ui_transformation_demo.tscn ./scenes/debug/test_scenes/ui_transform_demo.tscn

# 3. Debug Scene Consolidation
echo "Moving debug scene files..."
cp ./scenes/debug/debug_dashboard.tscn ./scenes/debug/dashboard.tscn
cp ./scenes/debug/test_component_scene.tscn ./scenes/debug/test_scenes/component_test.tscn
cp ./scenes/debug/half_brain.tscn ./scenes/educational/sectional_view.tscn

# 4. Move Gemini Setup Dialog
echo "Moving dialog files..."
cp ./ui/panels/GeminiSetupDialog.tscn ./scenes/ui/dialogs/gemini_setup.tscn
# Create a symbolic link to maintain backward compatibility
ln -sf ../../../scenes/ui/dialogs/gemini_setup.tscn ./ui/panels/GeminiSetupDialog.tscn

echo "Copying complete. Updating file references..."

# Update main scene reference in project.godot (use sed for simple replacement)
# This is a demonstration - the actual implementation would need to parse and update the file
echo "NOTE: You'll need to manually update the main scene reference in project.godot"
echo "  Change: config/main_scene=\"res://scenes/main/node_3d.tscn\""
echo "  To:     config/main_scene=\"res://scenes/core/main.tscn\""

# Update script paths in the copied scenes
# This is a demonstration - a full implementation would parse and update .tscn files
echo "NOTE: You'll need to verify script paths in the moved .tscn files"
echo "  For example, in scenes/core/main.tscn:"
echo "  Change: script=\"res://scenes/main/node_3d.gd\""
echo "  To:     script=\"res://scenes/core/main.gd\""

echo "Reorganization complete. Please test before removing old files."
echo ""
echo "After verification, you can remove old files with:"
echo "  rm -rf ./scenes/main"
echo "  rm ./scenes/enhanced_panel_test.*"
echo "  rm ./scenes/model_control_panel.*"
echo "  rm ./scenes/node_3d_new.tscn"
echo "  rm ./scenes/ui_info_panel*.tscn"
echo "  rm ./scenes/ui_info_panel*.gd"
echo ""
echo "=== Completed ==="