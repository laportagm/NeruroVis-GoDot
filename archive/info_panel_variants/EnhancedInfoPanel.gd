extends PanelContainer
class_name EnhancedInfoPanel

# UI Components
@onready var header_container: Control
@onready var content_container: Control
@onready var close_button: Button
@onready var title_label: Label
@onready var structure_icon: TextureRect
@onready var description_container: VBoxContainer
@onready var functions_container: VBoxContainer
@onready var clinical_container: VBoxContainer
@onready var related_container: VBoxContainer

# Animation state
var is_expanded: bool = true
var is_animating: bool = false

# Data
var current_structure_data: Dictionary = {}

# Theme colors
const THEME_COLORS = {
	"bg_primary": Color(0.08, 0.08, 0.12, 0.92),
	"bg_secondary": Color(0.12, 0.12, 0.18, 0.85),
	"accent": Color("#00D9FF"),
	"accent_secondary": Color("#06FFA5"),
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color("#B0B0C0"),
	"text_muted": Color("#808090"),
	"border": Color(0, 217.0/255, 1, 0.15),
	"shadow": Color(0, 0, 0, 0.4)
}

# Signals
signal panel_closed()
signal structure_selected(structure_name: String)
signal bookmark_toggled(structure_id: String, bookmarked: bool)

func _ready() -> void:
	# Set initial size
	custom_minimum_size = Vector2(380, 500)
	
	# Create UI structure
	_create_ui_structure()
	
	# Apply initial styling
	_apply_modern_styling()
	
	# Setup animations
	_setup_animations()
	
	# Connect signals
	_connect_signals()

func _create_ui_structure() -> void:
	## Create the modern UI structure
	
	# Main container
	var main_vbox = VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	add_child(main_vbox)
	
	# Header
	_create_header(main_vbox)
	
	# Content scroll container
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_theme_constant_override("margin_left", 16)
	scroll.add_theme_constant_override("margin_right", 16)
	scroll.add_theme_constant_override("margin_top", 8)
	scroll.add_theme_constant_override("margin_bottom", 16)
	main_vbox.add_child(scroll)
	
	# Content container
	content_container = VBoxContainer.new()
	content_container.add_theme_constant_override("separation", 16)
	scroll.add_child(content_container)
	
	# Create sections
	_create_description_section()
	_create_functions_section()
	_create_clinical_section()
	_create_related_section()

func _create_header(parent: Control) -> void:
	## Create modern header with glassmorphism
	header_container = PanelContainer.new()
	header_container.custom_minimum_size.y = 60
	parent.add_child(header_container)
	
	# Header style
	var header_style = StyleBoxFlat.new()
	header_style.bg_color = THEME_COLORS.bg_secondary
	header_style.border_color = THEME_COLORS.border
	header_style.set_border_width_all(0)
	header_style.set_border_width(SIDE_BOTTOM, 1)
	header_container.add_theme_stylebox_override("panel", header_style)
	
	# Header content
	var header_hbox = HBoxContainer.new()
	header_hbox.add_theme_constant_override("separation", 12)
	header_container.add_child(header_hbox)
	
	# Icon placeholder
	structure_icon = TextureRect.new()
	structure_icon.custom_minimum_size = Vector2(40, 40)
	structure_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	structure_icon.modulate = THEME_COLORS.accent
	header_hbox.add_child(structure_icon)
	
	# Title
	title_label = Label.new()
	title_label.text = "Brain Structure"
	title_label.add_theme_font_size_override("font_size", 20)
	title_label.add_theme_color_override("font_color", THEME_COLORS.text_primary)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_hbox.add_child(title_label)
	
	# Action buttons container
	var actions_container = HBoxContainer.new()
	actions_container.add_theme_constant_override("separation", 8)
	header_hbox.add_child(actions_container)
	
	# Bookmark button
	var bookmark_btn = _create_icon_button("⭐", "Bookmark", THEME_COLORS.accent_secondary)
	bookmark_btn.pressed.connect(_on_bookmark_pressed)
	actions_container.add_child(bookmark_btn)
	
	# Minimize button
	var minimize_btn = _create_icon_button("−", "Minimize", THEME_COLORS.text_secondary)
	minimize_btn.pressed.connect(_on_minimize_pressed)
	actions_container.add_child(minimize_btn)
	
	# Close button
	close_button = _create_icon_button("×", "Close", THEME_COLORS.text_muted)
	close_button.pressed.connect(_on_close_pressed)
	actions_container.add_child(close_button)

func _create_icon_button(icon: String, tooltip: String, color: Color) -> Button:
	## Create a modern icon button
	var button = Button.new()
	button.text = icon
	button.tooltip_text = tooltip
	button.custom_minimum_size = Vector2(32, 32)
	button.flat = true
	
	# Style
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", color)
	button.add_theme_color_override("font_hover_color", color.lightened(0.2))
	button.add_theme_color_override("font_pressed_color", color.darkened(0.2))
	
	return button

func _create_description_section() -> void:
	## Create description section
	description_container = _create_section("Description", THEME_COLORS.accent)
	
	var desc_label = RichTextLabel.new()
	desc_label.fit_content = true
	desc_label.bbcode_enabled = true
	desc_label.add_theme_color_override("default_color", THEME_COLORS.text_secondary)
	desc_label.add_theme_font_size_override("normal_font_size", 14)
	description_container.add_child(desc_label)

func _create_functions_section() -> void:
	## Create functions section
	functions_container = _create_section("Functions", THEME_COLORS.accent_secondary)

func _create_clinical_section() -> void:
	## Create clinical relevance section
	clinical_container = _create_section("Clinical Relevance", Color("#FFB800"))

func _create_related_section() -> void:
	## Create related structures section
	related_container = _create_section("Related Structures", Color("#7209B7"))

func _create_section(title: String, accent_color: Color) -> VBoxContainer:
	## Create a modern section with header
	var section = VBoxContainer.new()
	section.add_theme_constant_override("separation", 8)
	content_container.add_child(section)
	
	# Section header
	var header = HBoxContainer.new()
	section.add_child(header)
	
	# Accent line
	var accent_line = Panel.new()
	accent_line.custom_minimum_size = Vector2(4, 24)
	var line_style = StyleBoxFlat.new()
	line_style.bg_color = accent_color
	line_style.set_corner_radius_all(2)
	accent_line.add_theme_stylebox_override("panel", line_style)
	header.add_child(accent_line)
	
	# Section title
	var title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", 16)
	title_label.add_theme_color_override("font_color", THEME_COLORS.text_primary)
	title_label.add_theme_constant_override("outline_size", 0)
	header.add_child(title_label)
	
	# Expand/collapse button
	var expand_btn = Button.new()
	expand_btn.text = "▼"
	expand_btn.flat = true
	expand_btn.custom_minimum_size = Vector2(24, 24)
	expand_btn.add_theme_color_override("font_color", THEME_COLORS.text_muted)
	expand_btn.pressed.connect(_on_section_toggle.bind(section))
	header.add_child(expand_btn)
	
	# Spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	
	return section

func _apply_modern_styling() -> void:
	## Apply modern glassmorphism styling
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = THEME_COLORS.bg_primary
	panel_style.border_color = THEME_COLORS.border
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(12)
	
	# Shadow
	panel_style.shadow_size = 20
	panel_style.shadow_color = THEME_COLORS.shadow
	panel_style.shadow_offset = Vector2(0, 8)
	
	add_theme_stylebox_override("panel", panel_style)

func _setup_animations() -> void:
	## Setup entrance and interaction animations
	# Initial state
	modulate = Color.TRANSPARENT
	scale = Vector2(0.95, 0.95)
	
	# Entrance animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)

func _connect_signals() -> void:
	## Connect internal signals
	pass

func display_structure_info(structure_data: Dictionary) -> void:
	## Display structure information with modern formatting
	current_structure_data = structure_data
	
	# Update header
	title_label.text = structure_data.get("displayName", "Unknown Structure")
	
	# Update description
	_update_description(structure_data)
	
	# Update functions
	_update_functions(structure_data.get("functions", []))
	
	# Update clinical relevance
	_update_clinical(structure_data.get("clinicalRelevance", []))
	
	# Update related structures
	_update_related(structure_data.get("relatedStructures", []))

func _update_description(data: Dictionary) -> void:
	## Update description section
	var desc_label = description_container.get_child(1) as RichTextLabel
	if desc_label:
		var desc_text = data.get("shortDescription", "No description available.")
		var long_desc = data.get("detailedDescription", "")
		
		desc_label.clear()
		desc_label.append_text(desc_text)
		
		if long_desc != "":
			desc_label.append_text("\n\n")
			desc_label.push_color(THEME_COLORS.text_muted)
			desc_label.append_text(long_desc)
			desc_label.pop()

func _update_functions(functions: Array) -> void:
	## Update functions section
	# Clear existing
	for child in functions_container.get_children():
		if child.name != "Header":
			child.queue_free()
	
	if functions.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No functions listed"
		empty_label.add_theme_color_override("font_color", THEME_COLORS.text_muted)
		functions_container.add_child(empty_label)
		return
	
	# Add function items
	for function in functions:
		var item = _create_list_item("• " + function, THEME_COLORS.accent_secondary)
		functions_container.add_child(item)

func _update_clinical(clinical_data) -> void:
	## Update clinical relevance section
	# Clear existing
	for child in clinical_container.get_children():
		if child.name != "Header":
			child.queue_free()
	
	var clinical_text = ""
	if typeof(clinical_data) == TYPE_STRING:
		clinical_text = clinical_data
	elif typeof(clinical_data) == TYPE_ARRAY and not clinical_data.is_empty():
		clinical_text = "\n".join(clinical_data)
	
	if clinical_text.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No clinical data available"
		empty_label.add_theme_color_override("font_color", THEME_COLORS.text_muted)
		clinical_container.add_child(empty_label)
		return
	
	var clinical_label = RichTextLabel.new()
	clinical_label.fit_content = true
	clinical_label.bbcode_enabled = true
	clinical_label.add_theme_color_override("default_color", THEME_COLORS.text_secondary)
	clinical_label.text = clinical_text
	clinical_container.add_child(clinical_label)

func _update_related(related: Array) -> void:
	## Update related structures section
	# Clear existing
	for child in related_container.get_children():
		if child.name != "Header":
			child.queue_free()
	
	if related.is_empty():
		var empty_label = Label.new()
		empty_label.text = "No related structures"
		empty_label.add_theme_color_override("font_color", THEME_COLORS.text_muted)
		related_container.add_child(empty_label)
		return
	
	# Add related structure buttons
	for structure in related:
		var btn = Button.new()
		btn.text = structure
		btn.flat = true
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.add_theme_color_override("font_color", THEME_COLORS.accent)
		btn.add_theme_color_override("font_hover_color", THEME_COLORS.accent.lightened(0.2))
		btn.pressed.connect(_on_related_structure_clicked.bind(structure))
		related_container.add_child(btn)

func _create_list_item(text: String, color: Color) -> Label:
	## Create a styled list item
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", THEME_COLORS.text_secondary)
	label.add_theme_font_size_override("font_size", 14)
	return label

# Signal handlers
func _on_close_pressed() -> void:
	# Animate out
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.2)
	tween.tween_callback(func(): panel_closed.emit()).set_delay(0.2)

func _on_minimize_pressed() -> void:
	# Toggle minimize state
	is_expanded = !is_expanded
	
	if is_animating:
		return
	
	is_animating = true
	var tween = create_tween()
	
	if is_expanded:
		tween.tween_property(self, "custom_minimum_size:y", 500, 0.3).set_trans(Tween.TRANS_CUBIC)
		content_container.show()
	else:
		content_container.hide()
		tween.tween_property(self, "custom_minimum_size:y", 60, 0.3).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_callback(func(): is_animating = false)

func _on_bookmark_pressed() -> void:
	var structure_id = current_structure_data.get("id", "")
	if structure_id != "":
		bookmark_toggled.emit(structure_id, true)
		_show_bookmark_feedback()

func _show_bookmark_feedback() -> void:
	## Show bookmark animation feedback
	var star = Label.new()
	star.text = "⭐"
	star.add_theme_font_size_override("font_size", 24)
	star.position = Vector2(size.x / 2, 30)
	add_child(star)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(star, "position:y", -20, 0.5).set_trans(Tween.TRANS_BACK)
	tween.tween_property(star, "modulate", Color.TRANSPARENT, 0.5)
	tween.tween_callback(star.queue_free).set_delay(0.5)

func _on_section_toggle(section: Control) -> void:
	## Toggle section visibility
	var expand_btn = section.get_child(0).get_child(2) as Button
	var is_visible = true
	
	# Toggle visibility of all children except header
	for i in range(1, section.get_child_count()):
		var child = section.get_child(i)
		is_visible = !child.visible
		child.visible = is_visible
	
	# Update button text
	expand_btn.text = "▼" if is_visible else "▶"

func _on_related_structure_clicked(structure_name: String) -> void:
	structure_selected.emit(structure_name)
