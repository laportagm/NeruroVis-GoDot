# Copy this function to replace the _input function in node_3d.gd

func _input(event: InputEvent) -> void:
	# Handle keyboard input for camera control
	if event is InputEventKey and event.pressed:
		var handled = true
		
		match event.keycode:
			# Camera rotation
			KEY_LEFT, KEY_A:  # Rotate camera left
				camera_rotation_y += CAMERA_ROTATION_SPEED * 4.0
				print("Camera rotating left")
			KEY_RIGHT, KEY_D:  # Rotate camera right
				camera_rotation_y -= CAMERA_ROTATION_SPEED * 4.0
				print("Camera rotating right")
			KEY_UP, KEY_W:  # Rotate camera up
				camera_rotation_x += CAMERA_ROTATION_SPEED * 4.0
				print("Camera rotating up")
			KEY_DOWN, KEY_S:  # Rotate camera down
				camera_rotation_x -= CAMERA_ROTATION_SPEED * 4.0
				print("Camera rotating down")
				
			# Camera zoom
			KEY_Q, KEY_MINUS:  # Zoom out
				camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
				print("Camera zooming out: ", camera_distance)
			KEY_E, KEY_PLUS, KEY_EQUAL:  # Zoom in
				camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
				print("Camera zooming in: ", camera_distance)
				
			# Reset camera
			KEY_R:  # Reset camera to default position
				camera_rotation_x = 0.3
				camera_rotation_y = 0.0
				camera_distance = 10.0
				print("Camera reset")
			
			# Toggle structure labels
			KEY_L:  # Toggle structure name labels
				if structure_labeler:
					structure_labeler.toggle_labels_visibility()
					print("Structure labels toggled - now visible: ", structure_labeler.labels_visible)
				
			_:  # If no match, mark as not handled
				handled = false
				
		# If we handled a key, update camera and mark as handled
		if handled:
			# Clamp vertical rotation
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			_update_camera_transform()
			get_viewport().set_input_as_handled()
			return
	
	# Handle mouse buttons (selection, rotation, zoom)
	if event is InputEventMouseButton:
		# Mouse wheel for zoom
		if event.button_index == MouseButton.WHEEL_UP:
			# Zoom in
			camera_distance = max(camera_distance - CAMERA_ZOOM_SPEED, CAMERA_MIN_DISTANCE)
			_update_camera_transform()
			print("Mouse wheel zoom in: ", camera_distance)
			get_viewport().set_input_as_handled()
			
		elif event.button_index == MouseButton.WHEEL_DOWN:
			# Zoom out
			camera_distance = min(camera_distance + CAMERA_ZOOM_SPEED, CAMERA_MAX_DISTANCE)
			_update_camera_transform()
			print("Mouse wheel zoom out: ", camera_distance)
			get_viewport().set_input_as_handled()
			
		# Handle rotation with middle mouse button or right mouse button
		elif event.button_index == MouseButton.MIDDLE:
			is_rotating = event.pressed
			last_mouse_position = event.position
			print("Middle button rotation: ", is_rotating)
			get_viewport().set_input_as_handled()
			
		elif event.button_index == MouseButton.RIGHT:
			is_rotating = event.pressed
			last_mouse_position = event.position
			print("Right button rotation: ", is_rotating)
			get_viewport().set_input_as_handled()
			
		# Handle left mouse click for selection
		elif event.button_index == MouseButton.LEFT and event.pressed:
			# Check if Alt is pressed for trackpad rotation alternative
			if Input.is_key_pressed(KEY_ALT):
				is_rotating = true
				last_mouse_position = event.position
				print("Alt+Left button rotation active")
				get_viewport().set_input_as_handled()
			else:
				# Normal selection
				_handle_selection(event.position)
				get_viewport().set_input_as_handled()
				
		# Handle left mouse button release when using Alt+Left for rotation
		elif event.button_index == MouseButton.LEFT and not event.pressed and Input.is_key_pressed(KEY_ALT):
			is_rotating = false
			print("Alt+Left button rotation ended")
			get_viewport().set_input_as_handled()
	
	# Handle mouse motion for camera rotation
	elif event is InputEventMouseMotion:
		# Print button mask for debugging when a button is pressed
		if event.button_mask != 0:
			print("Motion with button mask: ", event.button_mask)
			
		# Handle trackpad and mouse rotation with any of these methods:
		# 1. Right button (mask value 2)
		# 2. Middle button (mask value 4)
		# 3. Alt+Left button (mask value 1 + Alt key)
		
		# Check button masks directly by value for clarity
		if event.button_mask & 0x2:  # Right button (2)
			is_rotating = true
		elif event.button_mask & 0x4:  # Middle button (4)
			is_rotating = true
		elif (event.button_mask & 0x1) and Input.is_key_pressed(KEY_ALT):  # Left button (1) + Alt
			is_rotating = true
			
		# Apply rotation if active
		if is_rotating:
			var motion = event.position - last_mouse_position
			camera_rotation_y -= motion.x * CAMERA_ROTATION_SPEED
			camera_rotation_x -= motion.y * CAMERA_ROTATION_SPEED
			
			# Limit vertical rotation to avoid flipping
			camera_rotation_x = clamp(camera_rotation_x, -1.2, 1.2)
			
			_update_camera_transform()
			get_viewport().set_input_as_handled()
		
		# Always update last mouse position
		last_mouse_position = event.position