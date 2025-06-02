## SimpleStyleApplier.gd
## Simplified styling that avoids initialization issues
##
## This version focuses on core visual improvements without complex dependencies
## @tutorial: Safe UI styling without initialization errors

extends Node

# === SIMPLE CONFIGURATION ===
@export var auto_apply_on_ready: bool = true
@export var use_enhanced_theme: bool = true
@export var enable_animations: bool = true

# Simple color palette
const ENHANCED_COLORS = {
	"panel_bg": Color(15.0/255, 15.0/255, 23.0/255, 0.85),
	"border": Color(0, 217.0/255, 1, 0.2),
	"text_primary": Color("#00D9FF"),
	"text_secondary": Color("#B0B0C0"),
	"button_primary": Color("#00D9FF"),
	"button_secondary": Color("#06FFA5"),
	"button_settings": Color("#7209B7")
}

const MINIMAL_COLORS = {
	"panel_bg": Color(1, 1, 1, 0.06),
	"border": Color(1, 1, 1, 0.1),
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color(1, 1, 1, 0.85),
	"button_primary": Color(1, 1, 1, 0.8),
	"button_secondary": Color(1, 1, 1, 0.6),
	"button_settings": Color(1, 1, 1, 0.4)
}

func _ready() -> void:
	if auto_apply_on_ready:
		call_deferred("apply_simple_styling")

func apply_simple_styling() -> void:
	"""Apply simplified styling that avoids complex dependencies"""
	print("🎨 [SimpleStyleApplier] Applying safe styling...")
	
	var main_scene = _find_main_scene()
	if not main_scene:
		print("❌ Could not find main scene")
		return
	
	# Apply safe styling
	_style_object_label_safe(main_scene)
	_style_panels_safe(main_scene)
	_add_simple_floating_buttons(main_scene)
	
	print("✅ Simple styling applied successfully!")
	_show_success_message()

func _find_main_scene() -> Node:
	"""Find the main scene node"""
	var current = self
	while current.get_parent():
		current = current.get_parent()
	return current

func _style_object_label_safe(main_scene: Node) -> void:
	"""Safely style the object label without complex dependencies"""
	var ui_layer = main_scene.get_node_or_null("UI_Layer")
	if not ui_layer:
		return
	
	var label = ui_layer.get_node_or_null("ObjectNameLabel")
	if not label:
		return
	
	print("🏷️ Styling object label safely...")
	
	# Create simple container
	var container = PanelContainer.new()
	container.name = "SimpleStyledContainer"
	container.custom_minimum_size = Vector2(400, 60)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Apply simple style
	var style = _create_simple_panel_style()
	style.set_corner_radius_all(30)  # More rounded for label
	container.add_theme_stylebox_override("panel", style)
	
	# Position container
	container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	container.position = Vector2(0, 20)
	container.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Reparent label
	ui_layer.remove_child(label)
	container.add_child(label)
	ui_layer.add_child(container)
	
	# Style label text
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	var colors = ENHANCED_COLORS if use_enhanced_theme else MINIMAL_COLORS
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", colors.text_primary)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)

func _style_panels_safe(main_scene: Node) -> void:
	"""Safely style existing panels"""
	var ui_layer = main_scene.get_node_or_null("UI_Layer")
	if not ui_layer:
		return
	
	print("📋 Styling panels safely...")
	
	# Style structure info panel
	var info_panel = ui_layer.get_node_or_null("StructureInfoPanel")
	if info_panel:
		var style = _create_simple_panel_style()
		info_panel.add_theme_stylebox_override("panel", style)
		_add_simple_hover_effect(info_panel)
	
	# Style model control panel
	var model_panel = ui_layer.get_node_or_null("ModelControlPanel")
	if model_panel:
		var style = _create_simple_panel_style()
		model_panel.add_theme_stylebox_override("panel", style)
		_add_simple_hover_effect(model_panel)

func _create_simple_panel_style() -> StyleBoxFlat:
	"""Create a simple panel style without complex dependencies"""
	var style = StyleBoxFlat.new()
	var colors = ENHANCED_COLORS if use_enhanced_theme else MINIMAL_COLORS
	
	# Background
	style.bg_color = colors.panel_bg
	
	# Border
	style.border_color = colors.border
	style.set_border_width_all(1)
	
	# Corners
	style.set_corner_radius_all(12)
	
	# Simple shadow
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.2)
	style.shadow_offset = Vector2(0, 4)
	
	return style

func _add_simple_hover_effect(control: Control) -> void:
	"""Add simple hover effect without complex dependencies"""
	if not enable_animations:
		return
	
	var original_modulate = control.modulate
	
	# Connect hover signals if available
	if control.has_signal("mouse_entered") and control.has_signal("mouse_exited"):
		control.mouse_entered.connect(func():
			var tween = create_tween()
			tween.tween_property(control, "modulate", Color(1.1, 1.1, 1.1, 1.0), 0.2)
		)
		control.mouse_exited.connect(func():
			var tween = create_tween()
			tween.tween_property(control, "modulate", original_modulate, 0.2)
		)

func _add_simple_floating_buttons(main_scene: Node) -> void:
	"""Add simple floating buttons without complex dependencies"""
	var ui_layer = main_scene.get_node_or_null("UI_Layer")
	if not ui_layer:
		return
	
	# Check if already exists
	if ui_layer.get_node_or_null("SimpleFloatingButtons"):
		return
	
	print("🎯 Adding simple floating buttons...")
	
	var fab_container = VBoxContainer.new()
	fab_container.name = "SimpleFloatingButtons"
	fab_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	fab_container.position = Vector2(-80, -200)
	fab_container.add_theme_constant_override("separation", 12)
	
	# Create buttons
	var theme_btn = _create_simple_fab("🎨", "Toggle Theme")
	var screenshot_btn = _create_simple_fab("📱", "Screenshot")
	var help_btn = _create_simple_fab("❓", "Help")
	
	# Connect button actions
	theme_btn.pressed.connect(_on_theme_toggle)
	screenshot_btn.pressed.connect(_on_screenshot)
	help_btn.pressed.connect(_on_help)
	
	fab_container.add_child(theme_btn)
	fab_container.add_child(screenshot_btn)
	fab_container.add_child(help_btn)
	
	ui_layer.add_child(fab_container)
	
	# Simple entrance animation
	if enable_animations:
		_animate_fab_entrance(fab_container)

func _create_simple_fab(text: String, tooltip: String) -> Button:
	"""Create a simple floating action button"""
	var button = Button.new()
	button.text = text
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(50, 50)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	var colors = ENHANCED_COLORS if use_enhanced_theme else MINIMAL_COLORS
	
	# Normal style
	var style = StyleBoxFlat.new()
	style.bg_color = colors.button_primary
	style.set_corner_radius_all(25)
	style.shadow_size = 6
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_offset = Vector2(0, 3)
	
	# Hover style
	var hover_style = style.duplicate()
	hover_style.bg_color = colors.button_primary.lightened(0.2)
	hover_style.shadow_size = 8
	hover_style.shadow_offset = Vector2(0, 4)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color.WHITE)
	
	return button

func _animate_fab_entrance(container: Control) -> void:
	"""Simple entrance animation for floating buttons"""
	var children = container.get_children()
	for i in range(children.size()):
		var child = children[i]
		child.modulate = Color.TRANSPARENT
		child.scale = Vector2(0.3, 0.3)
		
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(child, "modulate", Color.WHITE, 0.4).set_delay(i * 0.1)
		tween.tween_property(child, "scale", Vector2.ONE, 0.4).set_delay(i * 0.1).set_trans(Tween.TRANS_BACK)

func _on_theme_toggle() -> void:
	"""Toggle theme mode"""
	use_enhanced_theme = !use_enhanced_theme
	apply_simple_styling()
	var theme_name = "Enhanced" if use_enhanced_theme else "Minimal"
	_show_notification("Theme: " + theme_name, "success")

func _on_screenshot() -> void:
	"""Take a screenshot"""
	var viewport = get_viewport()
	var image = viewport.get_texture().get_image()
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var filename = "user://neurovis_screenshot_" + timestamp + ".png"
	image.save_png(filename)
	_show_notification("Screenshot saved!", "success")

func _on_help() -> void:
	"""Show help"""
	_show_notification("Help: Hover panels, click buttons!", "info")

func _show_notification(message: String, type: String = "info") -> void:
	"""Show a simple notification"""
	print("💬 [Notification] " + message)

func _show_success_message() -> void:
	"""Show success message"""
	print("")
	print("🎉 Simple styling applied successfully!")
	print("✨ Look for these improvements:")
	print("   • Enhanced object label with glassmorphism")
	print("   • Styled panels with modern borders")
	print("   • Floating action buttons (bottom-right)")
	print("   • Smooth hover effects")
	print("")
	print("🎮 Try clicking the floating buttons!")

# Public interface
func toggle_theme() -> void:
	"""Public method to toggle theme"""
	_on_theme_toggle()

func take_screenshot() -> void:
	"""Public method to take screenshot"""
	_on_screenshot()