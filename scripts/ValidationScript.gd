@tool
extends EditorScript

# This script performs a comprehensive validation of all the modified files
# to ensure they're robust and handle edge cases correctly

func _run() -> void:
	print("\n===== VALIDATION SCRIPT STARTED =====")
	
	# Test KnowledgeBase robustness
	test_knowledge_base_robustness()
	
	# Test NeuralNet mapping
	test_neural_net_robustness()
	
	# Test UI scripts
	test_ui_scripts()
	
	print("===== VALIDATION COMPLETE =====\n")

func test_knowledge_base_robustness() -> void:
	print("\n----- Testing KnowledgeBase Robustness -----")
	
	var kb = KnowledgeBase.new()
	
	# Test normal operation
	print("Normal operation test:")
	var loaded = kb.load_knowledge_base()
	print("Knowledge base loaded: " + str(loaded))
	print("Is loaded flag: " + str(kb.is_loaded))
	
	if kb.is_loaded:
		# Test structure access with valid and invalid IDs
		print("\nStructure access tests:")
		
		# Valid structure
		var valid_structure = kb.get_structure("Thalamus")
		print("Valid structure access result: " + str(not valid_structure.is_empty()))
		
		# Invalid structure
		var invalid_structure = kb.get_structure("NonExistentStructure")
		print("Invalid structure access result: " + str(invalid_structure.is_empty()))
		
		# Test has_structure
		print("\nhas_structure tests:")
		print("Has Thalamus: " + str(kb.has_structure("Thalamus")))
		print("Has NonExistentStructure: " + str(kb.has_structure("NonExistentStructure")))
		
		# Check warnings array
		print("\nWarnings count: " + str(kb.warnings.size()))
	
	# Clean up
	kb.free()
	print("----- KnowledgeBase Robustness Test Complete -----")

func test_neural_net_robustness() -> void:
	print("\n----- Testing NeuralNet Robustness -----")
	
	var nn = NeuralNet.new()
	
	# Test mapping with various inputs
	print("Testing map_mesh_name_to_structure_id with various inputs:")
	
	# Normal case
	var normal_result = nn.map_mesh_name_to_structure_id("Thalamus")
	print("Normal mapping: " + normal_result)
	
	# Null input (should handle gracefully)
	var null_result = nn.map_mesh_name_to_structure_id(null)
	print("Null input mapping: " + null_result)
	
	# Empty string
	var empty_result = nn.map_mesh_name_to_structure_id("")
	print("Empty string mapping: " + empty_result)
	
	# Non-string input
	var non_string_result = nn.map_mesh_name_to_structure_id(123)
	print("Non-string input mapping: " + non_string_result)
	
	# Non-existent mesh name
	var nonexistent_result = nn.map_mesh_name_to_structure_id("ThisMeshDoesNotExist")
	print("Non-existent mesh mapping: " + nonexistent_result)
	
	# Clean up
	nn.free()
	print("----- NeuralNet Robustness Test Complete -----")

func test_ui_scripts() -> void:
	print("\n----- Testing UI Scripts -----")
	
	# Test StructureInfoPanel (UI component)
	test_info_panel()
	
	# Test UIDiagnostic (runtime diagnostic tool)
	test_ui_diagnostic()
	
	print("----- UI Scripts Test Complete -----")

func test_info_panel() -> void:
	print("\nTesting StructureInfoPanel:")
	
	# Create a panel instance
	var panel = StructureInfoPanel.new()
	print("StructureInfoPanel created")
	
	# We can't fully test without a scene context, but check methods exist
	if panel.has_method("display_structure_data"):
		print("Has display_structure_data method")
	else:
		print("WARNING: display_structure_data method not found")
	
	if panel.has_method("clear_data"):
		print("Has clear_data method")
	else:
		print("WARNING: clear_data method not found")
	
	# Test signal exists
	var signal_list = panel.get_signal_list()
	var has_panel_closed_signal = false
	for signal_info in signal_list:
		if signal_info.name == "panel_closed":
			has_panel_closed_signal = true
			break
	
	print("Has panel_closed signal: " + str(has_panel_closed_signal))
	
	# Clean up
	panel.free()

func test_ui_diagnostic() -> void:
	print("\nTesting UIDiagnostic:")
	
	# Create a UIDiagnostic instance
	var ui_diag = UIDiagnostic.new()
	print("UIDiagnostic created")
	
	# Check methods
	var methods = [
		"run_diagnostics",
		"check_info_panel",
		"check_ui_visibility",
		"check_structure_selection_flow",
		"test_info_panel_with_data",
		"trace_info_panel_calls"
	]
	
	var missing_methods = []
	for method in methods:
		if not ui_diag.has_method(method):
			missing_methods.append(method)
	
	if missing_methods.is_empty():
		print("All expected methods found")
	else:
		print("WARNING: Some methods missing: " + str(missing_methods))
	
	# Test helper functions
	if ui_diag.has_method("_get_validated_main_scene"):
		print("Has _get_validated_main_scene helper")
	else:
		print("WARNING: _get_validated_main_scene helper missing")
	
	if ui_diag.has_method("_safe_call_method"):
		print("Has _safe_call_method helper")
	else:
		print("WARNING: _safe_call_method helper missing")
	
	if ui_diag.has_method("_has_signal"):
		print("Has _has_signal helper")
	else:
		print("WARNING: _has_signal helper missing")
	
	# Clean up
	ui_diag.free()