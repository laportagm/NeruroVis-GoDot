## SystemBootstrap.gd
## Handles system initialization in proper dependency order
## Centralizes startup logic and provides clean separation of concerns

class_name SystemBootstrap
extends Node

# Preload core dependencies
const AnatomicalKnowledgeDatabaseScript = preload("res://scripts/core/AnatomicalKnowledgeDatabase.gd")
const BrainVisualizationCoreScript = preload("res://scripts/core/BrainVisualizationCore.gd")
const ModelVisibilityManagerScript = preload("res://scripts/models/ModelVisibilityManager.gd")
const ModelCoordinatorScene = preload("res://scripts/models/ModelRegistry.gd")
const BrainStructureSelectionManagerScript = preload("res://scripts/interaction/BrainStructureSelectionManager.gd")
const CameraBehaviorControllerScript = preload("res://scripts/interaction/CameraBehaviorController.gd")
const LoadingOverlay = preload("res://scripts/ui/LoadingOverlay.gd")

# System initialization tracking
var systems_initialized: Dictionary = {}
var initialization_attempt_count: int = 0
var max_initialization_attempts: int = 3
var initialization_complete: bool = false

# System references
var knowledge_base = null
var neural_net = null
var model_switcher = null
var model_coordinator = null
var selection_manager = null
var camera_controller = null

# Signals for system status
signal system_initialized(system_name: String)
signal all_systems_initialized()
signal initialization_failed(system_name: String, error: String)

func _ready() -> void:
	print("[BOOTSTRAP] Starting system bootstrap...")
	name = "SystemBootstrap"

## Main initialization function
func initialize_all_systems(main_scene: Node3D) -> bool:
	"""
	Initialize all systems in proper dependency order
	Returns true if all systems initialized successfully
	"""
	print("[BOOTSTRAP] Beginning system initialization...")
	
	initialization_attempt_count += 1
	
	if initialization_attempt_count > max_initialization_attempts:
		push_error("[BOOTSTRAP] Maximum initialization attempts exceeded!")
		emit_signal("initialization_failed", "bootstrap", "Max attempts exceeded")
		return false
	
	# Show loading overlay
	var loading_overlay = _create_loading_overlay(main_scene)
	
	# Initialize systems in dependency order
	var success = true
	success = success && await _initialize_debug_systems()
	success = success && await _initialize_core_systems(main_scene)
	success = success && await _initialize_model_systems(main_scene)
	success = success && await _initialize_interaction_systems(main_scene)
	success = success && await _initialize_final_systems(main_scene)
	
	if success:
		initialization_complete = true
		print("[BOOTSTRAP] All systems initialized successfully")
		emit_signal("all_systems_initialized")
	else:
		print("[BOOTSTRAP] System initialization failed")
	
	# Hide loading overlay
	if loading_overlay:
		loading_overlay.hide_loading()
		await get_tree().create_timer(0.5).timeout
		loading_overlay.queue_free()
	
	return success

## Debug systems initialization (highest priority)
func _initialize_debug_systems() -> bool:
	"""Initialize debug and monitoring systems first"""
	print("[BOOTSTRAP] Initializing debug systems...")
	
	if OS.is_debug_build():
		# Initialize resource debugger if available
		if _validate_autoload("ResourceDebugger"):
			ResourceDebugger.initialize()
			systems_initialized["ResourceDebugger"] = true
			emit_signal("system_initialized", "ResourceDebugger")
		
		# Initialize resource load tracer
		if _validate_autoload("ResourceLoadTracer"):
			ResourceLoadTracer.initialize()
			ResourceLoadTracer.diagnose_common_issues()
			systems_initialized["ResourceLoadTracer"] = true
			emit_signal("system_initialized", "ResourceLoadTracer")
	
	systems_initialized["debug_systems"] = true
	await get_tree().process_frame
	return true

## Core systems initialization (knowledge base, neural net)
func _initialize_core_systems(main_scene: Node3D) -> bool:
	"""Initialize core business logic systems"""
	print("[BOOTSTRAP] Initializing core systems...")
	
	# Initialize knowledge base
	if not await _initialize_knowledge_base(main_scene):
		return false
	
	# Initialize neural network module
	if not await _initialize_neural_net(main_scene):
		return false
	
	systems_initialized["core_systems"] = true
	await get_tree().process_frame
	return true

## Model management systems
func _initialize_model_systems(main_scene: Node3D) -> bool:
	"""Initialize model management and coordination systems"""
	print("[BOOTSTRAP] Initializing model systems...")
	
	# Initialize model switcher
	if not await _initialize_model_switcher(main_scene):
		return false
	
	# Initialize model coordinator
	if not await _initialize_model_coordinator(main_scene):
		return false
	
	systems_initialized["model_systems"] = true
	await get_tree().process_frame
	return true

## Interaction systems (selection, camera)
func _initialize_interaction_systems(main_scene: Node3D) -> bool:
	"""Initialize user interaction systems"""
	print("[BOOTSTRAP] Initializing interaction systems...")
	
	# Initialize selection manager
	if not await _initialize_selection_manager(main_scene):
		return false
	
	# Initialize camera controller
	if not await _initialize_camera_controller(main_scene):
		return false
	
	systems_initialized["interaction_systems"] = true
	await get_tree().process_frame
	return true

## Final setup and validation
func _initialize_final_systems(main_scene: Node3D) -> bool:
	"""Perform final system setup and validation"""
	print("[BOOTSTRAP] Finalizing system initialization...")
	
	# Register debug commands if available
	_register_debug_commands()
	
	# Validate all critical systems
	if not _validate_critical_systems():
		push_error("[BOOTSTRAP] Critical system validation failed")
		return false
	
	systems_initialized["final_systems"] = true
	await get_tree().process_frame
	return true

## Individual system initializers
func _initialize_knowledge_base(main_scene: Node3D) -> bool:
	"""Initialize the anatomical knowledge database"""
	try:
		knowledge_base = AnatomicalKnowledgeDatabaseScript.new()
		if knowledge_base == null:
			push_error("[BOOTSTRAP] Failed to create knowledge base instance")
			emit_signal("initialization_failed", "knowledge_base", "Instance creation failed")
			return false
		
		main_scene.add_child(knowledge_base)
		knowledge_base.load_knowledge_base()
		
		systems_initialized["knowledge_base"] = true
		emit_signal("system_initialized", "knowledge_base")
		print("[BOOTSTRAP] Knowledge base initialized successfully")
		return true
		
	except:
		push_error("[BOOTSTRAP] Exception during knowledge base initialization")
		emit_signal("initialization_failed", "knowledge_base", "Exception occurred")
		return false

func _initialize_neural_net(main_scene: Node3D) -> bool:
	"""Initialize the brain visualization core"""
	try:
		neural_net = BrainVisualizationCoreScript.new()
		if neural_net == null:
			push_error("[BOOTSTRAP] Failed to create neural net instance")
			emit_signal("initialization_failed", "neural_net", "Instance creation failed")
			return false
		
		main_scene.add_child(neural_net)
		
		systems_initialized["neural_net"] = true
		emit_signal("system_initialized", "neural_net")
		print("[BOOTSTRAP] Neural network module initialized successfully")
		return true
		
	except:
		push_error("[BOOTSTRAP] Exception during neural net initialization")
		emit_signal("initialization_failed", "neural_net", "Exception occurred")
		return false

func _initialize_model_switcher(main_scene: Node3D) -> bool:
	"""Initialize the model visibility manager"""
	try:
		model_switcher = ModelVisibilityManagerScript.new()
		if model_switcher == null:
			push_error("[BOOTSTRAP] Failed to create model switcher instance")
			emit_signal("initialization_failed", "model_switcher", "Instance creation failed")
			return false
		
		main_scene.add_child(model_switcher)
		
		systems_initialized["model_switcher"] = true
		emit_signal("system_initialized", "model_switcher")
		print("[BOOTSTRAP] Model switcher initialized successfully")
		return true
		
	except:
		push_error("[BOOTSTRAP] Exception during model switcher initialization")
		emit_signal("initialization_failed", "model_switcher", "Exception occurred")
		return false

func _initialize_model_coordinator(main_scene: Node3D) -> bool:
	"""Initialize the model coordination system"""
	try:
		model_coordinator = ModelCoordinatorScene.new()
		if model_coordinator == null:
			push_error("[BOOTSTRAP] Failed to create model coordinator instance")
			emit_signal("initialization_failed", "model_coordinator", "Instance creation failed")
			return false
		
		main_scene.add_child(model_coordinator)
		
		# Setup brain model parent if available
		var brain_parent = main_scene.get_node_or_null("BrainModel")
		if brain_parent:
			model_coordinator.set_model_parent(brain_parent)
		
		systems_initialized["model_coordinator"] = true
		emit_signal("system_initialized", "model_coordinator")
		print("[BOOTSTRAP] Model coordinator initialized successfully")
		return true
		
	except:
		push_error("[BOOTSTRAP] Exception during model coordinator initialization")
		emit_signal("initialization_failed", "model_coordinator", "Exception occurred")
		return false

func _initialize_selection_manager(main_scene: Node3D) -> bool:
	"""Initialize the brain structure selection manager"""
	try:
		selection_manager = BrainStructureSelectionManagerScript.new()
		if selection_manager == null:
			push_error("[BOOTSTRAP] Failed to create selection manager instance")
			emit_signal("initialization_failed", "selection_manager", "Instance creation failed")
			return false
		
		main_scene.add_child(selection_manager)
		
		systems_initialized["selection_manager"] = true
		emit_signal("system_initialized", "selection_manager")
		print("[BOOTSTRAP] Selection manager initialized successfully")
		return true
		
	except:
		push_error("[BOOTSTRAP] Exception during selection manager initialization")
		emit_signal("initialization_failed", "selection_manager", "Exception occurred")
		return false

func _initialize_camera_controller(main_scene: Node3D) -> bool:
	"""Initialize the camera behavior controller"""
	try:
		camera_controller = CameraBehaviorControllerScript.new()
		if camera_controller == null:
			push_error("[BOOTSTRAP] Failed to create camera controller instance")
			emit_signal("initialization_failed", "camera_controller", "Instance creation failed")
			return false
		
		main_scene.add_child(camera_controller)
		
		# Initialize with camera and brain model parent
		var camera = main_scene.get_node_or_null("Camera3D")
		var brain_parent = main_scene.get_node_or_null("BrainModel")
		
		if camera:
			camera_controller.initialize(camera, brain_parent)
		else:
			push_warning("[BOOTSTRAP] No camera found for camera controller")
		
		systems_initialized["camera_controller"] = true
		emit_signal("system_initialized", "camera_controller")
		print("[BOOTSTRAP] Camera controller initialized successfully")
		return true
		
	except:
		push_error("[BOOTSTRAP] Exception during camera controller initialization")
		emit_signal("initialization_failed", "camera_controller", "Exception occurred")
		return false

## Helper functions
func _create_loading_overlay(main_scene: Node3D):
	"""Create and show loading overlay"""
	var loading_overlay = LoadingOverlay.new()
	loading_overlay.name = "LoadingOverlay"
	main_scene.add_child(loading_overlay)
	loading_overlay.show_loading(LoadingOverlay.LoadingState.INITIALIZATION)
	return loading_overlay

func _validate_autoload(autoload_name: String) -> bool:
	"""Validate that an autoload exists and is accessible"""
	return Engine.has_singleton(autoload_name) or get_node("/root/" + autoload_name) != null

func _validate_critical_systems() -> bool:
	"""Validate that all critical systems are properly initialized"""
	var critical_systems = ["knowledge_base", "selection_manager", "camera_controller"]
	
	for system in critical_systems:
		if not systems_initialized.has(system) or not systems_initialized[system]:
			push_error("[BOOTSTRAP] Critical system not initialized: " + system)
			return false
	
	return true

func _register_debug_commands() -> void:
	"""Register debug commands if debug system is available"""
	if not OS.is_debug_build():
		return
	
	if not _validate_autoload("DebugCmd"):
		return
	
	DebugCmd.register_command("system_status", _debug_system_status, "Show system initialization status")
	DebugCmd.register_command("reinit_system", _debug_reinit_system, "Reinitialize a specific system")
	print("[BOOTSTRAP] Debug commands registered")

## Debug command implementations
func _debug_system_status() -> void:
	"""Show status of all systems"""
	print("=== SYSTEM STATUS ===")
	print("Initialization complete: ", initialization_complete)
	print("Attempt count: ", initialization_attempt_count, "/", max_initialization_attempts)
	print("Systems:")
	for system_name in systems_initialized.keys():
		var status = "✓" if systems_initialized[system_name] else "✗"
		print("  ", status, " ", system_name)

func _debug_reinit_system(system_name: String = "") -> void:
	"""Reinitialize a specific system (for debugging)"""
	if system_name.is_empty():
		print("Usage: reinit_system <system_name>")
		print("Available systems: ", systems_initialized.keys())
		return
	
	print("Reinitializing system: ", system_name)
	# Implementation would depend on specific system requirements
	print("System reinitialization not yet implemented")

## Getters for system references
func get_knowledge_base():
	"""Get the knowledge base system reference"""
	return knowledge_base

func get_neural_net():
	"""Get the neural net system reference"""
	return neural_net

func get_model_switcher():
	"""Get the model switcher system reference"""
	return model_switcher

func get_model_coordinator():
	"""Get the model coordinator system reference"""
	return model_coordinator

func get_selection_manager():
	"""Get the selection manager system reference"""
	return selection_manager

func get_camera_controller():
	"""Get the camera controller system reference"""
	return camera_controller

func is_system_initialized(system_name: String) -> bool:
	"""Check if a specific system is initialized"""
	return systems_initialized.get(system_name, false)

func is_initialization_complete() -> bool:
	"""Check if all systems are initialized"""
	return initialization_complete

## Cleanup
func _exit_tree():
	"""Clean up system references"""
	knowledge_base = null
	neural_net = null
	model_switcher = null
	model_coordinator = null
	selection_manager = null
	camera_controller = null
	systems_initialized.clear()
	initialization_complete = false