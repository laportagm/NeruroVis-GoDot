## ErrorNotification.gd
## Educational error notification component for NeuroVis
##
## Displays educational-context-aware error messages with appropriate styling
## and accessibility features for the educational neuroscience platform.
##
## @educational_context: Error handling in educational environment
## @version: 2.0

class_name ErrorNotification
extends Control

# === CONSTANTS ===
const DISPLAY_DURATION: float = 5.0
const FADE_DURATION: float = 0.3
const ERROR_ICON: String = "⚠️"
const WARNING_ICON: String = "⚡"
const INFO_ICON: String = "ℹ️"

# === EXPORTS ===
@export var auto_dismiss: bool = true
@export var dismiss_duration: float = DISPLAY_DURATION
@export var notification_type: NotificationType = NotificationType.ERROR

# === ENUMS ===
enum NotificationType { ERROR, WARNING, INFO, SUCCESS }

# === SIGNALS ===
## Emitted when the notification is dismissed
signal notification_dismissed()

## Emitted when the notification is clicked
signal notification_clicked()

# === PRIVATE VARIABLES ===
var _label: Label
var _close_button: Button
var _icon_label: Label
var _background_panel: Panel
var _dismiss_timer: Timer

# === LIFECYCLE METHODS ===
func _ready() -> void:
	"""Initialize the error notification component"""
	_setup_ui_structure()
	_apply_educational_theme()
	_setup_interactions()
	
	# Start auto-dismiss timer if enabled
	if auto_dismiss:
		_start_dismiss_timer()

# === PUBLIC METHODS ===
## Display an educational error message
## @param message: The error message to display
## @param type: The type of notification (error, warning, info, success)
func show_notification(message: String, type: NotificationType = NotificationType.ERROR) -> void:
	"""Display an educational error notification"""
	notification_type = type
	
	if _label:
		_label.text = message
	
	if _icon_label:
		_icon_label.text = _get_icon_for_type(type)
	
	_apply_type_styling(type)
	
	# Animate entrance
	UIThemeManager.animate_enhanced_entrance(self)
	
	# Reset dismiss timer
	if auto_dismiss and _dismiss_timer:
		_dismiss_timer.start(dismiss_duration)

## Dismiss the notification
func dismiss_notification() -> void:
	"""Dismiss the notification with animation"""
	if _dismiss_timer:
		_dismiss_timer.stop()
	
	# Animate exit
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, FADE_DURATION)
	tween.tween_callback(_on_notification_dismissed)

## Set the notification message
## @param message: The message text to display
func set_message(message: String) -> void:
	"""Set the notification message"""
	if _label:
		_label.text = message

# === PRIVATE METHODS ===
func _setup_ui_structure() -> void:
	"""Setup the UI structure for the notification"""
	# Main background panel
	_background_panel = Panel.new()
	_background_panel.name = "BackgroundPanel"
	add_child(_background_panel)
	
	# Container for content
	var container = HBoxContainer.new()
	container.name = "ContentContainer"
	_background_panel.add_child(container)
	
	# Icon label
	_icon_label = Label.new()
	_icon_label.name = "IconLabel"
	_icon_label.text = ERROR_ICON
	container.add_child(_icon_label)
	
	# Message label
	_label = Label.new()
	_label.name = "MessageLabel"
	_label.text = "Error message"
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(_label)
	
	# Close button
	_close_button = Button.new()
	_close_button.name = "CloseButton"
	_close_button.text = "✕"
	_close_button.custom_minimum_size = Vector2(32, 32)
	container.add_child(_close_button)
	
	# Dismiss timer
	_dismiss_timer = Timer.new()
	_dismiss_timer.name = "DismissTimer"
	_dismiss_timer.wait_time = dismiss_duration
	_dismiss_timer.one_shot = true
	add_child(_dismiss_timer)

func _apply_educational_theme() -> void:
	"""Apply educational theme styling"""
	# Apply panel styling
	UIThemeManager.apply_enhanced_panel_style(_background_panel, "elevated")
	
	# Apply typography
	UIThemeManager.apply_enhanced_typography(_icon_label, "heading")
	UIThemeManager.apply_enhanced_typography(_label, "body")
	UIThemeManager.apply_enhanced_typography(_close_button, "small")
	
	# Apply button styling
	UIThemeManager.apply_enhanced_button_style(_close_button, "secondary")
	
	# Set size and position
	custom_minimum_size = Vector2(320, 80)
	anchor_left = 1.0
	anchor_right = 1.0
	anchor_top = 0.0
	anchor_bottom = 0.0
	offset_left = -340  # Position from right edge
	offset_right = -20
	offset_top = 20
	offset_bottom = 100

func _apply_type_styling(type: NotificationType) -> void:
	"""Apply styling based on notification type"""
	var color: Color
	
	match type:
		NotificationType.ERROR:
			color = UIThemeManager.ACCENT_RED
		NotificationType.WARNING:
			color = UIThemeManager.ACCENT_ORANGE
		NotificationType.INFO:
			color = UIThemeManager.ACCENT_BLUE
		NotificationType.SUCCESS:
			color = UIThemeManager.ACCENT_GREEN
		_:
			color = UIThemeManager.ACCENT_RED
	
	# Apply color to icon
	if _icon_label:
		_icon_label.add_theme_color_override("font_color", color)
	
	# Apply border color if available
	if _background_panel and _background_panel.has_theme_stylebox("panel"):
		var style = _background_panel.get_theme_stylebox("panel").duplicate()
		if style is StyleBoxFlat:
			style.border_color = color
			_background_panel.add_theme_stylebox_override("panel", style)

func _setup_interactions() -> void:
	"""Setup interaction handling"""
	# Close button
	if _close_button:
		_close_button.pressed.connect(_on_close_button_pressed)
	
	# Dismiss timer
	if _dismiss_timer:
		_dismiss_timer.timeout.connect(_on_dismiss_timer_timeout)
	
	# Click to dismiss
	gui_input.connect(_on_notification_input)

func _get_icon_for_type(type: NotificationType) -> String:
	"""Get icon character for notification type"""
	match type:
		NotificationType.ERROR:
			return ERROR_ICON
		NotificationType.WARNING:
			return WARNING_ICON
		NotificationType.INFO:
			return INFO_ICON
		NotificationType.SUCCESS:
			return "✅"
		_:
			return ERROR_ICON

func _start_dismiss_timer() -> void:
	"""Start the auto-dismiss timer"""
	if _dismiss_timer:
		_dismiss_timer.start(dismiss_duration)

# === EVENT HANDLERS ===
func _on_close_button_pressed() -> void:
	"""Handle close button press"""
	dismiss_notification()

func _on_dismiss_timer_timeout() -> void:
	"""Handle auto-dismiss timer timeout"""
	dismiss_notification()

func _on_notification_input(event: InputEvent) -> void:
	"""Handle notification click"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		notification_clicked.emit()
		# Don't auto-dismiss on click, let the user decide

func _on_notification_dismissed() -> void:
	"""Handle notification dismissal"""
	notification_dismissed.emit()
	queue_free()

# === STATIC FACTORY METHODS ===
## Create and show an error notification
## @param message: Error message to display
## @param parent: Parent node to add notification to
## @returns: ErrorNotification instance
static func show_error(message: String, parent: Node) -> ErrorNotification:
	"""Factory method to create and show an error notification"""
	var notification = ErrorNotification.new()
	parent.add_child(notification)
	notification.show_notification(message, NotificationType.ERROR)
	return notification

## Create and show a warning notification
## @param message: Warning message to display
## @param parent: Parent node to add notification to
## @returns: ErrorNotification instance
static func show_warning(message: String, parent: Node) -> ErrorNotification:
	"""Factory method to create and show a warning notification"""
	var notification = ErrorNotification.new()
	parent.add_child(notification)
	notification.show_notification(message, NotificationType.WARNING)
	return notification

## Create and show an info notification
## @param message: Info message to display
## @param parent: Parent node to add notification to
## @returns: ErrorNotification instance
static func show_info(message: String, parent: Node) -> ErrorNotification:
	"""Factory method to create and show an info notification"""
	var notification = ErrorNotification.new()
	parent.add_child(notification)
	notification.show_notification(message, NotificationType.INFO)
	return notification

## Create and show a success notification
## @param message: Success message to display
## @param parent: Parent node to add notification to
## @returns: ErrorNotification instance
static func show_success(message: String, parent: Node) -> ErrorNotification:
	"""Factory method to create and show a success notification"""
	var notification = ErrorNotification.new()
	parent.add_child(notification)
	notification.show_notification(message, NotificationType.SUCCESS)
	return notification