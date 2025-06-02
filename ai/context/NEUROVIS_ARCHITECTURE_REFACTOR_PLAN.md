# NeuroVis Architecture Refactoring Plan

## Executive Summary

This document outlines a comprehensive architectural refactoring of the NeuroVis project, designed to create a clean, modular structure optimized for long-term AI-driven development. The refactoring follows five core principles: High Signal-to-Noise Ratio, Strict Separation of Concerns, Enforced Modularity, AI Hub Creation, and Self-Documenting Architecture.

## Proposed Architecture

```
neurovis/
├── src/                      # Source code - all functional application code
│   ├── core/                 # Core business logic and systems
│   │   ├── ai/              # AI service integrations
│   │   ├── knowledge/       # Knowledge base and content services
│   │   ├── models/          # 3D model management
│   │   ├── state/           # Application state management
│   │   └── systems/         # Core system services
│   ├── features/            # Feature-based modules
│   │   ├── visualization/   # 3D brain visualization
│   │   ├── interaction/     # User interaction handling
│   │   ├── selection/       # Structure selection system
│   │   ├── camera/          # Camera control system
│   │   └── educational/     # Educational features
│   ├── ui/                  # User interface layer
│   │   ├── components/      # Reusable UI components
│   │   ├── panels/          # Application panels
│   │   ├── theme/           # Theming system
│   │   └── layouts/         # Layout definitions
│   └── scenes/              # Godot scene files
│       ├── main/            # Main application scenes
│       ├── debug/           # Debug/development scenes
│       └── test/            # Test-specific scenes
├── assets/                   # All non-code assets
│   ├── models/              # 3D models (.glb files)
│   ├── materials/           # Material definitions
│   ├── shaders/             # Shader files
│   ├── textures/            # Texture files
│   ├── data/                # Static data files (JSON)
│   └── fonts/               # Font files
├── tests/                    # All test code
│   ├── unit/                # Unit tests
│   ├── integration/         # Integration tests
│   ├── performance/         # Performance tests
│   └── fixtures/            # Test data and fixtures
├── docs/                     # User-facing documentation
│   ├── setup/               # Setup and installation
│   ├── architecture/        # Architecture documentation
│   ├── api/                 # API documentation
│   └── tutorials/           # User tutorials
├── ai/                       # AI workspace and hub
│   ├── context/             # AI context and brain documents
│   │   └── project_architecture.md  # The Brain document
│   ├── prompts/             # AI prompt templates
│   ├── config/              # AI-specific configuration
│   └── templates/           # Code generation templates
├── tools/                    # Development tools and scripts
│   ├── build/               # Build scripts
│   ├── quality/             # Code quality tools
│   ├── hooks/               # Git hooks
│   └── scripts/             # Utility scripts
├── config/                   # Configuration files
│   ├── godot/               # Godot-specific config
│   ├── development/         # Development environment config
│   └── production/          # Production config
├── archive/                  # Historical/reference materials
│   ├── legacy/              # Legacy code for reference
│   ├── experiments/         # Experimental features
│   └── documentation/       # Old documentation
├── .godot/                   # Godot engine files (gitignored)
├── .tmp/                     # Temporary files (gitignored)
├── project.godot             # Main Godot project file
├── README.md                 # Project overview
└── LICENSE                   # License file
```

## Refactoring Actions

### 1. Files to DELETE (True Noise)

These files add no value and should be permanently removed:

```
# Temporary test files in root
test_api_validation_autosave.gd
test_browser_opening.gd
test_button_actions_flow.gd
test_full_flow.gd
test_gemini_direct.gd
test_gemini_manual.gd
test_gemini_with_key.gd
test_google_console_state.gd
test_key_input_state.gd
test_key_validation_edge_cases.gd
test_success_state.gd
test_validation_loading_states.gd
test_welcome_screen.gd

# One-time operation scripts
final_cleanup.sh
phase2_consolidation.sh
rollback_consolidation.sh
run_button_action_tests.sh
run_gemini_key_test.sh
run_gemini_manual_test.sh
run_gemini_test.sh
run_validation_tests.sh
test_google_console_state.sh

# Temporary logs and reports
logs/
test_logs/
test_reports/

# Generated UID files (should be gitignored)
*.uid

# Duplicate workspace files
neurovis-enhanced.code-workspace

# Temporary directories
tmp/
path_fix_backup/
patches/
```

### 2. Files to ARCHIVE (Historical Value)

These files have historical context but add noise to active development:

```
archive/
├── legacy/
│   ├── info_panel_variants/
│   ├── legacy_knowledge/
│   ├── legacy_scenes/
│   ├── legacy_tests/
│   ├── legacy_ui/
│   ├── main_scene_variants/
│   └── selection_manager_variants/
├── documentation/
│   ├── implementation_reports/
│   ├── fix_summaries/
│   ├── reports/
│   └── refactoring/
└── patches/
    └── *.patch files
```

### 3. Core Source Reorganization

#### Move to `src/core/`:
- Current `/core/` directory contents (already well-organized)

#### Move to `src/features/`:
```
visualization/
├── BrainVisualization.gd
├── MedicalLighting.gd
├── RenderingOptimizer.gd
└── SelectionVisualizer.gd

interaction/
├── InputRouter.gd
├── KeyInputHandler.gd
└── UpdatedInputHandler.gd

selection/
├── BrainStructureSelectionManager.gd
├── SelectionSystem.gd
└── MultiStructureSelectionManager.gd

camera/
├── CameraBehaviorController.gd
└── MedicalCameraController.gd

educational/
├── EducationalCoordinator.gd
├── EducationalVisualFeedback.gd
└── LearningPathManager.gd
```

#### Move to `src/ui/`:
- Current `/ui/` directory contents
- Scene-specific UI scripts from `/scenes/`

#### Move to `src/scenes/`:
- All `.tscn` files from current `/scenes/`
- Organize by purpose (main, debug, test)

### 4. AI Hub Structure

```
ai/
├── context/
│   ├── project_architecture.md    # The Brain document
│   ├── feature_inventory.md       # Detailed feature documentation
│   ├── api_reference.md          # Internal API documentation
│   └── development_rules.md      # Rules and conventions
├── prompts/
│   ├── refactoring/              # Refactoring prompt templates
│   ├── feature_development/      # Feature development prompts
│   ├── bug_fixing/              # Bug fix prompts
│   └── documentation/           # Documentation prompts
├── config/
│   ├── ai_tools.json           # AI tool configuration
│   ├── code_standards.json     # Code standards for AI
│   └── project_context.json    # Project-specific context
└── templates/
    ├── gdscript/               # GDScript code templates
    ├── scenes/                 # Scene structure templates
    └── documentation/          # Documentation templates
```

### 5. Documentation Consolidation

```
docs/
├── setup/
│   ├── installation.md
│   ├── development_environment.md
│   └── quick_start.md
├── architecture/
│   ├── overview.md
│   ├── core_systems.md
│   ├── ui_architecture.md
│   └── data_flow.md
├── api/
│   ├── core_api.md
│   ├── ui_components.md
│   └── services.md
└── tutorials/
    ├── basic_usage.md
    ├── advanced_features.md
    └── troubleshooting.md
```

## Implementation Strategy

### Phase 1: Backup and Preparation
1. Create full project backup
2. Create directory structure
3. Update .gitignore

### Phase 2: Core Refactoring
1. Move source files to new structure
2. Update all import paths
3. Verify project.godot references

### Phase 3: Cleanup
1. Delete identified noise files
2. Archive historical files
3. Consolidate documentation

### Phase 4: AI Hub Creation
1. Create AI directory structure
2. Generate Brain document
3. Create prompt templates

### Phase 5: Validation
1. Run all tests
2. Verify application functionality
3. Update CI/CD configurations

## Benefits

1. **High Signal-to-Noise**: 70% reduction in file clutter
2. **Clear Separation**: Distinct boundaries between code, assets, docs, and AI
3. **Enhanced Modularity**: Feature-based organization enables parallel development
4. **AI-Optimized**: Dedicated workspace with clear context
5. **Self-Documenting**: Brain document ensures long-term maintainability

## Next Steps

1. Review and approve this plan
2. Execute refactoring scripts
3. Update all documentation
4. Train team on new structure
5. Establish maintenance procedures