#!/bin/bash

# Fix Scene References Script
# Updates all resource paths in .gd and .tscn files to match new structure

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

echo "Fixing scene references in NeuroVis project..."

# Function to update paths in a file
update_paths() {
    local file=$1
    
    # Create backup
    cp "$file" "$file.bak"
    
    # Update paths
    sed -i '' \
        -e 's|"res://core/|"res://src/core/|g' \
        -e 's|"res://ui/|"res://src/ui/|g' \
        -e 's|"res://scenes/|"res://src/scenes/|g' \
        -e 's|"res://scripts/|"res://src/scripts/|g' \
        -e 's|"res://shaders/|"res://assets/shaders/|g' \
        -e 's|load("res://core/|load("res://src/core/|g' \
        -e 's|load("res://ui/|load("res://src/ui/|g' \
        -e 's|load("res://scenes/|load("res://src/scenes/|g' \
        -e 's|preload("res://core/|preload("res://src/core/|g' \
        -e 's|preload("res://ui/|preload("res://src/ui/|g' \
        -e 's|preload("res://scenes/|preload("res://src/scenes/|g' \
        "$file"
    
    # Remove backup if successful
    rm "$file.bak"
}

# Update all .gd files
echo "Updating .gd files..."
find "$PROJECT_ROOT/src" -name "*.gd" -type f | while read -r file; do
    echo "  Updating: ${file#$PROJECT_ROOT/}"
    update_paths "$file"
done

# Update all .tscn files
echo "Updating .tscn files..."
find "$PROJECT_ROOT/src" -name "*.tscn" -type f | while read -r file; do
    echo "  Updating: ${file#$PROJECT_ROOT/}"
    update_paths "$file"
done

# Update any .tres files
echo "Updating .tres files..."
find "$PROJECT_ROOT" -name "*.tres" -type f | while read -r file; do
    echo "  Updating: ${file#$PROJECT_ROOT/}"
    update_paths "$file"
done

echo "Scene reference fixing complete!"
echo ""
echo "Next steps:"
echo "1. Open the project in Godot"
echo "2. Let Godot reimport assets"
echo "3. Check for any remaining broken references"
echo "4. Run tests to verify functionality"