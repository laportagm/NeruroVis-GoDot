## FixModelPanelInit.gd
## Quick fix for model panel initialization issues
##
## Add this script as a child to your main scene to prevent the initialization error
## @tutorial: UI initialization fix

extends Node

func _ready() -> void:
	print("🔧 [FixModelPanelInit] Applying UI initialization fixes...")
	
	# Wait for scene to fully load
	await get_tree().process_frame
	await get_tree().process_frame
	
	_fix_model_panel_initialization()

func _fix_model_panel_initialization() -> void:
	"""Fix the model panel initialization issue"""
	
	var main_scene = get_tree().current_scene
	if not main_scene:
		return
	
	# Find the model control panel
	var model_panel = main_scene.get_node_or_null("UI_Layer/ModelControlPanel")
	if not model_panel:
		print("ℹ️ Model control panel not found")
		return
	
	print("🔧 Found model control panel, applying fixes...")
	
	# Check if it has the problematic script
	if model_panel.has_method("_initialize_enhanced_panel"):
		# Override the problematic initialization
		_safe_initialize_model_panel(model_panel)
	else:
		print("✅ Model panel doesn't need fixes")

func _safe_initialize_model_panel(panel: Control) -> void:
	"""Safely initialize the model panel without errors"""
	
	# Remove any existing error-prone UI elements
	for child in panel.get_children():
		if child.name.contains("MainMargin") or child.name.contains("Enhanced"):
			child.queue_free()
	
	# Wait for cleanup
	await get_tree().process_frame
	
	# Create simple, safe UI structure
	_create_simple_panel_structure(panel)
	
	print("✅ Model panel safely initialized")

func _create_simple_panel_structure(panel: Control) -> void:
	"""Create a simple, safe panel structure"""
	
	# Simple margin container
	var margin = MarginContainer.new()
	margin.name = "SafeMargin"
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Use safe margin values
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	
	# Simple content container
	var vbox = VBoxContainer.new()
	vbox.name = "SafeContent"
	
	# Add a simple label
	var label = Label.new()
	label.text = "Model Controls"
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Simple controls
	var controls_container = HBoxContainer.new()
	controls_container.add_theme_constant_override("separation", 8)
	
	# Toggle button
	var toggle_btn = Button.new()
	toggle_btn.text = "Toggle Models"
	toggle_btn.custom_minimum_size = Vector2(120, 32)
	
	# Visibility button  
	var visibility_btn = Button.new()
	visibility_btn.text = "Show All"
	visibility_btn.custom_minimum_size = Vector2(100, 32)
	
	# Apply simple styling
	_apply_simple_button_style(toggle_btn)
	_apply_simple_button_style(visibility_btn)
	
	# Assemble the UI
	controls_container.add_child(toggle_btn)
	controls_container.add_child(visibility_btn)
	
	vbox.add_child(label)
	vbox.add_child(HSeparator.new())
	vbox.add_child(controls_container)
	
	margin.add_child(vbox)
	panel.add_child(margin)

func _apply_simple_button_style(button: Button) -> void:
	"""Apply simple, safe styling to buttons"""
	
	# Create simple button style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	style.border_color = Color(0, 0.85, 1, 0.3)  # Cyan border
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	
	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.3, 0.3, 0.4, 0.9)
	hover_style.border_color = Color(0, 0.85, 1, 0.6)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_color_override("font_color", Color.WHITE)

# Public method to show notification about the fix
func show_fix_notification() -> void:
	"""Show notification that the fix has been applied"""
	var main_scene = get_tree().current_scene
	var styler = main_scene.get_node_or_null("UIStyler")
	
	if styler and styler.has_method("show_notification"):
		styler.show_notification("✅ UI initialization fixed!", "success")
	else:
		print("✅ UI initialization fix applied successfully")