## SelectionSystem.gd
## Educational brain structure selection system with learning context
##
## This system manages user interaction for selecting anatomical structures,
## providing visual feedback, educational tooltips, and learning analytics.
## Designed as a focused, self-contained component for AI-friendly development.
##
## @tutorial: Educational selection patterns
## @version: 3.0 - Clean Scene-Based Architecture

class_name SelectionSystem
extends Node3D

# === EDUCATIONAL EVENTS ===
## Emitted when user selects a brain structure for educational exploration
signal structure_learning_started(structure_data: Dictionary)
## Emitted when structure selection is cleared
signal structure_learning_ended()
## Emitted when user hovers over a structure (preview learning opportunity)
signal structure_preview_started(structure_data: Dictionary)
## Emitted when hover ends
signal structure_preview_ended()
## Emitted when multiple structures are selected for comparison
signal comparison_learning_started(structures: Array)

# === CONFIGURATION ===
@export_group("Educational Settings")
@export var enable_learning_tooltips: bool = true
@export var track_learning_analytics: bool = true
@export var max_comparison_structures: int = 3

@export_group("Visual Feedback")
@export var selection_color: Color = Color(0.0, 1.0, 0.0, 0.8)
@export var hover_color: Color = Color(1.0, 0.7, 0.0, 0.6)
@export var emission_energy: float = 0.5

@export_group("Interaction")
@export var ray_length: float = 1000.0
@export var enable_multi_selection: bool = true

# === PRIVATE STATE ===
var _camera: Camera3D
var _brain_model_parent: Node3D
var _selected_structures: Array[Dictionary] = []
var _hovered_structure: Dictionary = {}
var _original_materials: Dictionary = {}
var _is_initialized: bool = false

# === LIFECYCLE METHODS ===
func _ready() -> void:
	print("[SelectionSystem] Initializing educational selection system...")
	set_process_input(false)  # Disable until initialized

func initialize(camera: Camera3D, brain_model_parent: Node3D) -> bool:
	"""Initialize the selection system with required components"""
	if _is_initialized:
		push_warning("[SelectionSystem] Already initialized")
		return false
	
	if not camera or not brain_model_parent:
		push_error("[SelectionSystem] Missing required components for initialization")
		return false
	
	_camera = camera
	_brain_model_parent = brain_model_parent
	
	# Enable input processing
	set_process_input(true)
	
	_is_initialized = true
	print("[SelectionSystem] ✓ Educational selection system ready")
	return true

# === INPUT HANDLING ===
func _input(event: InputEvent) -> void:
	if not _is_initialized:
		return
	
	# Handle mouse hover for educational preview
	if event is InputEventMouseMotion:
		_handle_educational_hover(event.position)
	
	# Handle right-click for structure selection
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_handle_educational_selection(event.position, event.ctrl_pressed)
		get_viewport().set_input_as_handled()

# === EDUCATIONAL INTERACTION METHODS ===
func _handle_educational_hover(screen_position: Vector2) -> void:
	"""Handle mouse hover for educational structure preview"""
	var structure_data = _get_structure_at_position(screen_position)
	
	if structure_data.is_empty():
		# No structure under cursor
		if not _hovered_structure.is_empty():
			_clear_hover_feedback()
			structure_preview_ended.emit()
			_hovered_structure = {}
	else:
		# Structure under cursor
		if _hovered_structure.get("id", "") != structure_data.get("id", ""):
			# New structure hovered
			_clear_hover_feedback()
			_apply_hover_feedback(structure_data)
			_hovered_structure = structure_data
			structure_preview_started.emit(structure_data)

func _handle_educational_selection(screen_position: Vector2, multi_select: bool) -> void:
	"""Handle structure selection for educational purposes"""
	var structure_data = _get_structure_at_position(screen_position)
	
	if structure_data.is_empty():
		# Clicked on empty space - clear selection
		_clear_all_selections()
		structure_learning_ended.emit()
		return
	
	if enable_multi_selection and multi_select:
		_handle_multi_selection(structure_data)
	else:
		_handle_single_selection(structure_data)

func _handle_single_selection(structure_data: Dictionary) -> void:
	"""Handle single structure selection for focused learning"""
	# Clear any existing selections
	_clear_all_selections()
	
	# Add new selection
	_selected_structures.append(structure_data)
	_apply_selection_feedback(structure_data)
	
	# Emit educational event
	structure_learning_started.emit(structure_data)
	
	# Track learning analytics if enabled
	if track_learning_analytics:
		_track_learning_interaction("structure_selected", structure_data)

func _handle_multi_selection(structure_data: Dictionary) -> void:
	"""Handle multiple structure selection for comparative learning"""
	var structure_id = structure_data.get("id", "")
	
	# Check if already selected
	var existing_index = -1
	for i in range(_selected_structures.size()):
		if _selected_structures[i].get("id", "") == structure_id:
			existing_index = i
			break
	
	if existing_index >= 0:
		# Deselect existing structure
		_clear_selection_feedback(_selected_structures[existing_index])
		_selected_structures.remove_at(existing_index)
	else:
		# Add new selection if under limit
		if _selected_structures.size() >= max_comparison_structures:
			push_warning("[SelectionSystem] Maximum comparison structures reached (%d)" % max_comparison_structures)
			return
		
		_selected_structures.append(structure_data)
		_apply_selection_feedback(structure_data)
	
	# Emit appropriate educational events
	if _selected_structures.size() > 1:
		comparison_learning_started.emit(_selected_structures)
	elif _selected_structures.size() == 1:
		structure_learning_started.emit(_selected_structures[0])
	else:
		structure_learning_ended.emit()
	
	# Track comparative learning analytics
	if track_learning_analytics:
		_track_learning_interaction("multi_selection_changed", {
			"selected_count": _selected_structures.size(),
			"structures": _selected_structures.map(func(s): return s.get("id", ""))
		})

# === STRUCTURE DETECTION ===
func _get_structure_at_position(screen_position: Vector2) -> Dictionary:
	"""Get educational structure data at screen position using raycast"""
	if not _camera or not _brain_model_parent:
		return {}
	
	# Create ray from camera through screen position
	var ray_origin = _camera.project_ray_origin(screen_position)
	var ray_direction = _camera.project_ray_normal(screen_position)
	
	# Perform raycast
	var space_state = _camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		ray_origin,
		ray_origin + ray_direction * ray_length
	)
	
	var result = space_state.intersect_ray(query)
	if result.is_empty():
		return {}
	
	# Get the mesh instance from collision
	var collider = result.get("collider")
	if not collider or not collider is MeshInstance3D:
		return {}
	
	# Convert mesh name to educational structure data
	return _get_educational_structure_data(collider.name)

func _get_educational_structure_data(mesh_name: String) -> Dictionary:
	"""Convert mesh name to educational structure data"""
	# Use KnowledgeService for educational content
	if KnowledgeService and KnowledgeService.is_initialized():
		var structure_data = KnowledgeService.get_structure(mesh_name)
		if not structure_data.is_empty():
			return structure_data
		
		# Try fuzzy search for educational content
		var search_results = KnowledgeService.search_structures(mesh_name)
		if not search_results.is_empty():
			return search_results[0]
	
	# Fallback to basic structure data
	return {
		"id": mesh_name.to_lower().replace(" ", "_"),
		"displayName": mesh_name,
		"mesh_reference": mesh_name,
		"shortDescription": "Educational content loading...",
		"educationalLevel": "basic"
	}

# === VISUAL FEEDBACK ===
func _apply_selection_feedback(structure_data: Dictionary) -> void:
	"""Apply visual feedback for selected structure"""
	var mesh_name = structure_data.get("mesh_reference", structure_data.get("displayName", ""))
	var mesh = _find_mesh_by_name(mesh_name)
	
	if mesh and mesh is MeshInstance3D:
		_store_original_material(mesh)
		_apply_highlight_material(mesh, selection_color)

func _apply_hover_feedback(structure_data: Dictionary) -> void:
	"""Apply visual feedback for hovered structure"""
	var mesh_name = structure_data.get("mesh_reference", structure_data.get("displayName", ""))
	var mesh = _find_mesh_by_name(mesh_name)
	
	if mesh and mesh is MeshInstance3D:
		# Only apply hover if not already selected
		if not _is_structure_selected(structure_data.get("id", "")):
			_store_original_material(mesh)
			_apply_highlight_material(mesh, hover_color)

func _clear_selection_feedback(structure_data: Dictionary) -> void:
	"""Clear visual feedback for a specific structure"""
	var mesh_name = structure_data.get("mesh_reference", structure_data.get("displayName", ""))
	var mesh = _find_mesh_by_name(mesh_name)
	
	if mesh and mesh is MeshInstance3D:
		_restore_original_material(mesh)

func _clear_hover_feedback() -> void:
	"""Clear hover visual feedback"""
	if not _hovered_structure.is_empty():
		# Only clear if not selected
		var structure_id = _hovered_structure.get("id", "")
		if not _is_structure_selected(structure_id):
			_clear_selection_feedback(_hovered_structure)

func _clear_all_selections() -> void:
	"""Clear all selections and visual feedback"""
	for structure_data in _selected_structures:
		_clear_selection_feedback(structure_data)
	
	_selected_structures.clear()

# === MATERIAL MANAGEMENT ===
func _store_original_material(mesh: MeshInstance3D) -> void:
	"""Store original material for later restoration"""
	if not _original_materials.has(mesh.get_instance_id()):
		_original_materials[mesh.get_instance_id()] = mesh.material_override

func _apply_highlight_material(mesh: MeshInstance3D, color: Color) -> void:
	"""Apply highlight material to mesh"""
	var highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = color
	highlight_material.emission_enabled = true
	highlight_material.emission = color
	highlight_material.emission_energy = emission_energy
	highlight_material.flags_transparent = true
	
	mesh.material_override = highlight_material

func _restore_original_material(mesh: MeshInstance3D) -> void:
	"""Restore original material to mesh"""
	var instance_id = mesh.get_instance_id()
	if _original_materials.has(instance_id):
		mesh.material_override = _original_materials[instance_id]
		_original_materials.erase(instance_id)

# === UTILITY METHODS ===
func _find_mesh_by_name(mesh_name: String) -> MeshInstance3D:
	"""Find mesh instance by name in brain model parent"""
	if not _brain_model_parent:
		return null
	
	return _find_mesh_recursive(_brain_model_parent, mesh_name)

func _find_mesh_recursive(node: Node, mesh_name: String) -> MeshInstance3D:
	"""Recursively search for mesh by name"""
	if node.name == mesh_name and node is MeshInstance3D:
		return node
	
	for child in node.get_children():
		var result = _find_mesh_recursive(child, mesh_name)
		if result:
			return result
	
	return null

func _is_structure_selected(structure_id: String) -> bool:
	"""Check if structure is currently selected"""
	for structure_data in _selected_structures:
		if structure_data.get("id", "") == structure_id:
			return true
	return false

func _track_learning_interaction(interaction_type: String, data: Dictionary) -> void:
	"""Track learning analytics for educational insights"""
	if not track_learning_analytics:
		return
	
	var analytics_data = {
		"timestamp": Time.get_unix_time_from_system(),
		"interaction_type": interaction_type,
		"data": data
	}
	
	# TODO: Send to learning analytics system
	print("[SelectionSystem] Learning interaction tracked: %s" % interaction_type)

# === PUBLIC API ===
func get_selected_structures() -> Array[Dictionary]:
	"""Get currently selected structures for educational use"""
	return _selected_structures.duplicate()

func clear_selections() -> void:
	"""Programmatically clear all selections"""
	_clear_all_selections()
	structure_learning_ended.emit()

func select_structure_by_id(structure_id: String) -> bool:
	"""Programmatically select a structure by ID"""
	var structure_data = _get_educational_structure_data(structure_id)
	if structure_data.is_empty():
		return false
	
	_handle_single_selection(structure_data)
	return true

func is_multi_selection_enabled() -> bool:
	"""Check if multi-selection is enabled"""
	return enable_multi_selection