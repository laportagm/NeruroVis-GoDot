# NeuroVis

An educational neuroscience visualization platform built with Godot 4.4.1 for interactive 3D brain anatomy exploration.

## Overview

NeuroVis provides medical students, researchers, and healthcare professionals with an immersive tool for learning neuroanatomy through interactive 3D visualization, AI-powered assistance, and comprehensive educational content.

## Features

- **3D Brain Visualization**: High-quality anatomical models with medical-grade rendering
- **Interactive Selection**: Click to explore brain structures with detailed information
- **AI Assistant**: Integrated Gemini AI for contextual explanations
- **Dual Theme System**: Enhanced (student-friendly) and Minimal (clinical) themes
- **Accessibility**: Full keyboard navigation and screen reader support
- **Educational Content**: Comprehensive anatomical database with clinical relevance

## Project Structure

```
neurovis/
├── src/          # Source code (core, ui, scenes)
├── assets/       # 3D models, shaders, data
├── tests/        # Test suite
├── docs/         # User documentation
├── ai/           # AI workspace and context
├── tools/        # Development tools
└── config/       # Configuration files
```

## Quick Start

1. Install Godot 4.4.1
2. Clone this repository
3. Open `project.godot` in Godot
4. Press F5 to run

## Development

For development guidelines and architecture details, see:
- `ai/context/BRAIN.md` - Project overview and context
- `ai/context/project_architecture.md` - Architecture documentation
- `docs/guides/` - Development guides

## Testing

Run the test suite:
```bash
./tools/scripts/quick_test.sh
```

## License

MIT License - See LICENSE file for details