class_name BrainStructureInfoPanel
extends Control

# UI Elements
@onready var structure_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/StructureNameLabel
@onready var description_label: Label = $PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel
@onready var functions_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/FunctionsContainer/FunctionsList
@onready var close_button: Button = $PanelContainer/MarginContainer/VBoxContainer/CloseButton

# Signals
signal panel_closed

func _ready() -> void:
	# Connect the close button
	close_button.pressed.connect(_on_close_button_pressed)
	
	# Hide panel initially
	visible = false
	
	print("Structure info panel initialized.")
	
func display_structure_data(structure_data: Dictionary) -> void:
	# Check if the structure data is valid
	if structure_data.is_empty():
		print("Error: Empty structure data provided to info panel")
		visible = false
		return
		
	print("INFO PANEL: Received structure data to display")
		
	# Update UI elements with structure data
	if structure_data.has("displayName"):
		structure_name_label.text = structure_data.displayName
		print("INFO PANEL: Setting name label to: " + structure_data.displayName)
	else:
		structure_name_label.text = structure_data.get("id", "Unknown Structure")
		print("INFO PANEL: No display name found, using ID: " + structure_data.get("id", "Unknown Structure"))
		
	if structure_data.has("shortDescription"):
		description_label.text = structure_data.shortDescription
		print("INFO PANEL: Description set - " + str(structure_data.shortDescription.length()) + " characters")
	else:
		description_label.text = "No description available."
		print("INFO PANEL: No description available")
		
	# Clear previous functions
	print("INFO PANEL: Clearing " + str(functions_list.get_child_count()) + " previous function items")
	for child in functions_list.get_children():
		child.queue_free()
		
	# Add functions if available
	if structure_data.has("functions") and structure_data.functions.size() > 0:
		print("INFO PANEL: Adding " + str(structure_data.functions.size()) + " functions")
		for function_text in structure_data.functions:
			var function_label = Label.new()
			function_label.text = "• " + function_text
			function_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			function_label.add_theme_font_size_override("font_size", 14)
			functions_list.add_child(function_label)
	else:
		print("INFO PANEL: No functions to display")
		var no_functions_label = Label.new()
		no_functions_label.text = "No functions listed."
		no_functions_label.add_theme_font_size_override("font_size", 14)
		functions_list.add_child(no_functions_label)
		
	# Ensure the panel is visible
	if not visible:
		visible = true
		print("INFO PANEL: Setting panel to visible")
	
	# Force panel to resize and update
	size_flags_horizontal = SIZE_EXPAND_FILL
	size_flags_vertical = SIZE_EXPAND_FILL
	
	# Request layout update
	queue_redraw()
	
	print("INFO PANEL: Displaying info for structure: " + structure_name_label.text)
	
func _on_close_button_pressed() -> void:
	visible = false
	emit_signal("panel_closed")
	print("Structure info panel closed.")