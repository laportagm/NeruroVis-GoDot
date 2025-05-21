# Manages structure selection, highlighting, and raycast operations for the NeuroVis application
class_name SelectionManager
extends Node

# Constants
const RAY_LENGTH: float = 1000.0

# Configuration variables
var highlight_color: Color = Color(0.0, 1.0, 0.0, 1.0)  # Green highlight
var emission_energy: float = 0.5

# Selection tracking
var current_selected_mesh: MeshInstance3D = null
var original_materials: Dictionary = {}  # mesh_instance -> original_material

# Signals
signal structure_selected(structure_name: String, mesh: MeshInstance3D)
signal structure_deselected

# Handles selection at a given screen position
func handle_selection_at_position(screen_position: Vector2) -> void:
	# Clear previous selection
	clear_current_selection()
	
	# Cast ray and find intersection
	var hit_mesh = _cast_selection_ray(screen_position)
	
	if hit_mesh:
		# Apply highlighting
		highlight_mesh(hit_mesh)
		current_selected_mesh = hit_mesh
		
		# Emit signal with structure info
		structure_selected.emit(hit_mesh.name, hit_mesh)
	else:
		structure_deselected.emit()

# Clears the current selection and restores original materials
func clear_current_selection() -> void:
	if current_selected_mesh != null:
		restore_original_material(current_selected_mesh)
		current_selected_mesh = null

# Highlights a mesh by applying a glowing material
func highlight_mesh(mesh: MeshInstance3D) -> void:
	if not mesh or not mesh.mesh:
		return
	
	# Store original materials before modifying
	_store_original_materials(mesh)
	
	# Create highlight material
	var highlight_material = StandardMaterial3D.new()
	highlight_material.albedo_color = highlight_color
	highlight_material.emission_enabled = true
	highlight_material.emission = highlight_color
	highlight_material.emission_energy = emission_energy
	
	# Apply highlight to all surfaces
	var surface_count = mesh.mesh.get_surface_count()
	for surface_idx in range(surface_count):
		mesh.set_surface_override_material(surface_idx, highlight_material)

# Restores the original material for a mesh
func restore_original_material(mesh: MeshInstance3D) -> void:
	if not mesh or not original_materials.has(mesh):
		return
	
	var original_material = original_materials[mesh]
	var surface_count = mesh.mesh.get_surface_count() if mesh.mesh else 1
	
	# Restore original material to all surfaces
	for surface_idx in range(surface_count):
		mesh.set_surface_override_material(surface_idx, original_material)
	
	# Remove from tracking dictionary
	original_materials.erase(mesh)

# Returns the name of the currently selected structure, or empty string if none
func get_selected_structure_name() -> String:
	if current_selected_mesh:
		return current_selected_mesh.name
	return ""

# Returns the currently selected mesh, or null if none
func get_selected_mesh() -> MeshInstance3D:
	return current_selected_mesh

# Configuration functions
func set_highlight_color(color: Color) -> void:
	highlight_color = color

func set_emission_energy(energy: float) -> void:
	emission_energy = energy

# Casts a ray from the camera through the screen position and returns the hit mesh
func _cast_selection_ray(screen_position: Vector2) -> MeshInstance3D:
	# Get the current camera
	var camera = get_viewport().get_camera_3d()
	if not camera:
		print("Warning: No camera found for selection raycast")
		return null
	
	# Calculate ray origin and direction
	var from = camera.project_ray_origin(screen_position)
	var to = from + camera.project_ray_normal(screen_position) * RAY_LENGTH
	
	# Setup raycast parameters
	var space_state = get_world_3d().direct_space_state
	if not space_state:
		print("Warning: No physics space found for selection raycast")
		return null
	
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	ray_params.collision_mask = 0xFFFFFFFF  # Detect all collision layers
	
	# Perform raycast
	var result = space_state.intersect_ray(ray_params)
	
	# Extract mesh from collision result
	if not result.is_empty():
		return _extract_mesh_from_collision(result)
	
	return null

# Extracts a MeshInstance3D from a physics collision result
func _extract_mesh_from_collision(collision_result: Dictionary) -> MeshInstance3D:
	if collision_result.is_empty() or not collision_result.has("collider"):
		return null
	
	var collider = collision_result.collider
	
	# Handle direct mesh instance hits
	if collider is MeshInstance3D:
		return collider
	
	# Handle static body hits (find parent mesh instance)
	if collider is StaticBody3D:
		var parent = collider.get_parent()
		if parent is MeshInstance3D:
			return parent
	
	# Could not find a valid mesh instance
	return null

# Stores original materials for a mesh before highlighting
func _store_original_materials(mesh: MeshInstance3D) -> void:
	if original_materials.has(mesh):
		return  # Already stored
	
	# Get the current material from the first surface
	var current_material = mesh.get_surface_override_material(0)
	if current_material == null and mesh.mesh != null:
		current_material = mesh.mesh.surface_get_material(0)
	
	# If still no material, create a default one
	if current_material == null:
		current_material = StandardMaterial3D.new()
		current_material.albedo_color = Color(0.8, 0.8, 0.8, 1.0)
	
	# Store a duplicate to preserve the original
	original_materials[mesh] = current_material.duplicate()