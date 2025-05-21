class_name MainScene
extends Node3D

# Constants
const RAY_LENGTH: float = 1000.0
const CAMERA_ROTATION_SPEED: float = 0.01  # Speed of rotation with middle mouse button
const CAMERA_ZOOM_SPEED: float = 0.5  # Increased for better responsiveness
const CAMERA_MIN_DISTANCE: float = 2.0  # Closer minimum zoom
const CAMERA_MAX_DISTANCE: float = 25.0  # Further maximum zoom
const DEBUG_MODE: bool = true  # Set to true to enable debugging features

# Export variables for customizing highlight appearance
@export var highlight_color: Color = Color(0.0, 1.0, 0.0, 1.0)  # Green highlight
@export var emission_energy: float = 0.5

# Camera control variables
var camera_distance: float = 10.0
var camera_rotation_x: float = 0.3  # Initial vertical angle
var camera_rotation_y: float = 0.0  # Initial horizontal angle
var is_rotating: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

# Continuous camera movement variables
var camera_input_vector = Vector2.ZERO
var camera_zoom_input = 0.0
var continuous_movement_active = false

# Node references
@onready var camera: Camera3D = $Camera3D
@onready var object_name_label: Label = $UI_Layer/ObjectNameLabel
@onready var info_panel = $UI_Layer/StructureInfoPanel  # Removed type annotation
@onready var brain_model_parent = $BrainModel

# System references
var knowledge_base: KnowledgeBase = null
var neural_net: NeuralNet = null
var model_switcher: ModelSwitcher = null
var model_control_panel = null

# Selection tracking variables
var current_selected_mesh: MeshInstance3D = null
var original_material: Material = null

# Signals
signal structure_selected(structure_name: String)
signal structure_deselected
signal models_loaded(model_names: Array)

func _ready() -> void:
	# Initialize the UI label
	object_name_label.text = "Selected: None"
	print("Main scene initialized.")
	
	# Initialize knowledge base
	knowledge_base = KnowledgeBase.new()
	add_child(knowledge_base)
	knowledge_base.load_knowledge_base()
	print("Knowledge base initialized and loaded.")
	
	# Initialize neural network module
	neural_net = NeuralNet.new()
	add_child(neural_net)
	print("Neural network module initialized.")
	
	# Initialize model switcher
	model_switcher = ModelSwitcher.new()
	add_child(model_switcher)
	print("Model switcher initialized.")
	
	# Setup UI layer
	$UI_Layer.visible = true  # Ensure UI layer is visible
	print("DEBUG: UI_Layer visibility set to: " + str($UI_Layer.visible))
	
	# Connect info panel signals
	info_panel.panel_closed.connect(_on_info_panel_closed)
	
	# Hide info panel until needed
	info_panel.visible = false
	
	# Add a debug print to check panel references
	print("DEBUG: Info panel reference valid: " + str(info_panel != null))
	print("DEBUG: Object name label reference valid: " + str(object_name_label != null))
	
	# Load 3D brain models
	_load_brain_models()
	print("Brain models loaded.")
	
	# Create model control panel
	_setup_model_control_panel()
	
	# Initialize camera with animation
	camera_distance = 10.0
	# Start with a different orientation to create a "reveal" effect
	camera_rotation_x = 0.5  # Looking more from above
	camera_rotation_y = -0.8  # From a side angle
	_update_camera_transform()
	
	# Add debug ray visualization
	_setup_debug_ray()
	
	# Start a timer to animate the camera to a better view
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.02  # 50fps animation
	timer.timeout.connect(_animate_camera)
	timer.start()
	print("Camera animation started.")
	
	# Print interaction instructions
	print("INTERACTION INSTRUCTIONS:")
	print("- Left-click to select brain structures")
	print("- Middle-click + drag to rotate the view")
	print("- Mouse wheel to zoom in/out")
	print("- Keyboard controls:")
	print("  - Arrow keys/WASD: Rotate camera")
	print("  - Q/- : Zoom out")
	print("  - E/+ : Zoom in")
	print("  - R: Reset camera view")

# Setup the model control panel
func _setup_model_control_panel() -> void:
	# Load the model control panel scene
	var panel_scene = load("res://scenes/model_control_panel.tscn")
	if not panel_scene:
		printerr("Failed to load model control panel scene")
		return
		
	# Instantiate the panel
	model_control_panel = panel_scene.instantiate()
	if not model_control_panel:
		printerr("Failed to instantiate model control panel")
		return
		
	# Add it to the UI layer
	$UI_Layer.add_child(model_control_panel)
	
	# Connect to model switcher signals if they exist
	if model_switcher.has_signal("model_visibility_changed"):
		model_switcher.model_visibility_changed.connect(_on_model_visibility_changed)
	
	# Connect to panel signals if they exist
	if model_control_panel.has_signal("model_selected"):
		model_control_panel.model_selected.connect(_on_model_selected)
	
	# Wait for models to be loaded
	if model_switcher.get_model_names().size() > 0:
		# Models already loaded, set up panel
		model_control_panel.setup_with_models(model_switcher.get_model_names())
	else:
		# Connect to models_loaded signal to set up panel when models are loaded
		models_loaded.connect(func(model_names): model_control_panel.setup_with_models(model_names))
	
	print("Model control panel set up")

# Handle model selected from the UI
func _on_model_selected(model_name: String) -> void:
	# Toggle visibility of the model
	model_switcher.toggle_model_visibility(model_name)

# Handle model visibility change from the model switcher
func _on_model_visibility_changed(model_name: String, is_visible: bool) -> void:
	# Update UI
	if model_control_panel:
		model_control_panel.update_button_state(model_name, is_visible)

# Handle all input events with higher priority than _unhandled_input
func _input(event: InputEvent) -> void:
	print("DEBUG: Input event received: " + event.get_class())
	
	# Handle keyboard input for camera control
	if event is InputEventKey and event.pressed:
		var handled = true
		
		match event.keycode:
			# Camera rotation
			KEY_LEFT, KEY_A:  # Rotate camera left
				camera_rotation_y += CAMERA_ROTATION_SPEED * 4.0
				print("DEBUG: Key press - rotate left")
			KEY_RIGHT, KEY_D:  # Rotate camera right
				camera_rotation_y -= CAMERA_ROTATION_SPEED * 4.0
				print("DEBUG: Key press - rotate right")
			KEY_UP, KEY_W:  # Rotate camera up
				camera_rotation_x += CAMERA_ROTATION_SPEED * 4.0
				print("DEBUG: Key press - rotate up")
			KEY_DOWN, KEY_S:  # Rotate camera down
				camera_rotation_x -= CAMERA_ROTATION_SPEED * 4.0
				print("DEBUG: Key press - rotate down")
				
			# Camera zoom
			KEY_Q, KEY_MINUS:  # Zoom out
				camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
				print("DEBUG: Key press - zoom out")
			KEY_E, KEY_PLUS, KEY_EQUAL:  # Zoom in
				camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
				print("DEBUG: Key press - zoom in")
				
			# Reset camera
			KEY_R:  # Reset camera to default position
				camera_rotation_x = 0.3
				camera_rotation_y = 0.0
				camera_distance = 10.0
				print("DEBUG: Key press - reset camera")
				
			_:  # If no match, mark as not handled
				handled = false
				
		# If we handled a key, update camera and mark as handled
		if handled:
			# Clamp vertical rotation
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			_update_camera_transform()
			get_viewport().set_input_as_handled()
			return
	
	# Handle mouse wheel for camera zoom
	if event is InputEventMouseButton:
		print("DEBUG: Mouse button event: " + str(event.button_index) + ", pressed: " + str(event.pressed))
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in - do immediate zoom plus set a brief continuous zoom
			print("DEBUG: Zoom in - distance before: " + str(camera_distance))
			camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
			_update_camera_transform()
			
			# Set a brief continuous zoom effect that will decay
			camera_zoom_input = -0.5
			
			# Create a timer to gradually reduce zoom input (momentum effect)
			var zoom_timer = Timer.new()
			add_child(zoom_timer)
			zoom_timer.wait_time = 0.1
			zoom_timer.one_shot = true
			zoom_timer.timeout.connect(func(): camera_zoom_input = 0.0)
			zoom_timer.start()
			
			print("DEBUG: New camera distance: " + str(camera_distance))
			get_viewport().set_input_as_handled()
			return
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out - do immediate zoom plus set a brief continuous zoom
			print("DEBUG: Zoom out - distance before: " + str(camera_distance))
			camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
			_update_camera_transform()
			
			# Set a brief continuous zoom effect that will decay
			camera_zoom_input = 0.5
			
			# Create a timer to gradually reduce zoom input (momentum effect)
			var zoom_timer = Timer.new()
			add_child(zoom_timer)
			zoom_timer.wait_time = 0.1
			zoom_timer.one_shot = true
			zoom_timer.timeout.connect(func(): camera_zoom_input = 0.0)
			zoom_timer.start()
			
			print("DEBUG: New camera distance: " + str(camera_distance))
			get_viewport().set_input_as_handled()
			return
			
		# Handle middle mouse button for camera rotation
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			print("DEBUG: Middle mouse " + ("pressed" if event.pressed else "released"))
			is_rotating = event.pressed
			last_mouse_position = event.position
			get_viewport().set_input_as_handled()
			return
			
		# Handle left mouse click for selection
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("DEBUG: Left click for selection")
			_handle_selection(event.position)
			get_viewport().set_input_as_handled()
			return
	
	# Handle mouse motion for camera rotation
	elif event is InputEventMouseMotion:
		if is_rotating:
			print("DEBUG: Camera rotation - mouse motion")
			var motion = event.position - last_mouse_position
			
			# Apply rotation (inverted Y axis for natural control)
			camera_rotation_y -= motion.x * CAMERA_ROTATION_SPEED
			camera_rotation_x -= motion.y * CAMERA_ROTATION_SPEED
			
			# Limit vertical rotation to avoid flipping
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			
			# Update the camera
			_update_camera_transform()
			
			# Save current mouse position for next frame
			last_mouse_position = event.position
			
			# Mark input as handled
			get_viewport().set_input_as_handled()
			return
			
	# For any other events we might want to handle in the future
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# Future controller support could go here
		pass
			
# Keep _unhandled_input as a backup
func _unhandled_input(event: InputEvent) -> void:
	# This is a fallback in case _input doesn't handle the event
	print("DEBUG: Unhandled input event: " + event.get_class())
	
	# Handle mouse wheel for camera zoom (fallback)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in with continuous effect
			camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
			_update_camera_transform()
			
			# Set brief continuous zoom
			camera_zoom_input = -0.5
			var zoom_timer = Timer.new()
			add_child(zoom_timer)
			zoom_timer.wait_time = 0.1
			zoom_timer.one_shot = true
			zoom_timer.timeout.connect(func(): camera_zoom_input = 0.0)
			zoom_timer.start()
			
			get_viewport().set_input_as_handled()
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out with continuous effect
			camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
			_update_camera_transform()
			
			# Set brief continuous zoom
			camera_zoom_input = 0.5
			var zoom_timer = Timer.new()
			add_child(zoom_timer)
			zoom_timer.wait_time = 0.1
			zoom_timer.one_shot = true
			zoom_timer.timeout.connect(func(): camera_zoom_input = 0.0)
			zoom_timer.start()
			
			get_viewport().set_input_as_handled()
			
		# Handle middle mouse button for camera rotation
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_rotating = event.pressed
			last_mouse_position = event.position
			get_viewport().set_input_as_handled()
			
		# Handle left mouse click for selection
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_selection(event.position)
			
	# Handle mouse motion for camera rotation (fallback)
	elif event is InputEventMouseMotion and is_rotating:
		var motion = event.position - last_mouse_position
		camera_rotation_y -= motion.x * CAMERA_ROTATION_SPEED
		camera_rotation_x -= motion.y * CAMERA_ROTATION_SPEED
		
		# Limit vertical rotation to avoid flipping
		camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
		
		_update_camera_transform()
		last_mouse_position = event.position
		get_viewport().set_input_as_handled()

func _handle_selection(click_position: Vector2) -> void:
	# Clear previous selection
	if current_selected_mesh != null:
		# Clear all surfaces if the mesh has multiple surfaces
		if current_selected_mesh.mesh and current_selected_mesh.mesh.get_surface_count() > 1:
			for surface_idx in range(current_selected_mesh.mesh.get_surface_count()):
				current_selected_mesh.set_surface_override_material(surface_idx, null)
			
			# Apply original material to surface 0 as fallback
			current_selected_mesh.set_surface_override_material(0, original_material)
		else:
			current_selected_mesh.set_surface_override_material(0, original_material)
		
		current_selected_mesh = null
		original_material = null
	
	# Cast ray from camera through click position
	var from = camera.project_ray_origin(click_position)
	var to = from + camera.project_ray_normal(click_position) * RAY_LENGTH
	
	# Visualize ray for debugging
	_draw_debug_ray(from, to)
	
	print("DEBUG: === Starting Ray Cast Process ===")
	print("DEBUG: Click position on screen: " + str(click_position))
	print("DEBUG: Ray origin in 3D space: " + str(from))
	print("DEBUG: Ray end point in 3D space: " + str(to))
	
	var space_state = get_world_3d().direct_space_state
	var ray_params = PhysicsRayQueryParameters3D.create(from, to)
	# Configure collision mask to detect all objects (default = 1)
	ray_params.collision_mask = 0xFFFFFFFF  # All bits set, detect all layers
	ray_params.hit_from_inside = true  # Detect hits from inside objects too
	
	# First try normal ray cast
	var result = space_state.intersect_ray(ray_params)
	
	# If no result, try different ray lengths (in case objects are very far or very near)
	if result.is_empty():
		print("DEBUG: Initial ray cast failed, trying shorter distance...")
		to = from + camera.project_ray_normal(click_position) * (RAY_LENGTH * 0.1)
		ray_params = PhysicsRayQueryParameters3D.create(from, to)
		ray_params.collision_mask = 0xFFFFFFFF
		ray_params.hit_from_inside = true
		result = space_state.intersect_ray(ray_params)
	
	if result.is_empty():
		# Try direct object picking with all meshes in scene as fallback
		print("DEBUG: Ray casting failed, attempting direct object detection...")
		
		# Use our helper class to store results by reference
		var mesh_finder = MeshFinder.new()
		
		# Get all mesh instances in the scene
		for model in brain_model_parent.get_children():
			_find_closest_mesh_to_ray(model, from, camera.project_ray_normal(click_position), mesh_finder)
		
		if mesh_finder.closest_mesh != null:
			# Create a synthetic result dictionary
			print("DEBUG: Found closest mesh through direct checking: " + mesh_finder.closest_mesh.name + 
				  " at distance: " + str(mesh_finder.min_distance))
			result = {
				"collider": mesh_finder.closest_mesh,
				"position": mesh_finder.closest_mesh.global_position
			}
	
	# Process selection result
	if not result.is_empty():
		print("DEBUG: Ray hit object: " + str(result.collider.name) + " of type: " + result.collider.get_class())
		
		# Handle both direct mesh instance hits and static body hits
		var mesh_instance = null
		if result.collider is MeshInstance3D:
			mesh_instance = result.collider
		elif result.collider is StaticBody3D:
			mesh_instance = _find_mesh_instance(result.collider)
		
		if mesh_instance != null:
			print("DEBUG: Found mesh instance: " + mesh_instance.name)
			# Update selection variables
			current_selected_mesh = mesh_instance
			
			print("DEBUG: Mesh has " + str(current_selected_mesh.mesh.get_surface_count()) + " surfaces")
			
			# Get original material (handle both override and mesh materials)
			var current_material = current_selected_mesh.get_surface_override_material(0)
			if current_material == null and current_selected_mesh.mesh != null:
				current_material = current_selected_mesh.mesh.surface_get_material(0)
			
			# Handle case where no material exists
			if current_material == null:
				print("DEBUG: No material found for " + mesh_instance.name + ", creating default")
				current_material = StandardMaterial3D.new()
				current_material.albedo_color = Color(0.8, 0.8, 0.8, 1.0)
			
			# Store a duplicate of the original material
			original_material = current_material.duplicate()
			
			# Create and apply highlight material
			var highlight_material = _create_highlight_material(original_material)
			
			# Apply highlight to all surfaces if there are multiple
			if current_selected_mesh.mesh.get_surface_count() > 1:
				print("DEBUG: Applying highlight to all " + str(current_selected_mesh.mesh.get_surface_count()) + " surfaces")
				for surface_idx in range(current_selected_mesh.mesh.get_surface_count()):
					current_selected_mesh.set_surface_override_material(surface_idx, highlight_material)
			else:
				current_selected_mesh.set_surface_override_material(0, highlight_material)
			
			# Update UI
			var structure_name = current_selected_mesh.name
			object_name_label.text = "Selected: " + structure_name
			print("DEBUG: Selected structure: " + structure_name)
			
			# Emit signal
			emit_signal("structure_selected", structure_name)
			
			# Display structure information if available
			_display_structure_info(structure_name)
			return
		else:
			print("DEBUG: Could not find a valid mesh instance from hit object")
	else:
		print("DEBUG: Ray did not hit any object")
	
	# If we reach here, nothing was selected or the selection failed
	object_name_label.text = "Selected: None"
	info_panel.visible = false
	emit_signal("structure_deselected")

# Helper function to find a MeshInstance3D in the typical collision structure
# Expected hierarchy can be:
# - StaticBody3D -> MeshInstance3D (child)
# - MeshInstance3D -> StaticBody3D (parent)
# - Node3D -> MeshInstance3D, StaticBody3D (siblings)
# - Any other structure with parent/child/sibling relationships
func _find_mesh_instance(node: Node) -> MeshInstance3D:
	print("DEBUG: Finding mesh instance for: " + node.name + " type: " + node.get_class())
	
	# If node is already a MeshInstance3D, return it
	if node is MeshInstance3D:
		print("DEBUG: Node is directly a MeshInstance3D")
		return node
		
	print("DEBUG: Trying all lookup strategies to find associated mesh...")
	
	# CASE 1: Try to find the mesh in the direct parent-child relationships
	if node.get_parent() != null and node.get_parent() is MeshInstance3D:
		print("DEBUG: Found a MeshInstance3D parent: " + node.get_parent().name)
		return node.get_parent() as MeshInstance3D
		
	# Case 2: Check if node has MeshInstance3D children
	print("DEBUG: Checking if node has MeshInstance3D children...")
	for child in node.get_children():
		print("DEBUG: Checking child: " + child.name + " of type: " + child.get_class())
		if child is MeshInstance3D:
			print("DEBUG: Found MeshInstance3D child: " + child.name)
			return child
	
	# Case 3: Look for sibling MeshInstance3D nodes under common parent
	var parent = node.get_parent()
	if parent != null:
		print("DEBUG: Checking siblings under parent: " + parent.name + " of type: " + parent.get_class())
		if parent is MeshInstance3D:
			print("DEBUG: ⭐⭐⭐ Parent is a MeshInstance3D: " + parent.name)
			return parent
			
		for child in parent.get_children():
			if child is MeshInstance3D and child != node:
				print("DEBUG: Found MeshInstance3D sibling: " + child.name)
				return child
				
		# Special case: Check if parent's parent is a mesh (common in some model formats)
		if parent.get_parent() != null and parent.get_parent() is MeshInstance3D:
			print("DEBUG: ⭐⭐⭐ Found MeshInstance3D grandparent: " + parent.get_parent().name)
			return parent.get_parent() as MeshInstance3D
	
	# Case 4: Drastic approach - find nearest mesh in the tree
	print("DEBUG: Using brute force approach to find related mesh...")
	
	# First look at parent hierarchy
	var current = node
	var hierarchy_depth = 0
	while current.get_parent() != null and hierarchy_depth < 5:
		hierarchy_depth += 1
		current = current.get_parent()
		print("DEBUG: Checking hierarchy level " + str(hierarchy_depth) + ": " + current.name + " (" + current.get_class() + ")")
		
		if current is MeshInstance3D:
			print("DEBUG: Found MeshInstance3D in parent hierarchy: " + current.name)
			return current
			
		# Look for meshes in all children at this level
		for child in current.get_children():
			if child is MeshInstance3D and child != node:
				print("DEBUG: Found a MeshInstance3D in parent's children: " + child.name)
				return child
		
		# If parent is a node3D with a specific name pattern, try to find mesh instance with similar name
		if current is Node3D and (current.name.contains("Structure") or current.name.contains("Model")):
			print("DEBUG: Found a likely model container node: " + current.name)
			# Search for meshes by name similarity
			var meshes = _find_all_meshes_in_tree(current)
			if not meshes.is_empty():
				print("DEBUG: Found " + str(meshes.size()) + " potential mesh matches")
				return meshes[0] # Return the first one found
	
	# Last resort - find first mesh in the scene
	var root = node.get_tree().root
	if root != null:
		var first_mesh = _find_first_mesh_in_tree(root, node.global_position)
		if first_mesh != null:
			print("DEBUG: LAST RESORT - Found a mesh somewhere in the scene: " + first_mesh.name)
			return first_mesh
	
	# No MeshInstance3D found
	print("DEBUG: Could not find any related MeshInstance3D")
	return null
	
# Helper function to find all meshes in a subtree
func _find_all_meshes_in_tree(node: Node) -> Array:
	var meshes = []
	
	if node is MeshInstance3D:
		meshes.append(node)
		
	for child in node.get_children():
		meshes.append_array(_find_all_meshes_in_tree(child))
		
	return meshes
	
# Helper function to find first mesh in a tree closest to a position
func _find_first_mesh_in_tree(node: Node, reference_position: Vector3) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
		
	for child in node.get_children():
		var result = _find_first_mesh_in_tree(child, reference_position)
		if result != null:
			return result
			
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
	if not knowledge_base.is_loaded:
		print("Warning: Knowledge base not loaded, cannot display structure info.")
		info_panel.visible = false
		return
	
	print("=== STRUCTURE INFO DISPLAY PROCESS ===")
	print("DEBUG: Displaying info for structure: " + structure_name)
	
	# Check UI components before proceeding
	print("DEBUG: UI_Layer visible: " + str($UI_Layer.visible))
	print("DEBUG: Info panel exists: " + str(info_panel != null))
	print("DEBUG: Info panel type: " + info_panel.get_class())
	
	# Try to find structure ID that matches or contains the mesh name
	# This is a simple mapping approach - in a real app, you might use metadata on the models
	var structure_id = _find_structure_id_by_name(structure_name)
	
	if structure_id.is_empty():
		print("No matching structure found in knowledge base for: " + structure_name)
		info_panel.visible = false
		return
	
	print("DEBUG: Found structure ID: " + structure_id)
	
	# Get structure data and display it
	var structure_data = knowledge_base.get_structure(structure_id)
	if not structure_data.is_empty():
		print("DEBUG: Successfully retrieved structure data. Displaying in info panel...")
		print("DEBUG: Structure display name: " + structure_data.get("displayName", "N/A"))
		
		# Ensure panel's parent (UI_Layer) is visible
		$UI_Layer.visible = true
		
		# Explicitly set the panel to visible first
		info_panel.visible = true
		
		# Call the display function
		info_panel.display_structure_data(structure_data)
		
		# Double-check visibility after display
		if not info_panel.visible:
			print("WARNING: Info panel not visible after display_structure_data call!")
			info_panel.visible = true
		
		# Force UI update
		get_tree().call_group("ui", "queue_redraw")
		
		print("DEBUG: Info panel visibility after display: " + str(info_panel.visible))
	else:
		print("Failed to retrieve structure data for ID: " + structure_id)
		info_panel.visible = false
	
	print("=== END OF STRUCTURE INFO DISPLAY PROCESS ===")

# Find a structure ID by name matching (helper function)
func _find_structure_id_by_name(mesh_name: String) -> String:
	# First try using our neural net mapping function
	if neural_net != null:
		var mapped_id = neural_net.map_mesh_name_to_structure_id(mesh_name)
		if not mapped_id.is_empty():
			print("DEBUG: Found structure ID via neural net mapping: " + mapped_id)
			return mapped_id
	
	# Fallback: Convert mesh name to lowercase for case-insensitive matching
	var lower_mesh_name = mesh_name.to_lower()
	print("DEBUG: Trying fallback method to find structure ID for: " + mesh_name)
	
	# Get all structure IDs
	var structure_ids = knowledge_base.get_all_structure_ids()
	
	# First, try exact match with display name
	for id in structure_ids:
		var structure = knowledge_base.get_structure(id)
		if structure.has("displayName") and structure.displayName.to_lower() == lower_mesh_name:
			print("DEBUG: Found exact match in knowledge base: " + id)
			return id
	
	# Next, try matching the ID directly
	if structure_ids.has(mesh_name):
		print("DEBUG: Direct ID match found: " + mesh_name)
		return mesh_name
	
	# Next, try partial match (if mesh name contains structure name or vice versa)
	for id in structure_ids:
		var structure = knowledge_base.get_structure(id)
		if structure.has("displayName"):
			var display_name = structure.displayName.to_lower()
			if lower_mesh_name.contains(display_name) or display_name.contains(lower_mesh_name):
				print("DEBUG: Found partial match in knowledge base: " + id)
				return id
	
	# No match found
	print("DEBUG: No structure ID match found for: " + mesh_name)
	return ""

# Handle info panel closed signal
func _on_info_panel_closed() -> void:
	# Optional: you can add additional logic here if needed
	pass

# Load 3D brain models from assets/models/ directory
func _load_brain_models() -> void:
	print("DEBUG: Starting to load brain models...")
	
	# Get the brain model parent node
	if not brain_model_parent:
		print("ERROR: BrainModel node not found in scene")
		return
	else:
		print("DEBUG: BrainModel node found at position " + str(brain_model_parent.global_position))
	
	# Define the models to load
	var models_to_load = [
		{
			"path": "res://assets/models/Half_Brain.glb",
			"position": Vector3(0, 0, 0),
			"rotation": Vector3(0, 180, 0),  # Rotate 180 degrees to face camera
			"scale": Vector3(0.7, 0.7, 0.7)  # Increase scale to 70%
		},
		{
			"path": "res://assets/models/Internal_Structures.glb",
			"position": Vector3(0, 0, 0),
			"rotation": Vector3(0, 180, 0),  # Rotate 180 degrees to face camera
			"scale": Vector3(0.7, 0.7, 0.7)  # Increase scale to 70%
		},
		{
			"path": "res://assets/models/Brainstem(Solid).glb",
			"position": Vector3(0, 0, 0),
			"rotation": Vector3(0, 180, 0),  # Rotate 180 degrees to face camera
			"scale": Vector3(0.7, 0.7, 0.7)  # Increase scale to 70%
		}
	]
	
	print("DEBUG: Will attempt to load " + str(models_to_load.size()) + " models")
	
	# Track successful loads
	var successful_loads = 0
	
	# Load each model
	for model_info in models_to_load:
		print("DEBUG: Processing model: " + model_info.path)
		
		# Check if the file exists
		if not ResourceLoader.exists(model_info.path):
			print("ERROR: Model file not found: " + model_info.path)
			continue
		else:
			print("DEBUG: Model file found: " + model_info.path)
		
		# Load the scene
		var model_scene = load(model_info.path)
		if not model_scene:
			print("ERROR: Failed to load model: " + model_info.path)
			continue
		else:
			print("DEBUG: Model scene loaded successfully")
		
		# Instantiate the scene
		var model_instance = model_scene.instantiate()
		if not model_instance:
			print("ERROR: Failed to instantiate model: " + model_info.path)
			continue
		else:
			print("DEBUG: Model instantiated with type: " + model_instance.get_class())
			
			# List children to understand model structure
			var child_count = model_instance.get_child_count()
			print("DEBUG: Model has " + str(child_count) + " direct children")
			for i in range(child_count):
				var child = model_instance.get_child(i)
				print("DEBUG: Child " + str(i) + ": " + child.get_class() + " named '" + child.name + "'")
				
				# If the child is a MeshInstance3D, print its material info
				if child is MeshInstance3D and child.mesh != null:
					var surface_count = child.mesh.get_surface_count()
					print("DEBUG: MeshInstance '" + child.name + "' has " + str(surface_count) + " surfaces")
					
					for s in range(surface_count):
						var material = child.mesh.surface_get_material(s)
						if material:
							print("DEBUG: Surface " + str(s) + " has material of type: " + material.get_class())
						else:
							print("DEBUG: Surface " + str(s) + " has no material")
		
		# Set transform
		model_instance.position = model_info.position
		model_instance.rotation_degrees = model_info.rotation
		model_instance.scale = model_info.scale
		
		# Add as child of brain model parent
		brain_model_parent.add_child(model_instance)
		print("DEBUG: Added model to scene: " + model_info.path.get_file())
		successful_loads += 1
		
		# Set up collision for all MeshInstance3D nodes in the model
		_setup_mesh_collisions(model_instance)
		
	print("DEBUG: Successfully loaded " + str(successful_loads) + " of " + str(models_to_load.size()) + " models")
	
	# Register models with the model switcher
	var model_names = []
	for i in range(brain_model_parent.get_child_count()):
		var model = brain_model_parent.get_child(i)
		var model_name = model.name.replace(".glb", "").replace("(Solid)", "")
		model_switcher.register_model(model, model_name)
		model_names.append(model_name)
	
	# Emit signal that models are loaded
	emit_signal("models_loaded", model_names)

# Set up collision bodies for mesh instances
func _setup_mesh_collisions(node: Node) -> void:
	# Process this node if it's a MeshInstance3D
	if node is MeshInstance3D and node.mesh != null:
		# Check if it already has a StaticBody3D parent
		var already_has_collision = false
		for child in node.get_children():
			if child is StaticBody3D:
				already_has_collision = true
				break
		
		# If no collision body exists, create one
		if not already_has_collision:
			var static_body = StaticBody3D.new()
			node.add_child(static_body)
			
			# Create collision shape
			var collision_shape = CollisionShape3D.new()
			static_body.add_child(collision_shape)
			
			# Create a shape that matches the mesh
			var shape = node.mesh.create_trimesh_shape()
			collision_shape.shape = shape
			
			print("DEBUG: Added collision to: " + node.name)
			
			# Check if the mesh has a material, if not add a default one
			var needs_default_material = true
			
			for i in range(node.mesh.get_surface_count()):
				if node.mesh.surface_get_material(i) != null:
					needs_default_material = false
					break
			
			if needs_default_material:
				print("DEBUG: Adding default material to: " + node.name)
				var default_material = StandardMaterial3D.new()
				default_material.albedo_color = Color(0.9, 0.9, 0.9, 1.0)
				default_material.metallic = 0.1
				default_material.roughness = 0.7
				node.set_surface_override_material(0, default_material)
	
	# Check all children recursively
	for child in node.get_children():
		_setup_mesh_collisions(child)


# Process function for continuous movement
func _process(delta: float) -> void:
	# Handle continuous camera movement if active
	if camera_input_vector != Vector2.ZERO:
		# Apply rotation based on input vector
		camera_rotation_y -= camera_input_vector.x * CAMERA_ROTATION_SPEED * delta * 60.0
		camera_rotation_x -= camera_input_vector.y * CAMERA_ROTATION_SPEED * delta * 60.0
		
		# Limit vertical rotation to avoid flipping
		camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
		
		# Update the camera
		_update_camera_transform()
	
	# Handle continuous zoom
	if camera_zoom_input != 0.0:
		camera_distance = clamp(
			camera_distance + (camera_zoom_input * CAMERA_ZOOM_SPEED * delta * 60.0),
			CAMERA_MIN_DISTANCE,
			CAMERA_MAX_DISTANCE
		)
		_update_camera_transform()

# Update camera transform based on orbital parameters
func _update_camera_transform() -> void:
	# Print current orbital parameters
	print("DEBUG: Camera update - distance: " + str(camera_distance) + 
		  ", rotation X: " + str(camera_rotation_x) + 
		  ", rotation Y: " + str(camera_rotation_y))
	
	# Calculate new camera position using spherical coordinates
	var x = camera_distance * sin(camera_rotation_x) * sin(camera_rotation_y)
	var y = camera_distance * cos(camera_rotation_x)
	var z = camera_distance * sin(camera_rotation_x) * cos(camera_rotation_y)
	
	# Create new position vector
	var new_position = Vector3(x, y, z)
	print("DEBUG: New camera position: " + str(new_position))
	
	# Set camera position - use global position for absolute positioning
	camera.global_position = new_position
	
	# Look target point (center of brain model + small Y offset)
	var look_target = $BrainModel.global_position + Vector3(0, 2, 0)
	print("DEBUG: Camera looking at: " + str(look_target))
	
	# Make camera look at the brain model
	camera.look_at(look_target)
	
	# Force camera update
	camera.force_update_transform()
	
	# Debug info - print final camera position and basis
	print("DEBUG: Final camera transform - position: " + str(camera.global_position) + 
		  ", forward: " + str(-camera.global_transform.basis.z.normalized()))

# Camera animation variables
var target_rotation_x: float = 0.3
var target_rotation_y: float = 0.0
var animation_progress: float = 0.0
var animation_duration: float = 2.0  # Seconds
var animation_active: bool = false
var auto_rotate: bool = false  # Whether camera should auto-rotate

# Animate camera to smoothly transition to default view
func _animate_camera() -> void:
	# Cancel animation if user is manually rotating
	if is_rotating:
		animation_active = false
		auto_rotate = false
		return
		
	if not animation_active:
		animation_active = true
		animation_progress = 0.0
	
	# Progress the animation
	animation_progress += 0.02  # Timer wait time
	var t = min(animation_progress / animation_duration, 1.0)
	
	# Use smoothstep for easing
	var ease_factor = t * t * (3.0 - 2.0 * t)
	
	# Interpolate camera rotation
	camera_rotation_x = lerp(camera_rotation_x, target_rotation_x, ease_factor * 0.05)
	camera_rotation_y = lerp(camera_rotation_y, target_rotation_y, ease_factor * 0.05)
	
	# Update camera
	_update_camera_transform()
	
	# Stop animation when done
	if t >= 1.0:
		animation_active = false
		auto_rotate = true
	
	# Apply very slow continuous rotation only if not manually controlled
	if auto_rotate and not is_rotating:
		camera_rotation_y += 0.0005  # Reduced rotation speed

# Helper class to store mesh finding results (pass by reference)
class MeshFinder:
	var min_distance: float = INF
	var closest_mesh: MeshInstance3D = null

# Helper function to recursively find closest mesh to ray
func _find_closest_mesh_to_ray(node: Node, ray_origin: Vector3, ray_direction: Vector3, finder: MeshFinder) -> void:
	if node is MeshInstance3D:
		# Calculate distance from ray to mesh center (simplified approach)
		var to_mesh = node.global_position - ray_origin
		var projection = to_mesh.project(ray_direction)
		var distance = (to_mesh - projection).length()
		
		# Check if this is the closest mesh so far
		if distance < finder.min_distance:
			finder.min_distance = distance
			finder.closest_mesh = node
			print("DEBUG: Potential mesh hit: " + node.name + " at distance: " + str(distance))
	
	# Check all children recursively
	for child in node.get_children():
		_find_closest_mesh_to_ray(child, ray_origin, ray_direction, finder)

# Debug ray visualization for raycasting
var debug_ray_mesh: MeshInstance3D = null
var debug_ray_visible: bool = false

# Setup debug ray visualization for easier debugging
func _setup_debug_ray() -> void:
	# Create ray mesh
	var immediate_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 0, 0, 1)  # Red
	material.emission_enabled = true
	material.emission = Color(1, 0, 0, 1)
	material.emission_energy = 2.0
	
	# Create mesh instance
	debug_ray_mesh = MeshInstance3D.new()
	debug_ray_mesh.mesh = immediate_mesh
	debug_ray_mesh.material_override = material
	add_child(debug_ray_mesh)
	
	# Set visibility based on debug mode
	debug_ray_visible = DEBUG_MODE
	debug_ray_mesh.visible = debug_ray_visible
	
	if DEBUG_MODE:
		print("DEBUG: Ray visualization enabled. Debug mode is ON.")

# Update debug ray when click occurs (temporary visualization)
func _draw_debug_ray(from: Vector3, to: Vector3) -> void:
	if debug_ray_mesh and debug_ray_visible:
		var immediate_mesh = debug_ray_mesh.mesh as ImmediateMesh
		immediate_mesh.clear_surfaces()
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES)
		immediate_mesh.surface_add_vertex(from)
		immediate_mesh.surface_add_vertex(to)
		immediate_mesh.surface_end()
		
		# Create a timer to hide the ray after 1 second
		var timer = Timer.new()
		add_child(timer)
		timer.wait_time = 1.0
		timer.one_shot = true
		timer.timeout.connect(func(): immediate_mesh.clear_surfaces())
		timer.start()

func _on_directional_light_3d_script_changed():
	pass # Replace with function body.


func _on_visibility_changed():
	pass # Replace with function body.


func _on_child_entered_tree(_node):
	pass # Replace with function body.


func _on_child_exiting_tree(_node):
	pass # Replace with function body.


func _on_tree_exiting():
	pass # Replace with function body.


func _on_script_changed():
	pass # Replace with function body.
