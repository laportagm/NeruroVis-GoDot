# NeuroVis Coding Standards

> Standards and conventions for maintaining code quality and consistency
> Version: 1.0 | Architecture: Clean Modular

## GDScript Standards

### Naming Conventions

#### Classes and Files
```gdscript
# Class names: PascalCase with class_name declaration
class_name BrainStructureManager
extends Node

# File name must match class name
# File: BrainStructureManager.gd
```

#### Functions and Variables
```gdscript
# Public functions: snake_case
func calculate_structure_volume(mesh: MeshInstance3D) -> float:
    return 0.0

# Private functions: _snake_case
func _update_internal_state() -> void:
    pass

# Variables: snake_case
var structure_name: String = ""
var _internal_cache: Dictionary = {}  # Private with underscore

# Constants: UPPER_SNAKE_CASE
const MAX_STRUCTURES: int = 100
const DEFAULT_COLOR: Color = Color.WHITE
```

#### Signals and Enums
```gdscript
# Signals: snake_case, descriptive
signal structure_selected(structure_name: String, position: Vector3)
signal animation_completed()

# Enums: PascalCase with UPPER_CASE values
enum VisualizationMode {
    NORMAL,
    WIREFRAME,
    TRANSPARENT,
    HIGHLIGHTED
}
```

### Code Organization

#### File Structure Template
```gdscript
## ClassName.gd
## Brief description of the class purpose
##
## Detailed description if needed, explaining the role
## of this class in the system and its key responsibilities.
##
## @tutorial: Link to relevant documentation

class_name ClassName
extends BaseClass

# === SIGNALS ===
signal example_signal(param: Type)

# === ENUMS ===
enum ExampleEnum { VALUE_ONE, VALUE_TWO }

# === CONSTANTS ===
const CONSTANT_NAME: Type = value

# === EXPORTED VARIABLES ===
@export var exposed_variable: Type = default_value
@export_group("Group Name")
@export var grouped_var: Type

# === PUBLIC VARIABLES ===
var public_variable: Type

# === PRIVATE VARIABLES ===
var _private_variable: Type

# === ONREADY VARIABLES ===
@onready var node_reference: Node = $NodePath

# === BUILT-IN METHODS ===
func _ready() -> void:
    pass

func _process(delta: float) -> void:
    pass

# === PUBLIC METHODS ===
func public_method() -> ReturnType:
    pass

# === PRIVATE METHODS ===
func _private_method() -> void:
    pass

# === SIGNAL HANDLERS ===
func _on_signal_received() -> void:
    pass
```

### Type Safety

#### Always Use Type Hints
```gdscript
# Good
func process_structure(structure: Node3D, color: Color) -> bool:
    var result: bool = true
    var name: String = structure.name
    return result

# Bad
func process_structure(structure, color):
    var result = true
    var name = structure.name
    return result
```

#### Null Safety
```gdscript
# Always check for null
func safe_process(node: Node) -> void:
    if not node:
        push_error("Node is null")
        return
    
    if not is_instance_valid(node):
        push_error("Node is invalid")
        return
    
    # Safe to process
    node.visible = true
```

### Error Handling

#### Use Proper Logging
```gdscript
# Error levels
push_error("Critical error: " + error_message)    # Errors
push_warning("Warning: " + warning_message)       # Warnings
print("Info: " + info_message)                    # Info/Debug

# With context
push_error("[ClassName] Method failed: " + reason)
```

#### Return Early Pattern
```gdscript
func validate_input(data: Dictionary) -> bool:
    # Validate early, return early
    if data.is_empty():
        push_error("Data is empty")
        return false
    
    if not data.has("required_field"):
        push_error("Missing required field")
        return false
    
    # Main logic here
    return true
```

### Documentation

#### Function Documentation
```gdscript
## Calculates the volume of a brain structure mesh.
## @param mesh: The MeshInstance3D to calculate volume for
## @param precision: Calculation precision (0.0 to 1.0)
## @returns: Volume in cubic millimeters, or -1.0 on error
func calculate_volume(mesh: MeshInstance3D, precision: float = 0.9) -> float:
    if not mesh:
        return -1.0
    # Implementation
    return volume
```

#### Inline Comments
```gdscript
# Use comments to explain WHY, not WHAT
# Bad: Increment counter
counter += 1

# Good: Track user interactions for analytics
counter += 1

# Complex logic needs explanation
# Calculate weighted average based on structure importance
var weight: float = importance * 0.7 + size * 0.3
```

## Scene Organization

### Node Naming
- Use descriptive names: `StructureInfoPanel` not `Panel`
- Group related nodes: `UI/Panels/InfoPanel`
- Avoid spaces, use PascalCase: `MainCamera` not `Main Camera`

### Scene Structure
```
MainScene
├── World
│   ├── BrainModel
│   ├── Lighting
│   └── Camera
├── UI
│   ├── Panels
│   │   ├── InfoPanel
│   │   └── ControlPanel
│   └── Dialogs
└── Systems
    ├── SelectionManager
    └── InputHandler
```

## Performance Guidelines

### Object Pooling
```gdscript
# Reuse objects instead of creating new ones
var _panel_pool: Array[Panel] = []

func get_panel() -> Panel:
    if _panel_pool.is_empty():
        return Panel.new()
    return _panel_pool.pop_back()

func return_panel(panel: Panel) -> void:
    panel.visible = false
    _panel_pool.append(panel)
```

### Efficient Signals
```gdscript
# Connect once, disconnect when done
func _ready() -> void:
    structure.selected.connect(_on_structure_selected)

func _exit_tree() -> void:
    if structure.selected.is_connected(_on_structure_selected):
        structure.selected.disconnect(_on_structure_selected)
```

### Avoid Per-Frame Allocations
```gdscript
# Bad: Creates new string every frame
func _process(delta: float) -> void:
    label.text = "FPS: " + str(Engine.get_frames_per_second())

# Good: Update only when changed
var _last_fps: int = 0
func _process(delta: float) -> void:
    var current_fps: int = Engine.get_frames_per_second()
    if current_fps != _last_fps:
        label.text = "FPS: " + str(current_fps)
        _last_fps = current_fps
```

## Best Practices

### Single Responsibility
Each class should have one clear purpose:
```gdscript
# Good: Focused responsibility
class_name StructureSelector  # Only handles selection
class_name StructureRenderer  # Only handles rendering

# Bad: Multiple responsibilities
class_name StructureManager  # Does selection, rendering, data, etc.
```

### Dependency Injection
```gdscript
# Good: Dependencies passed in
class_name StructurePanel
var knowledge_service: KnowledgeService

func initialize(service: KnowledgeService) -> void:
    knowledge_service = service

# Bad: Hard-coded dependencies
func _ready() -> void:
    knowledge_service = get_node("/root/KnowledgeService")
```

### Configuration Over Code
```gdscript
# Good: Configurable behavior
@export var highlight_color: Color = Color.CYAN
@export var selection_distance: float = 100.0

# Bad: Hard-coded values
var highlight_color: Color = Color(0, 1, 1)
var selection_distance: float = 100.0
```

## Code Review Checklist

Before committing, ensure:
- [ ] All functions have type hints
- [ ] No commented-out code
- [ ] Proper error handling with messages
- [ ] Clear variable and function names
- [ ] Documentation for complex logic
- [ ] No hard-coded paths or magic numbers
- [ ] Signals properly connected/disconnected
- [ ] Memory leaks prevented (free objects)
- [ ] Follows file organization template
- [ ] Runs without errors or warnings