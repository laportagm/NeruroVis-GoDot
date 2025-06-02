# NeuroVis Feature Inventory

> Comprehensive catalog of all features and their locations in the clean architecture
> Last Updated: 2025-01-02

## Core Features

### 1. 3D Brain Visualization
**Purpose**: Render anatomical brain models with medical-grade quality

**Key Components**:
- `src/core/visualization/BrainVisualizationCore.gd` - Main visualization system
- `src/core/visualization/MedicalLighting.gd` - Medical-grade lighting setup
- `src/core/visualization/RenderingOptimizer.gd` - Performance optimization
- `src/scenes/visualization_systems/BrainVisualization.tscn` - Main visualization scene

**Models**:
- `assets/models/Half_Brain.glb` - Sectional brain model
- `assets/models/Internal_Structures.glb` - Deep brain structures
- `assets/models/Brainstem(Solid).glb` - Brainstem model

### 2. Interactive Structure Selection
**Purpose**: Allow users to select and explore brain structures

**Key Components**:
- `src/core/interaction/BrainStructureSelectionManager.gd` - Selection logic
- `src/core/visualization/SelectionVisualizer.gd` - Visual feedback
- `src/scenes/visualization_systems/SelectionSystem.tscn` - Selection scene

**Features**:
- Right-click selection
- Visual highlighting
- Multi-selection support
- Educational tooltips

### 3. Knowledge Base System
**Purpose**: Provide anatomical information and educational content

**Key Components**:
- `src/core/knowledge/KnowledgeService.gd` - Primary knowledge service (Autoload)
- `assets/data/anatomical_data.json` - Anatomical database
- `assets/data/anatomical_data_v2.json` - Updated database

**Features**:
- Structure information lookup
- Fuzzy search
- Clinical relevance data
- Educational content

### 4. AI Assistant Integration
**Purpose**: Provide AI-powered educational support

**Key Components**:
- `src/core/ai/AIAssistantService.gd` - AI service interface (Autoload)
- `src/core/ai/GeminiAIService.gd` - Gemini API integration (Autoload)
- `src/ui/panels/GeminiSetupDialog.gd` - API key setup

**Features**:
- Contextual explanations
- Educational Q&A
- Structure analysis
- Learning support

### 5. Camera Control System
**Purpose**: Medical viewing angles and smooth navigation

**Key Components**:
- `src/core/interaction/CameraBehaviorController.gd` - Camera behavior
- `src/core/interaction/MedicalCameraController.gd` - Medical presets
- `src/scripts/systems/CameraSystem.gd` - Camera management

**Features**:
- Orbital rotation
- Medical viewing presets (1, 3, 7 keys)
- Focus on structure (F key)
- Smooth transitions

### 6. Model Management
**Purpose**: Control visibility and properties of 3D models

**Key Components**:
- `src/core/models/ModelRegistry.gd` - Model coordination
- `src/core/models/ModelVisibilityManager.gd` - Visibility control (Autoload)
- `src/core/models/ModelLoader.gd` - Model loading
- `src/scenes/model_control_panel.tscn` - UI panel

**Features**:
- Layer-based visibility
- Model switching
- LOD management
- Material control

### 7. UI Theme System
**Purpose**: Provide adaptive UI for different contexts

**Key Components**:
- `src/ui/panels/UIThemeManager.gd` - Theme management (Autoload)
- `src/ui/theme/StyleEngine.gd` - Style application
- `src/ui/theme/DesignSystem.gd` - Design tokens

**Themes**:
- Enhanced (student-friendly, gamified)
- Minimal (clinical, professional)

### 8. Information Display
**Purpose**: Show educational content about selected structures

**Key Components**:
- `src/ui/panels/InfoPanelFactory.gd` - Panel creation
- `src/ui/panels/EnhancedInformationPanel.gd` - Main info panel
- `src/ui/components/panels/ModularInfoPanel.gd` - Modular implementation

**Features**:
- Quick facts
- Functions
- Clinical relevance
- Study questions

### 9. Input Handling
**Purpose**: Route and process user input

**Key Components**:
- `src/core/interaction/InputRouter.gd` - Central input routing
- `src/core/interaction/KeyInputHandler.gd` - Keyboard shortcuts
- `src/core/interaction/UpdatedInputHandler.gd` - Enhanced input

**Controls**:
- Mouse: Selection, camera orbit
- Keyboard: Shortcuts, debug console (F1)
- Touch: Future support planned

### 10. Debug System
**Purpose**: Development and diagnostic tools

**Key Components**:
- `src/core/systems/DebugCommands.gd` - Debug console (Autoload)
- `src/core/systems/DebugController.gd` - Debug management
- `src/core/visualization/DebugVisualizer.gd` - Visual debugging

**Commands**:
- F1: Open console
- `test autoloads`: Validate services
- `kb status`: Check knowledge base
- `performance`: Show metrics

### 11. Educational Features
**Purpose**: Structured learning support

**Key Components**:
- `src/scenes/educational_systems/EducationalCoordinator.gd` - Learning orchestration
- `src/scripts/ai/LearningPathManager.gd` - Progress tracking
- `src/scripts/ai/QuizSystem.gd` - Assessment

**Features**:
- Learning pathways
- Progress tracking
- Quizzes
- Educational feedback

### 12. Accessibility
**Purpose**: Ensure inclusive access

**Key Components**:
- `src/core/systems/AccessibilityManager.gd` - Accessibility features (Autoload)
- `src/ui/panels/AccessibilitySettingsPanel.gd` - Settings UI
- `src/ui/components/controls/AccessibilityManager.gd` - UI accessibility

**Features**:
- Screen reader support
- Keyboard navigation
- High contrast modes
- Font scaling

## System Integration Map

```
User Input → InputRouter → Feature Systems → UI Update
     ↓                           ↓
Debug Console              Knowledge Service
                                ↓
                          AI Assistant
```

## Autoload Services

1. **KnowledgeService** - Anatomical content
2. **AIAssistant** - AI integration
3. **GeminiAI** - Gemini API
4. **UIThemeManager** - Theme control
5. **ModelSwitcherGlobal** - Model visibility
6. **DebugCmd** - Debug commands
7. **AccessibilityManager** - Accessibility
8. **StructureAnalysisManager** - Content analysis
9. **FeatureFlags** - Feature toggles

## Key Scenes

- **Main**: `src/scenes/main/node_3d.tscn`
- **Debug**: `src/scenes/debug/debug_scene.tscn`
- **Tests**: `src/scenes/test/`

## Configuration

- **Project**: `project.godot`
- **Development**: `project_core_development.godot`
- **Features**: `config/presets/feature_presets.cfg`
- **Memory**: `config/memory_settings.cfg`