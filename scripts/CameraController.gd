# Manages camera movement, input handling, and orbital controls for the NeuroVis application
class_name CameraController
extends Node

# Constants for camera behavior
const CAMERA_ROTATION_SPEED: float = 0.01
const CAMERA_ZOOM_SPEED: float = 0.5
const CAMERA_MIN_DISTANCE: float = 2.0
const CAMERA_MAX_DISTANCE: float = 25.0

# Camera control variables
var camera_distance: float = 10.0
var camera_rotation_x: float = 0.3  # Initial vertical angle
var camera_rotation_y: float = 0.0  # Initial horizontal angle
var is_rotating: bool = false
var last_mouse_position: Vector2 = Vector2.ZERO

# Animation variables
var target_rotation_x: float = 0.3
var target_rotation_y: float = 0.0
var animation_progress: float = 0.0
var animation_duration: float = 2.0  # Seconds
var animation_active: bool = false
var animation_timer: Timer = null

# Node references
var controlled_camera: Camera3D = null
var look_at_target: Node3D = null

# Configuration
var rotation_speed: float = CAMERA_ROTATION_SPEED
var zoom_speed: float = CAMERA_ZOOM_SPEED
var min_distance: float = CAMERA_MIN_DISTANCE
var max_distance: float = CAMERA_MAX_DISTANCE

# Signals
signal camera_animation_finished
signal camera_reset_completed

func _ready() -> void:
	# Setup animation timer
	animation_timer = Timer.new()
	add_child(animation_timer)
	animation_timer.wait_time = 0.02  # 50fps animation
	animation_timer.timeout.connect(_animate_camera_step)
	print("CameraController initialized")

# Initialize the camera controller with required references
func initialize(camera: Camera3D, target: Node3D = null) -> void:
	controlled_camera = camera
	look_at_target = target
	
	if not controlled_camera:
		print("Error: CameraController requires a valid Camera3D reference")
		return
	
	# Set initial camera position
	_update_camera_transform()
	print("CameraController initialized with camera: " + controlled_camera.name)

# Handle camera input events
func handle_camera_input(event: InputEvent) -> bool:
	var handled = false
	
	# Handle keyboard input for camera control
	if event is InputEventKey and event.pressed:
		match event.keycode:
			# Camera rotation
			KEY_LEFT, KEY_A:  # Rotate camera left
				camera_rotation_y += rotation_speed * 4.0
				handled = true
			KEY_RIGHT, KEY_D:  # Rotate camera right
				camera_rotation_y -= rotation_speed * 4.0
				handled = true
			KEY_UP, KEY_W:  # Rotate camera up
				camera_rotation_x += rotation_speed * 4.0
				handled = true
			KEY_DOWN, KEY_S:  # Rotate camera down
				camera_rotation_x -= rotation_speed * 4.0
				handled = true
				
			# Camera zoom
			KEY_Q, KEY_MINUS:  # Zoom out
				camera_distance = min(camera_distance + zoom_speed, max_distance)
				handled = true
			KEY_E, KEY_PLUS, KEY_EQUAL:  # Zoom in
				camera_distance = max(camera_distance - zoom_speed, min_distance)
				handled = true
				
			# Reset camera
			KEY_R:  # Reset camera to default position
				reset_camera_position()
				handled = true
		
		# If we handled a key, update camera
		if handled:
			# Clamp vertical rotation
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			_update_camera_transform()
	
	# Handle mouse buttons
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in
			camera_distance = max(camera_distance - zoom_speed, min_distance)
			_update_camera_transform()
			handled = true
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out
			camera_distance = min(camera_distance + zoom_speed, max_distance)
			_update_camera_transform()
			handled = true
			
		# Handle middle mouse button for camera rotation
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				start_mouse_rotation(event.position)
			else:
				stop_mouse_rotation()
			handled = true
	
	# Handle mouse motion for camera rotation
	elif event is InputEventMouseMotion and is_rotating:
		var motion = event.position - last_mouse_position
		camera_rotation_y -= motion.x * rotation_speed
		camera_rotation_x -= motion.y * rotation_speed
		
		# Limit vertical rotation to avoid flipping
		camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
		
		_update_camera_transform()
		last_mouse_position = event.position
		handled = true
	
	return handled

# Start mouse rotation mode
func start_mouse_rotation(position: Vector2) -> void:
	is_rotating = true
	last_mouse_position = position
	# Stop any active animation when user starts manual control
	if animation_active:
		stop_camera_animation()

# Stop mouse rotation mode
func stop_mouse_rotation() -> void:
	is_rotating = false

# Update camera transform based on orbital parameters
func _update_camera_transform() -> void:
	if not controlled_camera:
		return
	
	# Calculate new camera position using spherical coordinates
	var x = camera_distance * sin(camera_rotation_x) * sin(camera_rotation_y)
	var y = camera_distance * cos(camera_rotation_x)
	var z = camera_distance * sin(camera_rotation_x) * cos(camera_rotation_y)
	
	# Set camera position - use global position for absolute positioning
	controlled_camera.global_position = Vector3(x, y, z)
	
	# Look at target (brain model center or origin)
	var target_position = Vector3.ZERO
	if look_at_target:
		target_position = look_at_target.global_position
	
	controlled_camera.look_at(target_position)

# Reset camera to default position
func reset_camera_position() -> void:
	camera_rotation_x = 0.3
	camera_rotation_y = 0.0
	camera_distance = 10.0
	_update_camera_transform()
	camera_reset_completed.emit()
	print("Camera reset to default position")

# Animate camera to a specific view
func animate_to_view(target_x: float, target_y: float, target_distance: float = -1.0, duration: float = 2.0) -> void:
	if animation_active:
		stop_camera_animation()
	
	target_rotation_x = target_x
	target_rotation_y = target_y
	if target_distance > 0:
		# Animate distance too if specified
		pass
	
	animation_duration = duration
	animation_progress = 0.0
	animation_active = true
	
	# Start animation timer
	animation_timer.start()
	print("Camera animation started")

# Animate to default view with smooth transition
func animate_to_default_view() -> void:
	animate_to_view(0.3, 0.0, 10.0, 2.0)

# Stop any active camera animation
func stop_camera_animation() -> void:
	if animation_timer:
		animation_timer.stop()
	animation_active = false

# Animation step function called by timer
func _animate_camera_step() -> void:
	# Cancel animation if user is manually rotating
	if is_rotating:
		stop_camera_animation()
		return
	
	# Progress the animation
	animation_progress += animation_timer.wait_time
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
		stop_camera_animation()
		camera_animation_finished.emit()
		print("Camera animation completed")

# Set up camera with initial reveal animation
func setup_initial_animation() -> void:
	# Start with a different orientation to create a "reveal" effect
	camera_rotation_x = 0.5  # Looking more from above
	camera_rotation_y = -0.8  # From a side angle
	_update_camera_transform()
	
	# Animate to default view
	animate_to_default_view()

# Configuration functions
func set_rotation_speed(speed: float) -> void:
	rotation_speed = speed

func set_zoom_speed(speed: float) -> void:
	zoom_speed = speed

func set_zoom_limits(min_dist: float, max_dist: float) -> void:
	min_distance = min_dist
	max_distance = max_dist
	# Clamp current distance to new limits
	camera_distance = clamp(camera_distance, min_distance, max_distance)

func set_camera_distance(distance: float) -> void:
	camera_distance = clamp(distance, min_distance, max_distance)
	_update_camera_transform()

# Getters for current camera state
func get_camera_distance() -> float:
	return camera_distance

func get_camera_rotation() -> Vector2:
	return Vector2(camera_rotation_x, camera_rotation_y)

func is_animation_active() -> bool:
	return animation_active

# Debug function to get current camera info
func get_camera_debug_info() -> Dictionary:
	return {
		"distance": camera_distance,
		"rotation_x": camera_rotation_x,
		"rotation_y": camera_rotation_y,
		"is_rotating": is_rotating,
		"animation_active": animation_active,
		"camera_position": controlled_camera.global_position if controlled_camera else Vector3.ZERO
	}