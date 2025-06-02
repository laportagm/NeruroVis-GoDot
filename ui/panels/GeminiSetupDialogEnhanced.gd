extends Control
class_name GeminiSetupDialogEnhanced

# UI References
@onready var backdrop: Panel
@onready var dialog_panel: PanelContainer
@onready var title_label: Label
@onready var subtitle_label: Label
@onready var api_key_input: LineEdit
@onready var get_started_button: Button
@onready var skip_button: Button
@onready var help_button: Button
@onready var progress_indicator: Control

# State
var is_validating: bool = false
var animation_tween: Tween

# Theme colors
const THEME_COLORS = {
	"primary": Color("#00D9FF"),      # Cyan
	"secondary": Color("#06FFA5"),    # Green
	"accent": Color("#7209B7"),       # Purple
	"danger": Color("#FF073A"),       # Red
	"warning": Color("#FFB800"),      # Orange
	"background": Color(0.05, 0.05, 0.08, 0.98),
	"surface": Color(0.08, 0.08, 0.12, 0.95),
	"text_primary": Color("#FFFFFF"),
	"text_secondary": Color("#B0B0C0"),
	"text_muted": Color("#808090")
}

# Signals
signal setup_completed
signal setup_cancelled

func _ready() -> void:
	# Set full screen
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# Create UI
	_create_ui()
	
	# Apply styling
	_apply_modern_styling()
	
	# Setup animations
	_animate_entrance()
	
	# Connect signals
	_connect_signals()
	
	# Focus on input
	call_deferred("_focus_input")

func _create_ui() -> void:
	## Create the modern UI structure
	
	# Dark backdrop
	backdrop = Panel.new()
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.modulate = Color(1, 1, 1, 0.8)
	var backdrop_style = StyleBoxFlat.new()
	backdrop_style.bg_color = Color(0, 0, 0, 0.7)
	backdrop.add_theme_stylebox_override("panel", backdrop_style)
	add_child(backdrop)
	
	# Main dialog panel
	dialog_panel = PanelContainer.new()
	dialog_panel.custom_minimum_size = Vector2(500, 400)
	dialog_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	add_child(dialog_panel)
	
	# Content container
	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	dialog_panel.add_child(content)
	
	# Header section
	_create_header(content)
	
	# Input section
	_create_input_section(content)
	
	# Action buttons
	_create_action_buttons(content)
	
	# Progress indicator
	_create_progress_indicator()

func _create_header(parent: Control) -> void:
	## Create the header section
	var header_container = VBoxContainer.new()
	header_container.add_theme_constant_override("separation", 8)
	parent.add_child(header_container)
	
	# Logo/Icon
	var icon_container = CenterContainer.new()
	header_container.add_child(icon_container)
	
	var icon_label = Label.new()
	icon_label.text = "🤖"
	icon_label.add_theme_font_size_override("font_size", 48)
	icon_container.add_child(icon_label)
	
	# Title
	title_label = Label.new()
	title_label.text = "Connect to Gemini"
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", THEME_COLORS.text_primary)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header_container.add_child(title_label)
	
	# Subtitle
	subtitle_label = Label.new()
	subtitle_label.text = "Set up Google's Gemini AI in 3 simple steps:\n1. Get an API key from Google\n2. Enter your key\n3. Start learning with AI assistance"
	subtitle_label.add_theme_font_size_override("font_size", 14)
	subtitle_label.add_theme_color_override("font_color", THEME_COLORS.text_secondary)
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	header_container.add_child(subtitle_label)

func _create_input_section(parent: Control) -> void:
	## Create the API key input section
	var input_container = VBoxContainer.new()
	input_container.add_theme_constant_override("separation", 12)
	parent.add_child(input_container)
	
	# Input label
	var input_label = Label.new()
	input_label.text = "API Key"
	input_label.add_theme_font_size_override("font_size", 14)
	input_label.add_theme_color_override("font_color", THEME_COLORS.text_secondary)
	input_container.add_child(input_label)
	
	# Input field container
	var field_container = HBoxContainer.new()
	field_container.add_theme_constant_override("separation", 12)
	input_container.add_child(field_container)
	
	# API key input
	api_key_input = LineEdit.new()
	api_key_input.placeholder_text = "Enter your Gemini API key..."
	api_key_input.secret = true
	api_key_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	api_key_input.custom_minimum_size.y = 48
	field_container.add_child(api_key_input)
	
	# Toggle visibility button
	var visibility_btn = Button.new()
	visibility_btn.text = "👁"
	visibility_btn.tooltip_text = "Show/Hide API key"
	visibility_btn.custom_minimum_size = Vector2(48, 48)
	visibility_btn.flat = true
	visibility_btn.pressed.connect(_on_visibility_toggle)
	field_container.add_child(visibility_btn)
	
	# Help text
	var help_container = HBoxContainer.new()
	input_container.add_child(help_container)
	
	var help_icon = Label.new()
	help_icon.text = "ℹ️"
	help_icon.add_theme_font_size_override("font_size", 12)
	help_container.add_child(help_icon)
	
	var help_text = Label.new()
	help_text.text = "Don't have an API key? "
	help_text.add_theme_font_size_override("font_size", 12)
	help_text.add_theme_color_override("font_color", THEME_COLORS.text_muted)
	help_container.add_child(help_text)
	
	# Get key link
	help_button = Button.new()
	help_button.text = "Get one from Google"
	help_button.flat = true
	help_button.add_theme_font_size_override("font_size", 12)
	help_button.add_theme_color_override("font_color", THEME_COLORS.primary)
	help_button.add_theme_color_override("font_hover_color", THEME_COLORS.primary.lightened(0.2))
	help_container.add_child(help_button)

func _create_action_buttons(parent: Control) -> void:
	## Create action buttons
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	parent.add_child(spacer)
	
	var button_container = HBoxContainer.new()
	button_container.add_theme_constant_override("separation", 12)
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(button_container)
	
	# Skip button
	skip_button = Button.new()
	skip_button.text = "Skip for now"
	skip_button.custom_minimum_size = Vector2(120, 48)
	skip_button.flat = true
	button_container.add_child(skip_button)
	
	# Get Started button
	get_started_button = Button.new()
	get_started_button.text = "Let's Get Started"
	get_started_button.custom_minimum_size = Vector2(180, 48)
	get_started_button.disabled = true
	button_container.add_child(get_started_button)

func _create_progress_indicator() -> void:
	## Create progress indicator for validation
	progress_indicator = Control.new()
	progress_indicator.visible = false
	progress_indicator.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dialog_panel.add_child(progress_indicator)
	
	var progress_bg = Panel.new()
	progress_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	progress_bg.modulate = Color(0, 0, 0, 0.8)
	var pg_style = StyleBoxFlat.new()
	pg_style.bg_color = Color.WHITE
	progress_bg.add_theme_stylebox_override("panel", pg_style)
	progress_indicator.add_child(progress_bg)
	
	var spinner_container = CenterContainer.new()
	spinner_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	progress_indicator.add_child(spinner_container)
	
	var spinner = Label.new()
	spinner.text = "⚡"
	spinner.add_theme_font_size_override("font_size", 48)
	spinner.add_theme_color_override("font_color", THEME_COLORS.primary)
	spinner_container.add_child(spinner)
	
	# Animate spinner
	var spin_tween = create_tween()
	spin_tween.set_loops()
	spin_tween.tween_property(spinner, "rotation", TAU, 1.0)

func _apply_modern_styling() -> void:
	## Apply modern glassmorphism styling
	
	# Dialog panel style
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = THEME_COLORS.surface
	panel_style.border_color = THEME_COLORS.primary
	panel_style.border_color.a = 0.2
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(16)
	panel_style.shadow_size = 32
	panel_style.shadow_color = Color(0, 0, 0, 0.5)
	panel_style.shadow_offset = Vector2(0, 12)
	panel_style.set_content_margin_all(32)
	dialog_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Input field style
	var input_style = StyleBoxFlat.new()
	input_style.bg_color = THEME_COLORS.background
	input_style.border_color = THEME_COLORS.primary
	input_style.border_color.a = 0.3
	input_style.set_border_width_all(1)
	input_style.set_corner_radius_all(8)
	input_style.set_content_margin_all(12)
	
	var input_style_focus = input_style.duplicate()
	input_style_focus.border_color = THEME_COLORS.primary
	input_style_focus.border_color.a = 0.8
	input_style_focus.border_width_left = 2
	input_style_focus.border_width_right = 2
	input_style_focus.border_width_top = 2
	input_style_focus.border_width_bottom = 2
	
	api_key_input.add_theme_stylebox_override("normal", input_style)
	api_key_input.add_theme_stylebox_override("focus", input_style_focus)
	api_key_input.add_theme_color_override("font_color", THEME_COLORS.text_primary)
	api_key_input.add_theme_color_override("font_placeholder_color", THEME_COLORS.text_muted)
	api_key_input.add_theme_font_size_override("font_size", 16)
	
	# Get Started button style
	var btn_style = StyleBoxFlat.new()
	btn_style.bg_color = THEME_COLORS.primary
	btn_style.set_corner_radius_all(24)
	btn_style.set_content_margin_all(16)
	
	var btn_style_hover = btn_style.duplicate()
	btn_style_hover.bg_color = THEME_COLORS.primary.lightened(0.1)
	
	var btn_style_pressed = btn_style.duplicate()
	btn_style_pressed.bg_color = THEME_COLORS.primary.darkened(0.1)
	
	var btn_style_disabled = btn_style.duplicate()
	btn_style_disabled.bg_color = THEME_COLORS.text_muted
	btn_style_disabled.bg_color.a = 0.3
	
	get_started_button.add_theme_stylebox_override("normal", btn_style)
	get_started_button.add_theme_stylebox_override("hover", btn_style_hover)
	get_started_button.add_theme_stylebox_override("pressed", btn_style_pressed)
	get_started_button.add_theme_stylebox_override("disabled", btn_style_disabled)
	get_started_button.add_theme_color_override("font_color", Color.WHITE)
	get_started_button.add_theme_color_override("font_disabled_color", THEME_COLORS.text_muted)
	get_started_button.add_theme_font_size_override("font_size", 16)
	
	# Skip button style
	skip_button.add_theme_color_override("font_color", THEME_COLORS.text_secondary)
	skip_button.add_theme_color_override("font_hover_color", THEME_COLORS.text_primary)
	skip_button.add_theme_font_size_override("font_size", 14)

func _animate_entrance() -> void:
	## Animate dialog entrance
	# Initial state
	backdrop.modulate = Color.TRANSPARENT
	dialog_panel.scale = Vector2(0.9, 0.9)
	dialog_panel.modulate = Color.TRANSPARENT
	
	# Animate
	animation_tween = create_tween()
	animation_tween.set_parallel(true)
	animation_tween.tween_property(backdrop, "modulate", Color.WHITE, 0.3)
	animation_tween.tween_property(dialog_panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK)
	animation_tween.tween_property(dialog_panel, "modulate", Color.WHITE, 0.3)

func _connect_signals() -> void:
	## Connect UI signals
	api_key_input.text_changed.connect(_on_api_key_changed)
	api_key_input.text_submitted.connect(_on_api_key_submitted)
	get_started_button.pressed.connect(_on_get_started_pressed)
	skip_button.pressed.connect(_on_skip_pressed)
	help_button.pressed.connect(_on_help_pressed)
	
	# Close on backdrop click
	backdrop.gui_input.connect(_on_backdrop_input)

func _focus_input() -> void:
	api_key_input.grab_focus()

# Signal handlers
func _on_api_key_changed(text: String) -> void:
	# Enable/disable button based on input
	get_started_button.disabled = text.strip_edges().is_empty()
	
	# Visual feedback for valid key format
	if text.length() > 30:  # Rough check for API key length
		api_key_input.modulate = Color.WHITE
	else:
		api_key_input.modulate = Color(1, 1, 1, 0.8)

func _on_api_key_submitted(text: String) -> void:
	if not text.strip_edges().is_empty():
		_on_get_started_pressed()

func _on_get_started_pressed() -> void:
	if is_validating:
		return
	
	var api_key = api_key_input.text.strip_edges()
	if api_key.is_empty():
		return
	
	# Show progress
	is_validating = true
	progress_indicator.visible = true
	get_started_button.disabled = true
	
	# Validate and save key
	_validate_and_save_key(api_key)

func _validate_and_save_key(api_key: String) -> void:
	## Validate and save the API key
	var gemini_service = get_node_or_null("/root/GeminiAI")
	if not gemini_service:
		_show_error("Gemini service not available")
		return
	
	# Save the key
	if gemini_service.has_method("set_api_key"):
		gemini_service.set_api_key(api_key)
		
		# Test the key with a simple request
		if gemini_service.has_method("test_connection"):
			var result = await gemini_service.test_connection()
			
			if result:
				# Success
				_on_setup_success()
			else:
				_show_error("Invalid API key. Please check and try again.")
		else:
			# No test method, assume success
			_on_setup_success()
	else:
		_show_error("Cannot save API key")

func _on_setup_success() -> void:
	## Handle successful setup
	progress_indicator.visible = false
	
	# Success animation
	var success_label = Label.new()
	success_label.text = "✓ Success!"
	success_label.add_theme_font_size_override("font_size", 24)
	success_label.add_theme_color_override("font_color", THEME_COLORS.secondary)
	success_label.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	dialog_panel.add_child(success_label)
	
	# Animate and close
	var tween = create_tween()
	tween.tween_property(success_label, "scale", Vector2(1.2, 1.2), 0.3).set_trans(Tween.TRANS_BACK)
	tween.tween_interval(0.5)
	tween.tween_callback(_close_dialog.bind(true))

func _show_error(message: String) -> void:
	## Show error message
	is_validating = false
	progress_indicator.visible = false
	get_started_button.disabled = false
	
	# Show error notification
	var error_label = Label.new()
	error_label.text = message
	error_label.add_theme_color_override("font_color", THEME_COLORS.danger)
	error_label.add_theme_font_size_override("font_size", 12)
	error_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	error_label.position.y = -60
	error_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialog_panel.add_child(error_label)
	
	# Auto remove after 3 seconds
	await get_tree().create_timer(3.0).timeout
	error_label.queue_free()

func _on_skip_pressed() -> void:
	_close_dialog(false)

func _on_help_pressed() -> void:
	# Open Google AI Studio in browser
	OS.shell_open("https://makersuite.google.com/app/apikey")

func _on_visibility_toggle() -> void:
	api_key_input.secret = !api_key_input.secret

func _on_backdrop_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_close_dialog(false)

func _close_dialog(success: bool) -> void:
	## Close dialog with animation
	if animation_tween:
		animation_tween.kill()
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dialog_panel, "scale", Vector2(0.9, 0.9), 0.2)
	tween.tween_property(dialog_panel, "modulate", Color.TRANSPARENT, 0.2)
	tween.tween_property(backdrop, "modulate", Color.TRANSPARENT, 0.3)
	
	if success:
		tween.tween_callback(func(): setup_completed.emit()).set_delay(0.3)
	else:
		tween.tween_callback(func(): setup_cancelled.emit()).set_delay(0.3)
	
	tween.tween_callback(queue_free).set_delay(0.3)
