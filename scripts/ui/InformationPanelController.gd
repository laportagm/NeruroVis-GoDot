class_name InformationPanelController
extends PanelContainer

# Node references
@onready var structure_name_label: Label = $MarginContainer/VBoxContainer/TitleBar/StructureName
@onready var close_button: Button = $MarginContainer/VBoxContainer/TitleBar/CloseButton
@onready var description_text: RichTextLabel = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DescriptionSection/DescriptionText
@onready var functions_list: VBoxContainer = $MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/FunctionsSection/FunctionsList

# Animation and enhancement components
var tween: Tween
var current_structure_id: String = ""
var is_animating: bool = false

# Enhanced styling options
var title_color: Color = Color(0.2, 0.8, 1.0, 1.0)  # Cyan for titles
var description_color: Color = Color(0.9, 0.9, 0.9, 1.0)  # Light gray for text
var function_color: Color = Color(0.8, 1.0, 0.8, 1.0)  # Light green for functions

# Signal emitted when the panel is closed
signal panel_closed
signal structure_info_requested(structure_id: String)

func _ready() -> void:
	# Tween will be created as needed in Godot 4.x
	
	# Validate UI nodes exist before connecting signals
	if not _validate_ui_nodes():
		print("[INFO_PANEL] UI nodes not found - using compatibility mode")
		return
	
	# Connect close button signal - check if it's already connected first
	if close_button:
		var signal_connections = close_button.get_signal_connection_list("pressed")
		var already_connected = false
		
		for connection in signal_connections:
			if connection.callable.get_object() == self and connection.callable.get_method() == "_on_close_button_pressed":
				already_connected = true
				break
		
		if not already_connected:
			close_button.pressed.connect(_on_close_button_pressed)
	
	# Setup enhanced styling
	_setup_enhanced_styling()
	
	# Initialize with empty data
	clear_data()
	
	print("Enhanced StructureInfoPanel initialized!")

func _validate_ui_nodes() -> bool:
	"""Validate that required UI nodes exist"""
	var nodes_valid = true
	
	if structure_name_label == null:
		print("[INFO_PANEL] Warning: structure_name_label node not found")
		nodes_valid = false
	
	if close_button == null:
		print("[INFO_PANEL] Warning: close_button node not found")
		nodes_valid = false
	
	if description_text == null:
		print("[INFO_PANEL] Warning: description_text node not found")
		nodes_valid = false
	
	if functions_list == null:
		print("[INFO_PANEL] Warning: functions_list node not found")
		nodes_valid = false
	
	return nodes_valid

# Display data for a brain structure with enhanced animations and styling
func display_structure_data(structure_data: Dictionary) -> void:
	# Check if structure data is valid
	if structure_data.is_empty():
		print("Warning: Attempted to display empty structure data")
		clear_data()
		return
	
	# Prevent multiple animations from overlapping
	if is_animating:
		return
	
	current_structure_id = structure_data.get("id", "unknown")
	print("INFO PANEL: Displaying enhanced structure data for " + current_structure_id)
	
	# Start entrance animation if not visible
	if not visible:
		_animate_panel_entrance()
	
	# Update content with animations
	_update_content_animated(structure_data)

# Animate panel entrance
func _animate_panel_entrance() -> void:
	if is_animating:
		return
	
	is_animating = true
	
	# Make sure parent CanvasLayer is visible
	var parent_layer = get_parent()
	if parent_layer is CanvasLayer and not parent_layer.visible:
		parent_layer.visible = true
	
	# Start with panel invisible and scaled down
	modulate.a = 0.0
	scale = Vector2(0.8, 0.8)
	visible = true
	
	# Animate entrance
	var entrance_tween = create_tween()
	entrance_tween.set_parallel(true)
	entrance_tween.tween_property(self, "modulate:a", 1.0, 0.3)
	entrance_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	entrance_tween.tween_callback(func(): is_animating = false)

# Update content with smooth animations
func _update_content_animated(structure_data: Dictionary) -> void:
	# Fade out current content
	if description_text:
		var content_tween = create_tween()
		content_tween.tween_property(description_text, "modulate:a", 0.0, 0.15)
		content_tween.tween_callback(_update_content_immediate.bind(structure_data))
		content_tween.tween_property(description_text, "modulate:a", 1.0, 0.15)

# Immediate content update (called during animation)
func _update_content_immediate(structure_data: Dictionary) -> void:
	# Update structure name with enhanced styling
	if structure_name_label:
		if structure_data.has("displayName"):
			structure_name_label.text = structure_data.displayName
			structure_name_label.modulate = title_color
		else:
			structure_name_label.text = "Unknown Structure"
	
	# Update description with rich text formatting
	if description_text:
		if structure_data.has("shortDescription"):
			var formatted_description = _format_description_text(structure_data.shortDescription)
			description_text.text = formatted_description
		else:
			description_text.text = "[color=#FFAAAA]No description available.[/color]"
	
	# Update functions list
	_populate_enhanced_functions_list(structure_data.get("functions", []))


# Enhanced functions list with better styling and animations
func _populate_enhanced_functions_list(functions_array: Array) -> void:
	print("INFO PANEL: Populating " + str(functions_array.size()) + " enhanced functions")
	
	if not functions_list:
		print("[INFO_PANEL] functions_list is null, cannot populate")
		return
	
	# Clear existing items first
	for child in functions_list.get_children():
		functions_list.remove_child(child)
		child.queue_free()
	
	# If no functions, add a styled placeholder
	if functions_array.is_empty():
		var label = RichTextLabel.new()
		label.text = "[color=#FFAAAA][i]No functions information available.[/i][/color]"
		label.fit_content = true
		label.scroll_active = false
		functions_list.add_child(label)
		return
	
	# Add each function with enhanced styling
	for i in range(functions_array.size()):
		var function_text = functions_array[i]
		var function_container = _create_enhanced_function_item(function_text, i)
		functions_list.add_child(function_container)

# Create an enhanced function list item with better styling
func _create_enhanced_function_item(function_text: String, index: int) -> Control:
	var container = HBoxContainer.new()
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Create styled bullet with color based on index
	var bullet_label = RichTextLabel.new()
	var bullet_color = Color.from_hsv(float(index) * 0.15, 0.7, 1.0)  # Varied colors
	bullet_label.text = "[color=#%s]▸[/color]" % bullet_color.to_html()
	bullet_label.fit_content = true
	bullet_label.scroll_active = false
	bullet_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	
	# Create styled function text
	var function_label = RichTextLabel.new()
	function_label.text = "[color=#%s]%s[/color]" % [function_color.to_html(), function_text]
	function_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	function_label.fit_content = true
	function_label.scroll_active = false
	
	container.add_child(bullet_label)
	container.add_child(function_label)
	
	return container

# Format description text with enhanced rich text styling
func _format_description_text(description: String) -> String:
	# Add basic rich text formatting to make description more readable
	var formatted = "[color=#%s]%s[/color]" % [description_color.to_html(), description]
	
	# Highlight key anatomical terms
	var anatomical_terms = [
		"brain", "cortex", "neurons", "synapses", "cerebral", "temporal", 
		"frontal", "parietal", "occipital", "hippocampus", "amygdala",
		"thalamus", "cerebellum", "brainstem", "spinal cord"
	]
	
	for term in anatomical_terms:
		# Case-insensitive replacement with highlighting
		var regex = RegEx.new()
		regex.compile("(?i)\\b" + term + "\\b")
		formatted = regex.sub(formatted, "[color=#FFD700][b]$0[/b][/color]", true)
	
	return formatted

# Setup enhanced styling for the panel
func _setup_enhanced_styling() -> void:
	# Setup panel styling
	if has_theme_stylebox_override("panel"):
		var panel_style = get_theme_stylebox("panel").duplicate()
		panel_style.bg_color = Color(0.1, 0.1, 0.15, 0.95)  # Semi-transparent dark blue
		add_theme_stylebox_override("panel", panel_style)

# Enhanced close with exit animation
func _on_close_button_pressed() -> void:
	print("INFO PANEL: Close button pressed with animation")
	_animate_panel_exit()

# Animate panel exit
func _animate_panel_exit() -> void:
	if is_animating:
		return
	
	is_animating = true
	
	var exit_tween = create_tween()
	exit_tween.set_parallel(true)
	exit_tween.tween_property(self, "modulate:a", 0.0, 0.2)
	exit_tween.tween_property(self, "scale", Vector2(0.8, 0.8), 0.2)
	exit_tween.tween_callback(func(): 
		visible = false
		scale = Vector2(1.0, 1.0)  # Reset scale
		modulate.a = 1.0  # Reset alpha
		is_animating = false
		emit_signal("panel_closed")
	)

# Clear data with enhanced reset and proper cleanup
func clear_data() -> void:
	current_structure_id = ""
	
	if structure_name_label:
		structure_name_label.text = "No Structure Selected"
		structure_name_label.modulate = Color.WHITE
	
	if description_text:
		description_text.text = "[color=#AAAAAA][i]Select a structure to view information.[/i][/color]"
	
	# Clear functions list with proper cleanup
	_clear_functions_list_safe()
	
	# Hide panel without animation
	visible = false

# Safe function list clearing with proper memory management
func _clear_functions_list_safe() -> void:
	if functions_list == null:
		print("[INFO_PANEL] functions_list is null, cannot clear")
		return
		
	for child in functions_list.get_children():
		functions_list.remove_child(child)
		child.queue_free()
	
	# Force garbage collection of freed nodes
	await get_tree().process_frame

# Cleanup method to prevent memory leaks
func _exit_tree() -> void:
	# Stop any running animations
	is_animating = false
	
	# Clear all references
	current_structure_id = ""
	
	# Clean up functions list
	_clear_functions_list_safe()
	
	print("[UI_PANEL] StructureInfoPanel cleaned up")

# Dispose of resources
func dispose() -> void:
	# Clear all data
	clear_data()
	
	# Disconnect signals to prevent memory leaks
	if close_button and close_button.has_signal("pressed"):
		var connections = close_button.get_signal_connection_list("pressed")
		for connection in connections:
			if connection.signal.is_connected(connection.callable):
				connection.signal.disconnect(connection.callable)
	
	_exit_tree()
