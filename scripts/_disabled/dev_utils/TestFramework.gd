extends Node

# A1-NeuroVis Enhanced Testing Framework
# Comprehensive integration testing, stress testing, and automated validation

signal test_started(test_name: String)
signal test_completed(test_name: String, success: bool, duration: float)
signal test_suite_completed(suite_name: String, results: Dictionary)

enum TestType {
	UNIT,
	INTEGRATION,
	STRESS,
	PERFORMANCE,
	UI_INTERACTION,
	MEMORY_LEAK
}

static var instance
var test_results: Dictionary = {}
var current_test: String = ""
var test_start_time: int = 0
var test_config: Dictionary = {
	"stress_test_duration": 30.0,
	"memory_leak_threshold": 1024 * 1024,  # 1MB
	"performance_samples": 60,
	"ui_interaction_delay": 0.1
}

func _init():
	instance = self

func _ready():
	print("🧪 Enhanced TestFramework initialized - Comprehensive testing ready")

# Main test execution methods
static func run_comprehensive_tests():
	if not instance:
		print("❌ TestFramework not initialized")
		return
	
	print_rich("[color=#00FF00]🧪 === Running Comprehensive A1-NeuroVis Test Suite ===[/color]")
	
	# Run all test categories
	await instance._run_integration_tests()
	await instance._run_stress_tests()
	await instance._run_performance_tests()
	await instance._run_ui_interaction_tests()
	await instance._run_memory_leak_tests()
	
	instance._print_comprehensive_results()

static func run_test_category(category: TestType):
	if not instance:
		return
	
	match category:
		TestType.INTEGRATION:
			await instance._run_integration_tests()
		TestType.STRESS:
			await instance._run_stress_tests()
		TestType.PERFORMANCE:
			await instance._run_performance_tests()
		TestType.UI_INTERACTION:
			await instance._run_ui_interaction_tests()
		TestType.MEMORY_LEAK:
			await instance._run_memory_leak_tests()

# Integration Tests
func _run_integration_tests():
	print_rich("[color=#4A90E2]🔗 Running Integration Tests[/color]")
	
	await _test_model_loader_integration()
	await _test_camera_model_integration()
	await _test_ui_knowledge_base_integration()
	await _test_selection_info_panel_integration()
	await _test_debug_system_integration()

func _test_model_loader_integration():
	_start_test("Model Loader Integration")
	
	var success = true
	var details = {}
	
	# Test ModelSwitcher + ModelCoordinator integration
	var model_switcher = get_node_or_null("/root/ModelSwitcherGlobal")
	if not model_switcher:
		success = false
		details["error"] = "ModelSwitcher not available"
	else:
		var models = model_switcher.get_available_models()
		if models.size() == 0:
			success = false
			details["error"] = "No models loaded"
		else:
			# Test switching between models
			for model in models:
				model_switcher.switch_to_model(model)
				await get_tree().process_frame
				
				# Verify model is actually loaded
				var current_model = model_switcher.get_current_model()
				if current_model != model:
					success = false
					details["error"] = "Model switch failed for %s" % model
					break
	
	_complete_test("Model Loader Integration", success, details)

func _test_camera_model_integration():
	_start_test("Camera Model Integration")
	
	var success = true
	var details = {}
	
	# Test camera interaction with loaded models
	var camera_controller = get_tree().get_first_node_in_group("camera_controller")
	if not camera_controller:
		success = false
		details["error"] = "Camera controller not found"
	else:
		# Test camera reset
		if camera_controller.has_method("reset_to_default"):
			camera_controller.reset_to_default()
			await get_tree().create_timer(0.5).timeout
			
			# Test camera movement
			if camera_controller.has_method("orbit_camera"):
				camera_controller.orbit_camera(Vector2(0.1, 0.1))
				await get_tree().process_frame
			
			details["camera_position"] = camera_controller.global_position
		else:
			success = false
			details["error"] = "Camera controller missing reset method"
	
	_complete_test("Camera Model Integration", success, details)

func _test_ui_knowledge_base_integration():
	_start_test("UI Knowledge Base Integration")
	
	var success = true
	var details = {}
	
	# Test UI info panel with knowledge base
	var kb = get_node_or_null("/root/KB")
	if not kb:
		success = false
		details["error"] = "Knowledge base not available"
	else:
		var structure_count = kb.get_structure_count() if kb.has_method("get_structure_count") else 0
		details["structure_count"] = structure_count
		
		if structure_count == 0:
			success = false
			details["error"] = "No structures in knowledge base"
		else:
			# Test info panel display
			var info_panel = get_tree().get_first_node_in_group("info_panel")
			if info_panel and info_panel.has_method("display_structure_info"):
				# Test displaying first structure
				var structures = kb.get_all_structures() if kb.has_method("get_all_structures") else []
				if structures.size() > 0:
					info_panel.display_structure_info(structures[0])
					await get_tree().process_frame
					details["test_structure"] = structures[0].get("displayName", "unknown")
				else:
					success = false
					details["error"] = "Cannot retrieve structure data"
			else:
				success = false
				details["error"] = "Info panel not found or missing method"
	
	_complete_test("UI Knowledge Base Integration", success, details)

func _test_selection_info_panel_integration():
	_start_test("Selection Info Panel Integration")
	
	var success = true
	var details = {}
	
	# Test selection system with info panel
	var selection_manager = get_tree().get_first_node_in_group("selection_manager")
	if not selection_manager:
		success = false
		details["error"] = "Selection manager not found"
	else:
		# Test selection mechanism
		if selection_manager.has_method("simulate_selection"):
			var test_result = selection_manager.simulate_selection(Vector3.ZERO)
			details["selection_test"] = test_result
		
		# Test if info panel responds to selection
		var info_panel = get_tree().get_first_node_in_group("info_panel")
		if info_panel:
			details["info_panel_connected"] = true
		else:
			success = false
			details["error"] = "Info panel not responsive to selection"
	
	_complete_test("Selection Info Panel Integration", success, details)

func _test_debug_system_integration():
	_start_test("Debug System Integration")
	
	var success = true
	var details = {}
	
	# Test debug command system
	var debug_cmd = get_node_or_null("/root/DebugCmd")
	if not debug_cmd:
		success = false
		details["error"] = "Debug command system not available"
	else:
		var command_count = debug_cmd.get_command_count() if debug_cmd.has_method("get_command_count") else 0
		details["registered_commands"] = command_count
		
		# Test error tracker integration
		var error_tracker = get_node_or_null("/root/ErrorTracker")
		if error_tracker:
			details["error_tracker_available"] = true
			# Test logging an error - use static call
			ErrorTracker.log_error(ErrorTracker.ErrorLevel.INFO, ErrorTracker.ErrorCategory.SYSTEM, "Integration test")
		else:
			details["error_tracker_available"] = false
		
		# Test health monitor integration
		var health_monitor = get_node_or_null("/root/HealthMonitor")
		if health_monitor:
			details["health_monitor_available"] = true
			# Use static call instead of instance call
			var health_status = HealthMonitor.get_health_status()
			details["health_status"] = health_status
		else:
			details["health_monitor_available"] = false
	
	_complete_test("Debug System Integration", success, details)
	
	# Emit suite completed signal
	var integration_results = _get_suite_results("Integration")
	test_suite_completed.emit("Integration Tests", integration_results)

# Stress Tests
func _run_stress_tests():
	print_rich("[color=#FF6B35]💪 Running Stress Tests[/color]")
	
	await _stress_test_model_switching()
	await _stress_test_camera_operations()
	await _stress_test_ui_interactions()
	await _stress_test_knowledge_base_access()

func _stress_test_model_switching():
	_start_test("Model Switching Stress Test")
	
	var success = true
	var details = {"switches": 0, "failures": 0}
	var start_time = Time.get_ticks_msec()
	var duration = test_config.stress_test_duration * 1000  # Convert to ms
	
	var model_switcher = get_node_or_null("/root/ModelSwitcherGlobal")
	if not model_switcher:
		_complete_test("Model Switching Stress Test", false, {"error": "ModelSwitcher not available"})
		return
	
	var models = model_switcher.get_available_models() if model_switcher.has_method("get_available_models") else []
	if models.size() < 2:
		_complete_test("Model Switching Stress Test", false, {"error": "Need at least 2 models for stress test"})
		return
	
	while Time.get_ticks_msec() - start_time < duration:
		for model in models:
			if model_switcher.has_method("switch_to_model"):
				model_switcher.switch_to_model(model)
				await get_tree().process_frame
				
				# Verify switch worked
				var current = model_switcher.get_current_model() if model_switcher.has_method("get_current_model") else null
				if current != model:
					details.failures += 1
					success = false
			
			details.switches += 1
			
			# Check if time limit reached
			if Time.get_ticks_msec() - start_time >= duration:
				break
	
	details["success_rate"] = float(details.switches - details.failures) / float(details.switches) if details.switches > 0 else 0.0
	
	_complete_test("Model Switching Stress Test", success, details)

func _stress_test_camera_operations():
	_start_test("Camera Operations Stress Test")
	
	var success = true
	var details = {"operations": 0, "failures": 0}
	var start_time = Time.get_ticks_msec()
	var duration = test_config.stress_test_duration * 1000
	
	var camera_controller = get_tree().get_first_node_in_group("camera_controller")
	if not camera_controller:
		_complete_test("Camera Operations Stress Test", false, {"error": "Camera controller not found"})
		return
	
	while Time.get_ticks_msec() - start_time < duration:
		# Random camera operations
		var operation = randi() % 4
		match operation:
			0:  # Orbit
				if camera_controller.has_method("orbit_camera"):
					camera_controller.orbit_camera(Vector2(randf_range(-1, 1), randf_range(-1, 1)))
			1:  # Zoom
				if camera_controller.has_method("zoom_camera"):
					camera_controller.zoom_camera(randf_range(-2, 2))
			2:  # Pan
				if camera_controller.has_method("pan_camera"):
					camera_controller.pan_camera(Vector2(randf_range(-1, 1), randf_range(-1, 1)))
			3:  # Reset
				if camera_controller.has_method("reset_to_default"):
					camera_controller.reset_to_default()
		
		details.operations += 1
		await get_tree().process_frame
		
		# Check for camera position validity
		if camera_controller.global_position.length() > 1000.0:
			details.failures += 1
			success = false
	
	details["success_rate"] = float(details.operations - details.failures) / float(details.operations) if details.operations > 0 else 0.0
	
	_complete_test("Camera Operations Stress Test", success, details)

func _stress_test_ui_interactions():
	_start_test("UI Interactions Stress Test")
	
	var success = true
	var details = {"interactions": 0, "failures": 0}
	var start_time = Time.get_ticks_msec()
	var duration = test_config.stress_test_duration * 1000
	
	var info_panel = get_tree().get_first_node_in_group("info_panel")
	if not info_panel:
		_complete_test("UI Interactions Stress Test", false, {"error": "Info panel not found"})
		return
	
	while Time.get_ticks_msec() - start_time < duration:
		# Simulate UI interactions
		if info_panel.has_method("hide") and info_panel.has_method("show"):
			if randf() < 0.5:
				info_panel.hide()
			else:
				info_panel.show()
		
		details.interactions += 1
		await get_tree().create_timer(test_config.ui_interaction_delay).timeout
	
	_complete_test("UI Interactions Stress Test", success, details)

func _stress_test_knowledge_base_access():
	_start_test("Knowledge Base Access Stress Test")
	
	var success = true
	var details = {"accesses": 0, "failures": 0}
	var start_time = Time.get_ticks_msec()
	var duration = test_config.stress_test_duration * 1000
	
	var kb = get_node_or_null("/root/KB")
	if not kb:
		_complete_test("Knowledge Base Access Stress Test", false, {"error": "Knowledge base not available"})
		return
	
	while Time.get_ticks_msec() - start_time < duration:
		# Rapid knowledge base access
		if kb.has_method("get_structure_by_id"):
			var result = kb.get_structure_by_id("test_id")
			if result == null:
				# Try with a real ID if available
				if kb.has_method("get_all_structure_ids"):
					var ids = kb.get_all_structure_ids()
					if ids.size() > 0:
						result = kb.get_structure_by_id(ids[randi() % ids.size()])
		
		details.accesses += 1
		
		# Small delay to prevent overwhelming the system
		if details.accesses % 10 == 0:
			await get_tree().process_frame
	
	_complete_test("Knowledge Base Access Stress Test", success, details)

# Performance Tests
func _run_performance_tests():
	print_rich("[color=#9013FE]⚡ Running Performance Tests[/color]")
	
	await _test_frame_rate_stability()
	await _test_memory_usage_patterns()
	await _test_model_loading_performance()

func _test_frame_rate_stability():
	_start_test("Frame Rate Stability")
	
	var fps_samples = []
	var sample_count = test_config.performance_samples
	
	for i in sample_count:
		fps_samples.append(Engine.get_frames_per_second())
		await get_tree().process_frame
	
	# Calculate statistics
	var mean_fps = 0.0
	for fps in fps_samples:
		mean_fps += fps
	mean_fps /= fps_samples.size()
	
	var variance = 0.0
	for fps in fps_samples:
		variance += pow(fps - mean_fps, 2)
	variance /= fps_samples.size()
	
	var std_dev = sqrt(variance)
	var stability_score = 1.0 - (std_dev / mean_fps) if mean_fps > 0 else 0.0
	
	var details = {
		"mean_fps": mean_fps,
		"std_deviation": std_dev,
		"stability_score": stability_score,
		"samples": sample_count
	}
	
	var success = mean_fps > 30.0 and stability_score > 0.8
	_complete_test("Frame Rate Stability", success, details)

func _test_memory_usage_patterns():
	_start_test("Memory Usage Patterns")
	
	var total_initial = OS.get_static_memory_usage()
	
	# Perform some memory-intensive operations
	var temp_arrays = []
	for i in 100:
		temp_arrays.append(range(1000))
		if i % 10 == 0:
			await get_tree().process_frame
	
	var total_peak = OS.get_static_memory_usage()
	
	# Clean up
	temp_arrays.clear()
	await get_tree().process_frame
	
	var total_final = OS.get_static_memory_usage()
	
	var memory_increase = total_final - total_initial
	var peak_increase = total_peak - total_initial
	var cleanup_efficiency = (total_peak - total_final) / float(peak_increase) if peak_increase > 0 else 1.0
	
	var details = {
		"initial_mb": total_initial / (1024.0 * 1024.0),
		"peak_mb": total_peak / (1024.0 * 1024.0),
		"final_mb": total_final / (1024.0 * 1024.0),
		"net_increase_mb": memory_increase / (1024.0 * 1024.0),
		"cleanup_efficiency": cleanup_efficiency
	}
	
	var success = memory_increase < test_config.memory_leak_threshold and cleanup_efficiency > 0.8
	_complete_test("Memory Usage Patterns", success, details)

func _test_model_loading_performance():
	_start_test("Model Loading Performance")
	
	var success = true
	var details = {"load_times": [], "average_load_time": 0.0}
	
	var model_switcher = get_node_or_null("/root/ModelSwitcherGlobal")
	if not model_switcher:
		_complete_test("Model Loading Performance", false, {"error": "ModelSwitcher not available"})
		return
	
	var models = model_switcher.get_available_models() if model_switcher.has_method("get_available_models") else []
	if models.size() == 0:
		_complete_test("Model Loading Performance", false, {"error": "No models available"})
		return
	
	# Test loading time for each model
	for model in models:
		var start_time = Time.get_ticks_msec()
		if model_switcher.has_method("switch_to_model"):
			model_switcher.switch_to_model(model)
			await get_tree().process_frame
		var load_time = Time.get_ticks_msec() - start_time
		
		details.load_times.append(load_time)
	
	# Calculate average
	var total_time = 0
	for time in details.load_times:
		total_time += time
	details.average_load_time = total_time / float(details.load_times.size()) if details.load_times.size() > 0 else 0.0
	
	# Consider successful if average load time is under 500ms
	success = details.average_load_time < 500.0
	
	_complete_test("Model Loading Performance", success, details)

# UI Interaction Tests
func _run_ui_interaction_tests():
	print_rich("[color=#FF9800]🖱️ Running UI Interaction Tests[/color]")
	
	await _test_model_control_panel()
	await _test_info_panel_interactions()
	await _test_debug_console_interactions()

func _test_model_control_panel():
	_start_test("Model Control Panel")
	
	var success = true
	var details = {}
	
	var control_panel = get_tree().get_first_node_in_group("model_control_panel")
	if not control_panel:
		_complete_test("Model Control Panel", false, {"error": "Model control panel not found"})
		return
	
	# Test panel visibility
	if control_panel.has_method("show") and control_panel.has_method("hide"):
		control_panel.show()
		await get_tree().process_frame
		details["visibility_test"] = "passed"
		
		control_panel.hide()
		await get_tree().process_frame
	else:
		success = false
		details["error"] = "Panel missing show/hide methods"
	
	_complete_test("Model Control Panel", success, details)

func _test_info_panel_interactions():
	_start_test("Info Panel Interactions")
	
	var success = true
	var details = {}
	
	var info_panel = get_tree().get_first_node_in_group("info_panel")
	if not info_panel:
		_complete_test("Info Panel Interactions", false, {"error": "Info panel not found"})
		return
	
	# Test panel update mechanism
	if info_panel.has_method("display_structure_info"):
		var test_data = {"displayName": "Test Structure", "shortDescription": "Test description"}
		info_panel.display_structure_info(test_data)
		await get_tree().process_frame
		details["update_test"] = "passed"
	else:
		success = false
		details["error"] = "Panel missing display method"
	
	_complete_test("Info Panel Interactions", success, details)

func _test_debug_console_interactions():
	_start_test("Debug Console Interactions")
	
	var success = true
	var details = {}
	
	var debug_cmd = get_node_or_null("/root/DebugCmd")
	if debug_cmd:
		# Test command execution
		if debug_cmd.has_method("execute_command"):
			var result = debug_cmd.execute_command("help")
			details["command_execution"] = "passed" if result else "failed"
		else:
			success = false
			details["error"] = "Missing execute_command method"
	else:
		success = false
		details["error"] = "Debug command system not available"
	
	_complete_test("Debug Console Interactions", success, details)

# Memory Leak Tests
func _run_memory_leak_tests():
	print_rich("[color=#E91E63]🔍 Running Memory Leak Tests[/color]")
	
	await _test_model_loading_memory_leaks()
	await _test_ui_memory_leaks()

func _test_model_loading_memory_leaks():
	_start_test("Model Loading Memory Leaks")
	
	var initial_memory = _get_total_memory()
	var details = {"initial_mb": initial_memory / (1024 * 1024)}
	
	# Load and unload models repeatedly
	var model_switcher = get_node_or_null("/root/ModelSwitcherGlobal")
	if model_switcher:
		var models = model_switcher.get_available_models() if model_switcher.has_method("get_available_models") else []
		if models.size() > 0:
			for i in 10:  # 10 cycles
				for model in models:
					if model_switcher.has_method("switch_to_model"):
						model_switcher.switch_to_model(model)
						await get_tree().process_frame
			
			# Force garbage collection
			for i in 3:
				await get_tree().process_frame
	
	var final_memory = _get_total_memory()
	var memory_increase = final_memory - initial_memory
	
	details["final_mb"] = final_memory / (1024 * 1024)
	details["increase_mb"] = memory_increase / (1024 * 1024)
	
	var success = memory_increase < test_config.memory_leak_threshold
	_complete_test("Model Loading Memory Leaks", success, details)

func _test_ui_memory_leaks():
	_start_test("UI Memory Leaks")
	
	var initial_memory = _get_total_memory()
	var details = {"initial_mb": initial_memory / (1024 * 1024)}
	
	# Rapid UI operations
	var info_panel = get_tree().get_first_node_in_group("info_panel")
	if info_panel:
		for i in 100:
			if info_panel.has_method("show") and info_panel.has_method("hide"):
				info_panel.show()
				await get_tree().process_frame
				info_panel.hide()
				await get_tree().process_frame
	
	var final_memory = _get_total_memory()
	var memory_increase = final_memory - initial_memory
	
	details["final_mb"] = final_memory / (1024 * 1024)
	details["increase_mb"] = memory_increase / (1024 * 1024)
	
	var success = memory_increase < test_config.memory_leak_threshold
	_complete_test("UI Memory Leaks", success, details)

# Helper methods
func _get_total_memory() -> int:
	return OS.get_static_memory_usage()

func _start_test(test_name: String):
	current_test = test_name
	test_start_time = Time.get_ticks_msec()
	test_started.emit(test_name)
	print("  ⏳ Starting: %s" % test_name)

func _complete_test(test_name: String, success: bool, details: Dictionary = {}):
	var duration = float(Time.get_ticks_msec() - test_start_time) / 1000.0
	
	if not test_results.has(test_name):
		test_results[test_name] = []
	
	test_results[test_name].append({
		"success": success,
		"duration": duration,
		"details": details,
		"timestamp": Time.get_datetime_string_from_system()
	})
	
	var status = "✅" if success else "❌"
	print("  %s %s (%.2fs)" % [status, test_name, duration])
	
	if not success and details.has("error"):
		print("    Error: %s" % details.error)
	
	test_completed.emit(test_name, success, duration)
	current_test = ""

func _print_comprehensive_results():
	print_rich("\n[color=#00FF00]🧪 === Comprehensive Test Results ===[/color]")
	
	var total_tests = 0
	var passed_tests = 0
	var total_duration = 0.0
	
	for test_name in test_results:
		var test_data = test_results[test_name][-1]  # Latest result
		total_tests += 1
		total_duration += test_data.duration
		
		if test_data.success:
			passed_tests += 1
	
	print("📊 Summary:")
	print("  Total tests: %d" % total_tests)
	print("  Passed: %d" % passed_tests)
	print("  Failed: %d" % (total_tests - passed_tests))
	print("  Success rate: %.1f%%" % ((float(passed_tests) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0))
	print("  Total duration: %.2fs" % total_duration)
	
	# Show failed tests
	var failed_tests = []
	for test_name in test_results:
		var test_data = test_results[test_name][-1]
		if not test_data.success:
			failed_tests.append(test_name)
	
	if failed_tests.size() > 0:
		print_rich("\n[color=#FF0000]❌ Failed Tests:[/color]")
		for test_name in failed_tests:
			print("  - %s" % test_name)

func _get_suite_results(suite_prefix: String) -> Dictionary:
	var suite_results = {}
	var total_tests = 0
	var passed_tests = 0
	
	for test_name in test_results:
		if test_name.to_lower().contains(suite_prefix.to_lower()):
			var test_data = test_results[test_name][-1]
			suite_results[test_name] = test_data
			total_tests += 1
			if test_data.success:
				passed_tests += 1
	
	suite_results["summary"] = {
		"total": total_tests,
		"passed": passed_tests,
		"failed": total_tests - passed_tests,
		"success_rate": (float(passed_tests) / float(total_tests)) * 100.0 if total_tests > 0 else 0.0
	}
	
	return suite_results

# Public API
static func get_test_results() -> Dictionary:
	if not instance:
		return {}
	return instance.test_results

static func run_single_test(test_name: String):
	if not instance:
		return
	
	match test_name:
		"model_loader_integration":
			await instance._test_model_loader_integration()
		"stress_model_switching":
			await instance._stress_test_model_switching()
		"frame_rate_stability":
			await instance._test_frame_rate_stability()
		"memory_leak_models":
			await instance._test_model_loading_memory_leaks()
		_:
			print("Unknown test: %s" % test_name)

# Debug command integration
func register_debug_commands():
	var debug_cmd = get_node_or_null("/root/DebugCmd")
	if debug_cmd and debug_cmd.has_method("register_command"):
		debug_cmd.register_command("run_tests", _cmd_run_tests, "Run comprehensive test suite")
		debug_cmd.register_command("test_results", _cmd_test_results, "Show latest test results")
		debug_cmd.register_command("stress_test", _cmd_stress_test, "Run stress tests only")

static func _cmd_run_tests(_args: Array):
	run_comprehensive_tests()

static func _cmd_test_results(_args: Array):
	var results = get_test_results()
	print_rich("[color=#4A90E2]📊 Test Results Summary[/color]")
	for test_name in results:
		var latest = results[test_name][-1]
		var status = "✅" if latest.success else "❌"
		print("%s %s (%.2fs)" % [status, test_name, latest.duration])

static func _cmd_stress_test(_args: Array):
	run_test_category(TestType.STRESS)
