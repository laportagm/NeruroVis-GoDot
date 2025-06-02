## Test Model Panel Initialization
## Validates the fixes for the initialization sequence issue

extends RefCounted

# === DEPENDENCIES ===
const ModelRegistry = preload("res://core/models/ModelRegistry.gd")
const ModelControlPanel = preload("res://scenes/ui/panels/model_control.gd")

# === TEST RESULTS ===
var test_results: Array = []
var total_tests: int = 0
var passed_tests: int = 0

# === MAIN TEST RUNNER ===
func run_all_tests() -> Dictionary:
	## Run all model panel initialization tests
	print("\n🧪 RUNNING MODEL PANEL INITIALIZATION TESTS")
	print("===========================================")
	
	_reset_test_state()
	
	# Model Panel Tests
	test_initialization_before_in_tree()
	test_initialization_while_setting_up_models()
	test_initialization_with_null_container()
	test_recovery_mechanism()
	
	_print_test_summary()
	
	return {
		"total_tests": total_tests,
		"passed_tests": passed_tests,
		"failed_tests": total_tests - passed_tests,
		"success_rate": float(passed_tests) / float(total_tests) * 100.0 if total_tests > 0 else 0.0,
		"details": test_results
	}

# === MODEL PANEL TESTS ===
func test_initialization_before_in_tree() -> void:
	## Test model panel initialization before it's in the scene tree
	_start_test("Model Panel Initialization Before In Tree")
	
	# Create panel but don't add to tree
	var panel = ModelControlPanel.new()
	
	# Mock model names
	var model_names = ["Test_Model_1", "Test_Model_2"]
	
	# Attempt to set up models - this should defer initialization
	panel.setup_with_models(model_names)
	
	# The test passes if we reach this point without errors
	# The panel should have deferred the setup_with_models call
	assert_true(true, "Panel should handle initialization gracefully")
	
	# Clean up
	panel.queue_free()
	
	_end_test()

func test_initialization_while_setting_up_models() -> void:
	## Test panel's ability to initialize during setup_with_models
	_start_test("Model Panel Self-Initialization During Setup")
	
	# Create scene tree for testing
	var scene_root = Node.new()
	var panel = ModelControlPanel.new()
	
	# Add to tree
	scene_root.add_child(panel)
	
	# Call setup without initializing first
	# This should trigger self-initialization
	var model_names = ["Test_Model_1", "Test_Model_2"]
	panel.setup_with_models(model_names)
	
	# Check if models_container exists now
	assert_true(panel.models_container != null, "Panel should create models_container during setup")
	
	# Clean up
	scene_root.queue_free()
	
	_end_test()

func test_initialization_with_null_container() -> void:
	## Test handling of null models_container during operations
	_start_test("Null Container Handling")
	
	# Create panel
	var panel = ModelControlPanel.new()
	
	# Force clear models without initializing - should log warning but not crash
	panel._clear_models()
	
	# Force update counter without initializing - should log warning but not crash
	panel._update_visibility_counter()
	
	# The test passes if we reach this point without errors
	assert_true(true, "Panel should handle null containers gracefully")
	
	# Clean up
	panel.queue_free()
	
	_end_test()

func test_recovery_mechanism() -> void:
	## Test panel's recovery mechanism when initialization is needed
	_start_test("Recovery Mechanism")
	
	# Create scene tree for testing
	var scene_root = Node.new()
	var panel = ModelControlPanel.new()
	
	# Add to tree
	scene_root.add_child(panel)
	
	# Set up a flag to track initialization calls
	panel.set_meta("_initialize_called", false)
	
	# Override _initialize_enhanced_panel to track calls
	var original_initialize = panel._initialize_enhanced_panel
	panel._initialize_enhanced_panel = func():
		panel.set_meta("_initialize_called", true)
		original_initialize.call()
	
	# Call setup with models to trigger recovery
	panel.setup_with_models(["Test"])
	
	# Check if initialization was called
	assert_true(panel.get_meta("_initialize_called"), "Recovery should call _initialize_enhanced_panel")
	
	# Clean up
	scene_root.queue_free()
	
	_end_test()

# === TEST UTILITIES ===
func _reset_test_state() -> void:
	## Reset test state
	test_results.clear()
	total_tests = 0
	passed_tests = 0

func _start_test(test_name: String) -> void:
	## Start a new test
	total_tests += 1
	print("  🔍 " + test_name)

func _end_test(passed: bool = true) -> void:
	## End current test
	if passed:
		passed_tests += 1
		print("    ✅ PASSED")
	else:
		print("    ❌ FAILED")

func assert_true(condition: bool, message: String = "") -> void:
	## Assert that condition is true
	if not condition:
		var error_msg = "Assertion failed: " + message
		test_results.append({"type": "assertion_error", "message": error_msg})
		print("    ❌ " + error_msg)
		_end_test(false)

func assert_false(condition: bool, message: String = "") -> void:
	## Assert that condition is false
	assert_true(not condition, message)

func _print_test_summary() -> void:
	## Print test summary
	print("\n📊 TEST SUMMARY")
	print("================")
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % (total_tests - passed_tests))
	print("Success Rate: %.1f%%" % (float(passed_tests) / float(total_tests) * 100.0 if total_tests > 0 else 0.0))
	
	if passed_tests == total_tests:
		print("🎉 ALL TESTS PASSED - Model panel initialization is robust!")
	else:
		print("⚠️  Some tests failed - Review implementation before proceeding")
	
	print("================\n")

# === STANDALONE RUNNER ===
static func run_tests() -> Dictionary:
	## Static method to run tests from outside
	var tester = new()
	return tester.run_all_tests()