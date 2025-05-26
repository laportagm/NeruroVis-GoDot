## node_3d_refactored.gd
## Refactored main scene using composition pattern with focused components
## Orchestrates system initialization and connections without handling logic directly

class_name MainSceneRefactored
extends Node3D

# Preload new components
const SystemBootstrap = preload("res://scripts/core/SystemBootstrap.gd")
const InputRouter = preload("res://scripts/interaction/InputRouter.gd")
const OnboardingManager = preload("res://scripts/ui/OnboardingManager.gd")
const ModernInfoDisplay = preload("res://scripts/ui/ModernInfoDisplay.gd")

# Export variables for configuration
@export var highlight_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var emission_energy: float = 0.5
@export var debug_mode: bool = true

# Core system components
var system_bootstrap: SystemBootstrap = null
var input_router: InputRouter = null

# Node references (validated during initialization)
@onready var camera: Camera3D = $Camera3D
@onready var object_name_label: Label = $UI_Layer/ObjectNameLabel
@onready var info_panel = $UI_Layer/StructureInfoPanel
@onready var brain_model_parent = $BrainModel
@onready var ui_layer = $UI_Layer

# Initialization tracking
var initialization_complete: bool = false
var error_recovery_active: bool = false

# Performance monitoring
var frame_count: int = 0
var fps_warning_threshold: float = 10.0

# Signals
signal structure_selected(structure_name: String)
signal structure_deselected
signal models_loaded(model_names: Array)
signal initialization_completed
signal initialization_failed(error: String)

func _ready() -> void:
	print("[MAIN_SCENE] Starting refactored main scene initialization...")
	name = "MainSceneRefactored"
	
	# Initialize the scene using composition pattern
	await initialize_scene()

## Main scene initialization orchestrator
func initialize_scene() -> void:
	"""
	Orchestrate scene initialization using focused components
	"""
	print("[MAIN_SCENE] Beginning scene initialization...")
	
	# Step 1: Validate core node references
	if not await _validate_core_nodes():
		emit_signal("initialization_failed", "Core node validation failed")
		return
	
	# Step 2: Create and initialize system bootstrap
	if not await _initialize_system_bootstrap():
		emit_signal("initialization_failed", "System bootstrap initialization failed")
		return
	
	# Step 3: Initialize all systems via bootstrap
	if not await system_bootstrap.initialize_all_systems(self):
		emit_signal("initialization_failed", "System initialization failed")
		return
	
	# Step 4: Create and configure input router
	if not await _initialize_input_router():
		emit_signal("initialization_failed", "Input router initialization failed")
		return
	
	# Step 5: Setup UI and signal connections
	await _setup_ui_and_connections()
	
	# Step 6: Apply modern theming and onboarding
	await _finalize_scene_setup()
	
	initialization_complete = true
	print("[MAIN_SCENE] Scene initialization completed successfully")
	emit_signal("initialization_completed")

## Core node validation
func _validate_core_nodes() -> bool:
	"""
	Validate that essential scene nodes exist and are accessible
	"""
	print("[MAIN_SCENE] Validating core scene nodes...")
	
	var validation_results = {
		"camera": _validate_camera(),
		"ui_layer": _validate_ui_layer(),
		"brain_model_parent": _validate_brain_model_parent(),
		"object_label": _validate_object_label(),
		"info_panel": _validate_info_panel()
	}
	
	var all_valid = true
	for node_name in validation_results.keys():
		var is_valid = validation_results[node_name]
		print("[MAIN_SCENE] Node validation - ", node_name, ": ", "✓" if is_valid else "✗")
		if not is_valid and node_name in ["camera", "ui_layer"]:  # Critical nodes
			all_valid = false
	
	return all_valid

func _validate_camera() -> bool:
	"""Validate camera node exists and create fallback if needed"""
	if is_instance_valid(camera) and camera is Camera3D:
		return true
	
	# Try to find camera
	camera = get_node_or_null("Camera3D")
	if camera and camera is Camera3D:
		return true
	
	# Create emergency camera
	print("[MAIN_SCENE] Creating emergency camera...")
	camera = Camera3D.new()
	camera.name = "EmergencyCamera"
	camera.transform = Transform3D(
		Vector3(1, 0, 0),
		Vector3(0, 0.866025, 0.5), 
		Vector3(0, -0.5, 0.866025),
		Vector3(0, 5, 10)
	)
	camera.current = true
	add_child(camera)
	return true

func _validate_ui_layer() -> bool:
	"""Validate UI layer exists"""
	if is_instance_valid(ui_layer):
		return true
	
	ui_layer = get_node_or_null("UI_Layer")
	if ui_layer:
		return true
	
	print("[MAIN_SCENE] UI_Layer not found - critical error")
	return false

func _validate_brain_model_parent() -> bool:
	"""Validate brain model parent exists"""
	if is_instance_valid(brain_model_parent):
		return true
	
	brain_model_parent = get_node_or_null("BrainModel")
	if brain_model_parent:
		return true
	
	# Create emergency brain model parent
	print("[MAIN_SCENE] Creating emergency brain model parent...")
	brain_model_parent = Node3D.new()
	brain_model_parent.name = "EmergencyBrainModel"
	add_child(brain_model_parent)
	return true

func _validate_object_label() -> bool:
	"""Validate object name label exists"""
	if is_instance_valid(object_name_label):
		return true
	
	object_name_label = get_node_or_null("UI_Layer/ObjectNameLabel")
	return object_name_label != null

func _validate_info_panel() -> bool:
	"""Validate info panel exists"""
	if is_instance_valid(info_panel):
		return true
	
	info_panel = get_node_or_null("UI_Layer/StructureInfoPanel")
	return info_panel != null

## System bootstrap initialization
func _initialize_system_bootstrap() -> bool:
	"""
	Create and initialize the system bootstrap component
	"""
	print("[MAIN_SCENE] Initializing system bootstrap...")
	
	system_bootstrap = SystemBootstrap.new()
	if not system_bootstrap:
		push_error("[MAIN_SCENE] Failed to create system bootstrap")
		return false
	
	add_child(system_bootstrap)
	
	# Connect to bootstrap signals
	system_bootstrap.all_systems_initialized.connect(_on_all_systems_initialized)
	system_bootstrap.system_initialized.connect(_on_system_initialized)
	system_bootstrap.initialization_failed.connect(_on_system_initialization_failed)
	
	print("[MAIN_SCENE] System bootstrap created and connected")
	return true

## Input router initialization
func _initialize_input_router() -> bool:
	"""
	Create and configure the input router component
	"""
	print("[MAIN_SCENE] Initializing input router...")
	
	input_router = InputRouter.new()
	if not input_router:
		push_error("[MAIN_SCENE] Failed to create input router")
		return false
	
	add_child(input_router)
	
	# Initialize input router with system references from bootstrap
	var camera_controller = system_bootstrap.get_camera_controller()
	var selection_manager = system_bootstrap.get_selection_manager()
	
	input_router.initialize(self, camera_controller, selection_manager)
	
	# Connect input router signals
	input_router.selection_attempted.connect(_on_selection_attempted)
	input_router.camera_shortcut_triggered.connect(_on_camera_shortcut_triggered)
	input_router.input_processed.connect(_on_input_processed)
	
	print("[MAIN_SCENE] Input router created and configured")
	return true

## UI and signal setup
func _setup_ui_and_connections() -> void:
	"""
	Setup UI elements and connect signals between systems
	"""
	print("[MAIN_SCENE] Setting up UI and connections...")
	
	# Configure UI layer
	if ui_layer:
		ui_layer.visible = true
		ui_layer.add_to_group("ui_layer")
	
	# Initialize object name label
	if object_name_label:
		object_name_label.text = "Selected: None"
	
	# Connect system signals
	await _connect_system_signals()
	
	# Setup model control panel
	await _setup_model_control_panel()

func _connect_system_signals() -> void:
	"""
	Connect signals between different systems
	"""
	var selection_manager = system_bootstrap.get_selection_manager()
	var model_coordinator = system_bootstrap.get_model_coordinator()
	
	# Connect selection manager signals
	if selection_manager:
		if selection_manager.has_signal("structure_selected"):
			selection_manager.structure_selected.connect(_on_structure_selected)
		if selection_manager.has_signal("structure_deselected"):
			selection_manager.structure_deselected.connect(_on_structure_deselected)
		if selection_manager.has_signal("structure_hovered"):
			selection_manager.structure_hovered.connect(_on_structure_hovered)
		if selection_manager.has_signal("structure_unhovered"):
			selection_manager.structure_unhovered.connect(_on_structure_unhovered)
		
		# Configure selection appearance
		selection_manager.configure_highlight_colors(highlight_color, Color(1.0, 0.7, 0.0, 0.6))
		selection_manager.set_emission_energy(emission_energy)
		selection_manager.set_outline_enabled(true)
	
	# Connect model coordinator signals
	if model_coordinator:
		if model_coordinator.has_signal("models_loaded"):
			model_coordinator.models_loaded.connect(_on_models_loaded)
		if model_coordinator.has_signal("model_load_failed"):
			model_coordinator.model_load_failed.connect(_on_model_load_failed)
		
		# Start loading models
		model_coordinator.load_brain_models()
	
	# Connect info panel signals
	if info_panel and info_panel.has_signal("panel_closed"):
		info_panel.panel_closed.connect(_on_info_panel_closed)
		info_panel.visible = false

func _setup_model_control_panel() -> void:
	"""
	Setup the model control panel with loaded models
	"""
	var model_control_panel = get_node_or_null("UI_Layer/ModelControlPanel")
	if not model_control_panel:
		print("[MAIN_SCENE] Model control panel not found in scene")
		return
	
	# Connect to ModelSwitcherGlobal if available
	if ModelSwitcherGlobal:
		if ModelSwitcherGlobal.has_signal("model_visibility_changed"):
			ModelSwitcherGlobal.model_visibility_changed.connect(_on_model_visibility_changed)
		
		# Setup with available models
		if ModelSwitcherGlobal.get_model_names().size() > 0:
			model_control_panel.setup_with_models(ModelSwitcherGlobal.get_model_names())
	
	# Connect panel signals
	if model_control_panel.has_signal("model_selected"):
		model_control_panel.model_selected.connect(_on_model_selected)

## Scene finalization
func _finalize_scene_setup() -> void:
	"""
	Apply final scene setup including theming and onboarding
	"""
	print("[MAIN_SCENE] Finalizing scene setup...")
	
	# Apply modern theme
	_apply_modern_theme()
	
	# Setup initial camera view
	var camera_controller = system_bootstrap.get_camera_controller()
	if camera_controller and camera_controller.has_method("setup_initial_animation"):
		camera_controller.setup_initial_animation()
	
	# Register debug commands
	_register_debug_commands()
	
	# Check for onboarding
	await _setup_onboarding_if_needed()
	
	# Print interaction instructions
	_print_interaction_instructions()

func _apply_modern_theme() -> void:
	"""Apply modern theming to UI elements"""
	var modern_theme = Theme.new()
	
	if ui_layer:
		for child in ui_layer.get_children():
			if child is Control:
				child.set_theme(modern_theme)

func _setup_onboarding_if_needed() -> void:
	"""Setup onboarding for first-time users"""
	if not OnboardingManager.has_completed_onboarding():
		print("[MAIN_SCENE] Starting onboarding for first-time user...")
		var onboarding = OnboardingManager.new()
		add_child(onboarding)
		
		await get_tree().create_timer(1.0).timeout
		onboarding.start_onboarding()
		await onboarding.onboarding_completed
		
		onboarding.queue_free()

## Input handling (delegated to InputRouter)
func _input(event: InputEvent) -> void:
	"""
	Input handling is now delegated to InputRouter
	This function serves as a fallback for any unhandled input
	"""
	if not initialization_complete or error_recovery_active:
		return
	
	# InputRouter handles all input - this is just a safety fallback
	pass

## Process functions with performance monitoring
func _process(delta):
	"""Optimized processing with performance monitoring"""
	if not initialization_complete or error_recovery_active:
		return
	
	# Performance monitoring every 60 frames
	frame_count += 1
	if frame_count % 60 == 0:
		var fps = Engine.get_frames_per_second()
		if fps < fps_warning_threshold and fps > 0:
			print("[MAIN_SCENE] Low FPS detected: ", fps)
		elif fps == 0:
			print("[MAIN_SCENE] Critical: FPS dropped to zero")
			_handle_performance_emergency()

## Signal handlers
func _on_all_systems_initialized() -> void:
	"""Called when all systems are successfully initialized"""
	print("[MAIN_SCENE] All systems initialization completed")

func _on_system_initialized(system_name: String) -> void:
	"""Called when an individual system is initialized"""
	print("[MAIN_SCENE] System initialized: ", system_name)

func _on_system_initialization_failed(system_name: String, error: String) -> void:
	"""Called when system initialization fails"""
	push_error("[MAIN_SCENE] System initialization failed - " + system_name + ": " + error)
	emit_signal("initialization_failed", "System " + system_name + " failed: " + error)

func _on_selection_attempted(position: Vector2, button: int) -> void:
	"""Called when input router detects a selection attempt"""
	print("[MAIN_SCENE] Selection attempted at: ", position, " with button: ", button)

func _on_camera_shortcut_triggered(shortcut: String) -> void:
	"""Called when input router triggers a camera shortcut"""
	print("[MAIN_SCENE] Camera shortcut triggered: ", shortcut)

func _on_input_processed(input_type: String, handled: bool) -> void:
	"""Called when input router processes input (optional logging)"""
	# Uncomment for detailed input logging
	# print("[MAIN_SCENE] Input processed: ", input_type, " handled: ", handled)
	pass

func _on_structure_selected(structure_name: String, mesh: MeshInstance3D) -> void:
	"""Handle structure selection"""
	if object_name_label:
		var tween = object_name_label.create_tween()
		tween.tween_property(object_name_label, "modulate:a", 0.0, 0.1)
		tween.tween_callback(func(): object_name_label.text = "Selected: " + structure_name)
		tween.tween_property(object_name_label, "modulate:a", 1.0, 0.1)
	
	emit_signal("structure_selected", structure_name)
	_display_structure_info_modern(structure_name)

func _on_structure_deselected() -> void:
	"""Handle structure deselection"""
	if object_name_label:
		object_name_label.text = "Selected: None"
	
	if info_panel:
		info_panel.visible = false
	
	emit_signal("structure_deselected")

func _on_structure_hovered(structure_name: String, mesh: MeshInstance3D) -> void:
	"""Handle structure hover"""
	if object_name_label:
		var selection_manager = system_bootstrap.get_selection_manager()
		if selection_manager and selection_manager.get_selected_structure_name().is_empty():
			object_name_label.text = "Hover: " + structure_name

func _on_structure_unhovered() -> void:
	"""Handle structure unhover"""
	if object_name_label:
		var selection_manager = system_bootstrap.get_selection_manager()
		if selection_manager and selection_manager.get_selected_structure_name().is_empty():
			object_name_label.text = "Hover: None"

func _on_models_loaded(model_names: Array) -> void:
	"""Handle models loaded"""
	print("[MAIN_SCENE] Models loaded: ", model_names)
	emit_signal("models_loaded", model_names)

func _on_model_load_failed(model_path: String, error: String) -> void:
	"""Handle model load failure"""
	push_error("[MAIN_SCENE] Model load failed - " + model_path + ": " + error)

func _on_model_selected(model_name: String) -> void:
	"""Handle model selection from control panel"""
	if ModelSwitcherGlobal:
		ModelSwitcherGlobal.toggle_model_visibility(model_name)

func _on_model_visibility_changed(model_name: String, is_visible: bool) -> void:
	"""Handle model visibility change"""
	var model_control_panel = get_node_or_null("UI_Layer/ModelControlPanel")
	if model_control_panel and model_control_panel.has_method("update_button_state"):
		model_control_panel.update_button_state(model_name, is_visible)

func _on_info_panel_closed() -> void:
	"""Handle info panel closure"""
	pass

## Helper functions
func _display_structure_info_modern(structure_name: String) -> void:
	"""Display structure information using modern UI"""
	var knowledge_base = system_bootstrap.get_knowledge_base()
	if not knowledge_base or not knowledge_base.is_loaded:
		print("[MAIN_SCENE] Knowledge base not ready for structure info")
		return
	
	# Find structure ID
	var structure_id = _find_structure_id_by_name(structure_name)
	if structure_id.is_empty():
		print("[MAIN_SCENE] No structure found for: ", structure_name)
		return
	
	# Get structure data
	var structure_data = knowledge_base.get_structure(structure_id)
	if structure_data.is_empty():
		print("[MAIN_SCENE] No data found for structure: ", structure_id)
		return
	
	# Create modern info display
	var existing_display = get_node_or_null("UI_Layer/ModernInfoDisplay")
	if existing_display:
		existing_display.queue_free()
	
	var modern_info = ModernInfoDisplay.new()
	modern_info.name = "ModernInfoDisplay"
	modern_info.position = Vector2(get_viewport().size.x - 360, 100)
	
	ui_layer.add_child(modern_info)
	modern_info.display_structure_data(structure_data)

func _find_structure_id_by_name(mesh_name: String) -> String:
	"""Find structure ID by mesh name using neural net mapping"""
	var neural_net = system_bootstrap.get_neural_net()
	var knowledge_base = system_bootstrap.get_knowledge_base()
	
	# Try neural net mapping first
	if neural_net:
		var mapped_id = neural_net.map_mesh_name_to_structure_id(mesh_name)
		if not mapped_id.is_empty():
			return mapped_id
	
	# Fallback to knowledge base search
	if knowledge_base:
		var structure_ids = knowledge_base.get_all_structure_ids()
		var lower_mesh_name = mesh_name.to_lower()
		
		# Try exact match first
		for id in structure_ids:
			var structure = knowledge_base.get_structure(id)
			if structure.has("displayName") and structure.displayName.to_lower() == lower_mesh_name:
				return id
		
		# Try partial match
		for id in structure_ids:
			var structure = knowledge_base.get_structure(id)
			if structure.has("displayName"):
				var display_name = structure.displayName.to_lower()
				if lower_mesh_name.contains(display_name) or display_name.contains(lower_mesh_name):
					return id
	
	return ""

## Performance and error handling
func _handle_performance_emergency() -> void:
	"""Handle performance emergencies"""
	print("[MAIN_SCENE] Handling performance emergency")
	error_recovery_active = true
	
	# Disable non-essential systems temporarily
	if input_router:
		input_router.disable_input()
	
	# Wait a frame and re-enable
	await get_tree().process_frame
	
	if input_router:
		input_router.enable_input()
	
	error_recovery_active = false

## Debug functions
func _register_debug_commands() -> void:
	"""Register debug commands for the refactored scene"""
	if not OS.is_debug_build() or not DebugCmd:
		return
	
	DebugCmd.register_command("scene_status", _debug_scene_status, "Show refactored scene status")
	DebugCmd.register_command("system_status", _debug_system_status, "Show system bootstrap status")
	DebugCmd.register_command("input_status", _debug_input_status, "Show input router status")

func _debug_scene_status() -> void:
	"""Show scene status for debugging"""
	print("=== REFACTORED SCENE STATUS ===")
	print("Initialization complete: ", initialization_complete)
	print("Error recovery active: ", error_recovery_active)
	print("Frame count: ", frame_count)
	print("System bootstrap: ", "✓" if system_bootstrap else "✗")
	print("Input router: ", "✓" if input_router else "✗")

func _debug_system_status() -> void:
	"""Show system bootstrap status"""
	if system_bootstrap:
		system_bootstrap._debug_system_status()
	else:
		print("System bootstrap not available")

func _debug_input_status() -> void:
	"""Show input router status"""
	if input_router:
		input_router.print_input_status()
	else:
		print("Input router not available")

func _print_interaction_instructions() -> void:
	"""Print user interaction instructions"""
	print("=== NEUROVIS INTERACTION GUIDE ===")
	print("Selection:")
	print("  • Right-click to select brain structures")
	print("Camera Controls:")
	print("  • Left-click + drag: Orbit view")
	print("  • Middle-click + drag: Pan view")
	print("  • Mouse wheel: Zoom in/out")
	print("Keyboard Shortcuts:")
	print("  • F: Focus on bounds")
	print("  • 1: Front view")
	print("  • 3: Right view") 
	print("  • 7: Top view")
	print("  • R: Reset view")

## Cleanup
func _exit_tree():
	"""Clean up when node is removed from tree"""
	initialization_complete = false
	error_recovery_active = false
	
	if system_bootstrap:
		system_bootstrap.queue_free()
		system_bootstrap = null
	
	if input_router:
		input_router.queue_free()
		input_router = null