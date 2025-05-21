class_name ModelControlPanel
extends PanelContainer

signal model_selected(model_name: String)

# Node references
@onready var models_container = $MarginContainer/VBoxContainer/ModelsContainer

# UI Elements we'll create dynamically
var model_buttons = {}

func _ready() -> void:
	print("ModelControlPanel initialized")

# Set up UI based on available models
func setup_with_models(model_names: Array) -> void:
	print("Setting up model control panel with " + str(model_names.size()) + " models")
	
	# Clear existing buttons first
	for child in models_container.get_children():
		models_container.remove_child(child)
		child.queue_free()
	
	model_buttons.clear()
	
	# Create a button for each model
	for model_name in model_names:
		var button = CheckButton.new()
		button.text = model_name
		button.button_pressed = true # Start with all models visible
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Connect toggle signal
		button.toggled.connect(_on_model_button_toggled.bind(model_name))
		
		models_container.add_child(button)
		model_buttons[model_name] = button
		
		print("Added toggle for model: " + model_name)
	
	# Create "Show All" button
	var show_all_button = Button.new()
	show_all_button.text = "Show All Models"
	show_all_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	show_all_button.pressed.connect(_on_show_all_pressed)
	models_container.add_child(show_all_button)

# Update a specific model button state without triggering the signal
func update_button_state(model_name: String, is_checked: bool) -> void:
	if not model_buttons.has(model_name):
		return
		
	# Disconnect signal temporarily to avoid recursion
	var button = model_buttons[model_name]
	var connections = button.get_signal_connection_list("toggled")
	for connection in connections:
		button.toggled.disconnect(connection.callable)
	
	# Set button state
	button.button_pressed = is_checked
	
	# Reconnect signal
	button.toggled.connect(_on_model_button_toggled.bind(model_name))

# Signal handler when a model button is toggled
func _on_model_button_toggled(is_checked: bool, model_name: String) -> void:
	print("Model '" + model_name + "' toggled to: " + str(is_checked))
	emit_signal("model_selected", model_name)

# Signal handler for "Show All" button
func _on_show_all_pressed() -> void:
	print("Show all models pressed")
	
	# Set all buttons to checked
	for model_name in model_buttons.keys():
		update_button_state(model_name, true)
		emit_signal("model_selected", model_name)