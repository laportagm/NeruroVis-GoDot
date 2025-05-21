class_name ModelSwitcherTest
extends Node
# Class for testing model switcher functionality

# This script tests the functionality of the model switcher system
# Add it as a child node to the main scene to run tests

signal test_completed(success: bool, message: String)

var model_switcher: ModelSwitcher = null
var model_control_panel = null

func _ready() -> void:
	# Delay test execution to ensure the scene is fully loaded
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(_run_tests)
	timer.start()
	
	print("ModelSwitcherTest initialized. Tests will run shortly...")

func _run_tests() -> void:
	print("\n===== MODEL SWITCHER TEST SUITE =====")
	
	# Get required references
	var main_scene = get_tree().current_scene
	if not main_scene:
		_report_failure("Failed to get main scene")
		return
		
	print("Test 1: Checking for model switcher reference")
	model_switcher = main_scene.model_switcher
	if not model_switcher:
		_report_failure("Failed to find model_switcher in main scene")
		return
	print("✓ Model switcher found")
	
	print("Test 2: Checking for model control panel")
	model_control_panel = main_scene.model_control_panel
	if not model_control_panel:
		_report_failure("Failed to find model_control_panel in main scene")
		return
	print("✓ Model control panel found")
	
	print("Test 3: Checking for registered models")
	var model_names = model_switcher.get_model_names()
	if model_names.size() == 0:
		_report_failure("No models registered with model_switcher")
		return
	print("✓ Found " + str(model_names.size()) + " registered models: " + str(model_names))
	
	print("Test 4: Testing model visibility toggling")
	# Test toggling the first model
	if model_names.size() > 0:
		var test_model_name = model_names[0]
		var initial_visibility = model_switcher.is_model_visible(test_model_name)
		
		print("  - Initial visibility of " + test_model_name + ": " + str(initial_visibility))
		print("  - Toggling visibility...")
		
		# Toggle via model switcher
		model_switcher.toggle_model_visibility(test_model_name)
		
		# Check if toggle worked
		var new_visibility = model_switcher.is_model_visible(test_model_name)
		print("  - New visibility: " + str(new_visibility))
		
		if new_visibility == initial_visibility:
			_report_failure("Failed to toggle model visibility")
			return
			
		# Toggle back to initial state
		model_switcher.toggle_model_visibility(test_model_name)
		print("  - Reset to initial visibility")
		
		print("✓ Model visibility toggle works")
	
	print("Test 5: Testing UI control connection")
	if model_names.size() > 0:
		var test_model_name = model_names[0]
		
		# Check if model control panel has method to trigger selection
		if not model_control_panel.has_method("update_button_state"):
			_report_failure("Model control panel doesn't have expected method")
			return
			
		print("  - UI control methods verified")
		
		# We can't directly simulate UI interaction, but we can check if
		# the panel is properly set up with buttons for each model
		var has_buttons = false
		for child in model_control_panel.get_node("MarginContainer/VBoxContainer/ModelsContainer").get_children():
			if child is CheckButton:
				has_buttons = true
				break
				
		if not has_buttons:
			_report_failure("Model control panel doesn't have expected buttons")
			return
			
		print("✓ UI control setup verified")
	
	print("Test 6: Validating model references")
	var main_model_parent = main_scene.brain_model_parent
	if not main_model_parent:
		_report_failure("Brain model parent not found")
		return
		
	if main_model_parent.get_child_count() == 0:
		_report_failure("No model children found in brain_model_parent")
		return
		
	print("✓ Model references valid")
	
	# All tests passed
	_report_success("All model switcher tests passed successfully!")

func _report_success(message: String) -> void:
	print("\n✓ TEST SUITE PASSED: " + message)
	print("===== END OF MODEL SWITCHER TEST SUITE =====\n")
	emit_signal("test_completed", true, message)

func _report_failure(message: String) -> void:
	printerr("\n❌ TEST SUITE FAILED: " + message)
	print("===== END OF MODEL SWITCHER TEST SUITE =====\n")
	emit_signal("test_completed", false, message)