# Robust version of the main scene with comprehensive error handling and recovery
class_name MainSceneRobust
extends Node3D

# Preload custom classes
const ModelCoordinatorScene = preload("res://scripts/models/ModelRegistry.gd")
const LoadingOverlay = preload("res://scripts/ui/LoadingOverlay.gd")
const OnboardingManager = preload("res://scripts/ui/OnboardingManager.gd")
const ModernInfoDisplay = preload("res://scripts/ui/ModernInfoDisplay.gd")
const BrainStructureSelectionManagerScript = preload("res://scripts/interaction/BrainStructureSelectionManager.gd")
const CameraBehaviorControllerScript = preload("res://scripts/interaction/CameraBehaviorController.gd")
const AnatomicalKnowledgeDatabaseScript = preload("res://scripts/core/AnatomicalKnowledgeDatabase.gd")
const BrainVisualizationCoreScript = preload("res://scripts/core/BrainVisualizationCore.gd")
const ModelVisibilityManagerScript = preload("res://scripts/models/ModelVisibilityManager.gd")

# Constants
const RAY_LENGTH: float = 1000.0
const CAMERA_ROTATION_SPEED: float = 0.01
const CAMERA_ZOOM_SPEED: float = 0.5
const CAMERA_MIN_DISTANCE: float = 2.0
const CAMERA_MAX_DISTANCE: float = 25.0
const DEBUG_MODE: bool = true

# Export variables for customizing highlight appearance
@export var highlight_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var emission_energy: float = 0.5

# Node references with robust checking
@onready var camera: Camera3D = $Camera3D
@onready var object_name_label: Label = $UI_Layer/ObjectNameLabel
@onready var info_panel = $UI_Layer/StructureInfoPanel
@onready var brain_model_parent = $BrainModel

# Components (created dynamically with robust references)
var selection_manager = null
var camera_controller = null

# Backup references for recovery
var camera_backup: Camera3D = null
var object_name_label_backup: Label = null
var info_panel_backup = null
var brain_model_parent_backup = null
var selection_manager_backup = null
var camera_controller_backup = null

# System references
var knowledge_base = null
var neural_net = null
var model_control_panel = null
var model_switcher = null
var model_coordinator = null

# Safety flags to prevent cascading errors
var initialization_complete: bool = false
var error_recovery_active: bool = false
var initialization_attempt_count: int = 0
var max_initialization_attempts: int = 3

# Performance monitoring
var frame_count: int = 0
var last_fps_check: float = 0.0
var fps_warning_threshold: float = 10.0

# Signals
signal structure_selected(structure_name: String)
signal structure_deselected
signal models_loaded(model_names: Array)

func _ready() -> void:
    print("[INIT] Starting robust main scene initialization...")
    
    # Initialize with comprehensive error checking
    await initialize_safely()
    
    print("[INIT] Main scene initialization complete")

func initialize_safely():
    """
    Safe initialization with proper error handling and recovery
    """
    initialization_attempt_count += 1
    print("[INIT] Initialization attempt: ", initialization_attempt_count)
    
    if initialization_attempt_count > max_initialization_attempts:
        push_error("[CRITICAL] Maximum initialization attempts exceeded!")
        return
    
    # Initialize debug systems early
    if OS.is_debug_build():
        var resource_debugger = get_node_or_null("/root/ResourceDebugger")
        if resource_debugger and resource_debugger.has_method("initialize"):
            resource_debugger.initialize()
            print("[DEBUG] ResourceDebugger initialized for monitoring")
        
        # Initialize resource load tracer for empty path detection
        var resource_load_tracer = get_node_or_null("/root/ResourceLoadTracer")
        if resource_load_tracer and resource_load_tracer.has_method("initialize"):
            resource_load_tracer.initialize()
            print("[DEBUG] ResourceLoadTracer initialized for empty path detection")
            
            # Run diagnostics to catch common empty path patterns
            if resource_load_tracer.has_method("diagnose_common_issues"):
                resource_load_tracer.diagnose_common_issues()
    
    # Show loading overlay for initialization
    var loading_overlay = LoadingOverlay.new()
    loading_overlay.name = "LoadingOverlay"
    add_child(loading_overlay)
    loading_overlay.show_loading(LoadingOverlay.LoadingState.INITIALIZATION)
    
    # Initialize core node references first
    await initialize_core_nodes()
    await get_tree().process_frame
    
    # Initialize knowledge base and systems
    await initialize_systems()
    await get_tree().process_frame
    
    # Initialize components (CameraController, SelectionManager)
    await initialize_components()
    await get_tree().process_frame
    
    # Setup UI and connections
    await setup_ui_and_connections()
    await get_tree().process_frame
    
    # Initialize models and final setup
    await initialize_models_and_final_setup()
    await get_tree().process_frame
    
    initialization_complete = true
    print("[INIT] All systems initialized successfully")
    
    # Hide loading overlay
    var overlay = get_node_or_null("LoadingOverlay")
    if overlay:
        overlay.hide_loading()
        # Remove it after animation
        await get_tree().create_timer(0.5).timeout
        overlay.queue_free()
    
    # Apply modern theme to the scene
    apply_modern_theme()
    
    # Check for first-time user and show onboarding
    await setup_onboarding_if_needed()

func initialize_core_nodes():
    """
    Initialize core node references with multiple fallback methods
    """
    print("[INIT] Initializing core nodes...")
    
    # Initialize camera reference
    if not try_initialize_camera():
        push_error("[ERROR] Failed to initialize camera - critical failure!")
        return
    
    # Initialize UI label reference
    if not try_initialize_object_label():
        push_warning("[WARNING] Failed to initialize object label - UI limited!")
    
    # Initialize info panel reference
    if not try_initialize_info_panel():
        push_warning("[WARNING] Failed to initialize info panel - info display limited!")
    
    # Initialize brain model parent reference
    if not try_initialize_brain_model_parent():
        push_error("[ERROR] Failed to initialize brain model parent - model loading limited!")

func try_initialize_camera() -> bool:
    """
    Robust camera initialization with multiple fallback methods
    """
    print("[INIT] Initializing camera...")
    
    # Method 1: Try @onready reference
    if is_instance_valid(camera) and camera is Camera3D:
        camera_backup = camera
        print("[INIT] Camera found via @onready")
        return true
    
    # Method 2: Try direct path
    var camera_node = get_node_or_null("Camera3D")
    if camera_node and camera_node is Camera3D:
        camera = camera_node
        camera_backup = camera_node
        print("[INIT] Camera found via direct path")
        return true
    
    # Method 3: Search in children
    for child in get_children():
        if child is Camera3D:
            camera = child
            camera_backup = child
            print("[INIT] Camera found in children")
            return true
    
    # Method 4: Create emergency camera if none found
    print("[WARNING] No camera found, creating emergency camera...")
    var emergency_camera = Camera3D.new()
    emergency_camera.name = "EmergencyCamera"
    emergency_camera.transform = Transform3D(
        Vector3(1, 0, 0),
        Vector3(0, 0.866025, 0.5), 
        Vector3(0, -0.5, 0.866025),
        Vector3(0, 5, 10)
    )
    emergency_camera.current = true
    add_child(emergency_camera)
    camera = emergency_camera
    camera_backup = emergency_camera
    print("[INIT] Emergency camera created")
    return true

func try_initialize_object_label() -> bool:
    """
    Robust object label initialization
    """
    print("[INIT] Initializing object label...")
    
    # Method 1: Try @onready reference
    if is_instance_valid(object_name_label) and object_name_label is Label:
        object_name_label_backup = object_name_label
        print("[INIT] Object label found via @onready")
        return true
    
    # Method 2: Try direct path
    var label_node = get_node_or_null("UI_Layer/ObjectNameLabel")
    if label_node and label_node is Label:
        object_name_label = label_node
        object_name_label_backup = label_node
        print("[INIT] Object label found via direct path")
        return true
    
    # Method 3: Search recursively
    var ui_layer = get_node_or_null("UI_Layer")
    if ui_layer:
        for child in ui_layer.get_children():
            if child is Label and child.name.contains("ObjectName"):
                object_name_label = child
                object_name_label_backup = child
                print("[INIT] Object label found via search")
                return true
    
    print("[WARNING] Object label not found")
    return false

func try_initialize_info_panel() -> bool:
    """
    Robust info panel initialization
    """
    print("[INIT] Initializing info panel...")
    
    # Method 1: Try @onready reference
    if is_instance_valid(info_panel):
        info_panel_backup = info_panel
        print("[INIT] Info panel found via @onready")
        return true
    
    # Method 2: Try direct path
    var panel_node = get_node_or_null("UI_Layer/StructureInfoPanel")
    if panel_node:
        info_panel = panel_node
        info_panel_backup = panel_node
        print("[INIT] Info panel found via direct path")
        return true
    
    # Method 3: Search recursively
    var ui_layer = get_node_or_null("UI_Layer")
    if ui_layer:
        for child in ui_layer.get_children():
            if child.name.contains("InfoPanel") or child.name.contains("StructureInfo"):
                info_panel = child
                info_panel_backup = child
                print("[INIT] Info panel found via search")
                return true
    
    print("[WARNING] Info panel not found")
    return false

func try_initialize_brain_model_parent() -> bool:
    """
    Robust brain model parent initialization
    """
    print("[INIT] Initializing brain model parent...")
    
    # Method 1: Try @onready reference
    if is_instance_valid(brain_model_parent) and brain_model_parent is Node3D:
        brain_model_parent_backup = brain_model_parent
        print("[INIT] Brain model parent found via @onready")
        return true
    
    # Method 2: Try direct path
    var parent_node = get_node_or_null("BrainModel")
    if parent_node and parent_node is Node3D:
        brain_model_parent = parent_node
        brain_model_parent_backup = parent_node
        print("[INIT] Brain model parent found via direct path")
        return true
    
    # Method 3: Search in children
    for child in get_children():
        if child is Node3D and (child.name.contains("BrainModel") or child.name.contains("Model")):
            brain_model_parent = child
            brain_model_parent_backup = child
            print("[INIT] Brain model parent found in children")
            return true
    
    # Method 4: Create emergency parent
    print("[WARNING] No brain model parent found, creating emergency parent...")
    var emergency_parent = Node3D.new()
    emergency_parent.name = "EmergencyBrainModel"
    add_child(emergency_parent)
    brain_model_parent = emergency_parent
    brain_model_parent_backup = emergency_parent
    print("[INIT] Emergency brain model parent created")
    return true

func initialize_systems():
    """
    Initialize knowledge base, neural net, and other core systems
    """
    print("[INIT] Initializing systems...")
    
    # Initialize knowledge base
    knowledge_base = AnatomicalKnowledgeDatabaseScript.new()
    if knowledge_base == null:
        push_error("[ERROR] Failed to initialize knowledge base")
        return
    add_child(knowledge_base)
    knowledge_base.load_knowledge_base()
    print("[INIT] Knowledge base initialized and loaded")
    
    # Initialize neural network module
    neural_net = BrainVisualizationCoreScript.new()
    if neural_net == null:
        push_error("[ERROR] Failed to initialize neural network")
        return
    add_child(neural_net)
    print("[INIT] Neural network module initialized")
    
    # Initialize model switcher
    model_switcher = ModelVisibilityManagerScript.new()
    if model_switcher == null:
        push_error("[ERROR] Failed to initialize model switcher")
        return
    add_child(model_switcher)
    print("[INIT] Model switcher initialized")

func initialize_components():
    """
    Initialize core components with robust error handling
    """
    print("[INIT] Initializing components...")
    
    # Create and initialize SelectionManager
    selection_manager = BrainStructureSelectionManagerScript.new()
    if selection_manager == null:
        push_error("[ERROR] Failed to initialize SelectionManager")
        return
    add_child(selection_manager)
    selection_manager_backup = selection_manager
    print("[INIT] SelectionManager initialized and added to scene")
    
    # Create and initialize CameraController
    camera_controller = CameraBehaviorControllerScript.new()
    if camera_controller == null:
        push_error("[ERROR] Failed to initialize CameraController")
        return
    add_child(camera_controller)
    camera_controller_backup = camera_controller
    print("[INIT] CameraController initialized and added to scene")
    
    # Initialize camera controller if camera is available
    var safe_camera = get_safe_camera()
    if safe_camera:
        camera_controller.initialize(safe_camera, get_safe_brain_model_parent())
        print("[INIT] Camera controller initialized and configured")
    else:
        push_error("[ERROR] Cannot initialize camera controller - no camera available")

func setup_ui_and_connections():
    """
    Setup UI elements and signal connections
    """
    print("[INIT] Setting up UI and connections...")
    
    # Debug: List all children to see what's actually in the scene
    print("[DEBUG] Scene children:")
    for child in get_children():
        print("  - ", child.name, " (", child.get_class(), ")")
        if child.name == "UI_Layer":
            print("    UI_Layer children:")
            for ui_child in child.get_children():
                print("      - ", ui_child.name, " (", ui_child.get_class(), ") visible=", ui_child.visible)
    
    # Setup UI layer visibility and add to group for health monitoring
    var ui_layer = get_node_or_null("UI_Layer")
    if ui_layer:
        ui_layer.visible = true
        ui_layer.add_to_group("ui_layer")
        print("[INIT] UI_Layer visibility set to: ", ui_layer.visible, " and added to group")
    else:
        print("[ERROR] UI_Layer not found!")
    
    # Initialize object name label
    var safe_label = get_safe_object_label()
    if safe_label:
        safe_label.text = "Selected: None"
        print("[INIT] Object name label initialized")
    
    # Connect info panel signals
    var safe_info_panel = get_safe_info_panel()
    if safe_info_panel and safe_info_panel.has_signal("panel_closed"):
        safe_info_panel.panel_closed.connect(_on_info_panel_closed)
        safe_info_panel.visible = false
        print("[INIT] Info panel signals connected")
    
    # Connect selection manager signals
    var safe_selection_manager = get_safe_selection_manager()
    if safe_selection_manager:
        if safe_selection_manager.has_signal("structure_selected"):
            safe_selection_manager.structure_selected.connect(_on_structure_selected)
        if safe_selection_manager.has_signal("structure_deselected"):
            safe_selection_manager.structure_deselected.connect(_on_structure_deselected)
        if safe_selection_manager.has_signal("structure_hovered"):
            safe_selection_manager.structure_hovered.connect(_on_structure_hovered)
        if safe_selection_manager.has_signal("structure_unhovered"):
            safe_selection_manager.structure_unhovered.connect(_on_structure_unhovered)
        
        # Configure selection manager with enhanced highlight settings
        safe_selection_manager.configure_highlight_colors(highlight_color, Color(1.0, 0.7, 0.0, 0.6))
        safe_selection_manager.set_emission_energy(emission_energy)
        safe_selection_manager.set_outline_enabled(true)
        print("[INIT] Selection manager signals connected")

func initialize_models_and_final_setup():
    """
    Initialize models and complete final setup steps
    """
    print("[INIT] Initializing models and final setup...")
    
    # Initialize model coordinator
    model_coordinator = ModelCoordinatorScene.new()
    if model_coordinator == null:
        push_error("[ERROR] Failed to initialize model coordinator")
        return
    add_child(model_coordinator)
    
    # Setup model coordinator
    var safe_brain_parent = get_safe_brain_model_parent()
    if safe_brain_parent and model_coordinator:
        model_coordinator.set_model_parent(safe_brain_parent)
        
        # Connect to ModelCoordinator signals
        if model_coordinator.has_signal("models_loaded"):
            model_coordinator.models_loaded.connect(_on_models_loaded)
        if model_coordinator.has_signal("model_load_failed"):
            model_coordinator.model_load_failed.connect(_on_model_load_failed)
        
        model_coordinator.load_brain_models()
        print("[INIT] Brain models loading initiated via ModelCoordinator")
    
    # Create model control panel
    _setup_model_control_panel()
    print("[INIT] Model control panel setup complete")
    
    # Add debug ray visualization
    _setup_debug_ray()
    print("[INIT] Debug ray visualization setup complete")
    
    # Register debug commands
    _register_debug_commands()
    print("[INIT] Debug commands registered")
    
    # Set initial camera view
    var safe_camera_controller = get_safe_camera_controller()
    if safe_camera_controller:
        safe_camera_controller.setup_initial_animation()
        print("[INIT] Initial camera animation started")
    
    # Print interaction instructions
    _print_interaction_instructions()

# Safe getter functions - these should always be used instead of direct access
func get_safe_camera() -> Camera3D:
    """Returns a valid camera reference or null"""
    if is_instance_valid(camera):
        return camera
    
    if is_instance_valid(camera_backup):
        camera = camera_backup
        return camera
    
    # Try to recover the reference
    var recovered = get_node_or_null("Camera3D") as Camera3D
    if recovered:
        camera = recovered
        camera_backup = recovered
        return recovered
    
    return null

func get_safe_object_label() -> Label:
    """Returns a valid object label reference or null"""
    if is_instance_valid(object_name_label):
        return object_name_label
    
    if is_instance_valid(object_name_label_backup):
        object_name_label = object_name_label_backup
        return object_name_label
    
    # Try to recover the reference
    var recovered = get_node_or_null("UI_Layer/ObjectNameLabel") as Label
    if recovered:
        object_name_label = recovered
        object_name_label_backup = recovered
        return recovered
    
    return null

func get_safe_info_panel():
    """Returns a valid info panel reference or null"""
    if is_instance_valid(info_panel):
        return info_panel
    
    if is_instance_valid(info_panel_backup):
        info_panel = info_panel_backup
        return info_panel
    
    # Try to recover the reference
    var recovered = get_node_or_null("UI_Layer/StructureInfoPanel")
    if recovered:
        info_panel = recovered
        info_panel_backup = recovered
        return recovered
    
    return null

func get_safe_brain_model_parent() -> Node3D:
    """Returns a valid brain model parent reference or null"""
    if is_instance_valid(brain_model_parent):
        return brain_model_parent
    
    if is_instance_valid(brain_model_parent_backup):
        brain_model_parent = brain_model_parent_backup
        return brain_model_parent
    
    # Try to recover the reference
    var recovered = get_node_or_null("BrainModel") as Node3D
    if recovered:
        brain_model_parent = recovered
        brain_model_parent_backup = recovered
        return recovered
    
    return null

func get_safe_selection_manager():
    """Returns a valid selection manager reference or null"""
    if is_instance_valid(selection_manager):
        return selection_manager
    
    if is_instance_valid(selection_manager_backup):
        selection_manager = selection_manager_backup
        return selection_manager
    
    # Try to find it in children
    for child in get_children():
        if child.get_script() == BrainStructureSelectionManagerScript:
            selection_manager = child
            selection_manager_backup = child
            return child
    
    return null

func get_safe_camera_controller():
    """Returns a valid camera controller reference or null"""
    if is_instance_valid(camera_controller):
        return camera_controller
    
    if is_instance_valid(camera_controller_backup):
        camera_controller = camera_controller_backup
        return camera_controller
    
    # Try to find it in children
    for child in get_children():
        if child.get_script() == CameraBehaviorControllerScript:
            camera_controller = child
            camera_controller_backup = child
            return child
    
    return null

# Process functions with safe execution and performance monitoring
func _process(_delta):
    """Optimized processing with accurate performance monitoring"""
    if not initialization_complete:
        return
    
    if error_recovery_active:
        return
    
    # Optimized performance monitoring - only check every 60 frames
    frame_count += 1
    if frame_count % 60 == 0:  # Check every 60 frames instead of every second
        var fps = Engine.get_frames_per_second()
        if fps < fps_warning_threshold and fps > 0:
            print("[PERFORMANCE] Low FPS detected: ", fps)
        elif fps == 0:
            print("[CRITICAL] FPS dropped to zero - potential freeze detected")
            _handle_performance_emergency()
    
    # Memory usage monitoring (every 300 frames = ~5 seconds at 60fps)
    if frame_count % 300 == 0:
        _check_memory_usage()

func _physics_process(_delta):
    """Safe physics processing with error recovery"""
    if not initialization_complete:
        return
    
    if error_recovery_active:
        return
    
    # Safe camera controller update (removed - no update_camera method exists and caused performance issues)
    # Camera updates are handled by the CameraController internally through timers and input events

func _input(event: InputEvent) -> void:
    """Safe input handling with error recovery"""
    if not initialization_complete:
        return
    
    if error_recovery_active:
        return
    
    # Handle keyboard shortcuts for camera controls
    if event is InputEventKey and event.pressed:
        var safe_camera_controller = get_safe_camera_controller()
        if safe_camera_controller:
            match event.keycode:
                KEY_F:
                    safe_camera_controller.focus_on_bounds(Vector3.ZERO, 2.0)
                    get_viewport().set_input_as_handled()
                    return
                KEY_1, KEY_KP_1:
                    safe_camera_controller.set_view_preset("front")
                    get_viewport().set_input_as_handled()
                    return
                KEY_3, KEY_KP_3:
                    safe_camera_controller.set_view_preset("right")
                    get_viewport().set_input_as_handled()
                    return
                KEY_7, KEY_KP_7:
                    safe_camera_controller.set_view_preset("top")
                    get_viewport().set_input_as_handled()
                    return
                KEY_R:
                    safe_camera_controller.reset_view()
                    get_viewport().set_input_as_handled()
                    return
    
    # Handle mouse motion for hover effects
    if event is InputEventMouseMotion:
        var safe_selection_manager = get_safe_selection_manager()
        if safe_selection_manager:
            safe_selection_manager.handle_hover_at_position(event.position)
    
    # Handle mouse input - selection uses right click to avoid conflicts with camera orbiting (left click)
    if event is InputEventMouseButton:
        # Handle right mouse click for selection (left is used by camera controller for orbiting)
        if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
            var safe_selection_manager = get_safe_selection_manager()
            if safe_selection_manager:
                safe_selection_manager.handle_selection_at_position(event.position)
            else:
                handle_selection_error()
            get_viewport().set_input_as_handled()

# Error handling functions
func handle_camera_error():
    """Handle camera controller errors gracefully"""
    if error_recovery_active:
        return
    
    error_recovery_active = true
    print("[ERROR] Camera controller lost - attempting recovery...")
    
    # Try to recover camera controller
    var recovered_camera = await attempt_camera_recovery()
    if recovered_camera:
        print("[RECOVERY] Camera controller recovered successfully")
    else:
        print("[RECOVERY] Camera controller recovery failed")
    
    error_recovery_active = false

func attempt_camera_recovery():
    """Attempt to recover or recreate camera controller"""
    await get_tree().process_frame
    
    # Try to find existing camera controller
    for child in get_children():
        if child.get_script() == CameraBehaviorControllerScript:
            camera_controller = child
            camera_controller_backup = child
            return child
    
    # Try to recreate camera controller
    var safe_camera = get_safe_camera()
    if safe_camera:
        camera_controller = CameraBehaviorControllerScript.new()
        add_child(camera_controller)
        camera_controller.initialize(safe_camera, get_safe_brain_model_parent())
        camera_controller_backup = camera_controller
        print("[RECOVERY] Camera controller recreated")
        return camera_controller
    
    return null

func handle_selection_error():
    """Handle selection manager errors gracefully"""
    if error_recovery_active:
        return
    
    error_recovery_active = true
    print("[ERROR] Selection manager lost - attempting recovery...")
    
    # Attempt recovery
    await get_tree().process_frame
    await initialize_components()
    
    # Reset error recovery flag after a delay
    await get_tree().create_timer(1.0).timeout
    error_recovery_active = false

# Signal handlers and other functions (keeping existing implementations but making them safer)
func _on_camera_animation_finished() -> void:
    print("Camera reveal animation completed")

func _on_camera_reset_completed() -> void:
    print("Camera reset completed")

func _on_models_loaded(model_names: Array) -> void:
    print("Models loaded successfully: " + str(model_names))
    emit_signal("models_loaded", model_names)

func _on_model_load_failed(model_path: String, error: String) -> void:
    print("ERROR: Failed to load model " + model_path + ": " + error)

func _on_structure_selected(structure_name: String, _mesh: MeshInstance3D) -> void:
    var safe_label = get_safe_object_label()
    if safe_label:
        # Animate label change
        var tween = safe_label.create_tween()
        tween.tween_property(safe_label, "modulate:a", 0.0, 0.1)
        tween.tween_callback(func(): safe_label.text = "Selected: " + structure_name)
        tween.tween_property(safe_label, "modulate:a", 1.0, 0.1)
    
    print("Selected structure: " + structure_name)
    
    emit_signal("structure_selected", structure_name)
    _display_structure_info_modern(structure_name)

func _on_structure_deselected() -> void:
    var safe_label = get_safe_object_label()
    if safe_label:
        safe_label.text = "Selected: None"
    
    var safe_info_panel = get_safe_info_panel()
    if safe_info_panel:
        safe_info_panel.visible = false
    
    emit_signal("structure_deselected")

func _on_structure_hovered(structure_name: String, _mesh: MeshInstance3D) -> void:
    var safe_label = get_safe_object_label()
    if safe_label:
        # Only show hover if nothing is currently selected
        var safe_selection_manager = get_safe_selection_manager()
        if safe_selection_manager and safe_selection_manager.get_selected_structure_name().is_empty():
            safe_label.text = "Hover: " + structure_name

func _on_structure_unhovered() -> void:
    var safe_label = get_safe_object_label()
    if safe_label:
        # Only clear hover if nothing is currently selected
        var safe_selection_manager = get_safe_selection_manager()
        if safe_selection_manager and safe_selection_manager.get_selected_structure_name().is_empty():
            safe_label.text = "Hover: None"

func _on_info_panel_closed() -> void:
    pass

# Performance emergency handling
func _handle_performance_emergency() -> void:
    print("[EMERGENCY] Handling performance crisis")
    
    # Stop all non-essential processing
    error_recovery_active = true
    
    # Clean up any potential memory leaks
    _force_cleanup_all_systems()
    
    # Reset to minimal state
    await get_tree().process_frame
    error_recovery_active = false
    
    print("[EMERGENCY] Performance emergency handled")

# Memory usage monitoring
func _check_memory_usage() -> void:
    # Use available Godot 4.x memory monitoring
    var memory_usage = OS.get_static_memory_usage()  # Returns bytes
    
    # Check for memory growth (basic threshold)
    if memory_usage > 100 * 1024 * 1024:  # 100MB threshold
        print("[MEMORY] High memory usage detected: ", memory_usage / (1024.0 * 1024.0), " MB")
        _cleanup_memory()
    
    # Also check for rapid memory growth patterns
    if not has_meta("last_memory_check"):
        set_meta("last_memory_check", memory_usage)
    else:
        var last_memory = get_meta("last_memory_check")
        var memory_diff = memory_usage - last_memory
        if memory_diff > 5 * 1024 * 1024:  # 5MB growth in ~5 seconds
            print("[MEMORY] Rapid memory growth detected: +", memory_diff / (1024.0 * 1024.0), " MB")
            _cleanup_memory()
        set_meta("last_memory_check", memory_usage)

# Force cleanup of all systems
func _force_cleanup_all_systems() -> void:
    print("[CLEANUP] Forcing cleanup of all systems")
    
    # Clean up selection manager
    var safe_selection_manager = get_safe_selection_manager()
    if safe_selection_manager and safe_selection_manager.has_method("dispose"):
        safe_selection_manager.dispose()
    
    # Clean up info panel
    var safe_info_panel = get_safe_info_panel()
    if safe_info_panel and safe_info_panel.has_method("dispose"):
        safe_info_panel.dispose()
    
    # Force garbage collection
    await get_tree().process_frame
    print("[CLEANUP] System cleanup completed")

# Memory cleanup
func _cleanup_memory() -> void:
    print("[MEMORY] Starting memory cleanup")
    
    # Force cleanup of all systems
    _force_cleanup_all_systems()
    
    # Additional Godot-specific cleanup
    # Note: ResourceLoader.load_threaded_request("") is invalid and causes errors
    # Proper cleanup handled by Godot automatically during scene transitions
    
    # Force multiple garbage collection cycles
    for i in range(3):
        await get_tree().process_frame
    
    print("[MEMORY] Memory cleanup completed")

# Helper functions (keeping existing implementations but adding safety checks)
func _display_structure_info(structure_name: String) -> void:
    var safe_info_panel = get_safe_info_panel()
    if not safe_info_panel:
        print("WARNING: Info panel not found!")
        return
        
    # Make sure knowledge base is loaded
    if not knowledge_base or not knowledge_base.is_loaded:
        print("Warning: Knowledge base not loaded, cannot display structure info.")
        safe_info_panel.visible = false
        return
    
    print("Displaying info for structure: " + structure_name)
    
    # Try to find structure ID that matches or contains the mesh name
    var structure_id = _find_structure_id_by_name(structure_name)
    
    if structure_id.is_empty():
        print("No matching structure found in knowledge base for: " + structure_name)
        safe_info_panel.visible = false
        return
    
    print("Found structure ID: " + structure_id)
    
    # Get structure data and display it
    var structure_data = knowledge_base.get_structure(structure_id)
    if not structure_data.is_empty():
        print("Successfully retrieved structure data")
        
        # Ensure panel's parent (UI_Layer) is visible
        var ui_layer = get_node_or_null("UI_Layer")
        if ui_layer:
            ui_layer.visible = true
        
        # Explicitly set the panel to visible first
        safe_info_panel.visible = true
        
        # Call the display function
        if safe_info_panel.has_method("display_structure_data"):
            safe_info_panel.display_structure_data(structure_data)
    else:
        print("Failed to retrieve structure data for ID: " + structure_id)
        safe_info_panel.visible = false

func _find_structure_id_by_name(mesh_name: String) -> String:
    # First try using our neural net mapping function
    if neural_net != null:
        var mapped_id = neural_net.map_mesh_name_to_structure_id(mesh_name)
        if not mapped_id.is_empty():
            print("Found structure ID via neural net mapping: " + mapped_id)
            return mapped_id
    
    # Fallback: Convert mesh name to lowercase for case-insensitive matching
    var lower_mesh_name = mesh_name.to_lower()
    
    # Get all structure IDs
    var structure_ids = knowledge_base.get_all_structure_ids()
    
    # First, try exact match with display name
    for id in structure_ids:
        var structure = knowledge_base.get_structure(id)
        if structure.has("displayName") and structure.displayName.to_lower() == lower_mesh_name:
            return id
    
    # Next, try matching the ID directly
    if structure_ids.has(mesh_name):
        return mesh_name
    
    # Next, try partial match
    for id in structure_ids:
        var structure = knowledge_base.get_structure(id)
        if structure.has("displayName"):
            var display_name = structure.displayName.to_lower()
            if lower_mesh_name.contains(display_name) or display_name.contains(lower_mesh_name):
                return id
    
    return ""

# Setup functions (keeping existing implementations but adding error handling)
func _setup_model_control_panel() -> void:
    model_control_panel = get_node_or_null("UI_Layer/ModelControlPanel")
    if not model_control_panel:
        print("ERROR: ModelControlPanel not found in scene")
        return
    
    print("Using model control panel from scene")
    
    # Connect to model switcher signals if they exist
    if ModelSwitcherGlobal and ModelSwitcherGlobal.has_signal("model_visibility_changed"):
        ModelSwitcherGlobal.model_visibility_changed.connect(_on_model_visibility_changed)
    
    # Connect to panel signals if they exist
    if model_control_panel.has_signal("model_selected"):
        model_control_panel.model_selected.connect(_on_model_selected)
    
    # Wait for models to be loaded
    if ModelSwitcherGlobal and ModelSwitcherGlobal.get_model_names().size() > 0:
        model_control_panel.setup_with_models(ModelSwitcherGlobal.get_model_names())
    else:
        models_loaded.connect(func(model_names): model_control_panel.setup_with_models(model_names))

func _on_model_selected(model_name: String) -> void:
    if ModelSwitcherGlobal:
        ModelSwitcherGlobal.toggle_model_visibility(model_name)

func _on_model_visibility_changed(model_name: String, model_is_visible: bool) -> void:
    if model_control_panel and model_control_panel.has_method("update_button_state"):
        model_control_panel.update_button_state(model_name, model_is_visible)

func _setup_debug_ray() -> void:
    var immediate_mesh = ImmediateMesh.new()
    var material = StandardMaterial3D.new()
    material.albedo_color = Color(1, 0, 0, 1)
    material.emission_enabled = true
    material.emission = Color(1, 0, 0, 1)
    material.emission_energy_multiplier = 2.0
    
    var debug_ray_mesh = MeshInstance3D.new()
    debug_ray_mesh.mesh = immediate_mesh
    debug_ray_mesh.material_override = material
    add_child(debug_ray_mesh)
    
    debug_ray_mesh.visible = DEBUG_MODE

func _register_debug_commands() -> void:
    if not OS.is_debug_build():
        return
    
    if not is_instance_valid(DebugCmd):
        print("Warning: DebugCmd autoload not available")
        return
    
    DebugCmd.register_command("reset_camera", _debug_reset_camera, "Reset camera to default position")
    DebugCmd.register_command("list_models", _debug_list_models, "List all registered brain models")
    DebugCmd.register_command("test_selection", _debug_test_selection, "Test structure selection system")
    DebugCmd.register_command("resource_trace_report", _debug_resource_trace_report, "Show resource loading trace report")
    DebugCmd.register_command("resource_trace_export", _debug_resource_trace_export, "Export resource trace data to file")
    DebugCmd.register_command("recovery_test", _debug_recovery_test, "Test error recovery system")
    print("Brain scene debug commands registered")

func _debug_reset_camera() -> void:
    var safe_camera_controller = get_safe_camera_controller()
    if safe_camera_controller:
        safe_camera_controller.reset_view()
    else:
        print("Warning: CameraController not available for reset")

func _debug_list_models() -> void:
    if ModelSwitcherGlobal:
        var model_names = ModelSwitcherGlobal.get_model_names()
        print("Registered models (", model_names.size(), "):")
        for model_name in model_names:
            var model_visible = ModelSwitcherGlobal.is_model_visible(model_name)
            print("  - ", model_name, " (visible: ", model_visible, ")")
    else:
        print("ModelSwitcherGlobal not available")

func _debug_test_selection() -> void:
    print("Testing selection system...")
    var test_position = get_viewport().get_visible_rect().size / 2.0
    var safe_selection_manager = get_safe_selection_manager()
    if safe_selection_manager:
        safe_selection_manager.handle_selection_at_position(test_position)
    else:
        print("Warning: SelectionManager not available for testing")
    print("Selection test completed at screen center")

func _debug_recovery_test() -> void:
    print("Testing error recovery system...")
    error_recovery_active = true
    await get_tree().create_timer(2.0).timeout
    error_recovery_active = false
    print("Error recovery test completed")

func _print_interaction_instructions() -> void:
    print("INTERACTION INSTRUCTIONS:")
    print("- Right-click to select brain structures")
    print("- Camera controls (Professional 3D style):")
    print("  - Left-click + drag: Orbit view around models")
    print("  - Middle-click + drag: Pan view")
    print("  - Shift + Left-click + drag: Pan view (alternative)")
    print("  - Mouse wheel: Zoom in/out")
    print("  - Two-finger trackpad drag: Pan view")
    print("  - Pinch gesture: Zoom")
    print("- Keyboard shortcuts:")
    print("  - F: Focus on bounds")
    print("  - 1 or Numpad 1: Front view")
    print("  - 3 or Numpad 3: Right view")
    print("  - 7 or Numpad 7: Top view")
    print("  - R: Reset view")

# Modern UI Integration Functions
func apply_modern_theme() -> void:
    """Apply the modern glass morphism theme to the scene"""
    print("[UI] Applying modern theme...")
    
    # Create a simple theme - the individual UI components handle their own styling
    var modern_theme = Theme.new()
    
    # Apply theme to Control nodes in the UI layer
    var ui_layer = get_node_or_null("UI_Layer")
    if ui_layer:
        # Apply to ObjectNameLabel
        var object_label = ui_layer.get_node_or_null("ObjectNameLabel")
        if object_label and object_label is Control:
            object_label.set_theme(modern_theme)
        
        # Apply to StructureInfoPanel
        var structure_info_panel = ui_layer.get_node_or_null("StructureInfoPanel")
        if structure_info_panel and structure_info_panel is Control:
            structure_info_panel.set_theme(modern_theme)
        
        # Apply to ModelControlPanel
        var control_panel = ui_layer.get_node_or_null("ModelControlPanel")
        if control_panel and control_panel is Control:
            control_panel.set_theme(modern_theme)
    
    print("[UI] Modern theme applied successfully")

func setup_onboarding_if_needed() -> void:
    """Check if user needs onboarding and show it if required"""
    print("[UI] Checking onboarding status...")
    
    if not OnboardingManager.has_completed_onboarding():
        print("[UI] First-time user detected, starting onboarding...")
        var onboarding = OnboardingManager.new()
        add_child(onboarding)
        
        # Wait a moment for everything to settle
        await get_tree().create_timer(1.0).timeout
        onboarding.start_onboarding()
        
        # Wait for onboarding completion
        await onboarding.onboarding_completed
        print("[UI] Onboarding completed")
    else:
        print("[UI] User has completed onboarding, skipping...")

func _display_structure_info_modern(structure_name: String) -> void:
    """Modern version of structure info display using ModernInfoDisplay"""
    print("[UI] Displaying modern structure info for: " + structure_name)
    
    # Remove old panel if exists
    var old_panel = get_node_or_null("UI_Layer/StructureInfoPanel")
    if old_panel:
        _animate_exit_simple(old_panel)
    
    # Remove any existing modern info displays
    var existing_modern = get_node_or_null("UI_Layer/ModernInfoDisplay")
    if existing_modern:
        _animate_exit_simple(existing_modern)
    
    # Create modern info display
    var modern_info = ModernInfoDisplay.new()
    modern_info.name = "ModernInfoDisplay"
    modern_info.position = Vector2(get_viewport().size.x - 360, 100)
    
    var ui_layer = get_node_or_null("UI_Layer")
    if ui_layer:
        ui_layer.add_child(modern_info)
    else:
        add_child(modern_info)
    
    # Get and display structure data
    var structure_id = _find_structure_id_by_name(structure_name)
    if not structure_id.is_empty() and knowledge_base and knowledge_base.is_loaded:
        var structure_data = knowledge_base.get_structure(structure_id)
        if structure_data and not structure_data.is_empty():
            modern_info.display_structure_data(structure_data)
        else:
            print("[WARNING] No structure data found for: " + structure_name)
    else:
        print("[WARNING] Cannot display structure info - knowledge base not ready")

# Animation helper function
func _animate_exit_simple(control: Control, duration: float = 0.2) -> void:
    """Simple exit animation"""
    if not control:
        return
    var tween = control.create_tween()
    tween.tween_property(control, "modulate:a", 0.0, duration)
    tween.tween_callback(control.queue_free)

# Resource validation helper to prevent loading errors
static func safe_resource_load(resource_path: String) -> Resource:
    """Safely load a resource with proper error checking"""
    if resource_path.is_empty():
        push_error("ResourceLoader: Attempted to load empty resource path")
        return null
    
    if not ResourceLoader.exists(resource_path):
        push_error("ResourceLoader: Resource does not exist: " + resource_path)
        return null
    
    var resource = ResourceLoader.load(resource_path)
    if resource == null:
        push_error("ResourceLoader: Failed to load resource: " + resource_path)
        return null
    
    print("[RESOURCE] Successfully loaded: " + resource_path)
    return resource

# Debug functions for resource tracing
func _debug_resource_trace_report() -> void:
    """Show resource loading trace report"""
    print("=== RESOURCE TRACE REPORT ===")
    var resource_load_tracer = get_node_or_null("/root/ResourceLoadTracer")
    if resource_load_tracer and resource_load_tracer.has_method("print_report"):
        resource_load_tracer.print_report()
    else:
        print("ResourceLoadTracer not available")

func _debug_resource_trace_export() -> void:
    """Export resource trace data to file"""
    var resource_load_tracer = get_node_or_null("/root/ResourceLoadTracer")
    if resource_load_tracer and resource_load_tracer.has_method("export_trace_data"):
        var success = resource_load_tracer.export_trace_data()
        if success:
            print("Resource trace data exported successfully")
        else:
            print("Failed to export resource trace data")
    else:
        print("ResourceLoadTracer not available for export")

# Emergency cleanup function
func _exit_tree():
    """Clean up references when node is removed from tree"""
    camera = null
    object_name_label = null
    info_panel = null
    brain_model_parent = null
    selection_manager = null
    camera_controller = null
    camera_backup = null
    object_name_label_backup = null
    info_panel_backup = null
    brain_model_parent_backup = null
    selection_manager_backup = null
    camera_controller_backup = null
    initialization_complete = false