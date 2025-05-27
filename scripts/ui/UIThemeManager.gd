# Modern UI Theme Manager for NeuroVis
# Provides consistent styling and theming across the application
class_name UIThemeManager
extends RefCounted

# Modern glass morphism color palette
const COLORS = {
	"primary": Color("#00D9FF"),        # Cyan for primary actions
	"secondary": Color("#FF006E"),      # Magenta for secondary elements
	"success": Color("#06FFA5"),        # Green for success states
	"warning": Color("#FFB800"),        # Orange for warnings
	"error": Color("#FF073A"),          # Red for errors
	"info": Color("#7209B7"),           # Purple for information
	"background": Color("#0A0A0F", 0.9), # Dark background with transparency
	"surface": Color("#1A1A2E", 0.8),   # Surface color for panels
	"text_primary": Color("#FFFFFF"),    # Primary text color
	"text_secondary": Color("#B0B0C0"),  # Secondary text color
	"border": Color("#FFFFFF", 0.1),     # Border color
	"shadow": Color("#000000", 0.3)      # Shadow color
}

# Typography scale
const FONT_SIZES = {
	"display": 32,      # Large headings
	"h1": 24,          # Main headings
	"h2": 20,          # Section headings
	"h3": 18,          # Subsection headings
	"body": 14,        # Body text
	"caption": 12,     # Small text
	"tiny": 10         # Very small text
}

# Legacy constants for compatibility
const FONT_SIZE_LARGE = 24
const FONT_SIZE_MEDIUM = 16
const FONT_SIZE_SMALL = 12
const FONT_SIZE_TINY = 10
const FONT_SIZE_H = 20

# Color constants (accent colors)
const ACCENT_BLUE = Color("#00D9FF")     # Primary cyan/blue
const ACCENT_CYAN = Color("#00D9FF")     # Same as primary
const ACCENT_GREEN = Color("#06FFA5")    # Success green
const ACCENT_ORANGE = Color("#FFB800")   # Warning orange
const ACCENT_PINK = Color("#FF006E")     # Secondary magenta/pink
const ACCENT_PURPLE = Color("#7209B7")   # Info purple
const ACCENT_RED = Color("#FF073A")      # Error red

# Text color constants
const TEXT_PRIMARY = Color("#FFFFFF")    # Primary text
const TEXT_SECONDARY = Color("#B0B0C0")  # Secondary text

# Margin constants
const MARGIN_TINY = 4
const MARGIN_SMALL = 8
const MARGIN_MEDIUM = 16
const MARGIN_LARGE = 24

# Additional color constants
const ACCENT_TEAL = Color("#00BCD4")     # Teal
const ACCENT_YELLOW = Color("#FFD700")   # Yellow/Gold
const FONT_SIZE_H2 = 20                  # H2 font size
const FONT_SIZE_H3 = 18                  # H3 font size

# Additional text colors
const TEXT_ACCENT = Color("#00D9FF")     # Accent text color
const TEXT_TERTIARY = Color("#808080")   # Tertiary text color
const TEXT_DISABLED = Color("#606060")   # Disabled text color

# Standard margin constant
const MARGIN_STANDARD = 16              # Standard margin (same as MEDIUM)

# Animation durations (in seconds)
const ANIMATION = {
	"fast": 0.15,      # Quick transitions
	"normal": 0.25,    # Standard transitions
	"slow": 0.4,       # Deliberate transitions
	"very_slow": 0.6   # Emphasis transitions
}

# Legacy animation duration constants
const ANIM_DURATION_FAST = 0.15
const ANIM_DURATION_STANDARD = 0.25
const ANIM_DURATION_SLOW = 0.4

# Create a glass morphism style box
static func create_glass_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = COLORS.surface
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_color = COLORS.border
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.shadow_size = 16
	style.shadow_color = COLORS.shadow
	style.shadow_offset = Vector2(0, 4)
	return style

# Create a button style
static func create_button_style(color: Color = COLORS.primary) -> StyleBoxFlat:
	var style = create_glass_style()
	style.bg_color = color
	style.bg_color.a = 0.8
	return style

# Create a panel style
static func create_panel_style() -> StyleBoxFlat:
	return create_glass_style()

# Apply theme to a Control node
static func apply_theme_to_control(control: Control) -> void:
	if not control:
		return
	
	var theme = Theme.new()
	
	# Apply panel style if it's a Panel or PanelContainer
	if control is Panel or control is PanelContainer:
		theme.set_stylebox("panel", "Panel", create_panel_style())
	
	# Apply button styles if it's a Button
	if control is Button:
		theme.set_stylebox("normal", "Button", create_button_style())
		theme.set_stylebox("hover", "Button", create_button_style(COLORS.primary.lightened(0.2)))
		theme.set_stylebox("pressed", "Button", create_button_style(COLORS.primary.darkened(0.2)))
	
	control.theme = theme

# Create a modern label with proper styling
static func create_styled_label(text: String, font_size_key: String = "body") -> Label:
	var label = Label.new()
	label.text = text
	label.add_theme_color_override("font_color", COLORS.text_primary)
	if FONT_SIZES.has(font_size_key):
		label.add_theme_font_size_override("font_size", FONT_SIZES[font_size_key])
	return label

# Create animated entrance effect (enhanced version with multiple signatures)
static func animate_entrance(control: Control, param1 = null, param2 = null, param3 = null) -> void:
	if not control:
		return
	
	var delay: float = 0.0
	var duration: float = ANIMATION.normal
	var _anim_type: String = "fade_scale"
	
	# Handle different parameter patterns
	if param1 != null and param2 != null and param3 != null:
		# 4 parameters: animate_entrance(control, delay, duration, type)
		delay = float(param1) if param1 is float or param1 is int else 0.0
		duration = float(param2) if param2 is float or param2 is int else ANIMATION.normal
		_anim_type = str(param3) if param3 is String else "fade_scale"
	elif param1 != null and param2 != null:
		# 3 parameters: animate_entrance(control, delay, duration)
		delay = float(param1) if param1 is float or param1 is int else 0.0
		duration = float(param2) if param2 is float or param2 is int else ANIMATION.normal
	elif param1 != null:
		# 2 parameters: animate_entrance(control, duration)
		duration = float(param1) if param1 is float or param1 is int else ANIMATION.normal
	
	# Start invisible and small
	control.modulate = Color.TRANSPARENT
	control.scale = Vector2(0.8, 0.8)
	
	# Create tween with delay
	var tween = control.create_tween()
	tween.set_parallel(true)
	
	# Apply delay if specified
	if delay > 0.0:
		tween.tween_callback(func(): pass).set_delay(delay)
	
	# Animate to visible and normal size
	tween.tween_property(control, "modulate", Color.WHITE, duration)
	tween.tween_property(control, "scale", Vector2.ONE, duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Create animated exit effect (enhanced version with multiple signatures)
static func animate_exit(control: Control, param1 = null, param2 = null) -> void:
	if not control:
		return
	
	var duration: float = ANIMATION.fast
	var _anim_type: String = "fade_scale"
	
	# Handle different parameter patterns
	if param1 != null and param2 != null:
		# 3 parameters: animate_exit(control, duration, type)
		duration = float(param1) if param1 is float or param1 is int else ANIMATION.fast
		_anim_type = str(param2) if param2 is String else "fade_scale"
	elif param1 != null:
		# 2 parameters: animate_exit(control, duration)
		duration = float(param1) if param1 is float or param1 is int else ANIMATION.fast
	
	var tween = control.create_tween()
	tween.set_parallel(true)
	tween.tween_property(control, "modulate", Color.TRANSPARENT, duration)
	tween.tween_property(control, "scale", Vector2(0.8, 0.8), duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(control.queue_free).set_delay(duration)

# Create hover effect for interactive elements
static func add_hover_effect(control: Control) -> void:
	if not control:
		return
	
	control.mouse_entered.connect(func(): _animate_hover_in(control))
	control.mouse_exited.connect(func(): _animate_hover_out(control))

static func _animate_hover_in(control: Control) -> void:
	var tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2(1.05, 1.05), ANIMATION.fast).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

static func _animate_hover_out(control: Control) -> void:
	var tween = control.create_tween()
	tween.tween_property(control, "scale", Vector2.ONE, ANIMATION.fast).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# Get color by name
static func get_color(color_name: String) -> Color:
	return COLORS.get(color_name, COLORS.text_primary)

# Get font size by name
static func get_font_size(size_name: String) -> int:
	return FONT_SIZES.get(size_name, FONT_SIZES.body)

# Get animation duration by name
static func get_animation_duration(duration_name: String) -> float:
	return ANIMATION.get(duration_name, ANIMATION.normal)

# Additional styling methods for enhanced UI components
static func apply_glass_panel(control: Control, opacity: float = 0.9, _style_type: String = "default") -> void:
	if not control:
		return
	
	var style = create_glass_style()
	style.bg_color.a = opacity
	
	if control is Panel or control is PanelContainer:
		control.add_theme_stylebox_override("panel", style)

static func apply_modern_label(label: Label, font_size: int, color: Color, _style_type: String = "default") -> void:
	if not label:
		return
	
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)

static func apply_modern_button(button: Button, color: Color, _style_type: String = "default") -> void:
	if not button:
		return
	
	var style = create_button_style(color)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", create_button_style(color.lightened(0.2)))
	button.add_theme_stylebox_override("pressed", create_button_style(color.darkened(0.2)))

static func apply_rich_text_styling(rich_text: RichTextLabel, font_size: int, style_type: String = "default") -> void:
	if not rich_text:
		return
	
	rich_text.add_theme_font_size_override("normal_font_size", font_size)
	rich_text.add_theme_color_override("default_color", TEXT_PRIMARY)

# Animate text change with fade transition
static func animate_fade_text_change(label: Label, new_text: String, duration: float = ANIMATION.normal) -> void:
	if not label:
		return
	
	var tween = label.create_tween()
	tween.set_parallel(false)
	
	# Fade out current text
	tween.tween_property(label, "modulate:a", 0.0, duration * 0.5)
	
	# Change text and fade in
	tween.tween_callback(func(): label.text = new_text)
	tween.tween_property(label, "modulate:a", 1.0, duration * 0.5)

# Advanced animation methods for enhanced UI
static func animate_button_press(button: Button, color: Color) -> void:
	if not button:
		return
	
	var tween = button.create_tween()
	tween.set_parallel(true)
	
	# Quick scale and color pulse
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(button, "modulate", color, 0.1)
	
	# Return to normal with chained animations
	tween.tween_property(button, "scale", Vector2.ONE, 0.1).set_delay(0.1)
	tween.tween_property(button, "modulate", Color.WHITE, 0.1).set_delay(0.1)

static func animate_hover_glow(control: Control, color: Color, intensity: float = 0.2) -> void:
	if not control:
		return
	
	var tween = control.create_tween()
	var glow_color = color
	glow_color.a = intensity
	tween.tween_property(control, "modulate", glow_color, ANIMATION.fast)

static func animate_hover_glow_off(control: Control) -> void:
	if not control:
		return
	
	var tween = control.create_tween()
	tween.tween_property(control, "modulate", Color.WHITE, ANIMATION.fast)

# Enhanced styling methods
static func apply_search_field_styling(line_edit: LineEdit, placeholder: String = "") -> void:
	if not line_edit:
		return
	
	var style = StyleBoxFlat.new()
	style.bg_color = COLORS.surface
	style.border_color = COLORS.border
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	
	line_edit.add_theme_stylebox_override("normal", style)
	line_edit.add_theme_color_override("font_color", TEXT_PRIMARY)
	if placeholder != "":
		line_edit.placeholder_text = placeholder

static func apply_progress_bar_styling(progress_bar: ProgressBar, color: Color = ACCENT_BLUE) -> void:
	if not progress_bar:
		return
	
	# Background style
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(color.r, color.g, color.b, 0.2)
	bg_style.corner_radius_top_left = 4
	bg_style.corner_radius_top_right = 4
	bg_style.corner_radius_bottom_left = 4
	bg_style.corner_radius_bottom_right = 4
	
	# Fill style
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.corner_radius_top_left = 4
	fill_style.corner_radius_top_right = 4
	fill_style.corner_radius_bottom_left = 4
	fill_style.corner_radius_bottom_right = 4
	
	progress_bar.add_theme_stylebox_override("background", bg_style)
	progress_bar.add_theme_stylebox_override("fill", fill_style)

static func create_educational_card_style(style_type: String = "default") -> StyleBoxFlat:
	var style = create_glass_style()
	
	match style_type:
		"info":
			style.bg_color = Color(ACCENT_BLUE.r, ACCENT_BLUE.g, ACCENT_BLUE.b, 0.1)
			style.border_color = ACCENT_BLUE
		"success":
			style.bg_color = Color(ACCENT_GREEN.r, ACCENT_GREEN.g, ACCENT_GREEN.b, 0.1)
			style.border_color = ACCENT_GREEN
		"warning":
			style.bg_color = Color(ACCENT_ORANGE.r, ACCENT_ORANGE.g, ACCENT_ORANGE.b, 0.1)
			style.border_color = ACCENT_ORANGE
		_:
			style.bg_color = COLORS.surface
			style.border_color = COLORS.border
	
	return style

static func create_learning_progress_indicator(_current_progress: float, total_items: int, completed_items: int) -> Dictionary:
	var percentage = (float(completed_items) / float(total_items)) * 100.0 if total_items > 0 else 0.0
	
	var color = ACCENT_RED
	if percentage >= 75.0:
		color = ACCENT_GREEN
	elif percentage >= 50.0:
		color = ACCENT_ORANGE
	elif percentage >= 25.0:
		color = ACCENT_YELLOW
	
	return {
		"percentage": percentage,
		"color": color,
		"completed": completed_items,
		"total": total_items
	}