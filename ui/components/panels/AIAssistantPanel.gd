# AI Assistant Panel for NeuroVis
# Interactive chat interface for educational brain anatomy assistance
class_name AIAssistantPanel
extends ResponsiveComponent

# === PANEL SIGNALS ===
signal question_asked(question: String)
signal panel_closed
signal feedback_given(rating: int, comment: String)

# === CONFIGURATION ===
@export var auto_suggestions: bool = true
@export var show_context_info: bool = true
@export var enable_quick_questions: bool = true
@export var max_visible_messages: int = 50

# === UI COMPONENTS ===
var title_bar: HBoxContainer
var context_indicator: Label
var chat_container: ScrollContainer
var messages_list: VBoxContainer
var input_container: VBoxContainer
var question_input: LineEdit
var send_button: Button
var quick_questions_container: HBoxContainer
var status_label: Label

# === STATE ===
var current_structure: String = ""
var ai_service: AIAssistantService
var message_count: int = 0
var is_waiting_for_response: bool = false

# === QUICK QUESTION TEMPLATES ===
var quick_questions = [
    {"text": "Function", "tooltip": "What does this structure do?", "type": "function"},
    {"text": "Location", "tooltip": "Where is this structure located?", "type": "location"},
    {"text": "Connections", "tooltip": "What connects to this structure?", "type": "connections"},
    {"text": "Clinical", "tooltip": "What happens when damaged?", "type": "clinical"}
]

func _setup_component() -> void:
    """Setup the AI assistant panel"""
    super._setup_component()
    
    # Get reference to AI service
    ai_service = get_node("/root/AIAssistant") if get_node_or_null("/root/AIAssistant") else null
    
    _create_panel_structure()
    _setup_ai_connections()
    _create_welcome_message()

func _create_panel_structure() -> void:
    """Create the AI panel UI structure"""
    # Set panel properties
    custom_minimum_size = Vector2(400, 500)
    
    # Apply modern panel styling
    UIThemeManager.apply_enhanced_panel_style(self, "elevated")
    
    # Main container
    var main_container = VBoxContainer.new()
    main_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    main_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("md"))
    add_child(main_container)
    
    # Create sections
    _create_title_bar()
    main_container.add_child(title_bar)
    
    if show_context_info:
        _create_context_indicator()
        main_container.add_child(context_indicator)
    
    _create_chat_area()
    main_container.add_child(chat_container)
    
    if enable_quick_questions:
        _create_quick_questions()
        main_container.add_child(quick_questions_container)
    
    _create_input_area()
    main_container.add_child(input_container)
    
    _create_status_area()
    main_container.add_child(status_label)

func _create_title_bar() -> void:
    """Create the panel title bar"""
    title_bar = HBoxContainer.new()
    title_bar.name = "TitleBar"
    
    # AI icon and title
    var icon_label = UIComponentFactory.create_label("🤖", "heading")
    icon_label.custom_minimum_size.x = 32
    title_bar.add_child(icon_label)
    
    var title_label = UIComponentFactory.create_label("NeuroBot Assistant", "heading")
    title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    title_bar.add_child(title_label)
    
    # Close button
    var close_btn = UIComponentFactory.create_button("✕", "icon", {
        "custom_minimum_size": Vector2(32, 32)
    })
    close_btn.tooltip_text = "Close AI Assistant"
    close_btn.pressed.connect(_on_close_pressed)
    title_bar.add_child(close_btn)

func _create_context_indicator() -> void:
    """Create context indicator showing current structure"""
    context_indicator = UIComponentFactory.create_label("No structure selected", "caption")
    context_indicator.name = "ContextIndicator"
    
    # Style as info badge
    var style = UIThemeManager.create_enhanced_glass_style(0.8)
    style.bg_color = UIThemeManager.get_color("button_secondary")
    style.corner_radius_top_left = 12
    style.corner_radius_top_right = 12
    style.corner_radius_bottom_left = 12
    style.corner_radius_bottom_right = 12
    style.content_margin_left = 12
    style.content_margin_right = 12
    style.content_margin_top = 6
    style.content_margin_bottom = 6
    
    var context_bg = PanelContainer.new()
    context_bg.add_theme_stylebox_override("panel", style)
    context_bg.add_child(context_indicator)

func _create_chat_area() -> void:
    """Create scrollable chat message area"""
    chat_container = ScrollContainer.new()
    chat_container.name = "ChatContainer"
    chat_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    chat_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
    
    messages_list = VBoxContainer.new()
    messages_list.name = "MessagesList"
    messages_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    messages_list.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    
    chat_container.add_child(messages_list)

func _create_quick_questions() -> void:
    """Create quick question buttons"""
    quick_questions_container = HBoxContainer.new()
    quick_questions_container.name = "QuickQuestions"
    quick_questions_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    
    for question_data in quick_questions:
        var btn = UIComponentFactory.create_button(question_data.text, "secondary", {
            "custom_minimum_size": Vector2(80, 32)
        })
        btn.tooltip_text = question_data.tooltip
        btn.pressed.connect(_on_quick_question_pressed.bind(question_data.type))
        quick_questions_container.add_child(btn)

func _create_input_area() -> void:
    """Create message input area"""
    input_container = VBoxContainer.new()
    input_container.name = "InputContainer"
    
    var input_row = HBoxContainer.new()
    input_row.add_theme_constant_override("separation", UIThemeManager.get_spacing("sm"))
    
    # Question input field
    question_input = UIComponentFactory.create_text_input("Ask about brain anatomy...")
    question_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    question_input.custom_minimum_size.y = 40
    question_input.text_submitted.connect(_on_question_submitted)
    input_row.add_child(question_input)
    
    # Send button
    send_button = UIComponentFactory.create_button("Send", "primary", {
        "custom_minimum_size": Vector2(80, 40)
    })
    send_button.pressed.connect(_on_send_pressed)
    input_row.add_child(send_button)
    
    input_container.add_child(input_row)

func _create_status_area() -> void:
    """Create status indicator"""
    status_label = UIComponentFactory.create_label("Ready", "caption")
    status_label.name = "StatusLabel"
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _create_welcome_message() -> void:
    """Create initial welcome message"""
    var welcome_text = "Hello! I'm NeuroBot, your brain anatomy assistant. I can help explain brain structures, their functions, and how they work together. Select a brain structure and ask me questions!"
    _add_message("assistant", welcome_text, "Welcome")

# === AI SERVICE INTEGRATION ===
func _setup_ai_connections() -> void:
    """Setup connections to AI service"""
    if not ai_service:
        _update_status("AI Service not available - using offline mode")
        return
    
    # Connect AI service signals
    ai_service.response_received.connect(_on_ai_response_received)
    ai_service.error_occurred.connect(_on_ai_error)
    ai_service.context_updated.connect(_on_ai_context_updated)
    
    _update_status("Connected to AI Assistant")

func set_current_structure(structure_name: String) -> void:
    """Update the current brain structure context"""
    current_structure = structure_name
    
    if ai_service:
        ai_service.set_current_structure(structure_name)
    
    # Update context indicator
    if context_indicator:
        if structure_name.is_empty():
            context_indicator.text = "No structure selected"
        else:
            context_indicator.text = "📍 " + structure_name
    
    # Auto-suggest relevant questions
    if auto_suggestions and not structure_name.is_empty():
        _show_structure_suggestions(structure_name)

func ask_question(question: String) -> void:
    """Ask a question to the AI assistant"""
    if question.strip() == "":
        return
    
    # Add user message to chat
    _add_message("user", question)
    
    # Clear input
    if question_input:
        question_input.text = ""
    
    # Set waiting state
    is_waiting_for_response = true
    _update_status("NeuroBot is thinking...")
    send_button.disabled = true
    
    # Send to AI service
    if ai_service:
        ai_service.ask_question(question)
        question_asked.emit(question)
    else:
        # Fallback for when AI service is not available
        _handle_offline_response(question)

# === MESSAGE MANAGEMENT ===
func _add_message(sender: String, content: String, title: String = "") -> void:
    """Add a message to the chat"""
    var message_container = VBoxContainer.new()
    message_container.add_theme_constant_override("separation", UIThemeManager.get_spacing("xs"))
    
    # Message header with sender and timestamp
    var header = HBoxContainer.new()
    
    var sender_label = UIComponentFactory.create_label("", "caption")
    if sender == "user":
        sender_label.text = "👤 You"
        sender_label.add_theme_color_override("font_color", UIThemeManager.get_color("text_accent"))
    else:
        sender_label.text = "🤖 NeuroBot"
        sender_label.add_theme_color_override("font_color", UIThemeManager.get_color("button_primary"))
    
    var timestamp = UIComponentFactory.create_label(Time.get_time_string_from_system(), "caption")
    timestamp.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    timestamp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    
    header.add_child(sender_label)
    header.add_child(timestamp)
    message_container.add_child(header)
    
    # Title (if provided)
    if title != "":
        var title_label = UIComponentFactory.create_label(title, "subheading")
        message_container.add_child(title_label)
    
    # Message content
    var content_label = RichTextLabel.new()
    content_label.bbcode_enabled = true
    content_label.fit_content = true
    content_label.scroll_active = false
    content_label.text = content
    content_label.custom_minimum_size.y = 30
    
    UIThemeManager.apply_rich_text_styling(content_label, UIThemeManager.FONT_SIZE_MEDIUM)
    
    # Style message bubble
    var bubble = PanelContainer.new()
    var bubble_style = UIThemeManager.create_enhanced_glass_style(0.6)
    
    if sender == "user":
        bubble_style.bg_color = UIThemeManager.get_color("surface_hover")
    else:
        bubble_style.bg_color = UIThemeManager.get_color("surface_bg")
    
    bubble.add_theme_stylebox_override("panel", bubble_style)
    bubble.add_child(content_label)
    message_container.add_child(bubble)
    
    # Add to messages list
    messages_list.add_child(message_container)
    message_count += 1
    
    # Limit message history
    if message_count > max_visible_messages:
        var oldest_message = messages_list.get_child(0)
        messages_list.remove_child(oldest_message)
        oldest_message.queue_free()
        message_count -= 1
    
    # Scroll to bottom
    await get_tree().process_frame
    chat_container.scroll_vertical = chat_container.get_v_scroll_bar().max_value

func _show_structure_suggestions(structure_name: String) -> void:
    """Show suggested questions for the current structure"""
    var suggestions = [
        "What does the %s do?" % structure_name,
        "Where is the %s located?" % structure_name,
        "What connects to the %s?" % structure_name
    ]
    
    var suggestion_text = "💡 Try asking:\n"
    for suggestion in suggestions:
        suggestion_text += "• " + suggestion + "\n"
    
    _add_message("assistant", suggestion_text, "Suggestions")

# === EVENT HANDLERS ===
func _on_question_submitted(text: String) -> void:
    """Handle question submission via Enter key"""
    ask_question(text)

func _on_send_pressed() -> void:
    """Handle send button press"""
    ask_question(question_input.text)

func _on_quick_question_pressed(question_type: String) -> void:
    """Handle quick question button press"""
    if current_structure.is_empty():
        _add_message("assistant", "Please select a brain structure first, then I can answer specific questions about it!")
        return
    
    if ai_service:
        ai_service.ask_about_current_structure(question_type)
    else:
        # Fallback questions
        var question = ""
        match question_type:
            "function":
                question = "What are the main functions of the %s?" % current_structure
            "location":
                question = "Where is the %s located?" % current_structure
            "connections":
                question = "What does the %s connect to?" % current_structure
            "clinical":
                question = "What happens when the %s is damaged?" % current_structure
        
        ask_question(question)

func _on_close_pressed() -> void:
    """Handle close button press"""
    panel_closed.emit()
    if animation_enabled:
        animate_hide()
    else:
        visible = false

func _on_ai_response_received(question: String, response: String) -> void:
    """Handle AI response"""
    _add_message("assistant", response)
    is_waiting_for_response = false
    _update_status("Ready")
    send_button.disabled = false

func _on_ai_error(error_message: String) -> void:
    """Handle AI service error"""
    _add_message("assistant", "Sorry, I'm having trouble right now. " + error_message, "Error")
    is_waiting_for_response = false
    _update_status("Error occurred")
    send_button.disabled = false

func _on_ai_context_updated(structure_name: String) -> void:
    """Handle AI context update"""
    set_current_structure(structure_name)

# === OFFLINE FALLBACK ===
func _handle_offline_response(question: String) -> void:
    """Handle questions when AI service is not available"""
    await get_tree().create_timer(1.0).timeout  # Simulate processing
    
    var response = "I'm currently in offline mode. For full AI assistance, please ensure an internet connection and API configuration. In the meantime, you can explore the 3D brain model and view structure information in the information panel."
    
    _add_message("assistant", response, "Offline Mode")
    is_waiting_for_response = false
    _update_status("Offline mode")
    send_button.disabled = false

# === UTILITY METHODS ===
func _update_status(status: String) -> void:
    """Update status label"""
    if status_label:
        status_label.text = status

func clear_chat() -> void:
    """Clear all chat messages"""
    for child in messages_list.get_children():
        child.queue_free()
    message_count = 0
    _create_welcome_message()

func get_chat_history() -> Array:
    """Get current chat history"""
    if ai_service:
        return ai_service.get_conversation_history()
    return []

func export_conversation() -> String:
    """Export conversation as text"""
    var export_text = "NeuroVis AI Assistant Conversation\n"
    export_text += "Generated: " + Time.get_datetime_string_from_system() + "\n"
    export_text += "Structure Context: " + current_structure + "\n\n"
    
    var history = get_chat_history()
    for entry in history:
        export_text += "%s: %s\n\n" % [entry.role.capitalize(), entry.content]
    
    return export_text