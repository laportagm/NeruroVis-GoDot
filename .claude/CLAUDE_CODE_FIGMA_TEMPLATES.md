# Claude Code Prompt Templates for Figma Integration

## 🎨 Design Token Implementation

### Template 1: Parse and Implement Design Tokens
```
I have a Figma design export at [PATH_TO_JSON]. Please:

1. Parse the design tokens including:
   - Color palette (with opacity values)
   - Typography scale (size, weight, line-height)
   - Spacing system
   - Animation timings

2. Update my UIThemeManager.gd to include these tokens as constants

3. Create helper methods for:
   - Applying glass morphism effects
   - Setting responsive typography
   - Managing animation curves

4. Ensure backward compatibility with existing color constants

Focus on creating a scalable system that other components can use.
```

### Template 2: Component Enhancement from Figma
```
Based on this Figma component design [DESCRIBE OR ATTACH SCREENSHOT]:

Component: [COMPONENT_NAME]
Current file: [CURRENT_FILE_PATH]

Enhance with:
- Glass morphism: [BLUR_AMOUNT]px blur, [OPACITY]% background
- Responsive behavior: [BREAKPOINT_RULES]
- Animations: [ENTRANCE/EXIT/HOVER_SPECS]
- New features: [LIST_FEATURES]

Maintain existing functionality while adding these professional touches.
```

## 🔧 Responsive Layout System

### Template 3: Create Responsive Manager
```
Create a ResponsiveLayoutManager for Godot based on these Figma breakpoints:
- Mobile: < 768px
- Tablet: 768-1024px  
- Desktop: > 1024px

The manager should:
1. Detect current breakpoint
2. Calculate panel widths (percentages from Figma)
3. Handle position updates on resize
4. Emit signals for breakpoint changes
5. Support these panel types: [info, control, navigation]

Make it reusable across all UI components.
```

## ✨ Animation Implementation

### Template 4: Figma Animation Specs to Code
```
Implement these Figma animation specifications:

Entrance:
- Duration: [X]s
- Easing: [CURVE_NAME or cubic-bezier]
- Properties: [opacity, scale, position]

Hover:
- Duration: [X]s  
- Scale: [X]
- Color shift: [HEX_VALUE]

Interactions:
- Button press: scale to [X] for [X]s
- Section toggle: rotate indicator [X]deg
- List item hover: translate [X]px

Apply consistently across all interactive elements.
```

## 🏗️ Component Architecture

### Template 5: Reusable Component from Figma Pattern
```
Create a reusable [COMPONENT_TYPE] component based on this Figma pattern:

Base class: [GlassPanel/Card/Button/etc]
Exports:
- @export var property_name: type = default

Required features:
- Configurable styling via exports
- Built-in animations
- Responsive sizing
- Signal emissions for interactions
- Theme override support

Example usage should be:
```gdscript
var component = ComponentClass.new()
component.property = value
add_child(component)
```
```

## 🔄 Integration Workflow

### Template 6: Integrate Enhanced Component
```
Help me integrate [ENHANCED_COMPONENT] into my existing project:

Current setup:
- Main scene: [PATH]
- Signals connected: [LIST]
- Data source: [MANAGER/CONTROLLER]

Integration needs:
1. Replace old component with enhanced version
2. Reconnect all signals
3. Update data binding
4. Test all interactions
5. Handle edge cases

Preserve all existing functionality while adding improvements.
```

## 🐛 Debugging and Optimization

### Template 7: Performance Optimization
```
The [COMPONENT] with Figma glass morphism is causing performance issues:

Symptoms:
- FPS drops when [CONDITION]
- Stuttering during [ANIMATION]
- Memory usage increases when [ACTION]

Please optimize while maintaining visual quality:
1. Analyze performance bottlenecks
2. Optimize shader/style calculations
3. Implement efficient update patterns
4. Add performance toggles for low-end devices
```

## 📚 Documentation

### Template 8: Generate Component Documentation
```
Create comprehensive documentation for [COMPONENT] including:

1. **Overview**: Purpose and design philosophy
2. **Design Tokens**: List all Figma values used
3. **Properties**: Exported variables and their effects
4. **Methods**: Public API
5. **Signals**: Emitted signals and when
6. **Usage Examples**: Common implementation patterns
7. **Responsive Behavior**: Breakpoint handling
8. **Accessibility**: Keyboard nav and screen reader support

Format as markdown with code examples.
```

## 🎯 Quick Prompts

### One-Liners for Common Tasks:

```bash
# Extract colors from Figma JSON
"Extract all color values from info-panel-design-spec.json and create Color constants"

# Add hover effect
"Add Figma-style hover effect: 1.05 scale, 0.15s duration, ease-out"

# Make responsive
"Make this panel responsive: 25% desktop, 40% tablet, 90% mobile"

# Add animation
"Add smooth entrance animation: fade + scale from 0.95 to 1.0 over 0.4s"

# Fix performance
"Optimize this glass morphism effect for better FPS without losing visual quality"
```

## 💡 Best Practices

1. **Always include context**: Current file paths, component names
2. **Specify exact values**: From your Figma exports when possible
3. **Request explanations**: "Explain why..." to understand changes
4. **Test incrementally**: "First, let's just update the colors..."
5. **Keep backups**: "Before making changes, create a backup..."

## 🚀 Complete Workflow Example

```bash
# 1. Start with design tokens
claude "Parse .claude/figma-exports/info-panel-design-spec.json and update UIThemeManager.gd with all design tokens"

# 2. Enhance specific component
claude "Using the design tokens, enhance ui_info_panel.gd with responsive layout and animations"

# 3. Test and fix
./quick_test.sh
claude "The hover effect is too aggressive, make it subtler"

# 4. Apply to other components  
claude "Apply the same design system to model_control_panel.gd"

# 5. Document
claude "Create a style guide documenting all the new design tokens and how to use them"
```

Save these templates and customize them for your specific needs!
