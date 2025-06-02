# NeuroVis Clean Architecture Documentation

## Architecture Overview

This document describes the clean, modular architecture implemented for the NeuroVis project. The architecture follows five core principles to ensure maintainability and AI-friendly development.

## Directory Structure

```
neurovis/
├── src/                    # All source code
│   ├── core/              # Core business logic
│   ├── ui/                # User interface
│   ├── scenes/            # Godot scenes
│   └── scripts/           # Utility scripts
├── assets/                 # Non-code resources
│   ├── data/              # JSON data files
│   ├── materials/         # Material definitions
│   ├── models/            # 3D models (.glb)
│   └── shaders/           # Shader files
├── tests/                  # All test code
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── qa/                # QA tests
├── docs/                   # User documentation
│   ├── guides/            # User guides
│   ├── api/               # API docs
│   └── tutorials/         # Tutorials
├── ai/                     # AI workspace
│   ├── context/           # AI context (BRAIN.md)
│   ├── prompts/           # Prompt templates
│   ├── sessions/          # Session logs
│   └── tools/             # AI tools
├── tools/                  # Dev tools
│   ├── scripts/           # Build scripts
│   ├── hooks/             # Git hooks
│   └── quality/           # Quality tools
├── config/                 # Configuration
├── archive/                # Historical artifacts
└── [root files]            # Minimal root
```

## Core Principles

### 1. High Signal-to-Noise Ratio
- Root directory contains only essential files
- All temporary/historical files moved to archive
- Clean, focused directory structure

### 2. Strict Separation of Concerns
- `src/` contains ONLY source code
- `assets/` contains ONLY non-code resources
- `docs/` contains ONLY user documentation
- No mixing of concerns between directories

### 3. Enforced Modularity
- Core systems provide shared functionality
- UI is completely separate from business logic
- Features can be developed independently

### 4. AI Hub Creation
- Dedicated `ai/` workspace for AI agents
- Central BRAIN.md document
- Organized prompts and context

### 5. Self-Documenting Architecture
- Clear, intuitive structure
- Each directory has a single purpose
- This document explains the architecture

## Module Organization

### Core Systems (`src/core/`)
Shared business logic used across the application:
- AI service integrations
- Knowledge base management
- 3D model coordination
- User interaction handling
- Visualization systems

### UI Layer (`src/ui/`)
All user interface code:
- Reusable components
- Application panels
- Theme management
- UI state handling

### Scenes (`src/scenes/`)
Godot scene files organized by purpose:
- Main application scenes
- Debug/development scenes
- Educational feature scenes

## Development Guidelines

### Adding New Features
1. Determine if it's core logic or UI
2. Create appropriate subdirectory
3. Follow existing patterns
4. Update documentation

### File Naming
- Classes: `PascalCase.gd`
- Scenes: `snake_case.tscn`
- Use descriptive names

### Dependencies
- UI can depend on Core
- Core should not depend on UI
- Use signals for loose coupling

## Maintenance

### Regular Tasks
1. Keep root directory clean
2. Archive old documentation
3. Update BRAIN.md when adding features
4. Run architecture validation

### Architecture Validation
Use `./tools/scripts/validate_architecture.sh` to ensure:
- Proper file organization
- No separation violations
- Clean root directory
- Proper naming conventions

## Benefits

1. **Clarity**: Easy to understand project structure
2. **Maintainability**: Clear boundaries prevent drift
3. **AI-Friendly**: Optimized for AI agent navigation
4. **Scalability**: New features don't affect existing code
5. **Performance**: Clean structure enables optimization