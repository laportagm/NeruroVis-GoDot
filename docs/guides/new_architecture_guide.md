# NeuroVis Development Guide - New Architecture

> Essential guide for working with the clean, modular architecture
> Version: 1.0 | Date: 2025-01-02

## Quick Start

Welcome to the new NeuroVis architecture! This guide will help you navigate and contribute to the project effectively.

### Key Changes
1. **All source code** is now in `src/`
2. **Clean root directory** with only essential files
3. **Dedicated AI workspace** at `ai/`
4. **Strict separation** between code, assets, docs, and tests

### Essential Reading
- `ai/context/BRAIN.md` - Project overview and context
- `ai/context/project_architecture.md` - Architecture details
- `ai/context/feature_inventory.md` - Feature locations

## Directory Structure

```
neurovis/
├── src/              # ALL source code
│   ├── core/         # Business logic
│   ├── ui/           # User interface
│   ├── scenes/       # Godot scenes
│   └── scripts/      # Utility scripts
├── assets/           # Non-code resources
├── tests/            # Test suite
├── docs/             # Documentation
├── ai/               # AI workspace
├── tools/            # Dev tools
└── config/           # Configuration
```

## Common Development Tasks

### Adding a New Feature

1. **Determine the type**:
   - Core business logic → `src/core/`
   - User interface → `src/ui/`
   - New feature module → `src/features/`

2. **Create the structure**:
   ```bash
   # Example: Adding a new analysis feature
   mkdir -p src/features/analysis
   touch src/features/analysis/AnalysisManager.gd
   touch src/features/analysis/AnalysisUI.gd
   ```

3. **Follow naming conventions**:
   - Classes: `PascalCase` with `class_name`
   - Files: Match class name (`AnalysisManager.gd`)
   - Functions: `snake_case()`
   - Variables: `snake_case`

### Adding UI Components

1. **Create in appropriate subdirectory**:
   ```
   src/ui/
   ├── components/   # Reusable components
   ├── panels/       # Full panels
   └── theme/        # Theme-related
   ```

2. **Use the component factory**:
   ```gdscript
   var panel = InfoPanelFactory.create_info_panel()
   ```

3. **Apply theme system**:
   ```gdscript
   UIThemeManager.apply_theme(my_component)
   ```

### Writing Tests

1. **Place tests parallel to source**:
   ```
   src/core/analysis/AnalysisManager.gd
   tests/unit/core/analysis/test_analysis_manager.gd
   ```

2. **Use test framework**:
   ```gdscript
   extends TestFramework
   
   func test_analysis_basic():
       var manager = AnalysisManager.new()
       assert_true(manager.analyze() != null)
   ```

### Working with Assets

1. **Asset locations**:
   - 3D Models: `assets/models/`
   - Shaders: `assets/shaders/`
   - Data: `assets/data/`
   - Materials: `assets/materials/`

2. **Reference assets**:
   ```gdscript
   # Correct
   var model = load("res://assets/models/brain_model.glb")
   
   # Incorrect (old structure)
   var model = load("res://models/brain_model.glb")
   ```

## Resource Paths Quick Reference

### Old → New Path Mappings

```
res://core/...       → res://src/core/...
res://ui/...         → res://src/ui/...
res://scenes/...     → res://src/scenes/...
res://scripts/...    → res://src/scripts/...
res://shaders/...    → res://assets/shaders/...
```

### Autoload Services

All autoloads have been updated to new paths:
- `KnowledgeService` → `res://src/core/knowledge/KnowledgeService.gd`
- `AIAssistant` → `res://src/core/ai/AIAssistantService.gd`
- `UIThemeManager` → `res://src/ui/panels/UIThemeManager.gd`

## Best Practices

### 1. Maintain Separation of Concerns
- **DON'T** mix UI code with business logic
- **DON'T** put documentation in source directories
- **DON'T** commit .uid files

### 2. Use Feature-Based Organization
```
src/features/
├── visualization/    # All viz-related code
├── interaction/      # All interaction code
└── educational/      # All educational features
```

### 3. Keep Root Clean
Only these files belong in root:
- `project.godot`
- `README.md`
- `LICENSE` / `LICENSES.md`
- `.gitignore`
- Workspace files

### 4. Document in AI Context
When adding significant features:
1. Update `ai/context/feature_inventory.md`
2. Add patterns to `ai/context/`
3. Keep `BRAIN.md` current

## Validation and Quality

### Before Committing

1. **Run architecture validation**:
   ```bash
   ./tools/scripts/quick_validation.sh
   ```

2. **Check for common issues**:
   ```bash
   # No .uid files
   find . -name "*.uid" | wc -l  # Should be 0
   
   # No files in wrong directories
   find src -name "*.md" | wc -l  # Should be 0
   ```

3. **Run tests**:
   ```bash
   ./tools/scripts/quick_test.sh
   ```

### Architecture Rules

1. **src/** contains ONLY source code (.gd, .tscn)
2. **assets/** contains ONLY non-code resources
3. **docs/** contains ONLY user documentation
4. **ai/context/** contains AI-relevant documentation
5. **tests/** mirrors src/ structure

## Troubleshooting

### Common Issues After Migration

1. **"Script not found" errors**
   - Update path to include `src/`
   - Check scene file references

2. **Broken autoloads**
   - Verify project.godot has updated paths
   - Restart Godot editor

3. **Missing assets**
   - Check assets/ directory
   - Update load() paths in code

4. **Test failures**
   - Update test import paths
   - Check test scene references

### Getting Help

1. Check `ai/context/BRAIN.md` for project overview
2. Run debug console (F1) for diagnostics
3. Use `tree` or `find` commands to locate files
4. Check migration summary at `ai/context/migration_summary.md`

## Quick Commands

```bash
# Find a file
find . -name "ClassName.gd" -type f

# Check architecture
./tools/scripts/quick_validation.sh

# Update all paths in a file
sed -i '' 's|res://core/|res://src/core/|g' myfile.gd

# Count files by type
find src -name "*.gd" | wc -l

# List recent changes
git status src/
```

## Next Steps

1. Familiarize yourself with the new structure
2. Update your local development environment
3. Review the feature inventory
4. Start developing with confidence!

Remember: The clean architecture makes development easier and more maintainable. When in doubt, check the AI context documents for guidance.