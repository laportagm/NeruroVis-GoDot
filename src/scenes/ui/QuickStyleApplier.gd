## QuickStyleApplier.gd
## One-click styling improvements for main.tscn
##
## Add this script to any node in your main scene and it will automatically
## apply modern styling to all UI components. Perfect for quick testing!
##
## @tutorial: Instant UI improvements
## @version: 1.0

@tool  # Enables running in editor
extends Node

# === QUICK CONFIGURATION ===
@export var auto_apply_on_ready: bool = true
@export var style_mode: String = "enhanced"  # "enhanced" or "minimal"
@export_group("Effects")
@export var enable_glassmorphism: bool = true
@export var enable_animations: bool = true
@export var enable_shadows: bool = true
@export_group("Actions")
@export var apply_styles_now: bool = false : set = _apply_styles_trigger

func _ready() -> void:
	if auto_apply_on_ready:
		call_deferred("apply_quick_styles")

func _apply_styles_trigger(value: bool) -> void:
	if value:
		apply_quick_styles()

func apply_quick_styles() -> void:
	"""Apply quick styling improvements to the main scene"""
	print("🎨 [QuickStyleApplier] Applying modern styles...")
	
	var main_scene = _find_main_scene()
	if not main_scene:
		print("❌ Could not find main scene")
		return
	
	# Apply styles to common components
	_style_object_label(main_scene)
	_style_info_panel(main_scene)
	_style_model_control_panel(main_scene)
	_add_modern_ui_elements(main_scene)
	
	print("✅ Modern styling applied successfully!")

func _find_main_scene() -> Node:
	"""Find the main scene node"""
	var current = self
	while current.get_parent():
		current = current.get_parent()
	return current

func _style_object_label(main_scene: Node) -> void:
	"""Style the object name label with modern appearance"""
	var label = main_scene.get_node_or_null("UI_Layer/ObjectNameLabel")
	if not label:
		return
	
	print("🏷️ Styling object label...")
	
	# Create glassmorphism container
	var container = PanelContainer.new()
	container.name = "ModernLabelContainer"
	container.custom_minimum_size = Vector2(400, 60)
	container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	container.position = Vector2(0, 20)
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Apply modern style
	var style = _create_modern_panel_style()
	style.set_corner_radius_all(30)  # More rounded for label
	container.add_theme_stylebox_override("panel", style)
	
	# Reparent label
	var ui_layer = label.get_parent()
	ui_layer.remove_child(label)
	container.add_child(label)
	ui_layer.add_child(container)
	
	# Style the label text
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", _get_theme_color("text_primary"))
	
	# Add text shadow
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)

func _style_info_panel(main_scene: Node) -> void:
	"""Style the structure info panel"""
	var panel = main_scene.get_node_or_null("UI_Layer/StructureInfoPanel")
	if not panel:
		return
	
	print("📋 Styling info panel...")
	
	# Apply modern style
	var style = _create_modern_panel_style()
	panel.add_theme_stylebox_override("panel", style)
	
	# Add hover effect
	_add_hover_glow(panel)

func _style_model_control_panel(main_scene: Node) -> void:
	"""Style the model control panel"""
	var panel = main_scene.get_node_or_null("UI_Layer/ModelControlPanel")
	if not panel:
		return
	
	print("🎛️ Styling model control panel...")
	
	# Apply modern style
	var style = _create_modern_panel_style()
	panel.add_theme_stylebox_override("panel", style)
	
	# Add hover effect
	_add_hover_glow(panel)

func _add_modern_ui_elements(main_scene: Node) -> void:
	"""Add modern UI elements like FABs and notifications"""
	var ui_layer = main_scene.get_node_or_null("UI_Layer")
	if not ui_layer:
		return
	
	print("✨ Adding modern UI elements...")
	
	# Add floating action buttons
	_create_floating_buttons(ui_layer)
	
	# Add notification area
	_create_notification_area(ui_layer)

func _create_floating_buttons(ui_layer: CanvasLayer) -> void:
	"""Create floating action buttons"""
	# Check if already exists
	if ui_layer.get_node_or_null("FloatingButtons"):
		return
	
	var fab_container = VBoxContainer.new()
	fab_container.name = "FloatingButtons"
	fab_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	fab_container.position = Vector2(-80, -200)
	fab_container.add_theme_constant_override("separation", 12)
	
	# Create buttons
	var buttons = [
		{"text": "🎨", "tooltip": "Toggle Theme", "color": Color("#00D9FF")},
		{"text": "📱", "tooltip": "Screenshot", "color": Color("#06FFA5")},
		{"text": "⚙️", "tooltip": "Settings", "color": Color("#7209B7")}
	]
	
	for button_data in buttons:
		var fab = _create_fab(button_data)
		fab_container.add_child(fab)
	
	ui_layer.add_child(fab_container)
	
	# Animate entrance if animations enabled
	if enable_animations:
		_animate_fab_entrance(fab_container)

func _create_fab(data: Dictionary) -> Button:
	"""Create a single floating action button"""
	var button = Button.new()
	button.text = data.text
	button.tooltip_text = data.tooltip
	button.custom_minimum_size = Vector2(50, 50)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Create circular style
	var style = StyleBoxFlat.new()
	style.bg_color = data.color
	style.set_corner_radius_all(25)
	
	if enable_shadows:
		style.shadow_size = 6
		style.shadow_color = Color(0, 0, 0, 0.3)
		style.shadow_offset = Vector2(0, 3)
	
	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = data.color.lightened(0.2)
	if enable_shadows:
		hover_style.shadow_size = 8
		hover_style.shadow_offset = Vector2(0, 4)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_font_size_override("font_size", 20)
	
	return button

func _create_notification_area(ui_layer: CanvasLayer) -> void:
	"""Create notification display area"""
	# Check if already exists
	if ui_layer.get_node_or_null("NotificationArea"):
		return
	
	var notif_area = VBoxContainer.new()
	notif_area.name = "NotificationArea"
	notif_area.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	notif_area.position = Vector2(0, 100)
	notif_area.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_area.add_theme_constant_override("separation", 8)
	
	ui_layer.add_child(notif_area)

func _create_modern_panel_style() -> StyleBoxFlat:
	"""Create a modern panel style based on theme mode"""
	var style = StyleBoxFlat.new()
	
	# Background and border based on theme
	if style_mode == "enhanced":
		style.bg_color = Color(15.0/255, 15.0/255, 23.0/255, 0.85) if enable_glassmorphism else Color(0.1, 0.1, 0.15, 0.9)
		style.border_color = Color(0, 217.0/255, 1, 0.2)
	else:  # minimal
		style.bg_color = Color(1, 1, 1, 0.06) if enable_glassmorphism else Color(0.95, 0.95, 0.95, 0.9)
		style.border_color = Color(1, 1, 1, 0.1)
	
	# Border and corners
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	
	# Shadow effects
	if enable_shadows:
		style.shadow_size = 8
		style.shadow_color = Color(0, 0, 0, 0.2)
		style.shadow_offset = Vector2(0, 4)
	
	return style

func _get_theme_color(color_name: String) -> Color:
	"""Get theme color based on current style mode"""
	var colors = {
		"enhanced": {
			"text_primary": Color("#00D9FF"),
			"text_secondary": Color("#B0B0C0"),
			"accent": Color("#06FFA5")
		},
		"minimal": {
			"text_primary": Color("#FFFFFF"),
			"text_secondary": Color(1, 1, 1, 0.85),
			"accent": Color(1, 1, 1, 0.6)
		}
	}
	
	return colors[style_mode].get(color_name, Color.WHITE)

func _add_hover_glow(control: Control) -> void:
	"""Add hover glow effect to a control"""
	if not enable_animations:
		return
	
	# Store original style
	var original_style = control.get_theme_stylebox("panel")
	
	# Create glow style
	var glow_style = _create_modern_panel_style()
	if style_mode == "enhanced":
		glow_style.border_color = Color(0, 217.0/255, 1, 0.4)
		glow_style.shadow_size = 12
	else:
		glow_style.border_color = Color(1, 1, 1, 0.2)
		glow_style.shadow_size = 10
	
	# Connect hover signals if available
	if control.has_signal("mouse_entered"):
		control.mouse_entered.connect(func():
			control.add_theme_stylebox_override("panel", glow_style)
		)
		control.mouse_exited.connect(func():
			control.add_theme_stylebox_override("panel", original_style)
		)

func _animate_fab_entrance(container: Control) -> void:
	"""Animate floating action button entrance"""
	var children = container.get_children()
	for i in range(children.size()):
		var child = children[i]
		child.modulate = Color.TRANSPARENT
		child.scale = Vector2(0.3, 0.3)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(child, "modulate", Color.WHITE, 0.4).set_delay(i * 0.1)
		tween.tween_property(child, "scale", Vector2.ONE, 0.4).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK)

# === PUBLIC METHODS ===

func show_notification(message: String, type: String = "info") -> void:
	"""Show a notification (if notification area exists)"""
	var main_scene = _find_main_scene()
	var notif_area = main_scene.get_node_or_null("UI_Layer/NotificationArea")
	
	if not notif_area:
		print("ℹ️ Notification: " + message)
		return
	
	var notif = _create_notification(message, type)
	notif_area.add_child(notif)
	
	# Auto-remove after 3 seconds
	get_tree().create_timer(3.0).timeout.connect(func():
		if notif and is_instance_valid(notif):
			notif.queue_free()
	)

func _create_notification(message: String, type: String) -> Control:
	"""Create a notification panel"""
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 50)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Style based on type
	var style = StyleBoxFlat.new()
	match type:
		"success": style.bg_color = Color("#06FFA5")
		"error": style.bg_color = Color("#FF073A")
		"warning": style.bg_color = Color("#FFB800")
		_: style.bg_color = Color("#00D9FF")
	
	style.bg_color.a = 0.9
	style.set_corner_radius_all(8)
	panel.add_theme_stylebox_override("panel", style)
	
	# Add label
	var label = Label.new()
	label.text = message
	label.add_theme_color_override("font_color", Color.WHITE)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	panel.add_child(label)
	
	return panel

func toggle_theme() -> void:
	"""Toggle between enhanced and minimal themes"""
	style_mode = "minimal" if style_mode == "enhanced" else "enhanced"
	apply_quick_styles()
	show_notification("Theme changed to " + style_mode, "success")

func take_screenshot() -> void:
	"""Take a screenshot of the current view"""
	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://neurovis_screenshot_" + timestamp + ".png"
	image.save_png(filename)
	show_notification("Screenshot saved!", "success")