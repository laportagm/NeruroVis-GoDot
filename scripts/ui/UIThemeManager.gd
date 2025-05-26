class_name UIThemeManager
extends Node

# Professional color palette
const COLORS = {
    "primary": Color("#00D9FF"),      # Cyan
    "secondary": Color("#FF006E"),    # Magenta  
    "success": Color("#06FFA5"),      # Green
    "warning": Color("#FFB700"),      # Amber
    "surface": Color("#1A1A2E"),      # Dark blue
    "surface_light": Color("#16213E"), # Lighter blue
    "text": Color("#FFFFFF"),         # White
    "text_secondary": Color("#B8BCC8") # Gray
}

# Create modern theme with glass morphism
static func create_modern_theme() -> Theme:
    var theme = Theme.new()
    
    # Glass panel style
    var panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color(COLORS.surface.r, COLORS.surface.g, COLORS.surface.b, 0.85)
    panel_style.border_width_left = 1
    panel_style.border_width_right = 1
    panel_style.border_width_top = 1
    panel_style.border_width_bottom = 1
    panel_style.border_color = Color(1, 1, 1, 0.1)
    panel_style.corner_radius_top_left = 12
    panel_style.corner_radius_top_right = 12
    panel_style.corner_radius_bottom_left = 12
    panel_style.corner_radius_bottom_right = 12
    panel_style.shadow_size = 20
    panel_style.shadow_color = Color(0, 0, 0, 0.3)
    panel_style.shadow_offset = Vector2(0, 8)
    
    # Modern button styling
    var button_normal = StyleBoxFlat.new()
    button_normal.bg_color = COLORS.primary
    button_normal.corner_radius_top_left = 8
    button_normal.corner_radius_top_right = 8
    button_normal.corner_radius_bottom_left = 8
    button_normal.corner_radius_bottom_right = 8
    button_normal.content_margin_left = 12
    button_normal.content_margin_right = 12
    button_normal.content_margin_top = 12
    button_normal.content_margin_bottom = 12
    
    var button_hover = button_normal.duplicate()
    button_hover.bg_color = COLORS.primary.lightened(0.1)
    button_hover.shadow_size = 4
    button_hover.shadow_color = COLORS.primary
    button_hover.shadow_offset = Vector2(0, 2)
    
    # Apply all styles
    theme.set_stylebox("panel", "PanelContainer", panel_style)
    theme.set_stylebox("normal", "Button", button_normal)
    theme.set_stylebox("hover", "Button", button_hover)
    theme.set_color("font_color", "Label", COLORS.text)
    theme.set_font_size("font_size", "Label", 14)
    
    return theme

# Smooth entrance animation for any control
static func animate_entrance(control: Control, delay: float = 0.0) -> void:
    control.modulate.a = 0
    control.scale = Vector2(0.9, 0.9)
    
    var tween = control.create_tween()
    if delay > 0:
        tween.tween_interval(delay)
    
    tween.set_parallel(true)
    tween.tween_property(control, "modulate:a", 1.0, 0.3).set_ease(Tween.EASE_OUT)
    tween.tween_property(control, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# Smooth exit animation
static func animate_exit(control: Control, duration: float = 0.2) -> void:
    var tween = control.create_tween()
    tween.set_parallel(true)
    tween.tween_property(control, "modulate:a", 0.0, duration)
    tween.tween_property(control, "scale", Vector2(0.9, 0.9), duration)
    tween.tween_callback(control.queue_free)

# Pulse animation for highlights
static func animate_pulse(control: Control, color: Color = COLORS.primary) -> void:
    var original_modulate = control.modulate
    var tween = control.create_tween()
    tween.set_loops()
    tween.tween_property(control, "modulate", color, 0.5).set_ease(Tween.EASE_IN_OUT)
    tween.tween_property(control, "modulate", original_modulate, 0.5).set_ease(Tween.EASE_IN_OUT)