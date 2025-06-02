#!/bin/bash

echo "Validating fix for parser errors..."
echo "Checking core/interaction/BrainStructureSelectionManager.gd..."

# Use Godot to check syntax
godot --headless --check-only --script core/interaction/BrainStructureSelectionManager.gd

if [ $? -eq 0 ]; then
  echo "✅ BrainStructureSelectionManager.gd passed syntax check"
else
  echo "❌ BrainStructureSelectionManager.gd has syntax errors"
fi

echo "Checking for class_name conflicts..."
grep -r "class_name BrainStructureSelectionManager" --include="*.gd" ./

if [ $? -eq 0 ]; then
  echo "Found class_name declarations - check for duplicates"
else
  echo "✅ No duplicate class_name BrainStructureSelectionManager found"
fi

echo "Validation complete"