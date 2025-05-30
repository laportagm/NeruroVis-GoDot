# GeminiSetupDialog.gd
# Setup dialog for Google Gemini AI configuration in NeuroVis
class_name GeminiSetupDialog
extends Control

# === SIGNALS ===
signal setup_completed(successful: bool, api_key: String)
signal setup_cancelled()

# === NODE REFERENCES ===
var api_key_input: LineEdit
var validate_button: Button
var save_button: Button
var cancel_button: Button
var model_option: OptionButton
var temperature_slider: HSlider
var max_tokens_spin: SpinBox
var status_label: Label
var safety_settings_container: VBoxContainer

# === CONFIGURATION ===
@export var show_advanced_options: bool = true
@export var show_safety_settings: bool = true

# === STATE ===
var gemini_service: GeminiAIService
var is_validating: bool = false
var is_api_key_valid: bool = false
var selected_model_index: int = 0
var safety_toggles: Dictionary = {}

func _ready() -> void:
    """Setup dialog on ready"""
    gemini_service = get_node_or_null("/root/GeminiAI")
    _setup_dialog()
    _setup_signals()
    _load_existing_configuration()

func _setup_dialog() -> void:
    """Create dialog UI structure"""
    custom_minimum_size = Vector2(500, 600)
    
    # Apply modern dialog styling
    UIThemeManager.apply_enhanced_panel_style(self, "elevated")
    
    # Main container
    var main_container = VBoxContainer.new()
    main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 20)
    main_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
    add_child(main_container)
    
    # Title
    var title = UIComponentFactory.create_label("Google Gemini AI Setup", "heading")
    main_container.add_child(title)
    
    # Description
    var description = UIComponentFactory.create_label(
        "Configure your Google Gemini API key and settings for AI assistant functionality. " +
        "You can get a free API key from https://ai.google.dev/", 
        "normal"
    )
    description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    main_container.add_child(description)
    
    # API key section
    var key_section = _create_section("API Key Configuration", "Required for Gemini integration")
    main_container.add_child(key_section)
    
    var api_key_container = VBoxContainer.new()
    api_key_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    key_section.add_child(api_key_container)
    
    var key_label = UIComponentFactory.create_label("Gemini API Key:", "normal")
    api_key_container.add_child(key_label)
    
    api_key_input = UIComponentFactory.create_text_input("Enter your API key here")
    api_key_input.secret = true
    api_key_container.add_child(api_key_input)
    
    var key_help = UIComponentFactory.create_label(
        "Your API key is stored locally and never shared.", 
        "caption"
    )
    key_help.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
    api_key_container.add_child(key_help)
    
    validate_button = UIComponentFactory.create_button("Validate Key", "primary")
    validate_button.custom_minimum_size.x = 150
    api_key_container.add_child(validate_button)
    
    status_label = UIComponentFactory.create_label("Enter your API key above", "normal")
    status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
    api_key_container.add_child(status_label)
    
    # Model selection section
    var model_section = _create_section("Model Selection", "Choose which Gemini model to use")
    main_container.add_child(model_section)
    
    var model_container = VBoxContainer.new()
    model_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    model_section.add_child(model_container)
    
    var model_label = UIComponentFactory.create_label("Gemini Model:", "normal")
    model_container.add_child(model_label)
    
    model_option = OptionButton.new()
    model_option.add_item("Gemini Pro", GeminiAIService.GeminiModel.GEMINI_PRO)
    model_option.add_item("Gemini Pro Vision", GeminiAIService.GeminiModel.GEMINI_PRO_VISION)
    model_option.add_item("Gemini Flash", GeminiAIService.GeminiModel.GEMINI_FLASH)
    model_container.add_child(model_option)
    
    var model_help = UIComponentFactory.create_label(
        "Gemini Pro is recommended for educational text generation.",
        "caption"
    )
    model_help.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
    model_container.add_child(model_help)
    
    # Advanced options
    if show_advanced_options:
        var advanced_section = _create_section("Advanced Options", "Fine-tune model behavior")
        main_container.add_child(advanced_section)
        
        var advanced_container = VBoxContainer.new()
        advanced_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
        advanced_section.add_child(advanced_container)
        
        # Temperature
        var temp_container = HBoxContainer.new()
        temp_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
        advanced_container.add_child(temp_container)
        
        var temp_label = UIComponentFactory.create_label("Temperature:", "normal")
        temp_label.custom_minimum_size.x = 150
        temp_container.add_child(temp_label)
        
        temperature_slider = HSlider.new()
        temperature_slider.min_value = 0.0
        temperature_slider.max_value = 1.0
        temperature_slider.step = 0.05
        temperature_slider.value = 0.7
        temperature_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        temp_container.add_child(temperature_slider)
        
        var temp_value = UIComponentFactory.create_label("0.7", "normal")
        temp_value.custom_minimum_size.x = 40
        temp_container.add_child(temp_value)
        
        # Update temperature label when slider moves
        temperature_slider.value_changed.connect(func(value): temp_value.text = "%.2f" % value)
        
        # Max output tokens
        var tokens_container = HBoxContainer.new()
        tokens_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
        advanced_container.add_child(tokens_container)
        
        var tokens_label = UIComponentFactory.create_label("Max Output Tokens:", "normal")
        tokens_label.custom_minimum_size.x = 150
        tokens_container.add_child(tokens_label)
        
        max_tokens_spin = SpinBox.new()
        max_tokens_spin.min_value = 50
        max_tokens_spin.max_value = 8192
        max_tokens_spin.step = 50
        max_tokens_spin.value = 2048
        max_tokens_spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        tokens_container.add_child(max_tokens_spin)
    
    # Safety settings
    if show_safety_settings:
        var safety_section = _create_section("Safety Settings", "Control content filtering")
        main_container.add_child(safety_section)
        
        var safety_container = VBoxContainer.new()
        safety_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
        safety_section.add_child(safety_container)
        
        var safety_info = UIComponentFactory.create_label(
            "Safety settings help ensure appropriate educational content. Each category can be set to different thresholds.", 
            "normal"
        )
        safety_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        safety_container.add_child(safety_info)
        
        safety_settings_container = VBoxContainer.new()
        safety_container.add_child(safety_settings_container)
        
        _create_safety_settings()
    
    # Buttons
    var button_container = HBoxContainer.new()
    button_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
    button_container.alignment = BoxContainer.ALIGNMENT_END
    main_container.add_child(button_container)
    
    cancel_button = UIComponentFactory.create_button("Cancel", "secondary")
    button_container.add_child(cancel_button)
    
    save_button = UIComponentFactory.create_button("Save Configuration", "primary")
    save_button.disabled = true
    button_container.add_child(save_button)

func _create_section(title: String, subtitle: String = "") -> PanelContainer:
    """Create a section with title and content"""
    var section = VBoxContainer.new()
    section.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    
    var title_label = UIComponentFactory.create_label(title, "subheading")
    section.add_child(title_label)
    
    if subtitle != "":
        var subtitle_label = UIComponentFactory.create_label(subtitle, "caption")
        subtitle_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
        section.add_child(subtitle_label)
    
    var panel = PanelContainer.new()
    var style = UIThemeManager.create_enhanced_glass_style(0.5)
    panel.add_theme_stylebox_override("panel", style)
    panel.add_theme_constant_override("margin_left", UIThemeManager.get_spacing("md"))
    panel.add_theme_constant_override("margin_right", UIThemeManager.get_spacing("md"))
    panel.add_theme_constant_override("margin_top", UIThemeManager.get_spacing("md"))
    panel.add_theme_constant_override("margin_bottom", UIThemeManager.get_spacing("md"))
    
    section.add_child(panel)
    
    return panel

func _create_safety_settings() -> void:
    """Create safety settings UI based on available options"""
    var safety_categories = {
        "HARASSMENT": "Harassment",
        "HATE_SPEECH": "Hate Speech",
        "SEXUALLY_EXPLICIT": "Sexually Explicit Content",
        "DANGEROUS_CONTENT": "Dangerous Content"
    }
    
    var threshold_options = {
        0: "Block None",
        1: "Block Some",
        2: "Block Most",
        3: "Block All"
    }
    
    for category_id in safety_categories:
        var category_name = safety_categories[category_id]
        var row = HBoxContainer.new()
        row.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
        
        var label = UIComponentFactory.create_label(category_name + ":", "normal")
        label.custom_minimum_size.x = 180
        row.add_child(label)
        
        var option = OptionButton.new()
        for threshold in threshold_options:
            option.add_item(threshold_options[threshold], threshold)
        
        # Default to "Block Most"
        option.selected = 2
        option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        row.add_child(option)
        
        safety_settings_container.add_child(row)
        safety_toggles[category_id] = option

func _setup_signals() -> void:
    """Connect signals for dialog interaction"""
    validate_button.pressed.connect(_on_validate_pressed)
    save_button.pressed.connect(_on_save_pressed)
    cancel_button.pressed.connect(_on_cancel_pressed)
    
    if gemini_service:
        gemini_service.api_key_validated.connect(_on_api_key_validated)
        gemini_service.model_list_updated.connect(_on_model_list_updated)

func _load_existing_configuration() -> void:
    """Load existing Gemini configuration if available"""
    if !gemini_service:
        return
    
    var api_key = gemini_service.get_api_key()
    if api_key != "":
        api_key_input.text = "••••••••"
        api_key_input.placeholder_text = "API key is already configured"
        is_api_key_valid = true
        status_label.text = "API key already configured"
        status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_success"))
    
    # Load model selection
    var model_name = gemini_service.get_model_name()
    for i in range(model_option.item_count):
        var model_id = model_option.get_item_id(i)
        if gemini_service.MODEL_NAMES[model_id] == model_name:
            model_option.selected = i
            selected_model_index = i
            break
    
    if show_advanced_options:
        var config = gemini_service.get_configuration()
        temperature_slider.value = config.temperature
        max_tokens_spin.value = config.max_output_tokens
    
    if show_safety_settings:
        var safety = gemini_service.get_safety_settings()
        for category in safety:
            if category in safety_toggles:
                safety_toggles[category].selected = safety[category]
    
    # Enable save button if API key is already valid
    save_button.disabled = !is_api_key_valid

# === SIGNAL HANDLERS ===
func _on_validate_pressed() -> void:
    """Validate API key"""
    var key = api_key_input.text.strip_edges()
    
    if key == "":
        status_label.text = "Please enter an API key"
        status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_error"))
        return
    
    is_validating = true
    status_label.text = "Validating API key..."
    status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
    validate_button.disabled = true
    
    if gemini_service:
        gemini_service.validate_api_key(key)
    else:
        # Fallback if service not available
        _on_api_key_validated(false, "Gemini service not available")

func _on_api_key_validated(success: bool, message: String) -> void:
    """Handle API key validation result"""
    is_validating = false
    validate_button.disabled = false
    
    if success:
        status_label.text = "✓ API key validated successfully"
        status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_success"))
        is_api_key_valid = true
        save_button.disabled = false
        
        # Fetch available models
        if gemini_service:
            gemini_service.update_available_models()
    else:
        status_label.text = "✗ " + message
        status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_error"))
        is_api_key_valid = false
        save_button.disabled = true

func _on_model_list_updated(models: Array) -> void:
    """Handle updated model list"""
    if models.size() > 0:
        model_option.clear()
        for model_name in models:
            var model_id = -1
            for key in gemini_service.MODEL_NAMES:
                if gemini_service.MODEL_NAMES[key] == model_name:
                    model_id = key
                    break
            
            if model_id != -1:
                model_option.add_item(model_name, model_id)
        
        # Reset selection to what it was
        if selected_model_index < model_option.item_count:
            model_option.selected = selected_model_index

func _on_save_pressed() -> void:
    """Save configuration and close dialog"""
    if !is_api_key_valid and api_key_input.text.strip_edges() != "":
        status_label.text = "Please validate your API key first"
        status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_error"))
        return
    
    var key = api_key_input.text.strip_edges()
    if key == "" and !is_api_key_valid:
        status_label.text = "API key is required"
        status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_error"))
        return
    
    # Get current key from service if user didn't change it (just sees placeholder)
    if key == "" or key == "••••••••":
        key = gemini_service.api_key if gemini_service else ""
    
    # Get selected model
    var selected_model = model_option.get_selected_id()
    
    # Get safety settings
    var safety = {}
    for category in safety_toggles:
        safety[category] = safety_toggles[category].get_selected_id()
    
    # Save configuration
    if gemini_service:
        gemini_service.save_configuration(key, selected_model)
        gemini_service.set_safety_settings(safety)
        
        if show_advanced_options:
            gemini_service.temperature = temperature_slider.value
            gemini_service.max_output_tokens = int(max_tokens_spin.value)
    
    # Close dialog
    setup_completed.emit(true, key)
    queue_free()

func _on_cancel_pressed() -> void:
    """Cancel setup and close dialog"""
    setup_cancelled.emit()
    queue_free()

# === PUBLIC API ===
func show_dialog() -> void:
    """Show the dialog"""
    if not is_inside_tree():
        get_tree().root.add_child.call_deferred(self)
    
    # Center in window
    var root_rect = get_viewport().get_visible_rect()
    position.x = (root_rect.size.x - size.x) / 2
    position.y = (root_rect.size.y - size.y) / 2
    
    # Show with fade animation
    modulate = Color(1, 1, 1, 0)
    show()
    var tween = create_tween()
    tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
    
    # Focus API key input if not already configured
    if api_key_input.text == "":
        api_key_input.grab_focus()