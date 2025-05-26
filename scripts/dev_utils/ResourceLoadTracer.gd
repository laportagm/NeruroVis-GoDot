# ResourceLoadTracer.gd - Traces empty resource loading to find "res://" errors
# Global autoload singleton for resource loading tracing
extends Node

# Tracing configuration
var trace_enabled: bool = true
var log_all_loads: bool = false
var empty_path_alerts: bool = true

# Storage for tracing data
var traced_calls: Array[Dictionary] = []
var empty_path_calls: Array[Dictionary] = []

# Initialize the tracer
func initialize() -> void:
	if not trace_enabled:
		return
	
	print("[RESOURCE_TRACER] Initialized - monitoring resource loading")
	print("[RESOURCE_TRACER] Use ResourceLoadTracer.trace_load() instead of direct load() calls")

# Trace a resource loading attempt with detailed context
func trace_load(resource_path: String, caller_info: String = "") -> Resource:
	var call_data = {
		"path": resource_path,
		"caller": caller_info,
		"timestamp": Time.get_datetime_string_from_system(),
		"stack": _get_simplified_stack(),
		"result": "unknown"
	}
	
	# Check for problematic patterns
	var is_problematic = false
	
	if resource_path.is_empty():
		call_data.result = "EMPTY_PATH_ERROR"
		is_problematic = true
		_alert_empty_path(call_data, "Empty string passed to resource loader")
	
	elif resource_path == "res://":
		call_data.result = "ROOT_PATH_ERROR" 
		is_problematic = true
		_alert_empty_path(call_data, "Root-only path 'res://' - invalid resource path")
	
	elif resource_path.begins_with("res://") and resource_path.length() <= 6:
		call_data.result = "INVALID_SHORT_PATH"
		is_problematic = true
		_alert_empty_path(call_data, "Suspiciously short resource path: " + resource_path)
	
	# Store the call for analysis
	traced_calls.append(call_data)
	if is_problematic:
		empty_path_calls.append(call_data)
	
	# Log if enabled
	if log_all_loads or is_problematic:
		_log_load_attempt(call_data, is_problematic)
	
	# Early return for problematic paths
	if is_problematic:
		push_error("[RESOURCE_TRACER] Blocked problematic resource load: " + resource_path)
		return null
	
	# Attempt actual load
	if not ResourceLoader.exists(resource_path):
		call_data.result = "FILE_NOT_FOUND"
		push_error("[RESOURCE_TRACER] Resource does not exist: " + resource_path)
		return null
	
	var resource = ResourceLoader.load(resource_path)
	if resource:
		call_data.result = "SUCCESS"
	else:
		call_data.result = "LOAD_FAILED"
		push_error("[RESOURCE_TRACER] Failed to load existing resource: " + resource_path)
	
	return resource

# Alert for empty/invalid path detection
func _alert_empty_path(call_data: Dictionary, message: String) -> void:
	if not empty_path_alerts:
		return
	
	print_rich("[color=red][RESOURCE_TRACER] ALERT: " + message + "[/color]")
	print("[RESOURCE_TRACER] Path: '" + call_data.path + "'")
	print("[RESOURCE_TRACER] Caller: " + call_data.caller)
	print("[RESOURCE_TRACER] Call Stack:")
	for line in call_data.stack:
		print("  → " + line)
	print("[RESOURCE_TRACER] Timestamp: " + call_data.timestamp)
	print("================================================")

# Log a load attempt
func _log_load_attempt(call_data: Dictionary, is_problematic: bool) -> void:
	var prefix = "[RESOURCE_TRACER] " + ("⚠️ " if is_problematic else "✅ ")
	print(prefix + call_data.result + ": " + call_data.path)
	if not call_data.caller.is_empty():
		print("  Called from: " + call_data.caller)

# Get simplified call stack for debugging
func _get_simplified_stack() -> Array[String]:
	var stack = get_stack()
	var simplified: Array[String] = []
	
	# Skip the first few frames (this function, trace_load, etc.)
	for i in range(3, min(8, stack.size())):
		var frame = stack[i]
		var line = frame.source.get_file() + ":" + str(frame.line) + " in " + frame.function
		simplified.append(line)
	
	return simplified

# Trace preload attempts (compile-time loading)
func trace_preload(resource_path: String, caller_info: String = "") -> Resource:
	print("[RESOURCE_TRACER] Preload traced: " + resource_path + " from " + caller_info)
	
	if resource_path.is_empty() or resource_path == "res://":
		push_error("[RESOURCE_TRACER] Invalid preload path: " + resource_path)
		return null
	
	# Preload validation (though this is compile-time, so limited runtime checking)
	return load(resource_path)

# Generate a comprehensive report
func generate_report() -> String:
	var report = "=== Resource Loading Trace Report ===\n"
	report += "Total traced calls: " + str(traced_calls.size()) + "\n"
	report += "Problematic calls: " + str(empty_path_calls.size()) + "\n"
	report += "Success rate: " + str(_calculate_success_rate()) + "%\n\n"
	
	if empty_path_calls.size() > 0:
		report += "🚨 PROBLEMATIC CALLS:\n"
		for call in empty_path_calls:
			report += "- " + call.result + ": '" + call.path + "'\n"
			report += "  From: " + call.caller + "\n"
			report += "  Time: " + call.timestamp + "\n\n"
	
	# Success calls summary
	var success_calls = traced_calls.filter(func(call): return call.result == "SUCCESS")
	if success_calls.size() > 0:
		report += "✅ SUCCESSFUL LOADS: " + str(success_calls.size()) + "\n"
		for call in success_calls.slice(0, 5):  # Show first 5
			report += "- " + call.path + "\n"
		if success_calls.size() > 5:
			report += "... and " + str(success_calls.size() - 5) + " more\n"
	
	return report

# Print the report to console
func print_report() -> void:
	print(generate_report())

# Calculate success rate
func _calculate_success_rate() -> float:
	if traced_calls.is_empty():
		return 100.0
	
	var success_count = traced_calls.filter(func(call): return call.result == "SUCCESS").size()
	return (success_count * 100.0) / traced_calls.size()

# Export trace data for analysis
func export_trace_data(file_path: String = "user://resource_trace_export.json") -> bool:
	var data = {
		"traced_calls": traced_calls,
		"empty_path_calls": empty_path_calls,
		"summary": {
			"total_calls": traced_calls.size(),
			"problematic_calls": empty_path_calls.size(),
			"success_rate": _calculate_success_rate()
		},
		"export_timestamp": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if not file:
		push_error("[RESOURCE_TRACER] Cannot write to: " + file_path)
		return false
	
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	print("[RESOURCE_TRACER] Trace data exported to: " + file_path)
	return true

# Clear all traced data
func clear_trace_data() -> void:
	traced_calls.clear()
	empty_path_calls.clear()
	print("[RESOURCE_TRACER] Trace data cleared")

# Quick diagnostic for common issues
func diagnose_common_issues() -> void:
	print("[RESOURCE_TRACER] Running diagnostics...")
	
	# Check for common problematic patterns
	var patterns_to_check = [
		"",
		"res://",
		"res:///",
		"res://null",
		"null"
	]
	
	for pattern in patterns_to_check:
		print("Testing pattern: '" + pattern + "'")
		trace_load(pattern, "diagnostic_test")
	
	print("[RESOURCE_TRACER] Diagnostic complete - check output above")