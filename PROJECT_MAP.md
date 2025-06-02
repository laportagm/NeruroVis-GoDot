# NeuroVis Project Map

This document provides a comprehensive overview of the NeuroVis project structure, optimized for AI-assisted development.

## 🎯 Entry Points

### Primary Entry Point
- **`scenes/main/node_3d.tscn`** - Main educational interface scene
- **`scenes/main/node_3d.gd`** - Main scene controller (`NeuroVisMainScene` class)

### Key Autoloads (Singletons)
- **`KnowledgeService`** - `core/knowledge/KnowledgeService.gd` - Educational content management
- **`AIAssistant`** - `core/ai/AIAssistantService.gd` - AI-powered learning support
- **`UIThemeManager`** - `ui/panels/UIThemeManager.gd` - Enhanced/Minimal theme system
- **`ModelSwitcherGlobal`** - `core/models/ModelVisibilityManager.gd` - 3D model management
- **`DebugCmd`** - `core/systems/DebugCommands.gd` - Development debugging tools

## 🏗️ Core Architecture

### `/core/` - Business Logic Layer
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `ai/` | AI services for educational support | `AIAssistantService.gd`, `GeminiAIService.gd` |
| `interaction/` | 3D interaction & user input | `BrainStructureSelectionManager.gd`, `MedicalCameraController.gd` |
| `knowledge/` | Educational content management | `KnowledgeService.gd` (primary), `AnatomicalKnowledgeDatabase.gd` (legacy) |
| `models/` | 3D model coordination | `ModelRegistry.gd`, `ModelVisibilityManager.gd`, `LODManager.gd` |
| `systems/` | Core platform systems | `DebugCommands.gd`, `ErrorHandler.gd`, `PerformanceMonitor.gd` |
| `visualization/` | Rendering & visual effects | `SelectionVisualizer.gd`, `MedicalLighting.gd`, `RenderingOptimizer.gd` |

### `/ui/` - User Interface Layer
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `components/` | Reusable UI elements | `BaseUIComponent.gd`, `ResponsiveComponent.gd` |
| `panels/` | Main interface panels | `UIThemeManager.gd`, `EnhancedInformationPanel.gd`, `GeminiSetupDialog.gd` |
| `theme/` | Design system | `DesignSystem.gd`, `StyleEngine.gd` |

### `/scenes/` - Godot Scene Files
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `main/` | Primary educational scenes | `node_3d.tscn` (main), various implementation variants |
| `debug/` | Development & testing scenes | Debug dashboards, test scenes |

### `/assets/` - Content Assets
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `data/` | Educational knowledge base | `anatomical_data.json` (primary educational content) |
| `models/` | 3D brain models | `Half_Brain.glb`, `Internal_Structures.glb`, `Brainstem(Solid).glb` |
| `materials/` | Shaders & visual materials | Medical shaders for brain visualization |

### `/tests/` - Testing Framework
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `framework/` | Testing infrastructure | `TestFramework.gd`, `comprehensive_test.gd` |
| `integration/` | End-to-end tests | Educational workflow tests, AI integration tests |
| `unit/` | Component unit tests | Individual system tests |
| `qa/` | Quality assurance | Selection system validation, performance tests |

### `/tools/` - Development Tools
| Directory | Purpose | Key Files |
|-----------|---------|-----------|
| `scripts/` | Automation & utilities | Performance benchmarks, configuration tools |
| `validation/` | Quality checks | Syntax validation, integration testing |

## 🔧 Development Workflow

### Theme System
- **Enhanced Theme**: Student-friendly, gamified interface (`UIThemeManager.ThemeMode.ENHANCED`)
- **Minimal Theme**: Clinical, professional interface (`UIThemeManager.ThemeMode.MINIMAL`)

### Content Access Pattern
```gdscript
# Primary educational content access
var structure = KnowledgeService.get_structure("hippocampus")
var search_results = KnowledgeService.search_structures("memory")

# Educational panel creation
var panel = InfoPanelFactory.create_info_panel()
panel.display_structure_info(structure)
```

### Debug Commands (F1 console)
- `test autoloads` - Validate core services
- `test ui_safety` - Check UI component safety
- `kb status` - Knowledge base status
- `performance` - Performance metrics
- `memory` - Memory usage monitoring

## 📁 File Organization Principles

### Naming Conventions
- **Classes**: PascalCase with `class_name` declaration
- **Files**: PascalCase for classes, snake_case for utilities
- **Variables/Functions**: snake_case
- **Constants**: ALL_CAPS_SNAKE_CASE

### Directory Rules
- **Maximum 3 levels** of nesting
- **Clear separation** between UI and business logic
- **Educational context** preserved in all naming
- **Single responsibility** per directory

## 🚫 Deprecated/Legacy Files

### Files Marked for Removal
- `ui/panels/minimal_info_panel.gd` - Merged into adaptive system
- `scenes/ui_info_panel.gd` - Legacy, superseded by enhanced system
- `core/knowledge/AnatomicalKnowledgeDatabase.gd` - Being phased out for KnowledgeService

### Multiple Implementations (Need Consolidation)
- `scenes/main/node_3d_*.gd` - Multiple main scene variants
- Various selection manager implementations
- Multiple info panel versions

## 📊 Project Statistics

- **Primary Language**: GDScript (Godot 4.4.1)
- **Architecture**: Modular educational platform
- **Target Users**: Medical students, researchers, healthcare professionals
- **Core Features**: 3D brain visualization, AI assistance, educational content management

---

**Last Updated**: Auto-generated during reorganization
**Maintainer**: Development team
**Version**: 2.1.0