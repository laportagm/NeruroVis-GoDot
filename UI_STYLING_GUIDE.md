# 🎨 NeuroVis UI Styling Guide

Transform your `main.tscn` scene with modern, professional styling using your existing theme system.

## 🚀 Quick Start (2 Minutes)

### Method 1: Add Enhanced Styling Script

1. **Open** `scenes/core/main.tscn` in Godot
2. **Add Child** to the root `MainScene` node → Choose "Node"
3. **Rename** the node to "EnhancedStyling"
4. **Attach Script** → Select `scenes/ui/EnhancedMainSceneStyling.gd`
5. **Run Scene** (F6) - Styling applies automatically!

### Method 2: Manual Theme Application

1. **Select** your panel nodes in the scene tree
2. **In Inspector** → Add "StyleBox Override"
3. **Apply** the styles below

---

## 🎯 What You'll Get

### ✨ Visual Improvements
- **Glassmorphism panels** with transparency and blur effects
- **Modern floating action buttons** with smooth animations
- **Enhanced typography** with proper sizing and shadows
- **Notification system** with slide-in animations
- **Hover effects** and smooth transitions
- **Professional shadows** and rounded corners

### 🎨 Two Theme Modes
- **Enhanced Mode**: Gaming/student-friendly with vibrant glassmorphism
- **Minimal Mode**: Clinical/professional with clean aesthetics

---

## 🔧 Component-by-Component Improvements

### 1. Object Name Label Enhancement

**Current**: Basic text label
**Enhanced**: Glassmorphism container with modern typography

```gdscript
# Automatic enhancement via EnhancedMainSceneStyling.gd
# OR manually apply these settings:

# Label Container
var container = PanelContainer.new()
var style = StyleBoxFlat.new()
style.bg_color = Color(15/255.0, 15/255.0, 23/255.0, 0.85)  # Dark glass
style.border_color = Color(0, 217/255.0, 1, 0.15)          # Cyan border
style.set_corner_radius_all(25)                            # Rounded
style.shadow_size = 10                                     # Drop shadow
container.add_theme_stylebox_override("panel", style)

# Label Typography
label.add_theme_font_size_override("font_size", 24)
label.add_theme_color_override("font_color", Color("#00D9FF"))  # Cyan text
```

### 2. Info Panel Modernization

**Current**: Basic panel container
**Enhanced**: Glassmorphism with animated entrance

```gdscript
# Apply via EnhancedMainSceneStyling.gd or manually:

var panel_style = StyleBoxFlat.new()
panel_style.bg_color = Color(15/255.0, 15/255.0, 23/255.0, 0.85)
panel_style.border_color = Color(0, 217/255.0, 1, 0.15)
panel_style.set_border_width_all(1)
panel_style.set_corner_radius_all(16)
panel_style.shadow_size = 8
panel_style.shadow_color = Color(0, 0, 0, 0.3)
structure_info_panel.add_theme_stylebox_override("panel", panel_style)
```

### 3. Model Control Panel Enhancement

**Current**: Plain control panel  
**Enhanced**: Modern styling with hover effects

```gdscript
# Same glassmorphism style as info panel
# Plus hover effects for interactivity
```

### 4. Floating Action Buttons (NEW!)

**Addition**: Modern FAB buttons for common actions

- 🎨 **Theme Toggle**: Switch between Enhanced/Minimal
- 👁 **Visibility Toggle**: Show/hide models
- 📱 **Screenshot**: Capture current view  
- ⚙️ **Settings**: Quick access to preferences

### 5. Notification System (NEW!)

**Addition**: Slide-in notifications for user feedback

- **Success notifications** (green) for completed actions
- **Info notifications** (blue) for general information  
- **Warning notifications** (orange) for cautions
- **Error notifications** (red) for problems

---

## 🎛️ Configuration Options

### Theme Modes

```gdscript
# Switch themes programmatically
enhanced_styling.apply_enhanced_mode()  # Glassmorphism + vibrant colors
enhanced_styling.apply_minimal_mode()   # Clean + professional
```

### Animation Controls

```gdscript
# Toggle animations
enhanced_styling.toggle_animations(true)   # Enable smooth transitions
enhanced_styling.toggle_animations(false)  # Disable for performance
```

### Effects Configuration

```gdscript
# In EnhancedMainSceneStyling.gd export variables:
@export var enable_glassmorphism: bool = true   # Glass effects
@export var enable_shadows: bool = true         # Drop shadows  
@export var enable_animations: bool = true      # Smooth transitions
```

---

## 🎨 Color Palette Reference

### Enhanced Theme (Gaming/Student)
```gdscript
# Backgrounds
panel_bg = Color(15, 15, 23, 0.85)      # Dark glass
border = Color(0, 217, 255, 0.15)       # Cyan border

# Text Colors  
text_heading = Color("#00D9FF")          # Cyan headings
text_body = Color("#E8E8E8")             # Light body text
text_accent = Color("#06FFA5")           # Green accent

# Action Colors
button_primary = Color("#00D9FF")        # Primary actions (cyan)
button_secondary = Color("#7209B7")      # Secondary actions (purple)
button_danger = Color("#FF073A")         # Danger actions (red)
```

### Minimal Theme (Clinical/Professional)
```gdscript
# Backgrounds
panel_bg = Color(255, 255, 255, 0.04)   # Subtle white glass
border = Color(255, 255, 255, 0.08)     # White border

# Text Colors
text_primary = Color("#FFFFFF")          # Pure white
text_secondary = Color(255, 255, 255, 0.85)  # White 85%
text_muted = Color(255, 255, 255, 0.3)       # White 30%
```

---

## 🚀 Advanced Customizations

### 1. Custom Button Styles

```gdscript
func create_custom_button(text: String, color: Color) -> Button:
    var button = Button.new()
    button.text = text
    
    var style = StyleBoxFlat.new()
    style.bg_color = color
    style.set_corner_radius_all(8)
    style.shadow_size = 4
    
    button.add_theme_stylebox_override("normal", style)
    return button
```

### 2. Animated Panel Transitions

```gdscript
func show_panel_with_animation(panel: Control):
    panel.modulate.a = 0.0
    panel.scale = Vector2(0.9, 0.9)
    
    var tween = create_tween()
    tween.set_parallel(true)
    tween.tween_property(panel, "modulate:a", 1.0, 0.3)
    tween.tween_property(panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)
```

### 3. Dynamic Glow Effects

```gdscript
func add_glow_effect(control: Control, glow_color: Color):
    var glow_style = StyleBoxFlat.new()
    glow_style.bg_color = Color.TRANSPARENT
    glow_style.border_color = glow_color
    glow_style.set_border_width_all(2)
    glow_style.set_corner_radius_all(8)
    
    # Apply on hover
    control.mouse_entered.connect(func(): 
        control.add_theme_stylebox_override("hover", glow_style)
    )
```

---

## 🔍 Debug & Testing

### Inspector Overrides (Quick Testing)

1. **Select** any panel in scene tree
2. **Inspector** → Theme Overrides → Styles  
3. **Add** "panel" override → Create new StyleBoxFlat
4. **Adjust** colors, corners, shadows in real-time

### Console Commands (F1 + Enter)

```bash
# Test styling commands (if EnhancedStyling script is added)
toggle_theme              # Switch Enhanced ↔ Minimal
show_notification("Test") # Test notification system
apply_enhanced_mode       # Force enhanced theme
apply_minimal_mode        # Force minimal theme
```

### Performance Testing

```gdscript
# Monitor performance impact
func _process(_delta):
    if Input.is_action_just_pressed("ui_home"):  # Home key
        print("FPS: ", Engine.get_frames_per_second())
        print("Memory: ", OS.get_static_memory_usage())
```

---

## 📱 Responsive Design Tips

### 1. Anchor-Based Layouts
```gdscript
# Use anchors for responsive positioning
control.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
control.position = Vector2(-80, -200)  # Offset from anchor
```

### 2. Size Flags
```gdscript
# Make components adapt to content
control.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
control.size_flags_vertical = Control.SIZE_EXPAND_FILL
```

### 3. Custom Minimum Sizes
```gdscript
# Ensure readability at all sizes
panel.custom_minimum_size = Vector2(300, 200)
```

---

## 🎯 Best Practices

### ✅ Do's
- **Use your existing UIThemeManager** for consistent colors
- **Apply animations gradually** to avoid overwhelming users
- **Test both theme modes** for different user preferences
- **Keep contrast ratios** above 4.5:1 for accessibility
- **Use size flags** for responsive layouts

### ❌ Don'ts  
- **Don't override every style** - be selective for best performance
- **Don't use too many animations** - can cause motion sickness
- **Don't ignore theme consistency** - stick to your color palette
- **Don't forget mobile considerations** - keep touch targets 44px+

---

## 🔄 Migration Path

### Phase 1: Quick Wins (Today)
1. Add `EnhancedMainSceneStyling.gd` to your scene
2. Test the automatic improvements
3. Adjust export variables to your preferences

### Phase 2: Custom Refinements (This Week)
1. Customize colors to match your brand
2. Add specific animations for key interactions
3. Create custom notification types

### Phase 3: Advanced Features (Future)
1. Implement theme persistence
2. Add accessibility options (high contrast, reduced motion)
3. Create component-specific styling systems

---

**Ready to enhance your UI?** Start with the `EnhancedMainSceneStyling.gd` script - it's the fastest way to see dramatic improvements in your scene's visual appeal!