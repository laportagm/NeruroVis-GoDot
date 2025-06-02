## EnhancedMainSceneStyling.gd
## Modern styling system for main.tscn components
##
## This script provides easy-to-apply styling improvements for the main scene
## using the existing UIThemeManager system. Add this to main.tscn as a child node.
##
## @tutorial: Modern UI styling for educational platform
## @version: 1.0

class_name EnhancedMainSceneStyling
extends Node

# === STYLING CONFIGURATION ===
@export var apply_on_ready: bool = true
@export var theme_mode: String = "enhanced"  # "enhanced" or "minimal"
@export var enable_animations: bool = true
@export var enable_glassmorphism: bool = true
@export var enable_shadows: bool = true

# === NODE REFERENCES ===
var main_scene: Node3D
var object_name_label: Label
var structure_info_panel: Control
var model_control_panel: Control
var ui_layer: CanvasLayer

# === STYLE CACHE ===
var styles_cache: Dictionary = {}

func _ready() -> void:
	if apply_on_ready:
		call_deferred("_apply_enhanced_styling")

func _apply_enhanced_styling() -> void:
	"""Apply modern styling to all main scene components"""
	print("[EnhancedStyling] Applying modern styling to main scene...")
	
	# Get references to main scene components
	_get_scene_references()
	
	# Apply styling to each component
	_style_object_label()
	_style_info_panel()
	_style_model_control_panel()
	_style_ui_layer()
	
	# Add dynamic effects
	if enable_animations:
		_add_entrance_animations()
	
	print("[EnhancedStyling] Enhanced styling applied successfully!")

func _get_scene_references() -> void:
	"""Get references to main scene components"""
	main_scene = get_parent()
	if not main_scene:
		return
	
	object_name_label = main_scene.get_node_or_null("UI_Layer/ObjectNameLabel")
	structure_info_panel = main_scene.get_node_or_null("UI_Layer/StructureInfoPanel")
	model_control_panel = main_scene.get_node_or_null("UI_Layer/ModelControlPanel")
	ui_layer = main_scene.get_node_or_null("UI_Layer")

func _style_object_label() -> void:
	"""Apply modern styling to the object name label"""
	if not object_name_label:
		return
	
	print("[EnhancedStyling] Styling object name label...")
	
	# Create modern container for the label
	var label_container = _create_glassmorphism_container(
		Vector2(400, 60), 
		"label_container"
	)
	
	# Position the container
	label_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	label_container.position = Vector2(0, 20)
	label_container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Reparent the label
	var original_parent = object_name_label.get_parent()
	original_parent.remove_child(object_name_label)
	label_container.add_child(object_name_label)
	original_parent.add_child(label_container)
	
	# Style the label text
	_apply_label_typography(object_name_label, "structure_name")
	object_name_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	object_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	object_name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func _style_info_panel() -> void:
	"""Apply modern styling to the structure info panel"""
	if not structure_info_panel:
		return
	
	print("[EnhancedStyling] Styling info panel...")
	
	# Apply glassmorphism background
	var panel_style = _create_glassmorphism_style()
	structure_info_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Add smooth corner radius
	if panel_style is StyleBoxFlat:
		panel_style.set_corner_radius_all(16)
	
	# Add entrance animation capability
	structure_info_panel.modulate.a = 0.0
	structure_info_panel.scale = Vector2(0.95, 0.95)

func _style_model_control_panel() -> void:
	"""Apply modern styling to the model control panel"""
	if not model_control_panel:
		return
	
	print("[EnhancedStyling] Styling model control panel...")
	
	# Apply modern background
	var panel_style = _create_glassmorphism_style()
	model_control_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Set rounded corners
	if panel_style is StyleBoxFlat:
		panel_style.set_corner_radius_all(16)
	
	# Add subtle hover effects
	_add_hover_effects(model_control_panel)

func _style_ui_layer() -> void:
	"""Apply global styling to the UI layer"""
	if not ui_layer:
		return
	
	print("[EnhancedStyling] Styling UI layer...")
	
	# Add floating action buttons
	_create_floating_action_buttons()
	
	# Add notification system
	_create_notification_system()

func _create_glassmorphism_container(size: Vector2, name_suffix: String) -> PanelContainer:
	"""Create a container with glassmorphism styling"""
	var container = PanelContainer.new()
	container.name = "GlassmorphismContainer_" + name_suffix
	container.custom_minimum_size = size
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Apply glassmorphism style
	var style = _create_glassmorphism_style()
	container.add_theme_stylebox_override("panel", style)
	
	return container

func _create_glassmorphism_style() -> StyleBoxFlat:
	"""Create a glassmorphism-styled StyleBox"""
	var style = StyleBoxFlat.new()
	
	# Get theme colors
	var colors = UIThemeManager.COLORS[theme_mode]
	
	# Background with transparency
	style.bg_color = colors.panel_bg if colors.has("panel_bg") else Color(0.08, 0.08, 0.12, 0.85)
	
	# Border
	var border_color = colors.border if colors.has("border") else Color(0, 217.0/255, 1, 0.15)
	style.border_color = border_color
	style.set_border_width_all(1)
	
	# Corner radius
	style.set_corner_radius_all(12)
	
	# Shadow effects
	if enable_shadows:
		style.shadow_color = Color(0, 0, 0, 0.3)
		style.shadow_size = 8
		style.shadow_offset = Vector2(0, 4)
	
	return style

func _apply_label_typography(label: Label, type_style: String) -> void:
	"""Apply typography styling to a label"""
	var typography = UIThemeManager.TYPOGRAPHY[theme_mode]
	var colors = UIThemeManager.COLORS[theme_mode]
	
	if typography.has(type_style):
		var style = typography[type_style]
		label.add_theme_font_size_override("font_size", style.get("size", 16))
	
	# Apply text color
	var text_color = colors.get("text_heading", Color.WHITE)
	label.add_theme_color_override("font_color", text_color)
	
	# Add text shadow
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	label.add_theme_constant_override("shadow_offset_x", 1)
	label.add_theme_constant_override("shadow_offset_y", 1)

func _add_hover_effects(control: Control) -> void:
	"""Add hover effects to a control"""
	if not control.has_signal("mouse_entered"):
		return
	
	control.mouse_entered.connect(_on_control_hover_enter.bind(control))
	control.mouse_exited.connect(_on_control_hover_exit.bind(control))

func _on_control_hover_enter(control: Control) -> void:
	"""Handle hover enter effect"""
	if not enable_animations:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "scale", Vector2(1.02, 1.02), 0.15)
	tween.tween_property(control, "modulate:a", 1.0, 0.15)

func _on_control_hover_exit(control: Control) -> void:
	"""Handle hover exit effect"""
	if not enable_animations:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "scale", Vector2.ONE, 0.15)
	tween.tween_property(control, "modulate:a", 0.9, 0.15)

func _create_floating_action_buttons() -> void:
	"""Create modern floating action buttons"""
	if not ui_layer:
		return
	
	var fab_container = VBoxContainer.new()
	fab_container.name = "FloatingActionButtons"
	fab_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	fab_container.position = Vector2(-80, -200)
	fab_container.add_theme_constant_override("separation", 16)
	
	# Create FAB buttons
	var buttons = [
		{"icon": "🎨", "tooltip": "Toggle Theme", "color": Color("#00D9FF"), "action": "toggle_theme"},
		{"icon": "👁", "tooltip": "Toggle Visibility", "color": Color("#06FFA5"), "action": "toggle_visibility"},
		{"icon": "📱", "tooltip": "Screenshot", "color": Color("#7209B7"), "action": "screenshot"},
		{"icon": "⚙️", "tooltip": "Settings", "color": Color("#FFB800"), "action": "settings"}
	]
	
	for button_data in buttons:
		var fab = _create_fab_button(button_data)
		fab_container.add_child(fab)
	
	ui_layer.add_child(fab_container)
	
	# Animate entrance
	if enable_animations:
		_animate_fab_entrance(fab_container)

func _create_fab_button(data: Dictionary) -> Button:
	"""Create a floating action button"""
	var button = Button.new()
	button.text = data.icon
	button.tooltip_text = data.tooltip
	button.custom_minimum_size = Vector2(56, 56)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Create circular style
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = data.color
	style_normal.set_corner_radius_all(28)
	
	if enable_shadows:
		style_normal.shadow_size = 8
		style_normal.shadow_color = Color(0, 0, 0, 0.3)
		style_normal.shadow_offset = Vector2(0, 4)
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = data.color.lightened(0.1)
	if enable_shadows:
		style_hover.shadow_size = 12
		style_hover.shadow_offset = Vector2(0, 6)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = data.color.darkened(0.1)
	if enable_shadows:
		style_pressed.shadow_size = 4
		style_pressed.shadow_offset = Vector2(0, 2)
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_font_size_override("font_size", 24)
	
	# Connect action
	button.pressed.connect(_on_fab_pressed.bind(data.action))
	
	return button

func _animate_fab_entrance(container: Control) -> void:
	"""Animate floating action buttons entrance"""
	var children = container.get_children()
	for i in range(children.size()):
		var child = children[i]
		child.modulate = Color.TRANSPARENT
		child.scale = Vector2(0.5, 0.5)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(child, "modulate", Color.WHITE, 0.3).set_delay(i * 0.1)
		tween.tween_property(child, "scale", Vector2.ONE, 0.3).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK)

func _create_notification_system() -> void:
	"""Create a modern notification system"""
	if not ui_layer:
		return
	
	var notif_container = VBoxContainer.new()
	notif_container.name = "NotificationSystem"
	notif_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	notif_container.position = Vector2(0, 100)
	notif_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_container.add_theme_constant_override("separation", 8)
	
	ui_layer.add_child(notif_container)

func _add_entrance_animations() -> void:
	"""Add entrance animations to all styled components"""
	# Animate info panel entrance
	if structure_info_panel:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(structure_info_panel, "modulate:a", 1.0, 0.4)
		tween.tween_property(structure_info_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK)
	
	# Animate model control panel
	if model_control_panel:
		var tween2 = create_tween()
		tween2.set_parallel(true)
		tween2.tween_property(model_control_panel, "modulate:a", 1.0, 0.4).set_delay(0.1)
		tween2.tween_property(model_control_panel, "scale", Vector2.ONE, 0.4).set_delay(0.1).set_trans(Tween.TRANS_BACK)

func _on_fab_pressed(action: String) -> void:
	"""Handle floating action button press"""
	match action:
		"toggle_theme":
			_toggle_theme()
		"toggle_visibility":
			_show_notification("Visibility toggled", "info")
		"screenshot":
			_take_screenshot()
		"settings":
			_show_notification("Settings panel", "info")

func _toggle_theme() -> void:
	"""Toggle between enhanced and minimal themes"""
	theme_mode = "minimal" if theme_mode == "enhanced" else "enhanced"
	_apply_enhanced_styling()
	_show_notification("Theme changed to " + theme_mode, "success")

func _take_screenshot() -> void:
	"""Take a screenshot of the current view"""
	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://neurovis_screenshot_" + timestamp + ".png"
	image.save_png(filename)
	_show_notification("Screenshot saved!", "success")

func _show_notification(message: String, type: String = "info", duration: float = 3.0) -> void:
	"""Show a modern notification"""
	var notif_system = ui_layer.get_node_or_null("NotificationSystem")
	if not notif_system:
		return
	
	var notif = _create_notification_panel(message, type)
	notif_system.add_child(notif)
	
	# Animate in
	var tween_in = create_tween()
	tween_in.set_parallel(true)
	tween_in.tween_property(notif, "modulate", Color.WHITE, 0.3)
	tween_in.tween_property(notif, "position:x", 0, 0.3).set_trans(Tween.TRANS_BACK)
	
	# Auto remove
	await get_tree().create_timer(duration).timeout
	
	# Animate out
	var tween_out = create_tween()
	tween_out.set_parallel(true)
	tween_out.tween_property(notif, "modulate", Color.TRANSPARENT, 0.3)
	tween_out.tween_property(notif, "position:x", 300, 0.3)
	tween_out.tween_callback(notif.queue_free).set_delay(0.3)

func _create_notification_panel(message: String, type: String) -> Control:
	"""Create a notification panel"""
	var notif = PanelContainer.new()
	notif.custom_minimum_size = Vector2(300, 60)
	notif.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	notif.modulate = Color.TRANSPARENT
	notif.position.x = -300
	
	# Style based on type
	var style = StyleBoxFlat.new()
	match type:
		"success":
			style.bg_color = Color("#06FFA5")
		"error":
			style.bg_color = Color("#FF073A")
		"warning":
			style.bg_color = Color("#FFB800")
		_:
			style.bg_color = Color("#00D9FF")
	
	style.bg_color.a = 0.9
	style.set_corner_radius_all(8)
	if enable_shadows:
		style.shadow_size = 6
		style.shadow_color = Color(0, 0, 0, 0.3)
	
	notif.add_theme_stylebox_override("panel", style)
	
	# Add message label
	var label = Label.new()
	label.text = message
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notif.add_child(label)
	
	return notif

# === PUBLIC INTERFACE ===

func apply_enhanced_mode() -> void:
	"""Apply enhanced glassmorphism theme"""
	theme_mode = "enhanced"
	enable_glassmorphism = true
	enable_shadows = true
	_apply_enhanced_styling()

func apply_minimal_mode() -> void:
	"""Apply minimal clean theme"""
	theme_mode = "minimal"
	enable_glassmorphism = false
	enable_shadows = false
	_apply_enhanced_styling()

func toggle_animations(enabled: bool) -> void:
	"""Enable or disable animations"""
	enable_animations = enabled

func show_notification(message: String, type: String = "info") -> void:
	"""Public method to show notifications"""
	_show_notification(message, type)