# NeuroVis Common Patterns

> Reusable patterns and solutions used throughout the codebase
> Version: 1.0

## Singleton Pattern (Autoloads)

### Service Implementation
```gdscript
# File: ServiceName.gd (in autoloads)
extends Node

# Singleton instance check
var _initialized: bool = false

func _ready() -> void:
    if _initialized:
        push_error("ServiceName already initialized")
        queue_free()
        return
    _initialized = true
    
    # Initialize service
    _setup_service()

func _setup_service() -> void:
    # Service initialization
    pass
```

### Accessing Autoloads Safely
```gdscript
# Safe autoload access pattern
func get_knowledge_service() -> KnowledgeService:
    if not has_node("/root/KnowledgeService"):
        push_error("KnowledgeService not found")
        return null
    return get_node("/root/KnowledgeService") as KnowledgeService
```

## Factory Pattern

### Panel Creation
```gdscript
# Factory for creating UI panels
class_name PanelFactory
extends RefCounted

static func create_panel(type: String) -> Panel:
    match type:
        "info":
            return preload("res://src/ui/panels/InfoPanel.tscn").instantiate()
        "control":
            return preload("res://src/ui/panels/ControlPanel.tscn").instantiate()
        _:
            push_error("Unknown panel type: " + type)
            return null
```

## Observer Pattern (Signals)

### Event Bus Implementation
```gdscript
# Global event bus for decoupled communication
extends Node

# Define signals
signal structure_selected(structure_name: String)
signal theme_changed(theme_mode: int)
signal loading_started()
signal loading_completed()

# Usage in other classes
func _ready() -> void:
    EventBus.structure_selected.connect(_on_structure_selected)
```

### Signal Best Practices
```gdscript
# Emit with validation
func select_structure(name: String) -> void:
    if name.is_empty():
        return
    structure_selected.emit(name)

# One-shot connections
func connect_once(target: Callable) -> void:
    structure_selected.connect(target, CONNECT_ONE_SHOT)
```

## Component Pattern

### Base Component
```gdscript
# Base class for UI components
class_name BaseUIComponent
extends Control

# Component lifecycle
signal component_ready()
signal component_destroyed()

var _is_initialized: bool = false

func initialize(config: Dictionary = {}) -> void:
    if _is_initialized:
        return
    
    _apply_config(config)
    _setup_component()
    _is_initialized = true
    component_ready.emit()

func _apply_config(config: Dictionary) -> void:
    # Override in subclasses
    pass

func _setup_component() -> void:
    # Override in subclasses
    pass

func destroy() -> void:
    component_destroyed.emit()
    queue_free()
```

## State Management

### State Machine Pattern
```gdscript
# Simple state machine for UI or game states
class_name StateMachine
extends Node

enum State {
    IDLE,
    LOADING,
    ACTIVE,
    ERROR
}

var current_state: State = State.IDLE
var previous_state: State = State.IDLE

signal state_changed(old_state: State, new_state: State)

func change_state(new_state: State) -> void:
    if new_state == current_state:
        return
    
    previous_state = current_state
    current_state = new_state
    state_changed.emit(previous_state, current_state)
    
    _enter_state(current_state)

func _enter_state(state: State) -> void:
    match state:
        State.IDLE:
            _enter_idle()
        State.LOADING:
            _enter_loading()
        State.ACTIVE:
            _enter_active()
        State.ERROR:
            _enter_error()
```

## Resource Management

### Lazy Loading Pattern
```gdscript
# Load resources only when needed
class_name ResourceCache
extends RefCounted

static var _cache: Dictionary = {}

static func get_resource(path: String) -> Resource:
    if path in _cache:
        return _cache[path]
    
    var resource = load(path)
    if resource:
        _cache[path] = resource
    else:
        push_error("Failed to load resource: " + path)
    
    return resource

static func clear_cache() -> void:
    _cache.clear()
```

### Preloading Pattern
```gdscript
# Preload frequently used resources
class_name AssetPreloader
extends Node

# Preload at compile time
const BRAIN_MODEL = preload("res://assets/models/brain.glb")
const SELECT_SOUND = preload("res://assets/audio/select.ogg")

# Runtime preloading
var _textures: Dictionary = {}

func preload_textures() -> void:
    var texture_paths = [
        "res://assets/textures/brain_diffuse.png",
        "res://assets/textures/brain_normal.png"
    ]
    
    for path in texture_paths:
        _textures[path] = load(path)
```

## UI Patterns

### Responsive Component
```gdscript
# Component that adapts to container size
extends Panel

var _min_size: Vector2 = Vector2(200, 150)
var _max_size: Vector2 = Vector2(800, 600)

func _ready() -> void:
    resized.connect(_on_resized)
    _update_layout()

func _on_resized() -> void:
    _update_layout()

func _update_layout() -> void:
    var current_size = size
    
    # Adjust font size based on panel size
    var font_size = int(current_size.y * 0.05)
    font_size = clamp(font_size, 12, 24)
    
    # Update all labels
    for label in find_children("*", "Label"):
        label.add_theme_font_size_override("font_size", font_size)
```

### Modal Dialog Pattern
```gdscript
# Reusable modal dialog
class_name ModalDialog
extends Control

signal confirmed()
signal cancelled()

@onready var overlay: ColorRect = $Overlay
@onready var dialog: Panel = $Dialog

func show_dialog() -> void:
    visible = true
    overlay.modulate.a = 0.0
    dialog.scale = Vector2(0.8, 0.8)
    
    var tween = create_tween()
    tween.parallel().tween_property(overlay, "modulate:a", 0.7, 0.3)
    tween.parallel().tween_property(dialog, "scale", Vector2.ONE, 0.3)\
        .set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func hide_dialog() -> void:
    var tween = create_tween()
    tween.parallel().tween_property(overlay, "modulate:a", 0.0, 0.2)
    tween.parallel().tween_property(dialog, "scale", Vector2(0.8, 0.8), 0.2)
    tween.tween_callback(func(): visible = false)
```

## Performance Patterns

### Object Pooling
```gdscript
# Generic object pool
class_name ObjectPool
extends RefCounted

var _pool: Array = []
var _active: Array = []
var _create_func: Callable

func _init(create_function: Callable, initial_size: int = 10):
    _create_func = create_function
    
    # Pre-populate pool
    for i in initial_size:
        _pool.append(_create_func.call())

func get_object() -> Object:
    var obj: Object
    
    if _pool.is_empty():
        obj = _create_func.call()
    else:
        obj = _pool.pop_back()
    
    _active.append(obj)
    return obj

func return_object(obj: Object) -> void:
    var index = _active.find(obj)
    if index >= 0:
        _active.remove_at(index)
        _pool.append(obj)
```

### Debounce Pattern
```gdscript
# Prevent excessive function calls
class_name Debouncer
extends RefCounted

var _timer: Timer
var _callback: Callable

func _init(callback: Callable, delay: float = 0.3):
    _callback = callback
    _timer = Timer.new()
    _timer.wait_time = delay
    _timer.one_shot = true
    _timer.timeout.connect(_on_timeout)

func call_debounced() -> void:
    _timer.stop()
    _timer.start()

func _on_timeout() -> void:
    _callback.call()
```

## Data Patterns

### Data Validation
```gdscript
# Validate and sanitize input data
class_name DataValidator
extends RefCounted

static func validate_structure_data(data: Dictionary) -> bool:
    var required_fields = ["id", "name", "mesh_path"]
    
    for field in required_fields:
        if not data.has(field):
            push_error("Missing required field: " + field)
            return false
        
        if data[field] == null or data[field] == "":
            push_error("Empty required field: " + field)
            return false
    
    # Type validation
    if not data["id"] is String:
        push_error("Invalid type for id field")
        return false
    
    return true
```

### Data Transformation
```gdscript
# Transform data between formats
class_name DataTransformer
extends RefCounted

static func structure_to_display(structure: Dictionary) -> Dictionary:
    return {
        "title": structure.get("displayName", "Unknown"),
        "description": structure.get("shortDescription", ""),
        "details": {
            "functions": structure.get("functions", []),
            "clinical": structure.get("clinicalRelevance", "")
        }
    }
```

## Error Handling Patterns

### Result Type Pattern
```gdscript
# Return results with error information
class_name Result
extends RefCounted

var success: bool = false
var value: Variant = null
var error: String = ""

static func ok(val: Variant) -> Result:
    var result = Result.new()
    result.success = true
    result.value = val
    return result

static func err(error_msg: String) -> Result:
    var result = Result.new()
    result.success = false
    result.error = error_msg
    return result

# Usage
func load_structure(id: String) -> Result:
    if id.is_empty():
        return Result.err("Invalid structure ID")
    
    var data = KnowledgeService.get_structure(id)
    if data.is_empty():
        return Result.err("Structure not found: " + id)
    
    return Result.ok(data)
```

## Testing Patterns

### Test Structure
```gdscript
# Standard test class structure
extends TestFramework

func setup() -> void:
    # Run before each test
    pass

func teardown() -> void:
    # Run after each test
    pass

func test_feature_basic() -> void:
    # Arrange
    var component = Component.new()
    
    # Act
    var result = component.process_data(test_data)
    
    # Assert
    assert_true(result.success)
    assert_equals(result.value, expected_value)

func test_feature_edge_case() -> void:
    # Test edge cases and error conditions
    pass
```

These patterns provide consistent, maintainable solutions to common problems in the NeuroVis codebase. Use them as templates and adapt as needed for specific requirements.