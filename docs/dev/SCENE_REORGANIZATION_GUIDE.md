# NeuroVis Scene Reorganization Guide

This document outlines the reorganization plan for the NeuroVis educational platform's `scenes/` directory, aiming to improve organization, educational focus, and maintainability.

## Reorganization Goals

1. **Improve Educational Organization**: Group scenes by educational function
2. **Remove Redundancy**: Eliminate duplicate and backup files
3. **Clarify Scene Hierarchy**: Create a clearer educational pathway through scenes
4. **Enhance Maintainability**: Make future development more intuitive
5. **Preserve Functionality**: Ensure all educational features remain working

## New Directory Structure

```
scenes/
├── core/                      # Primary educational scenes
│   ├── main.tscn              # Renamed from node_3d.tscn
│   └── main.gd                # Main educational controller
├── ui/                        # Educational UI components
│   ├── panels/                # Educational information panels
│   │   ├── info_panel.tscn    # Primary information panel
│   │   ├── model_control.tscn # Model control panel
│   │   └── comparative.tscn   # Comparative analysis panel
│   └── dialogs/               # Modal dialogs
│       └── gemini_setup.tscn  # Gemini setup dialog
├── debug/                     # Development and testing
│   ├── dashboard.tscn         # Debug dashboard
│   └── test_scenes/           # Test-specific scenes
│       ├── component_test.tscn
│       └── selection_test.tscn
└── educational/               # Educational specialized scenes
    ├── sectional_view.tscn    # Anatomical sections
    ├── guided_tour.tscn       # Educational guided tours (future)
    └── pathology_view.tscn    # Clinical correlation views (future)
```

## File Migration Plan

### Main Scene Files

| Original File | New Location | Notes |
|---------------|-------------|-------|
| `scenes/main/node_3d.tscn` | `scenes/core/main.tscn` | Primary educational interface |
| `scenes/main/node_3d.gd` | `scenes/core/main.gd` | Main educational controller |

### UI Panel Files

| Original File | New Location | Notes |
|---------------|-------------|-------|
| `scenes/model_control_panel_enhanced.tscn` | `scenes/ui/panels/model_control.tscn` | Educational model control |
| `scenes/model_control_panel_enhanced.gd` | `scenes/ui/panels/model_control.gd` | Educational model control |
| `scenes/ui_info_panel_enhanced.tscn` | `scenes/ui/panels/info_panel.tscn` | Educational information display |
| `scenes/ui_info_panel_enhanced.gd` | `scenes/ui/panels/info_panel.gd` | Educational information display |
| `ui/panels/GeminiSetupDialog.tscn` | `scenes/ui/dialogs/gemini_setup.tscn` | AI setup dialog |

### Debug & Test Files

| Original File | New Location | Notes |
|---------------|-------------|-------|
| `scenes/debug/debug_dashboard.tscn` | `scenes/debug/dashboard.tscn` | Development dashboard |
| `scenes/debug/test_component_scene.tscn` | `scenes/debug/test_scenes/component_test.tscn` | Component testing |
| `scenes/debug/half_brain.tscn` | `scenes/educational/sectional_view.tscn` | Educational sectional view |
| `scenes/ui_transformation_demo.tscn` | `scenes/debug/test_scenes/ui_transform_demo.tscn` | UI testing scene |

## Files to Archive/Remove

These files appear to be outdated, unused, or superseded by newer implementations:

1. `scenes/enhanced_panel_test.gd` and `.tscn`
2. `scenes/model_control_panel.gd` and `.tscn` (superseded by enhanced version)
3. `scenes/node_3d_new.tscn` (development variant)
4. `scenes/ui_info_panel.gd` and `.tscn` (superseded by enhanced version)
5. `scenes/ui_info_panel_backup.tscn`
6. `scenes/ui_info_panel_fixed.tscn` 
7. `scenes/ui_info_panel_new.tscn`
8. All backup and alternative versions in scenes/main/ (node_3d_backup.gd, node_3d_components.gd, etc.)

## Implementation Steps

1. **Create Backup**: Create a timestamped backup of the current scenes directory
2. **Create New Structure**: Create the new directory structure
3. **Copy Files**: Copy files to their new locations (don't move yet until verified)
4. **Update References**: Update all file references in the copied scenes
5. **Test**: Verify all scenes work properly with new paths
6. **Cleanup**: Remove original files after successful verification

## Post-Reorganization Tasks

1. **Update project.godot**: Change main scene path to `res://scenes/core/main.tscn`
2. **Update Documentation**: Update any documentation referring to the old paths
3. **Update Scripts**: Update any scripts with hardcoded scene paths
4. **Clean Git History**: Commit changes with a clear message about the reorganization

## Implementation Script

A script has been provided to automate this reorganization:
```
scripts/organization/reorganize_scenes.sh
```

The script creates a backup, implements the reorganization, and provides guidance for manual updates needed.

## Educational Impact

This reorganization enhances NeuroVis as an educational platform by:

1. **Improved Navigation**: Clearer path to educational resources
2. **Better Onboarding**: Easier for new developers to understand the structure
3. **Enhanced Focus**: Dedicated space for purely educational scenes
4. **Future Expansion**: Clear places to add new educational features
5. **Structural Clarity**: Better separation of core, UI, and educational components

## Future Educational Scene Development

The new structure supports upcoming educational features:

1. **Guided Educational Tours**: Will be added to `scenes/educational/`
2. **Clinical Pathology Views**: Will be added to `scenes/educational/`
3. **Educational Assessment Tools**: Will be added to `scenes/educational/`
4. **Educational Workflow Patterns**: Will be documented with the new structure

## Compatibility Notes

1. The reorganization maintains backward compatibility through symbolic links for critical files
2. The dual UI system (legacy and modern component) continues to function as before
3. All educational features remain fully functional with the new organization

---

**Version:** 1.0  
**Author:** Claude  
**Date:** 2025-06-01  
**Project:** NeuroVis Educational Platform