## EducationalCoordinator.gd
## Minimal coordinator demonstrating the new scene-based architecture
##
## This shows how the new educational systems work together through events,
## serving as a proof-of-concept for the architecture while the old system remains.
##
## @tutorial: Scene-based coordination patterns
## @version: 3.0 - Clean Architecture Demo

class_name EducationalCoordinator
extends Node

# === COMPONENT REFERENCES ===
var selection_system: SelectionSystem
var brain_visualization: BrainVisualization
var educational_ui: EducationalUI
var event_bus: Node  # EventBus (will be autoload)

# === INITIALIZATION ===
func _ready() -> void:
	print("[EducationalCoordinator] Initializing new architecture demo...")
	
	# Get or create event bus
	event_bus = get_node_or_null("/root/EventBus")
	if not event_bus:
		# Load EventBus script as temporary demonstration
		var EventBusScript = load("res://scenes/coordination/EventBus.gd")
		event_bus = EventBusScript.new()
		event_bus.name = "EventBus_Demo"
		add_child(event_bus)
	
	# Setup systems
	_setup_selection_system()
	_setup_brain_visualization()
	_setup_educational_ui()
	_connect_educational_events()
	
	print("[EducationalCoordinator] ✓ New architecture demo ready")

func _setup_selection_system() -> void:
	"""Setup the new SelectionSystem component"""
	# Load and instantiate SelectionSystem
	var SelectionSystemScene = load("res://scenes/visualization_systems/SelectionSystem.tscn")
	selection_system = SelectionSystemScene.instantiate()
	selection_system.name = "SelectionSystem_New"
	add_child(selection_system)
	
	# Configure for educational use
	selection_system.enable_learning_tooltips = true
	selection_system.track_learning_analytics = true
	selection_system.enable_multi_selection = true
	
	print("[EducationalCoordinator] ✓ SelectionSystem component ready")

func _setup_brain_visualization() -> void:
	"""Setup the new BrainVisualization component"""
	# Load and instantiate BrainVisualization
	var BrainVisualizationScene = load("res://scenes/visualization_systems/BrainVisualization.tscn")
	brain_visualization = BrainVisualizationScene.instantiate()
	brain_visualization.name = "BrainVisualization_New"
	add_child(brain_visualization)
	
	# Configure for educational use
	brain_visualization.auto_load_models = true
	brain_visualization.enable_educational_layering = true
	brain_visualization.enable_progressive_disclosure = true
	brain_visualization.default_learning_mode = "exploration"
	
	print("[EducationalCoordinator] ✓ BrainVisualization component ready")

func _setup_educational_ui() -> void:
	"""Setup the new EducationalUI component"""
	# Load and instantiate EducationalUI
	var EducationalUIScene = load("res://scenes/interface_systems/EducationalUI.tscn")
	educational_ui = EducationalUIScene.instantiate()
	educational_ui.name = "EducationalUI_New"
	get_tree().root.add_child(educational_ui)  # Add to root for UI overlay
	
	# Configure for educational use
	educational_ui.default_theme_mode = "enhanced"
	educational_ui.enable_learning_tooltips = true
	educational_ui.track_ui_interactions = true
	
	# Initialize the UI system
	educational_ui.initialize()
	
	print("[EducationalCoordinator] ✓ EducationalUI component ready")

func _connect_educational_events() -> void:
	"""Connect educational events between systems"""
	if not selection_system or not event_bus:
		return
	
	# Connect selection system to event bus
	selection_system.structure_learning_started.connect(_on_structure_learning_started)
	selection_system.structure_learning_ended.connect(_on_structure_learning_ended)
	selection_system.structure_preview_started.connect(_on_structure_preview_started)
	selection_system.structure_preview_ended.connect(_on_structure_preview_ended)
	selection_system.comparison_learning_started.connect(_on_comparison_learning_started)
	
	# Connect brain visualization system
	if brain_visualization:
		brain_visualization.educational_models_ready.connect(_on_educational_models_ready)
		brain_visualization.educational_model_visibility_changed.connect(_on_model_visibility_changed)
		brain_visualization.educational_focus_changed.connect(_on_educational_focus_changed)
	
	# Connect educational UI system
	if educational_ui:
		educational_ui.educational_action_triggered.connect(_on_educational_action_triggered)
	
	print("[EducationalCoordinator] ✓ Educational events connected")

# === EDUCATIONAL EVENT HANDLERS ===
func _on_structure_learning_started(structure_data: Dictionary) -> void:
	"""Handle start of structure learning session"""
	print("[EducationalCoordinator] Learning started: %s" % structure_data.get("displayName", "Unknown"))
	
	# Emit through event bus for other systems
	if event_bus and event_bus.has_method("emit_structure_learning_started"):
		event_bus.emit_structure_learning_started(structure_data)
	
	# Request educational panel display through new UI system
	if educational_ui:
		educational_ui.display_educational_panel("structure_info", structure_data)
	
	# Also emit through event bus for other systems
	if event_bus and event_bus.has_method("emit_educational_panel_request"):
		event_bus.emit_educational_panel_request("structure_info", structure_data)

func _on_structure_learning_ended() -> void:
	"""Handle end of structure learning session"""
	print("[EducationalCoordinator] Learning session ended")
	
	if event_bus and event_bus.has_method("emit_structure_learning_ended"):
		event_bus.emit_structure_learning_ended()

func _on_structure_preview_started(structure_data: Dictionary) -> void:
	"""Handle structure preview (hover)"""
	print("[EducationalCoordinator] Preview: %s" % structure_data.get("displayName", "Unknown"))

func _on_structure_preview_ended() -> void:
	"""Handle end of structure preview"""
	pass  # Minimal logging for preview end

func _on_comparison_learning_started(structures: Array) -> void:
	"""Handle start of comparative learning session"""
	var structure_names = structures.map(func(s): return s.get("displayName", "Unknown"))
	print("[EducationalCoordinator] Comparison learning: %s" % ", ".join(structure_names))
	
	# Request comparative panel display through new UI system
	if educational_ui:
		educational_ui.display_educational_panel("comparison", {"structures": structures})
	
	# Also emit through event bus for other systems
	if event_bus and event_bus.has_method("emit_educational_panel_request"):
		event_bus.emit_educational_panel_request("comparison", {"structures": structures})

# === NEW COMPONENT EVENT HANDLERS ===
func _on_educational_models_ready(model_data: Array) -> void:
	"""Handle brain models loaded and ready for educational use"""
	print("[EducationalCoordinator] Educational models ready: %d models" % model_data.size())
	
	# Log available models for learning
	for model in model_data:
		var model_name = model.get("name", "Unknown")
		var educational_level = model.get("educational_level", "basic")
		print("  - %s (%s level)" % [model_name, educational_level])

func _on_model_visibility_changed(model_name: String, visible: bool, learning_context: String) -> void:
	"""Handle educational model visibility changes"""
	print("[EducationalCoordinator] Model visibility: %s %s (%s)" % [
		model_name, 
		"visible" if visible else "hidden",
		learning_context
	])

func _on_educational_focus_changed(focus_data: Dictionary) -> void:
	"""Handle educational focus changes for camera coordination"""
	var structure_name = focus_data.get("structure_name", "Unknown")
	var model_name = focus_data.get("model_name", "Unknown")
	print("[EducationalCoordinator] Educational focus: %s in %s" % [structure_name, model_name])

func _on_educational_action_triggered(action: String, context: Dictionary) -> void:
	"""Handle educational actions from UI system"""
	print("[EducationalCoordinator] Educational action: %s" % action)
	
	match action:
		"learn_more":
			_handle_learn_more_action(context)
		"bookmark":
			_handle_bookmark_action(context)
		"start_quiz":
			_handle_quiz_action(context)
		_:
			print("[EducationalCoordinator] Unknown educational action: %s" % action)

func _handle_learn_more_action(context: Dictionary) -> void:
	"""Handle 'learn more' educational action"""
	var structure_name = context.get("displayName", "Unknown")
	print("[EducationalCoordinator] Learning more about: %s" % structure_name)
	
	# Could trigger detailed information panel, related structures, etc.
	if educational_ui:
		educational_ui.display_educational_panel("learning_objectives", context)

func _handle_bookmark_action(context: Dictionary) -> void:
	"""Handle bookmark educational action"""
	var structure_name = context.get("displayName", "Unknown")
	print("[EducationalCoordinator] Bookmarked: %s" % structure_name)
	
	# Could save to user learning progress, favorites, etc.

func _handle_quiz_action(context: Dictionary) -> void:
	"""Handle quiz/assessment educational action"""
	var structure_name = context.get("displayName", "Unknown")
	print("[EducationalCoordinator] Starting quiz for: %s" % structure_name)
	
	# Could trigger assessment panel
	if educational_ui:
		educational_ui.display_educational_panel("assessment", context)

# === PUBLIC API ===
func initialize_with_components(camera: Camera3D, brain_model_parent: Node3D) -> bool:
	"""Initialize the coordinator with required 3D components"""
	var all_success = true
	
	# Initialize SelectionSystem
	if not selection_system:
		push_error("[EducationalCoordinator] SelectionSystem not ready")
		return false
	
	var selection_success = selection_system.initialize(camera, brain_model_parent)
	if not selection_success:
		push_error("[EducationalCoordinator] Failed to initialize SelectionSystem")
		all_success = false
	
	# Initialize BrainVisualization
	if brain_visualization:
		var visualization_success = brain_visualization.initialize(brain_model_parent)
		if not visualization_success:
			push_error("[EducationalCoordinator] Failed to initialize BrainVisualization")
			all_success = false
	
	if all_success:
		print("[EducationalCoordinator] ✓ All systems initialized with 3D components")
	else:
		print("[EducationalCoordinator] ✗ Some systems failed to initialize")
	
	return all_success

func get_selection_system() -> SelectionSystem:
	"""Get the selection system for integration testing"""
	return selection_system

func get_event_bus() -> Node:
	"""Get the event bus for integration testing"""
	return event_bus

# === INTEGRATION HELPERS ===
func demonstrate_new_architecture() -> void:
	"""Demonstrate the new architecture capabilities"""
	print("\\n=== NEW ARCHITECTURE DEMONSTRATION ===")
	print("1. Clean scene-based component structure")
	print("2. Educational event-driven communication")
	print("3. Focused, AI-friendly component design")
	print("4. Easy to test and modify individual systems")
	print("5. Clear separation of educational vs technical concerns")
	print("\\n• Try right-clicking on brain structures")
	print("• Use Ctrl+right-click for multi-selection")
	print("• Notice clean console output for educational events")
	print("=====================================\\n")

func compare_with_old_system() -> void:
	"""Compare new vs old architecture"""
	print("\\n=== ARCHITECTURE COMPARISON ===")
	print("OLD: 1400+ line monolithic script")
	print("NEW: Multiple focused components <300 lines each")
	print("\\nOLD: Direct method calls, tight coupling")
	print("NEW: Event-driven, loose coupling")
	print("\\nOLD: Mixed educational and technical concerns")
	print("NEW: Clear educational event layer")
	print("\\nOLD: Hard for AI to edit safely")
	print("NEW: AI can modify individual components")
	print("===============================\\n")