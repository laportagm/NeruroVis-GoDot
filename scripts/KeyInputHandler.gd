# This is a replacement for the _input function in node_3d.gd
# Copy this code into the _input function to add the new structure labeling feature

func _input(event: InputEvent) -> void:
	# Handle keyboard input for camera control
	if event is InputEventKey and event.pressed:
		var handled = true
		
		match event.keycode:
			# Camera rotation
			KEY_LEFT, KEY_A:  # Rotate camera left
				camera_rotation_y += CAMERA_ROTATION_SPEED * 4.0
			KEY_RIGHT, KEY_D:  # Rotate camera right
				camera_rotation_y -= CAMERA_ROTATION_SPEED * 4.0
			KEY_UP, KEY_W:  # Rotate camera up
				camera_rotation_x += CAMERA_ROTATION_SPEED * 4.0
			KEY_DOWN, KEY_S:  # Rotate camera down
				camera_rotation_x -= CAMERA_ROTATION_SPEED * 4.0
				
			# Camera zoom
			KEY_Q, KEY_MINUS:  # Zoom out
				camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
			KEY_E, KEY_PLUS, KEY_EQUAL:  # Zoom in
				camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
				
			# Reset camera
			KEY_R:  # Reset camera to default position
				camera_rotation_x = 0.3
				camera_rotation_y = 0.0
				camera_distance = 10.0
				
			# Toggle structure labels
			KEY_L:  # Toggle structure name labels in 3D view
				if structure_labeler:
					structure_labeler.toggle_labels_visibility()
				
			_:  # If no match, mark as not handled
				handled = false
				
		# If we handled a key, update camera and mark as handled
		if handled:
			# Clamp vertical rotation
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			_update_camera_transform()
			get_viewport().set_input_as_handled()
			return
	
	# Handle mouse buttons (selection, rotation)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Zoom in
			camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
			_update_camera_transform()
			get_viewport().set_input_as_handled()
			
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Zoom out
			camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
			_update_camera_transform()
			get_viewport().set_input_as_handled()
			
		# Handle middle mouse button for camera rotation
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_rotating = event.pressed
			last_mouse_position = event.position
			get_viewport().set_input_as_handled()
			
		# Handle left mouse click for selection
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_selection(event.position)
			get_viewport().set_input_as_handled()
	
	# Handle mouse motion for camera rotation
	elif event is InputEventMouseMotion and is_rotating:
		var motion = event.position - last_mouse_position
		camera_rotation_y -= motion.x * CAMERA_ROTATION_SPEED
		camera_rotation_x -= motion.y * CAMERA_ROTATION_SPEED
		
		# Limit vertical rotation to avoid flipping
		camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
		
		_update_camera_transform()
		last_mouse_position = event.position
		get_viewport().set_input_as_handled()