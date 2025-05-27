# Manages structure selection, highlighting, and raycast operations for the NeuroVis application
class_name BrainStructureSelectionManager
extends Node

# Constants
const RAY_LENGTH: float = 1000.0
const HOVER_FADE_SPEED: float = 2.0
const OUTLINE_THICKNESS: float = 0.02

# Configuration variables - will be initialized in _ready()
var highlight_color: Color = Color(0.2, 0.8, 1.0, 1.0)  # Default cyan
var hover_color: Color = Color(1.0, 0.7, 0.0, 0.6)     # Default orange
var success_color: Color = Color(0.0, 1.0, 0.6, 1.0)   # Default green
var emission_energy: float = 0.8
var outline_enabled: bool = true

# Selection tracking
var current_selected_mesh: MeshInstance3D = null
var current_hovered_mesh: MeshInstance3D = null
var original_materials: Dictionary = {}  # mesh_instance -> original_material
var hover_tween: Tween

# Signals
signal structure_selected(structure_name: String, mesh: MeshInstance3D)
signal structure_deselected
signal structure_hovered(structure_name: String, mesh: MeshInstance3D)
signal structure_unhovered

# Initialize tween for hover effects with proper cleanup
func _ready() -> void:
    # Initialize with proper cleanup tracking
    set_process_unhandled_input(true)
    
    # Initialize modern UI theme colors if available
    _initialize_modern_colors()

# Handles hover at a given screen position (for mouse movement)
func handle_hover_at_position(screen_position: Vector2) -> void:
    var hit_mesh = _cast_selection_ray(screen_position)
    
    # Handle hover state changes
    if hit_mesh != current_hovered_mesh:
        # Clear previous hover
        if current_hovered_mesh and current_hovered_mesh != current_selected_mesh:
            clear_hover_effect(current_hovered_mesh)
            structure_unhovered.emit()
        
        # Apply new hover
        current_hovered_mesh = hit_mesh
        if current_hovered_mesh and current_hovered_mesh != current_selected_mesh:
            apply_hover_effect(current_hovered_mesh)
            structure_hovered.emit(current_hovered_mesh.name, current_hovered_mesh)

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
        
        # Clear hover since we're now selected
        if current_hovered_mesh == hit_mesh:
            current_hovered_mesh = null
        
        # Emit signal with structure info
        structure_selected.emit(hit_mesh.name, hit_mesh)
    else:
        structure_deselected.emit()

# Clears the current selection and restores original materials
func clear_current_selection() -> void:
    if current_selected_mesh != null:
        restore_original_material(current_selected_mesh)
        current_selected_mesh = null

# Applies modern hover effect with smooth glow and pulse
func apply_hover_effect(mesh: MeshInstance3D) -> void:
    if not mesh or not mesh.mesh:
        return
    
    _store_original_materials(mesh)
    
    # Create modern hover material with glass effect
    var hover_material = StandardMaterial3D.new()
    hover_material.albedo_color = hover_color.lightened(0.3)
    hover_material.emission_enabled = true
    hover_material.emission = hover_color
    hover_material.emission_energy_multiplier = 0.5
    hover_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    hover_material.metallic = 0.2
    hover_material.roughness = 0.3
    hover_material.rim_enabled = true
    hover_material.rim_tint = 0.8
    hover_material.rim = 0.5
    
    var surface_count = mesh.mesh.get_surface_count()
    for surface_idx in range(surface_count):
        mesh.set_surface_override_material(surface_idx, hover_material)
    
    # Add smooth pulsing animation
    _animate_hover_pulse(mesh)

# Clears hover effect with smooth transition
func clear_hover_effect(mesh: MeshInstance3D) -> void:
    if not mesh or not original_materials.has(mesh):
        return
    
    # Clean up any running animations
    _cleanup_mesh_animations(mesh)
    
    # Restore original material
    restore_original_material(mesh)

# Highlights a mesh with modern selection effects
func highlight_mesh(mesh: MeshInstance3D) -> void:
    if not mesh or not mesh.mesh:
        return
    
    # Clean up any hover animations first
    _cleanup_mesh_animations(mesh)
    
    # Store original materials before modifying
    _store_original_materials(mesh)
    
    # Create modern selection material with glass effect
    var highlight_material = StandardMaterial3D.new()
    highlight_material.albedo_color = highlight_color.lightened(0.2)
    highlight_material.emission_enabled = true
    highlight_material.emission = highlight_color
    highlight_material.emission_energy_multiplier = emission_energy
    highlight_material.metallic = 0.3
    highlight_material.roughness = 0.2
    
    # Add premium rim lighting effect
    highlight_material.rim_enabled = true
    highlight_material.rim_tint = 0.8
    highlight_material.rim = 0.5
    
    # Enhanced transparency for glass effect
    highlight_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    highlight_material.albedo_color.a = 0.8
    
    # Apply highlight to all surfaces
    var surface_count = mesh.mesh.get_surface_count()
    for surface_idx in range(surface_count):
        mesh.set_surface_override_material(surface_idx, highlight_material)
    
    # Animate the selection with a pulse effect
    _animate_selection_pulse(mesh)

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
    var space_state = get_viewport().world_3d.direct_space_state
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


# Enhanced configuration methods
func configure_highlight_colors(selection_color: Color, hover_color_param: Color) -> void:
    highlight_color = selection_color
    hover_color = hover_color_param

func set_outline_enabled(enabled: bool) -> void:
    outline_enabled = enabled

func get_hovered_structure_name() -> String:
    if current_hovered_mesh:
        return current_hovered_mesh.name
    return ""

# Cleanup method to prevent memory leaks
func _exit_tree() -> void:
    # Clear all references
    current_selected_mesh = null
    current_hovered_mesh = null
    
    # Clean up materials dictionary
    for mesh in original_materials.keys():
        if is_instance_valid(mesh):
            restore_original_material(mesh)
    original_materials.clear()
    
    print("[SELECTION] SelectionManager cleaned up")

# Initialize modern UI colors
func _initialize_modern_colors() -> void:
    """Initialize colors from UIThemeManager if available"""
    # Use modern UI colors (these match UIThemeManager.COLORS)
    highlight_color = Color("#00D9FF")      # Primary cyan
    hover_color = Color("#FF006E")          # Secondary magenta  
    success_color = Color("#06FFA5")        # Success green
    print("[SELECTION] Modern UI colors applied")

# Modern animation functions
func _animate_hover_pulse(mesh: MeshInstance3D) -> void:
    """Add a subtle pulsing glow effect to hovered meshes"""
    if not mesh or not mesh.mesh:
        return
    
    # Create a tween for the pulsing effect
    var tween = mesh.create_tween()
    tween.set_loops()
    
    # Animate the scale with a subtle pulse
    var original_scale = mesh.scale
    var pulse_scale = original_scale * 1.02
    
    tween.tween_property(mesh, "scale", pulse_scale, 0.8)
    tween.tween_property(mesh, "scale", original_scale, 0.8)
    
    # Store tween reference for cleanup
    mesh.set_meta("hover_tween", tween)

func _animate_selection_pulse(mesh: MeshInstance3D) -> void:
    """Add a selection confirmation pulse with modern easing"""
    if not mesh or not mesh.mesh:
        return
    
    var tween = mesh.create_tween()
    tween.set_parallel(true)
    
    # Quick scale pulse for confirmation
    var original_scale = mesh.scale
    tween.tween_property(mesh, "scale", original_scale * 1.1, 0.1).set_ease(Tween.EASE_OUT)
    tween.tween_property(mesh, "scale", original_scale, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
    
    # Quick glow pulse
    var material = mesh.get_surface_override_material(0)
    if material and material.emission_enabled:
        var original_energy = material.emission_energy_multiplier
        # Fixed: Using lambda for cleaner callback handling
        tween.tween_method(func(energy): _set_material_emission(material, energy), original_energy, original_energy * 2.0, 0.1)
        tween.tween_method(func(energy): _set_material_emission(material, energy), original_energy * 2.0, original_energy, 0.3)

# Modern Godot 4 approach using lambda (see above)
# Legacy approach with corrected parameter order:
func _update_emission_energy(energy: float, material: Material) -> void:
    """Helper function to update emission energy during animation (legacy approach)"""
    if material and material.has_method("set"):
        material.emission_energy_multiplier = energy

# Clean helper function for material emission updates
func _set_material_emission(material: Material, energy: float) -> void:
    """Safe helper to set material emission energy"""
    if not material:
        return
    
    if material.has_method("set") and "emission_energy_multiplier" in material:
        material.emission_energy_multiplier = energy
    else:
        push_warning("Material does not support emission_energy_multiplier property")

func _cleanup_mesh_animations(mesh: MeshInstance3D) -> void:
    """Clean up any running animations on a mesh"""
    if not mesh:
        return
    
    # Kill any existing hover tween
    if mesh.has_meta("hover_tween"):
        var mesh_hover_tween = mesh.get_meta("hover_tween")
        if mesh_hover_tween and is_instance_valid(mesh_hover_tween):
            mesh_hover_tween.kill()
        mesh.remove_meta("hover_tween")
    
    # Reset scale to normal
    mesh.scale = Vector3.ONE

# Dispose of resources and references
func dispose() -> void:
    # Clear current selections
    clear_current_selection()
    if current_hovered_mesh:
        clear_hover_effect(current_hovered_mesh)
    
    # Disconnect any remaining signals
    if has_signal("structure_selected"):
        var connections = get_signal_connection_list("structure_selected")
        for connection in connections:
            if connection.signal.is_connected(connection.callable):
                connection.signal.disconnect(connection.callable)
    
    # Call _exit_tree cleanup
    _exit_tree()
