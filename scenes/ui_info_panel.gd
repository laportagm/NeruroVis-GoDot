class_name StructureInfoPanel
extends PanelContainer

# Node references
@onready var structure_name_label: Label = $MarginContainer/VBoxContainer/TitleBar/StructureName
@onready var close_button: Button = $MarginContainer/VBoxContainer/TitleBar/CloseButton
@onready var description_text: RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DescriptionSection/DescriptionText
@onready var functions_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/FunctionsSection/FunctionsList

# Signal emitted when the panel is closed
signal panel_closed

func _ready() -> void:
	# Connect close button signal - check if it's already connected first
	var signal_connections = close_button.get_signal_connection_list("pressed")
	var already_connected = false
	
	for connection in signal_connections:
		if connection.callable.get_object() == self and connection.callable.get_method() == "_on_close_button_pressed":
			already_connected = true
			break
	
	if not already_connected:
		close_button.pressed.connect(_on_close_button_pressed)
	
	# Initialize with empty data
	clear_data()
	
	print("StructureInfoPanel initialized!")

# Display data for a brain structure
func display_structure_data(structure_data: Dictionary) -> void:
	# Check if structure data is valid
	if structure_data.is_empty():
		print("Warning: Attempted to display empty structure data")
		clear_data()
		return
	
	print("INFO PANEL: Displaying structure data for " + structure_data.get("id", "unknown"))
		
	# Update structure name
	if structure_data.has("displayName"):
		structure_name_label.text = structure_data.displayName
		print("INFO PANEL: Set name to: " + structure_data.displayName)
	else:
		structure_name_label.text = "Unknown Structure"
	
	# Update description
	if structure_data.has("shortDescription"):
		description_text.text = structure_data.shortDescription
		print("INFO PANEL: Set description of " + str(structure_data.shortDescription.length()) + " characters")
	else:
		description_text.text = "No description available."
	
	# Update functions list
	_populate_functions_list(structure_data.get("functions", []))
	
	# Make panel visible and bring to front
	if not visible:
		print("INFO PANEL: Setting panel to visible")
		# Make sure parent CanvasLayer is visible too
		var parent_layer = get_parent()
		if parent_layer is CanvasLayer and not parent_layer.visible:
			print("INFO PANEL: Parent CanvasLayer was invisible! Setting to visible.")
			parent_layer.visible = true
			
		visible = true
		print("INFO PANEL: Panel visibility now: " + str(visible))
	
	# Force layout update and redraw
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	queue_redraw()
	
	# Delay a frame and check visibility again (to catch any issues)
	get_tree().create_timer(0.05).timeout.connect(func(): 
		if not visible:
			print("INFO PANEL: Panel still invisible after timeout! Forcing visible.")
			visible = true
	)

# Populate the functions list with the structure's functions
func _populate_functions_list(functions_array: Array) -> void:
	print("INFO PANEL: Populating " + str(functions_array.size()) + " functions")
	
	# Clear existing items first
	for child in functions_list.get_children():
		functions_list.remove_child(child)
		child.queue_free()
	
	# If no functions, add a placeholder text
	if functions_array.is_empty():
		var label = Label.new()
		label.text = "No functions information available."
		functions_list.add_child(label)
		return
	
	# Add each function as a bullet point
	for function_text in functions_array:
		var bullet_container = HBoxContainer.new()
		bullet_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var bullet = Label.new()
		bullet.text = "•"
		bullet.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		var function_label = Label.new()
		function_label.text = function_text
		function_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		function_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		
		bullet_container.add_child(bullet)
		bullet_container.add_child(function_label)
		
		functions_list.add_child(bullet_container)

# Clear all displayed data
func clear_data() -> void:
	structure_name_label.text = "No Structure Selected"
	description_text.text = "Select a structure to view information."
	
	# Clear functions list
	for child in functions_list.get_children():
		functions_list.remove_child(child)
		child.queue_free()
	
	# Hide panel
	visible = false

# Close button pressed handler
func _on_close_button_pressed() -> void:
	print("INFO PANEL: Close button pressed")
	visible = false
	emit_signal("panel_closed")
