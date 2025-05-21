# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

NeuroVis is an AI-Enhanced Brain Anatomy Visualizer desktop application built with Godot Engine 4.2. It aims to create an advanced, interactive, and intuitive desktop educational tool that enhances learning and understanding of neuroanatomy through intelligent interaction with 3D brain models, supported by an AI assistant for dynamic explanations and Q&A.

## Development Environment

- **Primary Framework:** Godot Engine 4.2
- **Primary Language:** GDScript
- **Development OS:** macOS
- **Target OS:** Windows 10+ and macOS
- **Version Control:** Git

## Common Commands

### Godot Engine Commands

- **Open the Project in Godot Editor:**
  ```bash
  godot -e --path /Users/gagelaporta/A1-NeuroVis
  ```

- **Run the Project:**
  ```bash
  godot --path /Users/gagelaporta/A1-NeuroVis
  ```

- **Run a Specific Scene:**
  ```bash
  godot /Users/gagelaporta/A1-NeuroVis/scenes/node_3d.tscn
  ```

- **Debug Mode:**
  ```bash
  godot -d --path /Users/gagelaporta/A1-NeuroVis
  ```

- **Export Project for macOS:**
  ```bash
  godot --headless --path /Users/gagelaporta/A1-NeuroVis --export-release "macOS" /path/to/output/NeuroVis.dmg
  ```

- **Export Project for Windows:**
  ```bash
  godot --headless --path /Users/gagelaporta/A1-NeuroVis --export-release "Windows Desktop" /path/to/output/NeuroVis.exe
  ```

## Project Structure

- **`/assets/`**: Contains all project assets
  - **`/data/`**: Data files for the brain anatomy information (anatomical_data.json)
  - **`/icons/`**: Application icons and UI icons
  - **`/models/`**: 3D models of brain anatomy (Brainstem, Half_Brain, Internal_Structures)
  - **`/textures/`**: Textures for 3D models

- **`/scenes/`**: Godot scene files (.tscn)
  - Currently contains a basic `node_3d.tscn` which is the starting point for the 3D visualization
  - `node_3d.gd` contains the scene's script functionality
  - `ui_info_panel.tscn`: Scene for the detailed anatomical information panel

- **`/scripts/`**: Contains GDScript files for application logic
  - `KnowledgeBase.gd`: Manages loading and accessing anatomical data
  - `NeuralNet.gd`: Handles 3D visualization of neural structures
  - `ui_info_panel.gd`: Script for the `ui_info_panel.tscn`, handles displaying structure data

- **`/docs/`**: Contains comprehensive project documentation
  - **`/Setup_Documentation/`**: Initial project setup files
  - **`/Roadmap_Docs/`**: Development roadmap and phase details
  - **`/AI_Prompting/`**: Guides for AI-assisted development
  - **`/Expansion/`**: Future content expansion plans

## Application Architecture

The project follows Godot's scene and node-based architecture:

1. **3D Visualization Core**:
   - 3D brain models loaded and displayed in a Godot 3D scene
   - Camera controls for orbit, zoom, and pan
   - Selection system for anatomical structures

2. **Information Display**:
   - Local knowledge base (`anatomical_data.json`) managed by `KnowledgeBase.gd` (Autoload: `KB`).
   - A dedicated UI panel (`StructureInfoPanel` from `ui_info_panel.tscn`) displays detailed structure information.

3. **AI Assistant Integration**:
   - Online API calls to third-party LLM service 
   - Prompts for neuroanatomy Q&A and explanations

## Autoloads

The project uses the following Autoload singletons for global functionality:

1. **`KB` (`res://scripts/KnowledgeBase.gd`)**:
   - Manages loading and accessing anatomical data from JSON files globally.

2. **`ModelSwitcherGlobal` (`res://scripts/ModelSwitcher.gd`)**:
   - Manages the visibility state of different 3D brain models globally across all scenes.

3. **`DebugCmd` (`res://scripts/DebugCommands.gd`)**:
   - Provides a debug command system for development builds (conditionally loaded based on `OS.is_debug_build()`).

## Key Classes and Resources

1. **KnowledgeBase (KnowledgeBase.gd)**:
   - Loads anatomical data from JSON
   - Provides methods to access structure information
   - Handles errors and status tracking for data loading
   - **Autoload Access:** Available globally as `KB`

2. **ModelSwitcher (ModelSwitcher.gd)**:
   - Manages 3D brain model visibility and registration
   - Handles model switching functionality with signals for UI updates
   - **Autoload Access:** Available globally as `ModelSwitcherGlobal`

3. **NeuralNet (NeuralNet.gd)**:
   - Manages 3D visualization of neural structures
   - Core class for brain visualization functionality

4. **Main Scene (node_3d.tscn)**:
   - Entry point for the application
   - Contains the 3D visualization environment

5. **Anatomical Data (res://assets/data/anatomical_data.json)**:
   - JSON file storing anatomical information.
   - Root object contains: `version` (String), `lastUpdated` (String), and `structures` (Array).
   - Each object in the `structures` array contains: `id` (String, ideally matches 3D mesh NodeName), `displayName` (String), `shortDescription` (String), and `functions` (Array of Strings).

6. **Structure Information Panel (ui_info_panel.tscn & ui_info_panel.gd)**:
   - Scene: `res://scenes/ui_info_panel.tscn` (instantiated in `node_3d.tscn` as `StructureInfoPanel`).
   - Script: `res://scripts/ui_info_panel.gd` (class_name: `StructureInfoPanel`).
   - Role: Displays detailed information (name, description, functions) for a selected anatomical structure. Interacts with `node_3d.gd`.

7. **Debug Commands (DebugCommands.gd)**:
   - Provides debug command registration and execution system
   - Available in debug builds for development and testing functionality
   - **Conditional Autoload Access:** Available as `DebugCmd` when `OS.is_debug_build()` is true

## Development Guidelines

1. **Follow Godot's Best Practices**:
   - Use Godot's scene/node hierarchy for structuring content
   - Use signals for communication between nodes
   - Follow GDScript style guidelines

2. **Version Control**:
   - Make frequent, small commits with clear messages
   - Work primarily on main/master branch (simplified for solo development)
   - Use Git tags for significant milestones

3. **Documentation**:
   - Document complex logic with comments
   - Keep README.md and documentation files updated
   - Use GDScript docstring format for functions

4. **Error Handling**:
   - Implement robust error handling for file operations and API calls
   - Display user-friendly error messages
   - Log errors for debugging

## Project Roadmap

The project is developed through the following phases:

1. **Phase 1: Core 3D Visualization & Basic Interaction**
   - Render 3D model
   - Implement camera controls
   - Enable click-to-select/highlight of model parts
   - Display static name of selected part

2. **Phase 2: Basic Information Display & Local Knowledge Base**
   - Display detailed information for selected structures
   - Implement local JSON knowledge base

3. **Phase 3: In-App AI via Online API**
   - Integrate online LLM API for Q&A
   - Provide dynamic explanations for selected structures

4. **Phase 4: Packaging and Distribution**
   - Create installable versions for Windows and macOS
   - Setup download distribution

5. **Phase 5: Refinement & Content Expansion**
   - Improve UI/UX based on testing
   - Expand knowledge base content
   - Refine AI prompts