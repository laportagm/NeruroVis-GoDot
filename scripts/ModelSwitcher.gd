class_name ModelSwitcher
extends Node

# Signal when model visibility changes
signal model_visibility_changed(model_name: String, is_visible: bool)

# Dictionary to track loaded models and their visibility
var models = {}

func _ready() -> void:
	print("ModelSwitcher initialized")

# Register a model with the switcher
func register_model(model_node: Node3D, friendly_name: String) -> void:
	if model_node == null:
		printerr("ModelSwitcher Error: Attempted to register null model")
		return
		
	# Store model with friendly name and current visibility
	models[friendly_name] = {
		"node": model_node,
		"visible": model_node.visible
	}
	
	print("ModelSwitcher: Registered model '" + friendly_name + "'")

# Get list of all registered model names
func get_model_names() -> Array:
	return models.keys()

# Check if a model is visible
func is_model_visible(model_name: String) -> bool:
	if not models.has(model_name):
		printerr("ModelSwitcher Warning: Unknown model name '" + model_name + "'")
		return false
		
	return models[model_name].visible

# Toggle a specific model's visibility
func toggle_model_visibility(model_name: String) -> void:
	if not models.has(model_name):
		printerr("ModelSwitcher Warning: Cannot toggle unknown model '" + model_name + "'")
		return
		
	var model_info = models[model_name]
	var new_visibility = not model_info.visible
	
	# Update visibility
	model_info.node.visible = new_visibility
	model_info.visible = new_visibility
	
	print("ModelSwitcher: Set '" + model_name + "' visibility to " + str(new_visibility))
	
	# Emit signal
	emit_signal("model_visibility_changed", model_name, new_visibility)

# Set specific model visibility
func set_model_visibility(model_name: String, is_visible: bool) -> void:
	if not models.has(model_name):
		printerr("ModelSwitcher Warning: Cannot set visibility for unknown model '" + model_name + "'")
		return
		
	var model_info = models[model_name]
	
	# Update visibility
	model_info.node.visible = is_visible
	model_info.visible = is_visible
	
	print("ModelSwitcher: Set '" + model_name + "' visibility to " + str(is_visible))
	
	# Emit signal
	emit_signal("model_visibility_changed", model_name, is_visible)

# Show only one model, hide all others
func show_only_model(model_name: String) -> void:
	if not models.has(model_name):
		printerr("ModelSwitcher Warning: Cannot show unknown model '" + model_name + "'")
		return
		
	# Hide all models first
	for model_key in models.keys():
		var model_info = models[model_key]
		model_info.node.visible = (model_key == model_name)
		model_info.visible = (model_key == model_name)
		
		# Emit signal for each changed model
		emit_signal("model_visibility_changed", model_key, model_info.visible)
		
	print("ModelSwitcher: Now showing only '" + model_name + "'")
