## ModelManagementPanelFix.gd
## Fix for null reference errors in model management panel
##
## This fix adds proper null checks and initialization for the models_container
## and related UI elements to prevent crashes when clearing models.

# === FIXED FUNCTIONS ===

func _update_visibility_counter() -> void:
	## Update the visibility counter in footer with null check
	if visibility_counter and is_instance_valid(visibility_counter):
		visibility_counter.text = "%d/%d models visible" % [visible_models, total_models]
	else:
		push_warning("[ModelPanel] visibility_counter is null or invalid")

func _clear_models() -> void:
	## Clear all model cards safely with null checks
	if not models_container or not is_instance_valid(models_container):
		push_warning("[ModelPanel] models_container is null in _clear_models()")
		return
		
	# Safely iterate and remove children
	var children = models_container.get_children()
	for child in children:
		if is_instance_valid(child):
			models_container.remove_child(child)
			child.queue_free()
	
	# Clear the model cards dictionary/array if it exists
	if model_cards:
		model_cards.clear()

# Enhanced signal handlers
func _on_model_toggled(pressed: bool, model_name: String, status_label: Label) -> void:
	## Handle model visibility toggle with enhanced feedback and null checks
	if not status_label or not is_instance_valid(status_label):
		push_error("[ModelPanel] status_label is null for model: %s" % model_name)
		return
	
	print("[ENHANCED_MODEL_PANEL] Model '%s' toggled to: %s" % [model_name, str(pressed)])
	
	# Update the status label
	if pressed:
		status_label.text = "Visible"
		status_label.modulate = Color(0.0, 1.0, 0.5)  # Green
		visible_models += 1
	else:
		status_label.text = "Hidden"
		status_label.modulate = Color(1.0, 0.3, 0.3)  # Red
		visible_models -= 1
	
	# Clamp visible_models to valid range
	visible_models = clamp(visible_models, 0, total_models)
	
	# Update visibility counter
	_update_visibility_counter()
	
	# Emit signal if needed (check if signal exists first)
	if has_signal("model_visibility_changed"):
		emit_signal("model_visibility_changed", model_name, pressed)

# === INITIALIZATION HELPERS ===

func _ensure_components_initialized() -> void:
	## Ensure all required components are properly initialized
	
	# Check and initialize models_container
	if not models_container:
		models_container = get_node_or_null(NodePath("VBoxContainer/ScrollContainer/ModelsContainer"))
		if not models_container:
			# Try alternative paths
			models_container = get_node_or_null(NodePath("ScrollContainer/ModelsContainer"))
			if not models_container:
				models_container = get_node_or_null(NodePath("ModelsContainer"))
				
		if not models_container:
			push_error("[ModelPanel] Failed to find models_container - creating new one")
			# Create a new container as fallback
			models_container = VBoxContainer.new()
			models_container.name = "ModelsContainer"
			# Add to appropriate parent if possible
			var scroll_container = get_node_or_null(NodePath("ScrollContainer"))
			if scroll_container:
				scroll_container.add_child(models_container)
			else:
				add_child(models_container)
	
	# Check and initialize visibility_counter
	if not visibility_counter:
		visibility_counter = get_node_or_null(NodePath("FooterContainer/VisibilityCounter"))
		if not visibility_counter:
			# Try alternative paths
			visibility_counter = get_node_or_null(NodePath("Footer/VisibilityCounter"))
			if not visibility_counter:
				visibility_counter = get_node_or_null(NodePath("VisibilityCounter"))
				
		if not visibility_counter:
			push_warning("[ModelPanel] Failed to find visibility_counter - creating new one")
			# Create a new label as fallback
			visibility_counter = Label.new()
			visibility_counter.name = "VisibilityCounter"
			visibility_counter.text = "0/0 models visible"
			# Add to appropriate parent if possible
			var footer = get_node_or_null(NodePath("FooterContainer"))
			if footer:
				footer.add_child(visibility_counter)

	# Initialize model_cards array/dictionary if needed
	if not model_cards:
		model_cards = []  # or {} if it's a dictionary

# === READY FUNCTION OVERRIDE ===

func _ready() -> void:
	## Enhanced ready function with proper initialization
	
	# Ensure all components are initialized first
	_ensure_components_initialized()
	
	# Initialize counters
	visible_models = 0
	total_models = 0
	
	# Update UI
	_update_visibility_counter()
	
	# Connect any signals if needed
	_connect_signals()

func _connect_signals() -> void:
	## Connect signals safely
	
	# Example: Connect to any toggle buttons in existing model cards
	if models_container and is_instance_valid(models_container):
		for child in models_container.get_children():
			if child.has_node("ToggleButton"):
				var toggle_button = child.get_node("ToggleButton")
				if toggle_button and not toggle_button.is_connected("toggled", _on_model_toggled):
					var model_name = child.get("model_name", "Unknown")
					var status_label = child.get_node_or_null("StatusLabel")
					toggle_button.toggled.connect(_on_model_toggled.bind(model_name, status_label))

# === UTILITY FUNCTIONS ===

func refresh_models_display() -> void:
	## Refresh the entire models display safely
	_ensure_components_initialized()
	_clear_models()
	# Add logic to repopulate models here
	_update_visibility_counter()

func get_visible_model_count() -> int:
	## Get the current visible model count
	return visible_models

func get_total_model_count() -> int:
	## Get the total model count
	return total_models
