# NeuroVis Troubleshooting Guide

> Common issues and their solutions in the new architecture
> Version: 1.0

## Post-Migration Issues

### Issue: "Script not found" Errors
**Symptoms**: Red errors in Godot about missing scripts

**Solutions**:
1. Check if path needs `src/` prefix:
   ```
   Old: res://core/systems/Example.gd
   New: res://src/core/systems/Example.gd
   ```

2. Verify file exists in new location:
   ```bash
   find . -name "MissingScript.gd" -type f
   ```

3. Update scene file references:
   ```bash
   ./tools/scripts/fix_scene_references.sh
   ```

### Issue: Broken Autoloads
**Symptoms**: Null reference errors for autoload services

**Solutions**:
1. Check project.godot has updated paths:
   ```ini
   [autoload]
   KnowledgeService="*res://src/core/knowledge/KnowledgeService.gd"
   ```

2. Restart Godot editor to reload autoloads

3. Verify autoload initialization order in Project Settings

### Issue: Assets Not Loading
**Symptoms**: Missing textures, models, or shaders

**Solutions**:
1. Update asset paths in code:
   ```gdscript
   # Old
   var shader = load("res://shaders/example.gdshader")
   
   # New
   var shader = load("res://assets/shaders/example.gdshader")
   ```

2. Clear Godot's import cache:
   ```bash
   rm -rf .godot/imported/
   # Then reopen project
   ```

## Common Runtime Errors

### Issue: "Invalid call. Nonexistent function"
**Symptoms**: Function calls failing at runtime

**Possible Causes**:
1. **Renamed or moved functions**
   - Check if function was refactored
   - Search for new location: `grep -r "function_name" src/`

2. **Signal connection issues**
   ```gdscript
   # Verify signal exists
   if node.has_signal("signal_name"):
       node.signal_name.connect(callback)
   ```

3. **Type mismatches**
   ```gdscript
   # Ensure correct types
   var panel: Panel = get_node("Panel") as Panel
   if panel:
       panel.do_something()
   ```

### Issue: "Attempt to call function on null instance"
**Solutions**:
1. **Add null checks**:
   ```gdscript
   func safe_process(node: Node) -> void:
       if not node:
           push_error("Node is null")
           return
       
       if not is_instance_valid(node):
           push_error("Node is invalid")
           return
       
       node.process()
   ```

2. **Use @onready correctly**:
   ```gdscript
   # Wrong - node might not exist yet
   var panel: Panel = $Panel
   
   # Right - waits for _ready
   @onready var panel: Panel = $Panel
   ```

### Issue: Performance Degradation
**Symptoms**: Low FPS, stuttering, high memory usage

**Diagnostics**:
```gdscript
# In debug console (F1)
performance
memory
models
```

**Solutions**:
1. **Check for memory leaks**:
   ```gdscript
   # Ensure objects are freed
   func _exit_tree() -> void:
       if is_instance_valid(temp_object):
           temp_object.queue_free()
   ```

2. **Profile performance**:
   ```bash
   ./tools/scripts/run_rendering_benchmark.gd
   ```

3. **Optimize scene complexity**:
   - Use LOD (Level of Detail) system
   - Implement culling for off-screen objects
   - Reduce polygon count in models

## UI/Theme Issues

### Issue: UI Elements Not Styled
**Symptoms**: Default Godot styling instead of NeuroVis theme

**Solutions**:
1. **Ensure UIThemeManager is loaded**:
   ```gdscript
   func _ready() -> void:
       if has_node("/root/UIThemeManager"):
           UIThemeManager.apply_theme(self)
   ```

2. **Check theme mode**:
   ```gdscript
   # In debug console
   UIThemeManager.get_current_theme()
   ```

3. **Force theme refresh**:
   ```gdscript
   UIThemeManager.refresh_all_themes()
   ```

### Issue: Panel Not Displaying Information
**Symptoms**: Info panel shows but content is empty

**Solutions**:
1. **Verify data source**:
   ```gdscript
   var data = KnowledgeService.get_structure("hippocampus")
   if data.is_empty():
       push_error("No data for structure")
   ```

2. **Check panel creation**:
   ```gdscript
   var panel = InfoPanelFactory.create_info_panel()
   if not panel:
       push_error("Failed to create panel")
   ```

## Selection System Issues

### Issue: Can't Select Brain Structures
**Symptoms**: Right-click doesn't select structures

**Diagnostics**:
```gdscript
# Check if selection manager exists
print(has_node("/root/BrainStructureSelectionManager"))

# Check collision layers
print(structure.collision_layer)
print(structure.collision_mask)
```

**Solutions**:
1. **Verify collision setup**:
   - Structures need CollisionShape3D
   - Correct collision layers (usually layer 1)
   - Selection raycast on matching mask

2. **Check input mapping**:
   ```
   Project Settings > Input Map > "select_structure"
   Should be: Mouse Button Right
   ```

## Build/Export Issues

### Issue: Exported Build Crashes
**Symptoms**: Works in editor but not in build

**Common Causes**:
1. **Missing resources**:
   - Ensure all resources use `preload()` or `load()`
   - Check export filters in Project Settings

2. **Debug-only code**:
   ```gdscript
   # Wrap debug code
   if OS.is_debug_build():
       print("Debug info")
   ```

3. **Path issues**:
   - Use `res://` paths, not absolute paths
   - Ensure case-sensitive filenames match

## Quick Diagnostic Commands

```bash
# Find broken scene references
grep -r "res://core/\|res://ui/\|res://scenes/" src/ --include="*.tscn"

# Check for old autoload paths
grep "res://core/\|res://ui/" project.godot

# Find potential null reference issues
grep -r "get_node\|$" src/ --include="*.gd" | grep -v "@onready"

# List large files that might cause performance issues
find src -name "*.gd" -exec wc -l {} + | sort -rn | head -20

# Check for missing assets
find src -name "*.gd" -exec grep -H "load\|preload" {} \; | grep -v "res://src/\|res://assets/"
```

## Getting Help

### Information Sources
1. **Check debug console** (F1):
   ```
   help - Show available commands
   tree - Inspect scene tree
   errors - Show recent errors
   ```

2. **Review logs**:
   - Editor: `~/.godot/app_userdata/NeuroVis/logs/`
   - Build: Check console output

3. **Architecture documentation**:
   - `ai/context/BRAIN.md` - Project overview
   - `ai/context/project_architecture.md` - Structure details
   - `docs/guides/new_architecture_guide.md` - Development guide

### Debug Mode Features
```gdscript
# Enable verbose logging
DebugCmd.set_verbose(true)

# Show all active nodes
DebugCmd.tree("UI")

# Profile specific function
DebugCmd.profile_start("my_function")
# ... code ...
DebugCmd.profile_end("my_function")
```

## Prevention Strategies

1. **Always run validation before committing**:
   ```bash
   ./tools/scripts/quick_validation.sh
   ```

2. **Test in clean environment**:
   ```bash
   # Clear cache and test
   rm -rf .godot/
   godot --path .
   ```

3. **Use type safety**:
   - Always add type hints
   - Use `as` for type casting
   - Check null before using

4. **Follow patterns**:
   - Use established patterns from `ai/context/common_patterns.md`
   - Maintain separation of concerns
   - Keep files in correct directories

Remember: Most issues after migration are path-related. When in doubt, check if paths need updating to include `src/` or if assets moved to `assets/`.