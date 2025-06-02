# NeuroVis Project BRAIN Document

> The authoritative cognitive map for AI agents working on NeuroVis
> Version: 2.0 | Architecture: Clean Modular | Last Updated: 2025-01-02

## Project Identity

**NeuroVis** is an educational neuroscience visualization platform built with Godot 4.4.1. It enables interactive 3D exploration of brain anatomy for medical students, researchers, and healthcare professionals.

## Architecture Overview

The project follows a **Clean Modular Architecture** with strict separation of concerns:

```
src/          → All source code (high signal)
assets/       → All non-code resources 
tests/        → All test code
docs/         → User documentation only
ai/           → AI workspace and context
tools/        → Development tools
config/       → Configuration files
archive/      → Historical artifacts (noise removed)
```

## Core Systems Map

### 1. Source Code (`src/`)

#### Core Business Logic (`src/core/`)
- **ai/**: AI service integrations (Gemini API)
- **knowledge/**: Anatomical knowledge base and search
- **models/**: 3D brain model management
- **interaction/**: User input handling and selection
- **visualization/**: Rendering and visual effects
- **systems/**: Infrastructure (debug, memory, performance)

#### User Interface (`src/ui/`)
- **components/**: Reusable UI elements
- **panels/**: Information panels, controls
- **theme/**: Enhanced/Minimal theme system
- **state/**: UI state management

#### Scenes (`src/scenes/`)
- **main/**: Primary application scenes
- **debug/**: Development/testing scenes
- **educational/**: Learning-focused scenes

### 2. Key Features

1. **3D Brain Visualization**
   - Multiple anatomical models
   - Layer-based visibility control
   - Medical-grade lighting

2. **Interactive Selection**
   - Right-click structure selection
   - Visual highlighting
   - Educational information display

3. **Knowledge Integration**
   - Anatomical database (JSON)
   - Fuzzy search capabilities
   - Clinical relevance data

4. **AI Assistance**
   - Gemini API integration
   - Context-aware explanations
   - Educational support

5. **Accessibility**
   - Enhanced/Minimal themes
   - Keyboard navigation
   - Screen reader support

## Development Rules

### File Organization
1. **Source code** → Only in `src/`
2. **Assets** → Only in `assets/`
3. **Tests** → Only in `tests/`
4. **Documentation** → User docs in `docs/`, AI context in `ai/context/`

### Naming Conventions
- Classes: `PascalCase` with `class_name`
- Functions: `snake_case()`
- Variables: `snake_case`
- Constants: `UPPER_SNAKE_CASE`
- Signals: `snake_case`

### Key Autoloads
- `KnowledgeService` - Primary content service
- `AIAssistant` - AI integration
- `UIThemeManager` - Theme management
- `ModelSwitcherGlobal` - Model visibility
- `DebugCmd` - Debug commands

## AI Integration Points

### Context Location
- Primary: `ai/context/BRAIN.md` (this file)
- Architecture: `ai/context/project_architecture.md`
- Features: `ai/context/features.md`
- CLAUDE instructions: `ai/context/CLAUDE.md`

### Development Workflow
1. Read context from `ai/context/`
2. Use templates from `ai/templates/`
3. Follow patterns in existing code
4. Update relevant documentation
5. Maintain clean architecture

### Key Commands
```bash
# Launch project
godot --path "/path/to/project"

# Run tests
./tools/scripts/quick_test.sh

# Validate architecture
./tools/scripts/validate_architecture.sh
```

## Current State

### Strengths
- Well-organized core systems
- Clean separation of concerns
- Strong educational focus
- Good test coverage

### Active Development
- Performance optimization
- Enhanced AI features
- Expanded educational content
- Multi-user support

### Technical Debt
- Legacy KB system (being phased out)
- Some duplicate UI implementations
- Parser errors need resolution

## Quick Reference

### File Paths
- Main scene: `src/scenes/main/node_3d.tscn`
- Knowledge data: `assets/data/anatomical_data.json`
- Models: `assets/models/*.glb`
- UI panels: `src/ui/panels/`

### Debug Console (F1)
- `test autoloads` - Validate services
- `kb status` - Check knowledge base
- `models` - List 3D models
- `performance` - Check metrics

### Common Issues
1. **Panel not showing**: Check InfoPanelFactory
2. **Selection not working**: Verify BrainStructureSelectionManager
3. **AI timeout**: Check API key configuration

## Architecture Principles

1. **High Signal-to-Noise**: Keep only functional code
2. **Separation of Concerns**: Each directory has one purpose
3. **Modularity**: Features are self-contained
4. **AI-First**: Optimized for AI development
5. **Self-Documenting**: Clear structure and naming

---

This BRAIN document is the single source of truth for understanding NeuroVis. When in doubt, refer to this document and the clean architecture it describes.