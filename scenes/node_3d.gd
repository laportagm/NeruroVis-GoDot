class_name MainScene
extends Node3D

# Constants
const RAY_LENGTH: float = 1000.0

# Export variables for customizing highlight appearance
@export var highlight_color: Color = Color(0.0, 1.0, 0.0, 1.0)  # Green highlight
@export var emission_energy: float = 0.5

# Node references
@onready var camera: Camera3D = $Camera3D
@onready var object_name_label: Label = $UI_Layer/ObjectNameLabel
@onready var info_panel: StructureInfoPanel = $UI_Layer/StructureInfoPanel

# Selection tracking variables
var current_selected_mesh: MeshInstance3D = null
var original_material: Material = null

func _ready() -> void:
	# Initialize the UI label
	object_name_label.text = "Selected: None"
	print("Main scene initialized.")
	
	# Connect info panel signals
	info_panel.panel_closed.connect(_on_info_panel_closed)
	
	# Hide info panel until needed
	info_panel.visible = false

func _unhandled_input(event: InputEvent) -> void:
	# Only process left mouse button clicks
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_handle_selection(event.position)

func _handle_selection(click_position: Vector2) -> void:
	# Clear previous selection
	if current_selected_mesh != null:
		current_selected_mesh.set_surface_override_material(0, original_material)
		current_selected_mesh = null
		original_material = null
	
	# Cast ray from camera through click position
	var from = camera.project_ray_origin(click_position)
	var to = from + camera.project_ray_normal(click_position) * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.new()
	ray_params.from = from
	ray_params.to = to
	var result = space_state.intersect_ray(ray_params)
	
	# Process selection result
	if not result.is_empty() and result.collider is StaticBody3D:
		var mesh_instance = _find_mesh_instance(result.collider)
		
		if mesh_instance != null:
			# Update selection variables
			current_selected_mesh = mesh_instance
			
			# Get original material (handle both override and mesh materials)
			var current_material = current_selected_mesh.get_surface_override_material(0)
			if current_material == null:
				current_material = current_selected_mesh.mesh.surface_get_material(0)
			
			# Store a duplicate of the original material
			original_material = current_material.duplicate()
			
			# Create and apply highlight material
			var highlight_material = _create_highlight_material(original_material)
			current_selected_mesh.set_surface_override_material(0, highlight_material)
			
			# Update UI
			var structure_name = current_selected_mesh.name
			object_name_label.text = "Selected: " + structure_name
			
			# Display structure information if available
			_display_structure_info(structure_name)
			return
	
	# If we reach here, nothing was selected or the selection failed
	object_name_label.text = "Selected: None"
	info_panel.visible = false

# Helper function to find a MeshInstance3D in the typical collision structure
# Expected hierarchy: StaticBody3D -> MeshInstance3D
func _find_mesh_instance(node: Node) -> MeshInstance3D:
	# If node is already a MeshInstance3D, return it
	if node is MeshInstance3D:
		return node
		
	# If node is a StaticBody3D, check direct children for a MeshInstance3D
	if node is StaticBody3D:
		for child in node.get_children():
			if child is MeshInstance3D:
				return child
	
	# No MeshInstance3D found
	return null

# Helper function to create a highlight material based on original material
func _create_highlight_material(base_material: Material) -> Material:
	# Handle null base_material
	if base_material == null:
		var default_null_material = StandardMaterial3D.new()
		default_null_material.albedo_color = highlight_color
		default_null_material.emission_enabled = true
		default_null_material.emission = highlight_color
		default_null_material.emission_energy = emission_energy
		return default_null_material

	var duplicated_material = base_material.duplicate()

	if duplicated_material is StandardMaterial3D:
		var std_material = duplicated_material as StandardMaterial3D
		var original_albedo = std_material.albedo_color
		std_material.albedo_color = original_albedo.lerp(highlight_color, 0.7)
		std_material.emission_enabled = true
		std_material.emission = highlight_color
		std_material.emission_energy = emission_energy
		# Preserve transparency
		if base_material is StandardMaterial3D: # Check original base_material for transparency property
			var original_std_base = base_material as StandardMaterial3D
			if original_std_base.transparency != BaseMaterial3D.TRANSPARENCY_DISABLED:
				std_material.albedo_color.a = original_albedo.a
	elif duplicated_material is ShaderMaterial:
		var shader_mat = duplicated_material as ShaderMaterial
		# Attempt to set common shader parameters
		if shader_mat.has_shader_parameter("albedo"): # Use has_shader_parameter for safety
			var original_albedo_param = shader_mat.get_shader_parameter("albedo")
			if original_albedo_param is Color:
				 shader_mat.set_shader_parameter("albedo", original_albedo_param.lerp(highlight_color, 0.7))
			else:
				 shader_mat.set_shader_parameter("albedo", highlight_color)
		# Similar safe checks for emission parameters
		if shader_mat.has_shader_parameter("emission_enabled"):
			shader_mat.set_shader_parameter("emission_enabled", true)
		if shader_mat.has_shader_parameter("emission"):
			shader_mat.set_shader_parameter("emission", highlight_color)
		if shader_mat.has_shader_parameter("emission_energy"):
			shader_mat.set_shader_parameter("emission_energy", emission_energy)
	else:
		# Fallback for other material types or if duplication fails to yield a known type
		var fallback_highlight_mat = StandardMaterial3D.new()
		fallback_highlight_mat.albedo_color = highlight_color
		fallback_highlight_mat.emission_enabled = true
		fallback_highlight_mat.emission = highlight_color
		fallback_highlight_mat.emission_energy = emission_energy
		return fallback_highlight_mat

	return duplicated_material

# Display structure information in the info panel
func _display_structure_info(structure_name: String) -> void:
	# Make sure knowledge base is loaded
	if not KB.is_loaded:
		print("Warning: Knowledge base not loaded, cannot display structure info.")
		info_panel.visible = false
		return
	
	# Try to find structure ID that matches or contains the mesh name
	# This is a simple mapping approach - in a real app, you might use metadata on the models
	var structure_id = _find_structure_id_by_name(structure_name)
	
	if structure_id.is_empty():
		print("No matching structure found in knowledge base for: " + structure_name)
		info_panel.visible = false
		return
	
	# Get structure data and display it
	var structure_data = KB.get_structure(structure_id)
	if not structure_data.is_empty():
		info_panel.display_structure_data(structure_data)
	else:
		print("Failed to retrieve structure data for ID: " + structure_id)
		info_panel.visible = false

# Find a structure ID by name matching (helper function)
func _find_structure_id_by_name(mesh_name: String) -> String:
	# Convert mesh name to lowercase for case-insensitive matching
	var lower_mesh_name = mesh_name.to_lower()
	
	# Get all structure IDs
	var structure_ids = KB.get_all_structure_ids()
	
	# First, try exact match with display name
	for id in structure_ids:
		var structure = KB.get_structure(id)
		if structure.has("displayName") and structure.displayName.to_lower() == lower_mesh_name:
			return id
	
	# Next, try partial match (if mesh name contains structure name or vice versa)
	for id in structure_ids:
		var structure = KB.get_structure(id)
		if structure.has("displayName"):
			var display_name = structure.displayName.to_lower()
			if lower_mesh_name.contains(display_name) or display_name.contains(lower_mesh_name):
				return id
	
	# No match found
	return ""

# Handle info panel closed signal
func _on_info_panel_closed() -> void:
	# Optional: you can add additional logic here if needed
	pass
