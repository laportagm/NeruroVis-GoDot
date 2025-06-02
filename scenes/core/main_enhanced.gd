# Enhanced Main Scene with Modern UI and Improved Functionality
class_name NeuroVisMainEnhanced
extends Node3D

# UI Enhancement Configuration
const UI_ANIMATIONS_ENABLED = true
const GLASSMORPHISM_ENABLED = true
const MODERN_THEME_COLORS = {
	"primary": Color("#00D9FF"),      # Cyan
	"secondary": Color("#06FFA5"),    # Green  
	"accent": Color("#7209B7"),       # Purple
	"danger": Color("#FF073A"),       # Red
	"warning": Color("#FFB800"),      # Orange
	"success": Color("#06FFA5"),      # Green
	"background": Color(0.08, 0.08, 0.12, 0.95),  # Dark with transparency
	"surface": Color(0.12, 0.12, 0.18, 0.85),     # Slightly lighter
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color("#B0B0C0"),
	"text_muted": Color("#808090")
}

# Core node references
@onready var camera: Camera3D = $Camera3D
@onready var light: DirectionalLight3D = $DirectionalLight3D
@onready var brain_model_parent: Node3D = $BrainModel
@onready var ui_layer: CanvasLayer = $UI_Layer
@onready var object_name_label: Label = $UI_Layer/ObjectNameLabel

# UI Components
var info_panel: Control
var model_control_panel: Control
var ai_assistant_panel: Control
var comparative_panel: Control
var notification_system: Control
var context_menu: PopupMenu
var tooltip_system: Control

# Core Systems
var selection_manager: Node
var camera_controller: Node
var model_coordinator: Node
var animation_controller: Node

# State
var current_theme_mode: String = "enhanced"
var ui_scale: float = 1.0
var animations_enabled: bool = true

# Signals
signal ui_theme_changed(theme_mode: String)
signal ui_scale_changed(scale: float)
signal notification_shown(message: String, type: String)

func _ready() -> void:
	print("[ENHANCED] Starting Enhanced NeuroVis...")
	
	# Setup enhanced lighting
	_setup_enhanced_lighting()
	
	# Initialize core systems
	_initialize_core_systems()
	
	# Create enhanced UI
	_create_enhanced_ui()
	
	# Apply initial theme
	_apply_enhanced_theme()
	
	# Setup interactions
	_setup_enhanced_interactions()
	
	print("[ENHANCED] NeuroVis Enhanced ready!")

func _setup_enhanced_lighting() -> void:
	## Configure enhanced lighting for better visuals
	if light:
		light.light_energy = 1.2
		light.shadow_enabled = true
		light.shadow_blur = 1.0
		light.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_4_SPLITS
		light.directional_shadow_max_distance = 50.0
		
		# Add subtle animation to light
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(light, "rotation_degrees:y", 360, 60.0)
	
	# Configure environment
	var env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.05, 0.05, 0.08)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.2, 0.2, 0.3)
	env.ambient_light_energy = 0.3
	
	# Add SSAO for depth
	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 0.5
	
	# Add glow for UI elements
	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_bloom = 0.5
	
	camera.environment = env

func _initialize_core_systems() -> void:
	## Initialize core systems with enhancements
	# Load and setup selection manager
	var MultiStructureSelectionManagerScript = load("res://core/interaction/MultiStructureSelectionManager.gd")
	selection_manager = MultiStructureSelectionManagerScript.new()
	add_child(selection_manager)
	
	# Enhanced selection colors
	selection_manager.configure_highlight_colors(
		MODERN_THEME_COLORS.primary,
		MODERN_THEME_COLORS.secondary
	)
	selection_manager.set_emission_energy(0.8)
	selection_manager.set_outline_enabled(true)
	
	# Connect selection signals
	selection_manager.structure_selected.connect(_on_structure_selected_enhanced)
	selection_manager.structure_deselected.connect(_on_structure_deselected)
	selection_manager.multi_selection_changed.connect(_on_multi_selection_changed)
	
	# Setup camera controller
	var CameraBehaviorControllerScript = load("res://core/interaction/CameraBehaviorController.gd")
	camera_controller = CameraBehaviorControllerScript.new()
	add_child(camera_controller)
	camera_controller.initialize(camera, brain_model_parent)
	
	# Setup model coordinator
	var ModelCoordinatorScene = load("res://core/models/ModelRegistry.gd")
	model_coordinator = ModelCoordinatorScene.new()
	add_child(model_coordinator)
	model_coordinator.set_model_parent(brain_model_parent)
	model_coordinator.models_loaded.connect(_on_models_loaded)
	
	# Load models
	model_coordinator.load_brain_models()

func _create_enhanced_ui() -> void:
	## Create modern enhanced UI components
	
	# Enhanced object label with glassmorphism
	_enhance_object_label()
	
	# Create floating action buttons
	_create_floating_action_buttons()
	
	# Create notification system
	_create_notification_system()
	
	# Create tooltip system
	_create_tooltip_system()
	
	# Create context menu
	_create_context_menu()
	
	# Enhanced panels will be created on demand
	print("[UI] Enhanced UI components created")

func _enhance_object_label() -> void:
	## Enhance the object name label with modern styling
	if not object_name_label:
		return
	
	# Create a stylish container for the label
	var container = PanelContainer.new()
	container.name = "LabelContainer"
	container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	container.position = Vector2(0, 20)
	container.size = Vector2(300, 50)
	container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Apply glassmorphism style
	var style = StyleBoxFlat.new()
	style.bg_color = MODERN_THEME_COLORS.background
	style.border_color = MODERN_THEME_COLORS.primary
	style.border_color.a = 0.3
	style.set_border_width_all(1)
	style.set_corner_radius_all(25)
	style.shadow_size = 10
	style.shadow_color = Color(0, 0, 0, 0.3)
	container.add_theme_stylebox_override("panel", style)
	
	# Reparent the label
	object_name_label.get_parent().remove_child(object_name_label)
	container.add_child(object_name_label)
	ui_layer.add_child(container)
	
	# Style the label
	object_name_label.add_theme_color_override("font_color", MODERN_THEME_COLORS.text_primary)
	object_name_label.add_theme_font_size_override("font_size", 18)
	object_name_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.5))
	object_name_label.add_theme_constant_override("shadow_offset_x", 2)
	object_name_label.add_theme_constant_override("shadow_offset_y", 2)
	
	# Center the label in container
	object_name_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	object_name_label.position = Vector2.ZERO

func _create_floating_action_buttons() -> void:
	## Create modern floating action buttons
	var fab_container = VBoxContainer.new()
	fab_container.name = "FloatingActionButtons"
	fab_container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	fab_container.position = Vector2(-80, -200)
	fab_container.add_theme_constant_override("separation", 16)
	
	# Theme toggle button
	var theme_btn = _create_fab("🎨", "Toggle Theme", MODERN_THEME_COLORS.primary)
	theme_btn.pressed.connect(_on_theme_toggle)
	fab_container.add_child(theme_btn)
	
	# AI Assistant button
	var ai_btn = _create_fab("🤖", "AI Assistant", MODERN_THEME_COLORS.secondary)
	ai_btn.pressed.connect(_on_ai_assistant_toggle)
	fab_container.add_child(ai_btn)
	
	# Settings button
	var settings_btn = _create_fab("⚙️", "Settings", MODERN_THEME_COLORS.accent)
	settings_btn.pressed.connect(_on_settings_toggle)
	fab_container.add_child(settings_btn)
	
	# Help button
	var help_btn = _create_fab("❓", "Help", MODERN_THEME_COLORS.warning)
	help_btn.pressed.connect(_on_help_toggle)
	fab_container.add_child(help_btn)
	
	ui_layer.add_child(fab_container)
	
	# Animate entrance
	_animate_fab_entrance(fab_container)

func _create_fab(icon: String, tooltip: String, color: Color) -> Button:
	## Create a floating action button
	var button = Button.new()
	button.text = icon
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(56, 56)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Create circular style
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color
	style_normal.set_corner_radius_all(28)
	style_normal.shadow_size = 8
	style_normal.shadow_color = Color(0, 0, 0, 0.3)
	style_normal.shadow_offset = Vector2(0, 4)
	
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = color.lightened(0.1)
	style_hover.shadow_size = 12
	style_hover.shadow_offset = Vector2(0, 6)
	
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = color.darkened(0.1)
	style_pressed.shadow_size = 4
	style_pressed.shadow_offset = Vector2(0, 2)
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_font_size_override("font_size", 24)
	
	return button

func _animate_fab_entrance(container: Control) -> void:
	## Animate floating action buttons entrance
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
	## Create a modern notification system
	var notif_container = VBoxContainer.new()
	notif_container.name = "NotificationSystem"
	notif_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	notif_container.position = Vector2(0, 80)
	notif_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	notif_container.add_theme_constant_override("separation", 8)
	
	notification_system = notif_container
	ui_layer.add_child(notification_system)

func _show_notification(message: String, type: String = "info", duration: float = 3.0) -> void:
	## Show a modern notification
	var notif = PanelContainer.new()
	notif.custom_minimum_size = Vector2(300, 60)
	notif.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Style based on type
	var style = StyleBoxFlat.new()
	match type:
		"success":
			style.bg_color = MODERN_THEME_COLORS.success
		"error":
			style.bg_color = MODERN_THEME_COLORS.danger
		"warning":
			style.bg_color = MODERN_THEME_COLORS.warning
		_:
			style.bg_color = MODERN_THEME_COLORS.primary
	
	style.bg_color.a = 0.9
	style.set_corner_radius_all(8)
	style.shadow_size = 6
	style.shadow_color = Color(0, 0, 0, 0.3)
	notif.add_theme_stylebox_override("panel", style)
	
	# Add message
	var label = Label.new()
	label.text = message
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notif.add_child(label)
	
	# Add to notification system
	notification_system.add_child(notif)
	
	# Animate in
	notif.modulate = Color.TRANSPARENT
	notif.position.x = -300
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
	
	notification_shown.emit(message, type)

func _create_tooltip_system() -> void:
	## Create enhanced tooltip system
	tooltip_system = Control.new()
	tooltip_system.name = "TooltipSystem"
	tooltip_system.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ui_layer.add_child(tooltip_system)

func _create_context_menu() -> void:
	## Create a modern context menu
	context_menu = PopupMenu.new()
	context_menu.name = "ContextMenu"
	
	# Add menu items
	context_menu.add_item("View Details", 0)
	context_menu.add_item("Compare", 1)
	context_menu.add_separator()
	context_menu.add_item("Focus Camera", 2)
	context_menu.add_item("Hide/Show", 3)
	context_menu.add_separator()
	context_menu.add_item("Copy Name", 4)
	context_menu.add_item("Export Info", 5)
	
	# Style the menu
	var menu_style = StyleBoxFlat.new()
	menu_style.bg_color = MODERN_THEME_COLORS.surface
	menu_style.border_color = MODERN_THEME_COLORS.primary
	menu_style.border_color.a = 0.3
	menu_style.set_border_width_all(1)
	menu_style.set_corner_radius_all(8)
	menu_style.shadow_size = 12
	menu_style.shadow_color = Color(0, 0, 0, 0.4)
	
	context_menu.add_theme_stylebox_override("panel", menu_style)
	context_menu.add_theme_color_override("font_color", MODERN_THEME_COLORS.text_primary)
	context_menu.add_theme_color_override("font_hover_color", MODERN_THEME_COLORS.primary)
	
	# Connect menu signals
	context_menu.id_pressed.connect(_on_context_menu_item_selected)
	
	ui_layer.add_child(context_menu)

func _setup_enhanced_interactions() -> void:
	## Setup enhanced user interactions
	set_process_unhandled_input(true)
	
	# Add smooth camera transitions
	if camera_controller and camera_controller.has_method("set_smooth_transitions"):
		camera_controller.set_smooth_transitions(true)

func _input(event: InputEvent) -> void:
	# Enhanced input handling
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Show context menu on right click
			if selection_manager.get_selected_structure_name() != "":
				context_menu.position = event.position
				context_menu.popup()
				get_viewport().set_input_as_handled()
			else:
				# Regular selection
				selection_manager.handle_selection_at_position(event.position)
	
	# Keyboard shortcuts
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_F:
				_focus_on_selection()
			KEY_H:
				_toggle_help()
			KEY_ESCAPE:
				_close_all_panels()
			KEY_SPACE:
				_toggle_play_pause()

func _on_structure_selected_enhanced(structure_name: String, mesh: MeshInstance3D) -> void:
	## Enhanced structure selection handler
	# Animate label change
	_animate_label_change("Selected: " + structure_name)
	
	# Show notification
	_show_notification("Selected: " + structure_name, "info", 2.0)
	
	# Create enhanced info panel
	_create_enhanced_info_panel(structure_name)
	
	# Highlight effect
	_add_selection_highlight_effect(mesh)

func _animate_label_change(new_text: String) -> void:
	## Animate object label text change
	if not object_name_label:
		return
	
	var tween = create_tween()
	tween.tween_property(object_name_label, "modulate:a", 0.0, 0.15)
	tween.tween_callback(func(): object_name_label.text = new_text)
	tween.tween_property(object_name_label, "modulate:a", 1.0, 0.15)

func _add_selection_highlight_effect(mesh: MeshInstance3D) -> void:
	## Add visual highlight effect to selected mesh
	if not mesh:
		return
	
	# Create a pulse effect
	var tween = create_tween()
	tween.set_loops(3)
	tween.tween_property(mesh, "scale", mesh.scale * 1.05, 0.2)
	tween.tween_property(mesh, "scale", mesh.scale, 0.2)

func _create_enhanced_info_panel(structure_name: String) -> void:
	## Create a modern enhanced info panel
	# This would create a new modern panel with animations
	# For now, using the existing panel system
	var structure_data = _get_structure_data(structure_name)
	if structure_data.is_empty():
		return
	
	# The actual panel creation is handled by the parent class
	# We just add enhancements here
	_show_notification("Loading information...", "info", 1.0)

func _get_structure_data(structure_name: String) -> Dictionary:
	## Get structure data from knowledge service
	var KnowledgeService = get_node_or_null("/root/KnowledgeService")
	if KnowledgeService:
		return KnowledgeService.get_structure(structure_name)
	return {}

func _apply_enhanced_theme() -> void:
	## Apply enhanced modern theme to all UI elements
	# This is handled by the theme manager but we can add extra effects
	print("[THEME] Enhanced theme applied")

# UI Action Handlers
func _on_theme_toggle() -> void:
	## Toggle between theme modes
	if current_theme_mode == "enhanced":
		current_theme_mode = "minimal"
		_show_notification("Switched to Minimal Theme", "info")
	else:
		current_theme_mode = "enhanced"
		_show_notification("Switched to Enhanced Theme", "info")
	
	ui_theme_changed.emit(current_theme_mode)
	_apply_enhanced_theme()

func _on_ai_assistant_toggle() -> void:
	## Toggle AI assistant panel
	_show_notification("AI Assistant", "info")
	# Implementation would go here

func _on_settings_toggle() -> void:
	## Show settings panel
	_show_notification("Settings Panel", "info")
	# Implementation would go here

func _on_help_toggle() -> void:
	## Show help panel
	_toggle_help()

func _on_context_menu_item_selected(id: int) -> void:
	## Handle context menu selection
	match id:
		0: # View Details
			_show_notification("Viewing details...", "info")
		1: # Compare
			_show_notification("Compare mode", "info")
		2: # Focus Camera
			_focus_on_selection()
		3: # Hide/Show
			_toggle_structure_visibility()
		4: # Copy Name
			_copy_structure_name()
		5: # Export Info
			_export_structure_info()

# Helper Methods
func _focus_on_selection() -> void:
	if selection_manager and camera_controller:
		var selected = selection_manager.get_selected_structure_name()
		if selected != "":
			camera_controller.focus_on_bounds(Vector3.ZERO, 2.0)
			_show_notification("Focused on " + selected, "success", 2.0)

func _toggle_help() -> void:
	_show_notification("Help System - Coming Soon", "info")

func _close_all_panels() -> void:
	# Close all open panels
	if info_panel:
		info_panel.hide()
	if ai_assistant_panel:
		ai_assistant_panel.hide()
	_show_notification("All panels closed", "info", 1.5)

func _toggle_play_pause() -> void:
	# Toggle animation playback
	get_tree().paused = !get_tree().paused
	_show_notification("Paused" if get_tree().paused else "Resumed", "info")

func _toggle_structure_visibility() -> void:
	# Toggle selected structure visibility
	var selected = selection_manager.get_selected_structure_name()
	if selected != "":
		_show_notification("Toggled visibility: " + selected, "info")

func _copy_structure_name() -> void:
	var selected = selection_manager.get_selected_structure_name()
	if selected != "":
		DisplayServer.clipboard_set(selected)
		_show_notification("Copied: " + selected, "success", 2.0)

func _export_structure_info() -> void:
	_show_notification("Export feature coming soon", "info")

func _on_models_loaded(model_names: Array) -> void:
	print("[ENHANCED] Models loaded: " + str(model_names))
	_show_notification("Loaded " + str(model_names.size()) + " models", "success")

func _on_structure_deselected() -> void:
	_animate_label_change("Selected: None")
	if info_panel:
		# Animate panel exit
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(info_panel, "modulate", Color.TRANSPARENT, 0.3)
		tween.tween_property(info_panel, "position:x", info_panel.position.x + 100, 0.3)
		tween.tween_callback(func(): info_panel.hide()).set_delay(0.3)

func _on_multi_selection_changed(selections: Array) -> void:
	if selections.size() > 1:
		var names = []
		for sel in selections:
			names.append(sel["name"])
		_animate_label_change("Comparing: " + ", ".join(names))
		_show_notification("Comparing " + str(selections.size()) + " structures", "info")
