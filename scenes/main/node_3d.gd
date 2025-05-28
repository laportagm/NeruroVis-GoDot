# Simplified Main Scene - Clean and Modern Implementation
class_name NeuroVisMainScene
extends Node3D

# Preload essential classes only
const BrainStructureSelectionManagerScript = preload("res://core/interaction/BrainStructureSelectionManager.gd")
const CameraBehaviorControllerScript = preload("res://core/interaction/CameraBehaviorController.gd")
const ModelCoordinatorScene = preload("res://core/models/ModelRegistry.gd")
const UIThemeManager = preload("res://ui/panels/UIThemeManager.gd")
const UnifiedStructureInfoPanelScript = preload("res://scenes/ui_info_panel_unified.gd")
const InfoPanelFactory = preload("res://ui/panels/InfoPanelFactory.gd")

# Constants
const RAY_LENGTH: float = 1000.0
const DEBUG_MODE: bool = true

# Export variables for customizing highlight appearance
@export var highlight_color: Color = Color(0.0, 1.0, 0.0, 1.0)
@export var emission_energy: float = 0.5

# Core node references
@onready var camera: Camera3D = $Camera3D
@onready var object_name_label: Label = $UI_Layer/ObjectNameLabel
@onready var info_panel: Control = $UI_Layer/StructureInfoPanel
@onready var brain_model_parent: Node3D = $BrainModel
@onready var model_control_panel: Control = $UI_Layer/ModelControlPanel

# Components
var selection_manager: Node
var camera_controller: Node
var model_coordinator: Node

# System state
var initialization_complete: bool = false
var last_selected_structure: String = ""

# Signals
signal structure_selected(structure_name: String)
signal structure_deselected
signal models_loaded(model_names: Array)

func _ready() -> void:
    print("[INIT] Starting NeuroVis main scene...")
    await initialize_core_systems()
    print("[INIT] NeuroVis ready!")

func initialize_core_systems() -> void:
    """Initialize core systems in proper order"""
    # Validate essential nodes exist
    if not _validate_essential_nodes():
        push_error("Critical UI nodes missing!")
        return
    
    # Initialize core components
    _setup_selection_manager()
    _setup_camera_controller()
    _setup_model_coordinator()
    
    # Setup enhanced UI
    _setup_enhanced_ui()
    
    # Setup UI and connections
    _setup_ui_connections()
    
    # Load models
    if model_coordinator:
        model_coordinator.load_brain_models()
    
    # Apply modern styling
    _apply_modern_theme()
    
    initialization_complete = true
    _print_instructions()

func _validate_essential_nodes() -> bool:
    """Validate that essential nodes exist"""
    var valid = true
    
    if not camera:
        push_error("Camera3D not found!")
        valid = false
    
    if not object_name_label:
        push_error("ObjectNameLabel not found!")
        valid = false
    
    if not info_panel:
        push_error("StructureInfoPanel not found!")
        valid = false
    
    if not brain_model_parent:
        push_error("BrainModel parent not found!")
        valid = false
    
    return valid

func _setup_selection_manager() -> void:
    """Setup structure selection manager"""
    selection_manager = BrainStructureSelectionManagerScript.new()
    add_child(selection_manager)
    
    # Connect signals
    selection_manager.structure_selected.connect(_on_structure_selected)
    selection_manager.structure_deselected.connect(_on_structure_deselected)
    selection_manager.structure_hovered.connect(_on_structure_hovered)
    selection_manager.structure_unhovered.connect(_on_structure_unhovered)
    
    # Configure appearance
    selection_manager.configure_highlight_colors(highlight_color, Color(1.0, 0.7, 0.0, 0.6))
    selection_manager.set_emission_energy(emission_energy)
    selection_manager.set_outline_enabled(true)
    
    print("[INIT] Selection manager ready")

func _setup_camera_controller() -> void:
    """Setup camera controller"""
    camera_controller = CameraBehaviorControllerScript.new()
    add_child(camera_controller)
    camera_controller.initialize(camera, brain_model_parent)
    
    print("[INIT] Camera controller ready")

func _setup_model_coordinator() -> void:
    """Setup model coordinator"""
    model_coordinator = ModelCoordinatorScene.new()
    add_child(model_coordinator)
    model_coordinator.set_model_parent(brain_model_parent)
    
    # Connect signals
    model_coordinator.models_loaded.connect(_on_models_loaded)
    model_coordinator.model_load_failed.connect(_on_model_load_failed)
    
    print("[INIT] Model coordinator ready")

func _setup_enhanced_ui() -> void:
    """Setup UI layer and theme toggle only"""
    # Get the UI layer where the info panel is located
    var ui_layer: CanvasLayer = $UI_Layer
    if not ui_layer:
        push_error("[ENHANCED_UI] UI_Layer not found!")
        return
    
    print("[ENHANCED_UI] UI_Layer found: " + ui_layer.name)
    
    # Remove any existing info panel placeholder
    var existing_panel = ui_layer.get_node_or_null("StructureInfoPanel")
    if existing_panel:
        existing_panel.queue_free()
        info_panel = null
        print("[ENHANCED_UI] Removed existing panel")
    
    # Load theme preference
    InfoPanelFactory.load_preference()
    
    # Add theme toggle button with safety checks
    var theme_toggle_script = preload("res://ui/panels/ThemeToggle.gd")
    if not theme_toggle_script:
        push_error("[ENHANCED_UI] Failed to load ThemeToggle script!")
        return
    
    var theme_toggle = theme_toggle_script.new()
    if not theme_toggle:
        push_error("[ENHANCED_UI] Failed to create ThemeToggle instance!")
        return
    
    theme_toggle.position = Vector2(10, 50)
    
    # Add to UI layer with safety check
    if ui_layer and theme_toggle:
        ui_layer.add_child(theme_toggle)
        print("[ENHANCED_UI] Theme toggle added successfully")
    else:
        push_error("[ENHANCED_UI] Cannot add theme toggle - ui_layer or theme_toggle is null")
        return
    
    print("[ENHANCED_UI] UI setup complete - panel will be created on demand")

func _setup_ui_connections() -> void:
    """Setup UI connections and styling"""
    # Setup object label
    object_name_label.text = "Selected: None"
    
    # Setup model control panel
    if model_control_panel:
        if ModelSwitcherGlobal and ModelSwitcherGlobal.has_signal("model_visibility_changed"):
            ModelSwitcherGlobal.model_visibility_changed.connect(_on_model_visibility_changed)
        
        if model_control_panel.has_signal("model_selected"):
            model_control_panel.model_selected.connect(_on_model_selected)
    
    print("[INIT] UI connections complete")

func _connect_panel_signals() -> void:
    """Connect signals for the info panel"""
    if not info_panel:
        return
    
    # Connect basic signals
    if info_panel.has_signal("panel_closed"):
        info_panel.panel_closed.connect(_on_info_panel_closed)
    
    # Connect enhanced panel signals (new format)
    if info_panel.has_signal("bookmark_toggled"):
        info_panel.bookmark_toggled.connect(_on_structure_bookmarked)
    if info_panel.has_signal("section_toggled"):
        info_panel.section_toggled.connect(_on_section_toggled)
    
    # Connect legacy unified panel signals (only if they exist)
    if info_panel.has_signal("structure_bookmarked"):
        info_panel.structure_bookmarked.connect(_on_structure_bookmarked)
    if info_panel.has_signal("structure_search_requested"):
        info_panel.structure_search_requested.connect(_on_structure_search_requested)
    if info_panel.has_signal("related_structure_selected"):
        info_panel.related_structure_selected.connect(_on_related_structure_selected)
    if info_panel.has_signal("quiz_requested"):
        info_panel.quiz_requested.connect(_on_quiz_requested)
    if info_panel.has_signal("notes_requested"):
        info_panel.notes_requested.connect(_on_notes_requested)
    if info_panel.has_signal("study_plan_requested"):
        info_panel.study_plan_requested.connect(_on_study_plan_requested)
    if info_panel.has_signal("fullscreen_requested"):
        info_panel.fullscreen_requested.connect(_on_fullscreen_requested)
    if info_panel.has_signal("feedback_submitted"):
        info_panel.feedback_submitted.connect(_on_feedback_submitted)

func _apply_modern_theme() -> void:
    """Apply modern glass morphism theme using UIThemeManager"""
    # Apply glass styling to object label
    if object_name_label:
        UIThemeManager.apply_modern_label(object_name_label, UIThemeManager.FONT_SIZE_MEDIUM, UIThemeManager.TEXT_PRIMARY, "default")
    
    # Note: Info panel styling is handled when it's created
    
    # Apply styling to model control panel
    if model_control_panel:
        UIThemeManager.apply_glass_panel(model_control_panel)
    
    print("[INIT] Modern theme applied")

# Input handling
func _input(event: InputEvent) -> void:
    if not initialization_complete:
        return
    
    # Keyboard shortcuts
    if event is InputEventKey and event.pressed:
        match event.keycode:
            KEY_F:
                camera_controller.focus_on_bounds(Vector3.ZERO, 2.0)
                get_viewport().set_input_as_handled()
            KEY_1, KEY_KP_1:
                camera_controller.set_view_preset("front")
                get_viewport().set_input_as_handled()
            KEY_3, KEY_KP_3:
                camera_controller.set_view_preset("right")
                get_viewport().set_input_as_handled()
            KEY_7, KEY_KP_7:
                camera_controller.set_view_preset("top")
                get_viewport().set_input_as_handled()
            KEY_R:
                camera_controller.reset_view()
                get_viewport().set_input_as_handled()
    
    # Mouse hover for structure highlighting
    if event is InputEventMouseMotion:
        selection_manager.handle_hover_at_position(event.position)
    
    # Right-click for structure selection
    if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
        selection_manager.handle_selection_at_position(event.position)
        get_viewport().set_input_as_handled()

# Signal handlers
func _on_structure_selected(structure_name: String, _mesh: MeshInstance3D) -> void:
    # Update label with modern animation
    UIThemeManager.animate_fade_text_change(object_name_label, "Selected: " + structure_name)
    
    # Display structure information
    _display_structure_info(structure_name)
    
    emit_signal("structure_selected", structure_name)
    print("Selected: " + structure_name)

func _on_structure_deselected() -> void:
    object_name_label.text = "Selected: None"
    if info_panel:
        info_panel.visible = false
    emit_signal("structure_deselected")

func _on_structure_hovered(structure_name: String, _mesh: MeshInstance3D) -> void:
    # Show hover feedback only if nothing is selected
    if selection_manager.get_selected_structure_name().is_empty():
        object_name_label.text = "Hover: " + structure_name

func _on_structure_unhovered() -> void:
    # Clear hover feedback only if nothing is selected
    if selection_manager.get_selected_structure_name().is_empty():
        object_name_label.text = "Selected: None"

func _on_info_panel_closed() -> void:
    if info_panel:
        info_panel.queue_free()
        info_panel = null

func _on_models_loaded(model_names: Array) -> void:
    print("Models loaded: " + str(model_names))
    emit_signal("models_loaded", model_names)
    
    # Setup model control panel
    if model_control_panel and model_control_panel.has_method("setup_with_models"):
        model_control_panel.setup_with_models(model_names)

func _on_model_load_failed(model_path: String, error: String) -> void:
    print("Failed to load model " + model_path + ": " + error)

func _on_model_selected(model_name: String) -> void:
    if ModelSwitcherGlobal:
        ModelSwitcherGlobal.toggle_model_visibility(model_name)

func _on_model_visibility_changed(model_name: String, is_visible: bool) -> void:
    if model_control_panel and model_control_panel.has_method("update_button_state"):
        model_control_panel.update_button_state(model_name, is_visible)

# Structure information display
func _display_structure_info(structure_name: String) -> void:
    if not KB or not KB.is_loaded:
        print("Knowledge base not ready")
        return
    
    # Store last selected structure
    last_selected_structure = structure_name
    
    # Find structure in knowledge base
    var structure_id = _find_structure_id(structure_name)
    if structure_id.is_empty():
        print("Structure not found in knowledge base: " + structure_name)
        return
    
    # Get structure data
    var structure_data = KB.get_structure(structure_id)
    if not structure_data or structure_data.is_empty():
        print("No data found for structure: " + structure_id)
        return
    
    # Get UI layer
    var ui_layer: CanvasLayer = $UI_Layer
    if not ui_layer:
        push_error("[ERROR] UI_Layer not found")
        return
    
    # Remove existing panel if any
    if info_panel:
        info_panel.queue_free()
        info_panel = null
    
    # Create new panel with current theme
    info_panel = InfoPanelFactory.create_info_panel()
    if not info_panel:
        push_error("[ERROR] Failed to create info panel")
        return
    
    info_panel.name = "StructureInfoPanel"
    
    # Add to UI layer first
    if ui_layer and info_panel:
        ui_layer.add_child(info_panel)
        print("[INFO] Info panel added to UI layer")
    else:
        push_error("[ERROR] Cannot add info panel - ui_layer or info_panel is null")
        return
    
    # Apply responsive positioning and sizing
    var viewport_size = get_viewport().get_visible_rect().size
    if info_panel.has_method("_update_responsive_layout"):
        # Enhanced panel has built-in responsive behavior
        info_panel._update_responsive_layout()
    else:
        # Legacy panels need manual positioning
        info_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_RIGHT)
        info_panel.position.x -= 400  # Move it in from the right edge
        info_panel.custom_minimum_size = Vector2(380, 500)
    
    # Connect panel signals
    _connect_panel_signals()
    
    # Display the data using the appropriate method
    if info_panel.has_method("display_structure_info"):
        # Enhanced panel method
        info_panel.display_structure_info(structure_data)
    elif info_panel.has_method("display_structure_data"):
        # Legacy panel method
        info_panel.display_structure_data(structure_data)
        info_panel.visible = true
    else:
        print("[ERROR] Info panel missing display methods")

func _find_structure_id(mesh_name: String) -> String:
    """Find structure ID by mesh name"""
    var lower_name = mesh_name.to_lower()
    var structure_ids = KB.get_all_structure_ids()
    
    # Try exact match first
    for id in structure_ids:
        var structure = KB.get_structure(id)
        if structure.has("displayName") and structure.displayName.to_lower() == lower_name:
            return id
    
    # Try partial match
    for id in structure_ids:
        var structure = KB.get_structure(id)
        if structure.has("displayName"):
            var display_name = structure.displayName.to_lower()
            if lower_name.contains(display_name) or display_name.contains(lower_name):
                return id
    
    return ""

# Refresh panel with new theme
func refresh_info_panel() -> void:
    """Recreate the info panel with the current theme if one is visible"""
    if info_panel and info_panel.visible and not last_selected_structure.is_empty():
        print("[THEME] Refreshing panel for: " + last_selected_structure)
        # Let the old panel finish freeing before creating new one
        await get_tree().process_frame
        _display_structure_info(last_selected_structure)

func _print_instructions() -> void:
    print("\n=== NEUROVIS CONTROLS ===")
    print("• Right-click: Select brain structures")
    print("• Left-click + drag: Orbit camera")
    print("• Middle-click + drag: Pan camera") 
    print("• Mouse wheel: Zoom")
    print("• F: Focus view")
    print("• R: Reset camera")
    print("• 1/3/7: Front/Right/Top view")
    print("========================\n")

# Enhanced UI Panel Signal Handlers
func _on_section_toggled(section_name: String, expanded: bool) -> void:
    print("[ENHANCED_UI] Section '%s' %s" % [section_name, "expanded" if expanded else "collapsed"])
    # Optional: Save section state preferences

func _on_structure_bookmarked(structure_id: String, bookmarked: bool) -> void:
    print("[ENHANCED_UI] Structure %s bookmark status: %s" % [structure_id, bookmarked])
    # TODO: Save bookmark state to persistent storage

func _on_structure_search_requested(query: String) -> void:
    print("[ENHANCED_UI] Search requested: %s" % query)
    # TODO: Implement search functionality across knowledge base

func _on_related_structure_selected(structure_id: String) -> void:
    print("[ENHANCED_UI] Related structure selected: %s" % structure_id)
    # Display the related structure
    _display_structure_info(structure_id)

func _on_quiz_requested(structure_id: String) -> void:
    print("[ENHANCED_UI] Quiz requested for: %s" % structure_id)
    # TODO: Launch quiz interface for this structure

func _on_notes_requested(structure_id: String) -> void:
    print("[ENHANCED_UI] Notes requested for: %s" % structure_id)
    # TODO: Open notes interface for this structure

func _on_study_plan_requested(structure_id: String) -> void:
    print("[ENHANCED_UI] Study plan requested for: %s" % structure_id)
    # TODO: Generate and display study plan

func _on_fullscreen_requested(structure_id: String) -> void:
    print("[ENHANCED_UI] Fullscreen mode requested for: %s" % structure_id)
    # TODO: Enter fullscreen study mode

func _on_feedback_submitted(structure_id: String, feedback: Dictionary) -> void:
    print("[ENHANCED_UI] Feedback submitted for: %s" % structure_id)
    print("Feedback data: %s" % feedback)
    # TODO: Process and store user feedback

# Debug command registration
func _register_debug_commands() -> void:
    if not OS.is_debug_build() or not DebugCmd:
        return
    
    DebugCmd.register_command("reset_camera", func(): camera_controller.reset_view(), "Reset camera")
    DebugCmd.register_command("list_models", _debug_list_models, "List models")
    DebugCmd.register_command("test_selection", _debug_test_selection, "Test selection")

func _debug_list_models() -> void:
    if ModelSwitcherGlobal:
        var models = ModelSwitcherGlobal.get_model_names()
        print("Models: " + str(models))

func _debug_test_selection() -> void:
    var center = get_viewport().get_visible_rect().size / 2.0
    selection_manager.handle_selection_at_position(center)