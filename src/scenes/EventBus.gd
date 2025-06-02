## EventBus.gd
## Central event coordination system for educational platform
##
## This autoload singleton manages all educational events between systems,
## providing loose coupling and clear educational event flow.
## Designed for AI-friendly development with clear event contracts.
##
## @tutorial: Educational event patterns
## @version: 3.0 - Clean Scene-Based Architecture

extends Node

# === EDUCATIONAL LEARNING EVENTS ===
## Emitted when user starts learning about a brain structure
signal structure_learning_started(structure_data: Dictionary)
## Emitted when structure learning session ends
signal structure_learning_ended()
## Emitted when user previews a structure (hover)
signal structure_preview_started(structure_data: Dictionary)
## Emitted when structure preview ends
signal structure_preview_ended()
## Emitted when multiple structures are selected for comparison
signal comparison_learning_started(structures: Array)

# === EDUCATIONAL PROGRESS EVENTS ===
## Emitted when learning objective is completed
signal learning_objective_completed(objective_data: Dictionary)
## Emitted when learning progress is updated
signal learning_progress_updated(progress_data: Dictionary)
## Emitted when assessment is started
signal assessment_started(assessment_data: Dictionary)
## Emitted when assessment is completed
signal assessment_completed(results: Dictionary)

# === UI DISPLAY EVENTS ===
## Emitted when educational information panel should be displayed
signal educational_panel_requested(panel_type: String, content_data: Dictionary)
## Emitted when panel should be hidden
signal educational_panel_dismissed(panel_type: String)
## Emitted when UI theme should change
signal ui_theme_change_requested(theme_mode: String)
## Emitted when accessibility settings change
signal accessibility_settings_changed(settings: Dictionary)

# === 3D VISUALIZATION EVENTS ===
## Emitted when 3D visualization should focus on specific structure
signal visualization_focus_requested(target_data: Dictionary)
## Emitted when camera view should change
signal camera_view_change_requested(view_data: Dictionary)
## Emitted when model visibility should change
signal model_visibility_change_requested(model_name: String, visible: bool)

# === AI ASSISTANT EVENTS ===
## Emitted when AI assistant should be shown
signal ai_assistant_requested(context_data: Dictionary)
## Emitted when user asks AI a question
signal ai_question_asked(question: String, context: Dictionary)
## Emitted when AI provides an answer
signal ai_answer_provided(answer: String, context: Dictionary)

# === SYSTEM EVENTS ===
## Emitted when system initialization is complete
signal educational_system_ready()
## Emitted when system error occurs
signal system_error_occurred(error_data: Dictionary)
## Emitted when debug command is executed
signal debug_command_executed(command: String, result: Dictionary)

# === EVENT TRACKING ===
var _event_history: Array[Dictionary] = []
var _max_history_size: int = 100

func _ready() -> void:
	print("[EventBus] Educational event coordination system ready")

# === EVENT EMISSION HELPERS ===
func emit_structure_learning_started(structure_data: Dictionary) -> void:
	"""Emit structure learning started event with analytics tracking"""
	_track_event("structure_learning_started", structure_data)
	structure_learning_started.emit(structure_data)

func emit_structure_learning_ended() -> void:
	"""Emit structure learning ended event"""
	_track_event("structure_learning_ended", {})
	structure_learning_ended.emit()

func emit_educational_panel_request(panel_type: String, content_data: Dictionary) -> void:
	"""Request educational panel display"""
	_track_event("educational_panel_requested", {"panel_type": panel_type})
	educational_panel_requested.emit(panel_type, content_data)

func emit_visualization_focus_request(target_data: Dictionary) -> void:
	"""Request 3D visualization focus"""
	_track_event("visualization_focus_requested", target_data)
	visualization_focus_requested.emit(target_data)

func emit_ai_question(question: String, context: Dictionary = {}) -> void:
	"""Emit AI question with educational context"""
	_track_event("ai_question_asked", {"question": question, "context": context})
	ai_question_asked.emit(question, context)

func emit_learning_progress_update(progress_data: Dictionary) -> void:
	"""Update learning progress"""
	_track_event("learning_progress_updated", progress_data)
	learning_progress_updated.emit(progress_data)

# === EVENT TRACKING ===
func _track_event(event_type: String, data: Dictionary) -> void:
	"""Track event for analytics and debugging"""
	var event_record = {
		"timestamp": Time.get_unix_time_from_system(),
		"event_type": event_type,
		"data": data
	}
	
	_event_history.append(event_record)
	
	# Maintain history size limit
	if _event_history.size() > _max_history_size:
		_event_history.pop_front()
	
	# Log educational events for debugging
	if OS.is_debug_build():
		print("[EventBus] %s: %s" % [event_type, str(data).substr(0, 100)])

# === ANALYTICS AND DEBUGGING ===
func get_recent_events(count: int = 10) -> Array[Dictionary]:
	"""Get recent events for debugging"""
	var start_index = max(0, _event_history.size() - count)
	return _event_history.slice(start_index)

func get_event_statistics() -> Dictionary:
	"""Get event statistics for analytics"""
	var stats = {}
	for event in _event_history:
		var event_type = event.get("event_type", "unknown")
		stats[event_type] = stats.get(event_type, 0) + 1
	
	return {
		"total_events": _event_history.size(),
		"event_types": stats,
		"time_range": {
			"start": _event_history[0].get("timestamp", 0) if _event_history.size() > 0 else 0,
			"end": _event_history[-1].get("timestamp", 0) if _event_history.size() > 0 else 0
		}
	}

func clear_event_history() -> void:
	"""Clear event history (for privacy/testing)"""
	_event_history.clear()
	print("[EventBus] Event history cleared")

# === CONNECTION HELPERS ===
func connect_educational_system(system: Node) -> void:
	"""Helper to connect a system to educational events"""
	print("[EventBus] Connecting educational system: %s" % system.name)
	
	# Connect common educational events
	if system.has_method("_on_structure_learning_started"):
		structure_learning_started.connect(system._on_structure_learning_started)
	
	if system.has_method("_on_structure_learning_ended"):
		structure_learning_ended.connect(system._on_structure_learning_ended)
	
	if system.has_method("_on_educational_panel_requested"):
		educational_panel_requested.connect(system._on_educational_panel_requested)
	
	if system.has_method("_on_visualization_focus_requested"):
		visualization_focus_requested.connect(system._on_visualization_focus_requested)

func disconnect_educational_system(system: Node) -> void:
	"""Helper to disconnect a system from educational events"""
	print("[EventBus] Disconnecting educational system: %s" % system.name)
	
	# Disconnect all signals from this system
	for signal_info in get_signal_list():
		var signal_name = signal_info.name
		var signal_obj = get(signal_name)
		if signal_obj and signal_obj.is_connected(system._on_structure_learning_started):
			signal_obj.disconnect(system._on_structure_learning_started)