## GeminiSetupDialog.gd
## Setup dialog for Google Gemini AI configuration in NeuroVis educational platform
##
## This dialog handles the initial configuration of the Google Gemini AI integration,
## allowing users to set their API key, select models, and configure safety settings.
## The dialog validates API keys before saving and provides feedback on configuration status.
##
## NOTE: Consider converting this to a scene-based approach for better performance
## and easier maintenance. Dynamic UI creation can be slower and harder to debug.
##
## @tutorial: Gemini Integration Guide
## @version: 1.0

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
    """Setup dialog on ready with error handling"""
    gemini_service = get_node_or_null("/root/GeminiAI")
    if not gemini_service:
        push_warning("[GeminiSetupDialog] GeminiAI service not found - some features may be limited")
    
    if not _setup_dialog():
        push_error("[GeminiSetupDialog] Failed to setup dialog UI")
        return
    
    _setup_signals()
    _load_existing_configuration()

func _setup_dialog() -> bool:
    """Create dialog UI structure
    @return: true if setup successful, false otherwise"""
    custom_minimum_size = Vector2(500, 600)
    
    # Apply modern dialog styling
    if UIThemeManager:
        UIThemeManager.apply_enhanced_panel_style(self, "elevated")
    else:
        push_warning("[GeminiSetupDialog] UIThemeManager not available")
    
    # Main container
    var main_container = VBoxContainer.new()
    if not main_container:
        push_error("[GeminiSetupDialog] Failed to create main container")
        return false
    
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
    if not key_section:
        push_error("[GeminiSetupDialog] Failed to create API key section")
        return false
    main_container.add_child(key_section)
    
    var api_key_container = VBoxContainer.new()
    api_key_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    var key_content = key_section.get_meta("content_container")
    if key_content:
        key_content.add_child(api_key_container)
    else:
        push_error("[GeminiSetupDialog] No content container found for API key section")
    
    var key_label = UIComponentFactory.create_label("Gemini API Key:", "normal")
    api_key_container.add_child(key_label)
    
    # Create API key input directly instead of using factory to avoid styling issues
    api_key_input = LineEdit.new()
    if not api_key_input:
        push_error("[GeminiSetupDialog] Failed to create API key input")
        return false
    
    api_key_input.placeholder_text = "Enter your API key here"
    api_key_input.secret = true
    api_key_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    api_key_input.custom_minimum_size.y = 40
    
    # Apply direct styling (not using the problematic theming method)
    if UIThemeManager:
        UIThemeManager.apply_search_field_styling(api_key_input, "Enter your API key here")
    
    api_key_container.add_child(api_key_input)
    print("[GeminiSetupDialog] API key input created")
    
    var key_help = UIComponentFactory.create_label(
        "Your API key is stored locally and never shared.", 
        "caption"
    )
    key_help.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
    api_key_container.add_child(key_help)
    
    validate_button = UIComponentFactory.create_button("Validate Key", "primary")
    if not validate_button:
        push_error("[GeminiSetupDialog] Failed to create validate button")
        return false
    validate_button.custom_minimum_size.x = 150
    api_key_container.add_child(validate_button)
    
    status_label = UIComponentFactory.create_label("Enter your API key above", "normal")
    if not status_label:
        push_error("[GeminiSetupDialog] Failed to create status label")
        return false
    status_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
    api_key_container.add_child(status_label)
    
    # Model selection section
    var model_section = _create_section("Model Selection", "Choose which Gemini model to use")
    if not model_section:
        push_error("[GeminiSetupDialog] Failed to create model section")
        return false
    main_container.add_child(model_section)
    
    var model_container = VBoxContainer.new()
    model_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    var model_content = model_section.get_meta("content_container")
    if model_content:
        model_content.add_child(model_container)
    else:
        push_error("[GeminiSetupDialog] No content container found for model section")
    
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
        var advanced_content = advanced_section.get_meta("content_container")
        if advanced_content:
            advanced_content.add_child(advanced_container)
        else:
            push_error("[GeminiSetupDialog] No content container found for advanced section")
        
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
        var safety_content = safety_section.get_meta("content_container")
        if safety_content:
            safety_content.add_child(safety_container)
        else:
            push_error("[GeminiSetupDialog] No content container found for safety section")
        
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
    
    return true

func _create_section(title: String, subtitle: String = "") -> VBoxContainer:
    """Create a section with title, optional subtitle, and content container.
    
    Returns a VBoxContainer with the following structure:
    - VBoxContainer (main section container)
      - Label (title)
      - Label (subtitle, if provided)
      - PanelContainer (styled background)
        - VBoxContainer (content container for child nodes)
    
    Access the content container via: section.get_meta("content_container")
    
    @param title: Section header text
    @param subtitle: Optional descriptive text below title
    @return: VBoxContainer with content_container in metadata
    """
    var section = VBoxContainer.new()
    if not section:
        push_error("[GeminiSetupDialog] Failed to create section container")
        return null
    
    section.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    
    # Add title
    var title_label = UIComponentFactory.create_label(title, "subheading")
    if title_label:
        section.add_child(title_label)
    else:
        push_warning("[GeminiSetupDialog] Failed to create title label for section: " + title)
    
    # Add subtitle if provided
    if subtitle != "":
        var subtitle_label = UIComponentFactory.create_label(subtitle, "caption")
        if subtitle_label:
            subtitle_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_secondary"))
            section.add_child(subtitle_label)
    
    # Create styled panel
    var panel = PanelContainer.new()
    if not panel:
        push_error("[GeminiSetupDialog] Failed to create panel container")
        return section
    
    var style = UIThemeManager.create_enhanced_glass_style(0.5)
    if style:
        panel.add_theme_stylebox_override("panel", style)
    
    panel.add_theme_constant_override("margin_left", UIThemeManager.get_spacing("md"))
    panel.add_theme_constant_override("margin_right", UIThemeManager.get_spacing("md"))
    panel.add_theme_constant_override("margin_top", UIThemeManager.get_spacing("md"))
    panel.add_theme_constant_override("margin_bottom", UIThemeManager.get_spacing("md"))
    
    # Create content container for the panel
    var content_container = VBoxContainer.new()
    if not content_container:
        push_error("[GeminiSetupDialog] Failed to create content container")
        return section
    
    content_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    panel.add_child(content_container)
    
    section.add_child(panel)
    section.set_meta("content_container", content_container)
    
    return section

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
    """Connect signals for dialog interaction with null checks"""
    print("[GeminiSetupDialog] Setting up signals")
    
    if validate_button:
        validate_button.pressed.connect(_on_validate_pressed)
        print("[GeminiSetupDialog] ✓ Validate button connected")
    else:
        push_warning("[GeminiSetupDialog] Validate button not available for signal connection")
    
    if save_button:
        save_button.pressed.connect(_on_save_pressed)
        print("[GeminiSetupDialog] ✓ Save button connected")
    else:
        push_warning("[GeminiSetupDialog] Save button not available for signal connection")
    
    if cancel_button:
        # Disconnect any existing connections first
        if cancel_button.pressed.is_connected(_on_cancel_pressed):
            cancel_button.pressed.disconnect(_on_cancel_pressed)
        
        cancel_button.pressed.connect(_on_cancel_pressed)
        print("[GeminiSetupDialog] ✓ Cancel button connected")
    else:
        push_warning("[GeminiSetupDialog] Cancel button not available for signal connection")
    
    if gemini_service:
        # Disconnect any existing connections first
        if gemini_service.api_key_validated.is_connected(_on_api_key_validated):
            gemini_service.api_key_validated.disconnect(_on_api_key_validated)
        if gemini_service.model_list_updated.is_connected(_on_model_list_updated):
            gemini_service.model_list_updated.disconnect(_on_model_list_updated)
        
        gemini_service.api_key_validated.connect(_on_api_key_validated)
        gemini_service.model_list_updated.connect(_on_model_list_updated)
        print("[GeminiSetupDialog] ✓ GeminiAI service connected")
    else:
        push_warning("[GeminiSetupDialog] GeminiAI service not available for signal connection")

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
    """Save configuration and close dialog
    
    Validates that all required fields are filled and saves configuration
    to user preferences before emitting setup_completed signal.
    """
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
    """Cancel setup and close dialog
    
    Emits setup_cancelled signal and closes dialog without
    modifying any existing configuration.
    """
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