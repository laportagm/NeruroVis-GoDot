# ResourceDebugger.gd - Comprehensive resource loading debug utility
# NOTE: No class_name to avoid autoload conflicts - accessed via autoload name "ResourceDebugger"
extends Node

# Enable/disable debug logging
var debug_enabled: bool = true
var trace_stack: bool = true
var log_file_path: String = "user://resource_debug.log"

# Track resource loading attempts
var loading_attempts: Array[Dictionary] = []
var failed_loads: Array[Dictionary] = []

# Initialize debug logging
func initialize() -> void:
	if not debug_enabled:
		return
	
	print("[RESOURCE_DEBUG] ResourceDebugger initialized")
	
	# Clear previous log
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		file.store_line("=== Resource Loading Debug Log ===")
		file.store_line("Timestamp: " + Time.get_datetime_string_from_system())
		file.close()

# Safe resource loading with comprehensive debugging
func safe_load(resource_path: String, expected_type: String = "") -> Resource:
	var load_info = {
		"path": resource_path,
		"expected_type": expected_type,
		"timestamp": Time.get_datetime_string_from_system(),
		"stack_trace": _get_call_stack() if trace_stack else "disabled",
		"success": false,
		"error": ""
	}
	
	# Validate path
	if resource_path.is_empty():
		load_info.error = "Empty resource path"
		_log_failed_load(load_info)
		push_error("[RESOURCE_DEBUG] Attempted to load empty resource path")
		return null
	
	if resource_path == "res://":
		load_info.error = "Invalid root-only path 'res://'"
		_log_failed_load(load_info)
		push_error("[RESOURCE_DEBUG] Attempted to load invalid root path: " + resource_path)
		return null
	
	# Check if resource exists
	if not ResourceLoader.exists(resource_path):
		load_info.error = "Resource does not exist"
		_log_failed_load(load_info)
		push_error("[RESOURCE_DEBUG] Resource not found: " + resource_path)
		return null
	
	# Attempt to load
	var resource = ResourceLoader.load(resource_path)
	if resource == null:
		load_info.error = "ResourceLoader.load() returned null"
		_log_failed_load(load_info)
		push_error("[RESOURCE_DEBUG] Failed to load existing resource: " + resource_path)
		return null
	
	# Type validation
	if not expected_type.is_empty() and not resource.is_class(expected_type):
		load_info.error = "Type mismatch - expected: " + expected_type + ", got: " + resource.get_class()
		_log_failed_load(load_info)
		push_warning("[RESOURCE_DEBUG] Type mismatch for " + resource_path + " - expected: " + expected_type + ", got: " + resource.get_class())
	
	# Success
	load_info.success = true
	loading_attempts.append(load_info)
	_log_successful_load(load_info)
	
	if debug_enabled:
		print("[RESOURCE_DEBUG] Successfully loaded: " + resource_path + " (" + resource.get_class() + ")")
	
	return resource

# Log failed load attempt
func _log_failed_load(load_info: Dictionary) -> void:
	failed_loads.append(load_info)
	loading_attempts.append(load_info)
	
	if debug_enabled:
		print("[RESOURCE_DEBUG] FAILED: " + load_info.path + " - " + load_info.error)
	
	_write_to_log_file("FAILED LOAD", load_info)

# Log successful load
func _log_successful_load(load_info: Dictionary) -> void:
	_write_to_log_file("SUCCESS", load_info)

# Write to debug log file
func _write_to_log_file(status: String, load_info: Dictionary) -> void:
	if not debug_enabled:
		return
	
	var file = FileAccess.open(log_file_path, FileAccess.WRITE_READ)
	if not file:
		return
	
	file.seek_end()
	file.store_line("")
	file.store_line("[" + status + "] " + load_info.timestamp)
	file.store_line("Path: " + load_info.path)
	file.store_line("Expected Type: " + load_info.expected_type)
	if not load_info.success:
		file.store_line("Error: " + load_info.error)
	if trace_stack and load_info.has("stack_trace"):
		file.store_line("Call Stack: " + str(load_info.stack_trace))
	file.close()

# Get simplified call stack
func _get_call_stack() -> String:
	var stack = get_stack()
	var result = ""
	for i in range(min(5, stack.size())):  # Limit to 5 frames
		var frame = stack[i]
		result += frame.source + ":" + str(frame.line) + " in " + frame.function + "\n"
	return result

# Monitor resource loading across the application
func hook_resource_loader() -> void:
	if not debug_enabled:
		return
	
	print("[RESOURCE_DEBUG] Hooking ResourceLoader for monitoring...")
	# Note: In a real implementation, you might want to override ResourceLoader methods
	# For now, we'll rely on manual calls to safe_load()

# Generate debug report
func generate_report() -> String:
	var report = "=== Resource Loading Debug Report ===\n"
	report += "Total attempts: " + str(loading_attempts.size()) + "\n"
	report += "Failed loads: " + str(failed_loads.size()) + "\n"
	report += "Success rate: " + str((loading_attempts.size() - failed_loads.size()) * 100.0 / max(1, loading_attempts.size())) + "%\n\n"
	
	if failed_loads.size() > 0:
		report += "Failed Loads:\n"
		for fail in failed_loads:
			report += "- " + fail.path + " (" + fail.error + ")\n"
	
	return report

# Print debug report to console
func print_report() -> void:
	print(generate_report())

# Export debug data to file
func export_debug_data(file_path: String = "user://resource_debug_export.json") -> bool:
	var data = {
		"loading_attempts": loading_attempts,
		"failed_loads": failed_loads,
		"timestamp": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[RESOURCE_DEBUG] Cannot write to: " + file_path)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("[RESOURCE_DEBUG] Debug data exported to: " + file_path)
	return true