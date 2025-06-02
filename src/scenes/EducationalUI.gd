## EducationalUI.gd
## Educational user interface management system
##
## This system manages educational information panels, learning interfaces,
## and educational UI components. Focused on learning outcomes and user experience.
## Designed as a clean, focused component for AI-friendly development.
##
## @tutorial: Educational UI management patterns
## @version: 3.0 - Clean Scene-Based Architecture

class_name EducationalUI
extends CanvasLayer

# === EDUCATIONAL UI EVENTS ===
## Emitted when learning panel is displayed for educational content
signal educational_panel_displayed(panel_type: String, content_data: Dictionary)
## Emitted when learning panel is closed
signal educational_panel_closed(panel_type: String)
## Emitted when educational action is triggered (bookmark, learn more, etc.)
signal educational_action_triggered(action: String, context: Dictionary)
## Emitted when accessibility setting changes
signal accessibility_setting_changed(setting: String, value: Variant)

# === CONFIGURATION ===
@export_group("Educational Display")
@export var default_theme_mode: String = "enhanced"  # enhanced, minimal, accessible
@export var enable_learning_tooltips: bool = true
@export var auto_adjust_for_accessibility: bool = true

@export_group("Panel Management")
@export var max_concurrent_panels: int = 2
@export var panel_animation_duration: float = 0.3
@export var enable_panel_persistence: bool = true

@export_group("Learning Analytics")
@export var track_ui_interactions: bool = true
@export var track_reading_time: bool = true
@export var track_accessibility_usage: bool = true

# === UI STATE ===
var _active_panels: Dictionary = {}  # panel_type -> panel_instance
var _panel_factory: RefCounted  # InfoPanelFactory equivalent
var _theme_manager: RefCounted  # UIThemeManager equivalent
var _accessibility_manager: RefCounted
var _is_initialized: bool = false

# === LEARNING ANALYTICS ===
var _interaction_history: Array[Dictionary] = []
var _panel_display_times: Dictionary = {}  # Track how long panels are viewed
var _accessibility_usage: Dictionary = {}

# === LIFECYCLE METHODS ===
func _ready() -> void:
	print("[EducationalUI] Initializing educational interface system...")
	layer = 10  # Ensure UI appears above 3D content
	
	_setup_ui_systems()
	_setup_accessibility()
	_connect_educational_events()

func initialize() -> bool:
	"""Initialize the educational UI system"""
	if _is_initialized:
		push_warning("[EducationalUI] Already initialized")
		return false
	
	# Load UI management systems
	if not _load_ui_managers():
		push_error("[EducationalUI] Failed to load UI management systems")
		return false
	
	_is_initialized = true
	print("[EducationalUI] ✓ Educational UI system ready")
	return true

# === EDUCATIONAL PANEL MANAGEMENT ===
func display_educational_panel(panel_type: String, content_data: Dictionary) -> bool:
	"""Display educational panel with learning content"""
	if not _is_initialized:
		push_error("[EducationalUI] Not initialized")
		return false
	
	# Check panel limits for focus
	if _active_panels.size() >= max_concurrent_panels:
		_close_oldest_panel()
	
	# Close existing panel of same type
	if _active_panels.has(panel_type):
		close_educational_panel(panel_type)
	
	# Create educational panel
	var panel = _create_educational_panel(panel_type, content_data)
	if not panel:
		push_error("[EducationalUI] Failed to create educational panel: %s" % panel_type)
		return false
	
	# Add to scene and track
	add_child(panel)
	_active_panels[panel_type] = panel
	_panel_display_times[panel_type] = Time.get_unix_time_from_system()
	
	# Apply educational styling and positioning
	_apply_educational_styling(panel, panel_type)
	_position_educational_panel(panel, panel_type)
	
	# Connect panel signals
	_connect_panel_signals(panel, panel_type)
	
	# Show panel with animation
	_animate_panel_display(panel)
	
	# Emit educational event
	educational_panel_displayed.emit(panel_type, content_data)
	
	# Track educational analytics
	if track_ui_interactions:
		_track_ui_interaction("panel_displayed", {
			"panel_type": panel_type,
			"content_summary": _summarize_content_data(content_data)
		})
	
	print("[EducationalUI] ✓ Educational panel displayed: %s" % panel_type)
	return true

func close_educational_panel(panel_type: String) -> bool:
	"""Close educational panel and track learning time"""
	if not _active_panels.has(panel_type):
		return false
	
	var panel = _active_panels[panel_type]
	
	# Calculate viewing time for learning analytics
	if _panel_display_times.has(panel_type):
		var display_time = Time.get_unix_time_from_system() - _panel_display_times[panel_type]
		_track_ui_interaction("panel_viewing_time", {
			"panel_type": panel_type,
			"viewing_seconds": display_time
		})
		_panel_display_times.erase(panel_type)
	
	# Animate panel close
	_animate_panel_close(panel)
	
	# Remove from tracking
	_active_panels.erase(panel_type)
	
	# Emit educational event
	educational_panel_closed.emit(panel_type)
	
	print("[EducationalUI] Educational panel closed: %s" % panel_type)
	return true

func _create_educational_panel(panel_type: String, content_data: Dictionary) -> Control:
	"""Create educational panel based on type and content"""
	var panel: Control = null
	
	match panel_type:
		"structure_info":
			panel = _create_structure_info_panel(content_data)
		"comparison":
			panel = _create_comparison_panel(content_data)
		"learning_objectives":
			panel = _create_learning_objectives_panel(content_data)
		"assessment":
			panel = _create_assessment_panel(content_data)
		_:
			# Generic educational panel
			panel = _create_generic_educational_panel(content_data)
	
	if panel:
		panel.name = "EducationalPanel_" + panel_type
		panel.set_meta("panel_type", panel_type)
		panel.set_meta("creation_time", Time.get_unix_time_from_system())
	
	return panel

func _create_structure_info_panel(content_data: Dictionary) -> Control:
	"""Create educational structure information panel"""
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Educational header
	var header = _create_educational_header(content_data.get("displayName", "Structure"))
	vbox.add_child(header)
	
	# Learning objectives section
	var objectives_section = _create_learning_objectives_section(content_data)
	vbox.add_child(objectives_section)
	
	# Content sections
	var content_section = _create_content_section(content_data)
	vbox.add_child(content_section)
	
	# Educational actions
	var actions_section = _create_educational_actions_section(content_data)
	vbox.add_child(actions_section)
	
	return panel

func _create_comparison_panel(content_data: Dictionary) -> Control:
	"""Create educational comparison panel for multiple structures"""
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Comparison header
	var header = Label.new()
	header.text = "Structure Comparison"
	header.add_theme_font_size_override("font_size", 18)
	vbox.add_child(header)
	
	# Structure comparison grid
	var structures = content_data.get("structures", [])
	var comparison_grid = _create_comparison_grid(structures)
	vbox.add_child(comparison_grid)
	
	return panel

func _create_learning_objectives_section(content_data: Dictionary) -> Control:
	"""Create learning objectives section for educational content"""
	var section = VBoxContainer.new()
	
	# Section header
	var header = Label.new()
	header.text = "Learning Objectives"
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	section.add_child(header)
	
	# Objectives list
	var objectives = content_data.get("learningObjectives", [])
	for objective in objectives:
		var objective_item = _create_objective_item(objective)
		section.add_child(objective_item)
	
	return section

func _create_objective_item(objective_text: String) -> Control:
	"""Create individual learning objective item"""
	var hbox = HBoxContainer.new()
	
	# Checkbox for completion tracking
	var checkbox = CheckBox.new()
	checkbox.text = ""
	checkbox.custom_minimum_size = Vector2(20, 20)
	hbox.add_child(checkbox)
	
	# Objective text
	var label = Label.new()
	label.text = objective_text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hbox.add_child(label)
	
	# Connect checkbox for learning analytics
	checkbox.toggled.connect(_on_learning_objective_toggled.bind(objective_text))
	
	return hbox

func _create_educational_actions_section(content_data: Dictionary) -> Control:
	"""Create educational action buttons section"""
	var section = HBoxContainer.new()
	
	# Learn More button
	var learn_more_btn = Button.new()
	learn_more_btn.text = "Learn More"
	learn_more_btn.pressed.connect(_on_educational_action.bind("learn_more", content_data))
	section.add_child(learn_more_btn)
	
	# Bookmark button
	var bookmark_btn = Button.new()
	bookmark_btn.text = "📖 Bookmark"
	bookmark_btn.pressed.connect(_on_educational_action.bind("bookmark", content_data))
	section.add_child(bookmark_btn)
	
	# Quiz button (if assessment content available)
	if content_data.has("assessmentQuestions"):
		var quiz_btn = Button.new()
		quiz_btn.text = "🧠 Quiz"
		quiz_btn.pressed.connect(_on_educational_action.bind("start_quiz", content_data))
		section.add_child(quiz_btn)
	
	return section

# === EDUCATIONAL STYLING ===
func _apply_educational_styling(panel: Control, panel_type: String) -> void:
	"""Apply educational styling based on theme and accessibility settings"""
	if not _theme_manager:
		return
	
	# Get current theme mode
	var theme_mode = default_theme_mode
	if _theme_manager.has_method("get_current_mode"):
		theme_mode = _theme_manager.get_current_mode()
	
	# Apply educational theme styling
	match theme_mode:
		"enhanced":
			_apply_enhanced_educational_styling(panel)
		"minimal":
			_apply_minimal_educational_styling(panel)
		"accessible":
			_apply_accessible_educational_styling(panel)

func _apply_enhanced_educational_styling(panel: Control) -> void:
	"""Apply enhanced educational styling with engaging visuals"""
	panel.modulate = Color(1.0, 1.0, 1.0, 0.95)
	# Add glassmorphism effect if theme manager supports it
	if _theme_manager and _theme_manager.has_method("apply_glass_panel"):
		_theme_manager.apply_glass_panel(panel)

func _apply_minimal_educational_styling(panel: Control) -> void:
	"""Apply minimal educational styling for clinical/professional use"""
	panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	# Apply clean, professional styling
	if _theme_manager and _theme_manager.has_method("apply_minimal_panel"):
		_theme_manager.apply_minimal_panel(panel)

func _apply_accessible_educational_styling(panel: Control) -> void:
	"""Apply accessible educational styling for diverse learning needs"""
	panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	# Apply high contrast, large text styling
	if _accessibility_manager and _accessibility_manager.has_method("apply_accessible_styling"):
		_accessibility_manager.apply_accessible_styling(panel)

# === POSITIONING ===
func _position_educational_panel(panel: Control, panel_type: String) -> void:
	"""Position educational panel for optimal learning experience"""
	var viewport_size = get_viewport().get_visible_rect().size
	
	match panel_type:
		"structure_info":
			# Right side for primary information
			panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
			panel.position.x = viewport_size.x - 420
			panel.custom_minimum_size = Vector2(400, 500)
		"comparison":
			# Left side for comparison
			panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_LEFT)
			panel.position.x = 20
			panel.custom_minimum_size = Vector2(450, 600)
		"learning_objectives":
			# Top center for objectives
			panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
			panel.position.y = 20
			panel.custom_minimum_size = Vector2(600, 200)
		_:
			# Default center positioning
			panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)

# === ANIMATIONS ===
func _animate_panel_display(panel: Control) -> void:
	"""Animate educational panel appearance"""
	if panel_animation_duration <= 0:
		return
	
	# Start from transparent and small
	panel.modulate.a = 0.0
	panel.scale = Vector2(0.8, 0.8)
	
	# Animate to full visibility
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 1.0, panel_animation_duration)
	tween.tween_property(panel, "scale", Vector2(1.0, 1.0), panel_animation_duration)

func _animate_panel_close(panel: Control) -> void:
	"""Animate educational panel closing"""
	if panel_animation_duration <= 0:
		panel.queue_free()
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(panel, "modulate:a", 0.0, panel_animation_duration)
	tween.tween_property(panel, "scale", Vector2(0.8, 0.8), panel_animation_duration)
	tween.tween_callback(panel.queue_free).set_delay(panel_animation_duration)

# === EVENT HANDLERS ===
func _on_educational_action(action: String, context: Dictionary) -> void:
	"""Handle educational action button presses"""
	print("[EducationalUI] Educational action: %s" % action)
	
	# Emit educational action event
	educational_action_triggered.emit(action, context)
	
	# Track educational analytics
	if track_ui_interactions:
		_track_ui_interaction("educational_action", {
			"action": action,
			"context_summary": _summarize_content_data(context)
		})

func _on_learning_objective_toggled(objective_text: String, completed: bool) -> void:
	"""Handle learning objective completion toggle"""
	print("[EducationalUI] Learning objective %s: %s" % [objective_text, "completed" if completed else "unchecked"])
	
	# Track learning progress
	if track_ui_interactions:
		_track_ui_interaction("learning_objective_toggled", {
			"objective": objective_text,
			"completed": completed
		})

# === SYSTEM SETUP ===
func _setup_ui_systems() -> void:
	"""Setup UI management systems"""
	# These would normally be loaded as autoloads or injected dependencies
	print("[EducationalUI] Setting up UI management systems...")

func _setup_accessibility() -> void:
	"""Setup accessibility features for educational use"""
	print("[EducationalUI] Setting up accessibility features...")
	
	# Setup screen reader support
	if auto_adjust_for_accessibility:
		_setup_screen_reader_support()

func _connect_educational_events() -> void:
	"""Connect to educational event system"""
	# Connect to EventBus if available
	var event_bus = get_node_or_null("/root/EventBus")
	if event_bus:
		if event_bus.has_signal("educational_panel_requested"):
			event_bus.educational_panel_requested.connect(_on_educational_panel_requested)

func _on_educational_panel_requested(panel_type: String, content_data: Dictionary) -> void:
	"""Handle educational panel requests from other systems"""
	display_educational_panel(panel_type, content_data)

# === UTILITY METHODS ===
func _load_ui_managers() -> bool:
	"""Load UI management systems"""
	# Load InfoPanelFactory equivalent
	var factory_script = load("res://ui/panels/InfoPanelFactory.gd")
	if factory_script:
		_panel_factory = factory_script.new()
	
	# Load UIThemeManager equivalent  
	var theme_script = load("res://ui/panels/UIThemeManager.gd")
	if theme_script:
		_theme_manager = theme_script.new()
	
	return true

func _close_oldest_panel() -> void:
	"""Close oldest panel to make room for new educational content"""
	var oldest_panel_type = ""
	var oldest_time = INF
	
	for panel_type in _panel_display_times.keys():
		var display_time = _panel_display_times[panel_type]
		if display_time < oldest_time:
			oldest_time = display_time
			oldest_panel_type = panel_type
	
	if not oldest_panel_type.is_empty():
		close_educational_panel(oldest_panel_type)

func _track_ui_interaction(interaction_type: String, data: Dictionary) -> void:
	"""Track UI interactions for educational analytics"""
	if not track_ui_interactions:
		return
	
	var interaction_record = {
		"timestamp": Time.get_unix_time_from_system(),
		"interaction_type": interaction_type,
		"data": data
	}
	
	_interaction_history.append(interaction_record)
	
	# Limit history size
	if _interaction_history.size() > 100:
		_interaction_history.pop_front()

func _summarize_content_data(content_data: Dictionary) -> Dictionary:
	"""Create summary of content data for analytics (no PII)"""
	return {
		"has_display_name": content_data.has("displayName"),
		"has_description": content_data.has("shortDescription"),
		"has_functions": content_data.has("functions"),
		"has_learning_objectives": content_data.has("learningObjectives"),
		"structure_count": content_data.get("structures", []).size()
	}

func _create_educational_header(title: String) -> Control:
	"""Create educational panel header"""
	var header = Label.new()
	header.text = title
	header.add_theme_font_size_override("font_size", 20)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return header

func _create_content_section(content_data: Dictionary) -> Control:
	"""Create main content section"""
	var section = VBoxContainer.new()
	
	# Description
	var description = Label.new()
	description.text = content_data.get("shortDescription", "No description available")
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	section.add_child(description)
	
	return section

func _create_comparison_grid(structures: Array) -> Control:
	"""Create comparison grid for multiple structures"""
	var grid = GridContainer.new()
	grid.columns = min(structures.size(), 3)
	
	for structure in structures:
		var structure_panel = _create_structure_summary(structure)
		grid.add_child(structure_panel)
	
	return grid

func _create_structure_summary(structure_data: Dictionary) -> Control:
	"""Create summary panel for structure in comparison"""
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var title = Label.new()
	title.text = structure_data.get("displayName", "Unknown")
	title.add_theme_font_size_override("font_size", 14)
	vbox.add_child(title)
	
	return panel

func _setup_screen_reader_support() -> void:
	"""Setup screen reader accessibility support"""
	# Implementation would depend on Godot's accessibility features
	pass

func _connect_panel_signals(panel: Control, panel_type: String) -> void:
	"""Connect panel signals for educational interaction tracking"""
	# Connect common panel signals if they exist
	pass

func _create_generic_educational_panel(content_data: Dictionary) -> Control:
	"""Create generic educational panel for unknown content types"""
	var panel = PanelContainer.new()
	var label = Label.new()
	label.text = "Educational Content: " + str(content_data.get("displayName", "Unknown"))
	panel.add_child(label)
	return panel

func _create_assessment_panel(content_data: Dictionary) -> Control:
	"""Create assessment/quiz panel for educational testing"""
	var panel = PanelContainer.new()
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var header = Label.new()
	header.text = "Assessment: " + content_data.get("displayName", "Structure")
	vbox.add_child(header)
	
	# Assessment questions would be created here
	
	return panel

# === PUBLIC API ===
func get_active_panels() -> Array[String]:
	"""Get list of active panel types"""
	return _active_panels.keys()

func is_panel_active(panel_type: String) -> bool:
	"""Check if specific panel type is active"""
	return _active_panels.has(panel_type)

func get_interaction_history() -> Array[Dictionary]:
	"""Get UI interaction history for analytics"""
	return _interaction_history.duplicate()

func set_theme_mode(theme_mode: String) -> void:
	"""Set educational UI theme mode"""
	default_theme_mode = theme_mode
	# Re-apply styling to active panels
	for panel in _active_panels.values():
		_apply_educational_styling(panel, panel.get_meta("panel_type", ""))