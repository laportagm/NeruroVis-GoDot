extends Node

# A1-NeuroVis Centralized Error Tracking and Recovery System
# Provides comprehensive error logging, categorization, and automatic recovery

signal error_logged(error_data: Dictionary)
signal recovery_attempted(error_type: String, success: bool)
signal critical_error_detected(error_data: Dictionary)

enum ErrorLevel {
	DEBUG,
	INFO,
	WARNING,
	ERROR,
	CRITICAL
}

enum ErrorCategory {
	SYSTEM,
	MODEL_LOADING,
	UI_INTERACTION,
	CAMERA_CONTROL,
	KNOWLEDGE_BASE,
	PERFORMANCE,
	NETWORK,
	FILE_SYSTEM
}

static var instance: ErrorTracker
var error_log: Array[Dictionary] = []
var error_counts: Dictionary = {}
var recovery_strategies: Dictionary = {}
var max_log_entries: int = 1000
var auto_recovery_enabled: bool = true

func _init():
	instance = self
	setup_recovery_strategies()

func _ready():
	print("🔍 ErrorTracker initialized - Monitoring system health")

static func log_error(level: ErrorLevel, category: ErrorCategory, message: String, details: Dictionary = {}):
	if not instance:
		push_error("ErrorTracker not initialized")
		return
	
	instance._log_error_internal(level, category, message, details)

func _log_error_internal(level: ErrorLevel, category: ErrorCategory, message: String, details: Dictionary = {}):
	var timestamp = Time.get_datetime_string_from_system()
	var stack_trace = get_stack()
	
	var error_data = {
		"timestamp": timestamp,
		"level": ErrorLevel.keys()[level],
		"category": ErrorCategory.keys()[category],
		"message": message,
		"details": details,
		"stack_trace": stack_trace
	}
	
	# Add to log
	error_log.append(error_data)
	if error_log.size() > max_log_entries:
		error_log.pop_front()
	
	# Update error counts
	var error_key = "%s_%s" % [ErrorLevel.keys()[level], ErrorCategory.keys()[category]]
	error_counts[error_key] = error_counts.get(error_key, 0) + 1
	
	# Print to console with color coding
	_print_colored_error(error_data)
	
	# Emit signals
	error_logged.emit(error_data)
	
	# Handle critical errors
	if level == ErrorLevel.CRITICAL:
		critical_error_detected.emit(error_data)
		_handle_critical_error(error_data)
	
	# Attempt recovery if enabled
	if auto_recovery_enabled and level >= ErrorLevel.ERROR:
		_attempt_recovery(category, error_data)

func _print_colored_error(error_data: Dictionary):
	var level = error_data.level
	var color_code = ""
	var icon = ""
	
	match level:
		"DEBUG":
			color_code = "[color=#888888]"
			icon = "🔍"
		"INFO":
			color_code = "[color=#4A90E2]"
			icon = "ℹ️"
		"WARNING":
			color_code = "[color=#F5A623]"
			icon = "⚠️"
		"ERROR":
			color_code = "[color=#D0021B]"
			icon = "❌"
		"CRITICAL":
			color_code = "[color=#B00020]"
			icon = "🚨"
	
	var output = "%s%s [%s][%s] %s: %s[/color]" % [
		color_code,
		icon,
		error_data.timestamp.split("T")[1].split(".")[0],
		error_data.category,
		error_data.level,
		error_data.message
	]
	
	print_rich(output)
	
	# Print details if available
	if not error_data.details.is_empty():
		print_rich("[color=#666666]   Details: %s[/color]" % str(error_data.details))

func setup_recovery_strategies():
	# Model Loading Recovery
	recovery_strategies[ErrorCategory.MODEL_LOADING] = {
		"strategy": _recover_model_loading,
		"max_attempts": 3,
		"cooldown": 2.0
	}
	
	# UI Interaction Recovery
	recovery_strategies[ErrorCategory.UI_INTERACTION] = {
		"strategy": _recover_ui_interaction,
		"max_attempts": 2,
		"cooldown": 1.0
	}
	
	# Camera Control Recovery
	recovery_strategies[ErrorCategory.CAMERA_CONTROL] = {
		"strategy": _recover_camera_control,
		"max_attempts": 2,
		"cooldown": 0.5
	}
	
	# Knowledge Base Recovery
	recovery_strategies[ErrorCategory.KNOWLEDGE_BASE] = {
		"strategy": _recover_knowledge_base,
		"max_attempts": 3,
		"cooldown": 1.0
	}
	
	# File System Recovery
	recovery_strategies[ErrorCategory.FILE_SYSTEM] = {
		"strategy": _recover_file_system,
		"max_attempts": 2,
		"cooldown": 1.0
	}

func _attempt_recovery(category: ErrorCategory, error_data: Dictionary):
	var strategy_key = category
	if not recovery_strategies.has(strategy_key):
		return
	
	var strategy = recovery_strategies[strategy_key]
	var attempt_key = "recovery_attempts_%s" % ErrorCategory.keys()[category]
	var attempts = error_data.get(attempt_key, 0)
	
	if attempts >= strategy.max_attempts:
		log_error(ErrorLevel.WARNING, ErrorCategory.SYSTEM,
			"Max recovery attempts reached for category: %s" % ErrorCategory.keys()[category])
		return
	
	# Wait for cooldown
	await get_tree().create_timer(strategy.cooldown).timeout
	
	print_rich("[color=#FFA500]🔧 Attempting recovery for %s (attempt %d/%d)[/color]" % [
		ErrorCategory.keys()[category],
		attempts + 1,
		strategy.max_attempts
	])
	
	var success = await strategy.strategy.call(error_data)
	recovery_attempted.emit(ErrorCategory.keys()[category], success)
	
	if success:
		print_rich("[color=#00FF00]✅ Recovery successful for %s[/color]" % ErrorCategory.keys()[category])
	else:
		print_rich("[color=#FF0000]❌ Recovery failed for %s[/color]" % ErrorCategory.keys()[category])

# Recovery Strategy Implementations
func _recover_model_loading(_error_data: Dictionary) -> bool:
	if ModelSwitcherGlobal:
		# Try to reload current models
		var available_models = ModelSwitcherGlobal.get_available_models()
		if available_models.size() > 0:
			# Switch to a known working model
			ModelSwitcherGlobal.switch_to_model(available_models[0])
			return true
	return false

func _recover_ui_interaction(_error_data: Dictionary) -> bool:
	# Try to reset UI to default state
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_method("reset_ui_state"):
		main_scene.reset_ui_state()
		return true
	return false

func _recover_camera_control(_error_data: Dictionary) -> bool:
	# Reset camera to default position
	var camera_controller = get_tree().get_first_node_in_group("camera_controller")
	if camera_controller and camera_controller.has_method("reset_to_default"):
		camera_controller.reset_to_default()
		return true
	return false

func _recover_knowledge_base(_error_data: Dictionary) -> bool:
	# Try to reload knowledge base
	if KB and KB.has_method("reload_data"):
		return KB.reload_data()
	return false

func _recover_file_system(_error_data: Dictionary) -> bool:
	# Check if file system is accessible
	var test_path = "res://project.godot"
	if ResourceLoader.exists(test_path):
		return true
	return false

func _handle_critical_error(error_data: Dictionary):
	print_rich("[color=#B00020]🚨 CRITICAL ERROR DETECTED - Initiating emergency procedures[/color]")
	
	# Save current state
	save_error_report()
	
	# Try to save user progress if applicable
	_emergency_save_state()
	
	# Notify user
	if get_tree().current_scene.has_method("show_critical_error_dialog"):
		get_tree().current_scene.show_critical_error_dialog(error_data)

func _emergency_save_state():
	# Save current application state for recovery
	var state_data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"current_scene": get_tree().current_scene.scene_file_path if get_tree().current_scene else "unknown",
		"error_count": error_counts,
		"last_errors": error_log.slice(-10) # Last 10 errors
	}
	
	var file = FileAccess.open("user://emergency_state.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(state_data))
		file.close()
		print("💾 Emergency state saved")

# Public API Methods
static func get_error_summary() -> Dictionary:
	if not instance:
		return {}
	
	return {
		"total_errors": instance.error_log.size(),
		"error_counts": instance.error_counts,
		"recent_errors": instance.error_log.slice(-5),
		"critical_errors": instance.error_log.filter(func(e): return e.level == "CRITICAL")
	}

static func save_error_report(filepath: String = "") -> bool:
	if not instance:
		return false
	
	var timestamp = Time.get_datetime_string_from_system().replace(":", "-")
	var default_path = "user://error_report_%s.json" % timestamp
	var save_path = filepath if filepath != "" else default_path
	
	var report_data = {
		"generated": timestamp,
		"total_errors": instance.error_log.size(),
		"error_counts": instance.error_counts,
		"full_log": instance.error_log,
		"system_info": {
			"godot_version": Engine.get_version_info(),
			"platform": OS.get_name(),
			"memory_usage": {"static": OS.get_static_memory_usage(), "dynamic": OS.get_static_memory_peak_usage()}
		}
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(report_data, "\t"))
		file.close()
		print("📄 Error report saved to: %s" % save_path)
		return true
	
	return false

static func clear_error_log():
	if instance:
		instance.error_log.clear()
		instance.error_counts.clear()
		print("🧹 Error log cleared")

static func set_auto_recovery(enabled: bool):
	if instance:
		instance.auto_recovery_enabled = enabled
		print("🔧 Auto recovery %s" % ("enabled" if enabled else "disabled"))

# Debug command integration
func register_debug_commands():
	if DebugCmd:
		DebugCmd.register_command("error_summary", _cmd_error_summary, "Show error tracking summary")
		DebugCmd.register_command("save_error_report", _cmd_save_error_report, "Save error report to file")
		DebugCmd.register_command("clear_errors", _cmd_clear_errors, "Clear error log")
		DebugCmd.register_command("toggle_recovery", _cmd_toggle_recovery, "Toggle auto recovery")

static func _cmd_error_summary(_args: Array):
	var summary = get_error_summary()
	print_rich("[color=#4A90E2]📊 Error Summary[/color]")
	print("Total errors: %d" % summary.total_errors)
	print("Error counts: %s" % str(summary.error_counts))
	print("Critical errors: %d" % summary.critical_errors.size())

static func _cmd_save_error_report(_args: Array):
	save_error_report()

static func _cmd_clear_errors(_args: Array):
	clear_error_log()

static func _cmd_toggle_recovery(_args: Array):
	if instance:
		set_auto_recovery(not instance.auto_recovery_enabled)
