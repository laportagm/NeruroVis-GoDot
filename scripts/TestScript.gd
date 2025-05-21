@tool
extends EditorScript

# This script is for testing purposes, it can be executed from the Godot Editor
# to test the robustness of our scripts

func _run() -> void:
	print("\n===== TESTING SCRIPT ROBUSTNESS =====")
	
	# Test KnowledgeBase
	test_knowledge_base()
	
	# Test NeuralNet
	test_neural_net()
	
	# Test UIDiagnostic
	test_ui_diagnostic()
	
	print("===== TEST COMPLETE =====\n")

func test_knowledge_base() -> void:
	print("\n----- Testing KnowledgeBase -----")
	
	var kb = KnowledgeBase.new()
	
	# Test loading knowledge base
	print("Loading knowledge base...")
	var loaded = kb.load_knowledge_base()
	print("Knowledge base loaded successfully: " + str(loaded))
	print("Is loaded flag: " + str(kb.is_loaded))
	print("Error message (if any): " + kb.load_error)
	
	if kb.is_loaded:
		# Test getting structure info
		print("\nTesting structure retrieval:")
		var test_structures = ["Thalamus", "NonExistentStructure", "Amygdala"]
		
		for struct_id in test_structures:
			var structure = kb.get_structure(struct_id)
			if structure.is_empty():
				print("Structure '" + struct_id + "' not found")
			else:
				print("Found '" + struct_id + "': " + structure.get("displayName", "No name"))
		
		# Test getting all IDs
		var all_ids = kb.get_all_structure_ids()
		print("\nTotal structures: " + str(all_ids.size()))
		print("First few structure IDs: " + str(all_ids.slice(0, min(3, all_ids.size()))))
		
		# Test metadata
		var metadata = kb.get_metadata()
		print("\nKnowledge base metadata:")
		print("Version: " + metadata.version)
		print("Last updated: " + metadata.lastUpdated)
		print("Structure count: " + str(metadata.structureCount))
	else:
		print("WARNING: Knowledge base didn't load, skipping structure tests")
		
	# Cleanup
	kb.free()
	print("----- KnowledgeBase Test Complete -----")

func test_neural_net() -> void:
	print("\n----- Testing NeuralNet -----")
	
	var nn = NeuralNet.new()
	
	# Test mesh name mapping
	print("Testing mesh name mapping:")
	var test_names = [
		"Thalamus", 
		"thalamus",
		"Hippocampus", 
		"Brain model (separated cerebellum 1) 6a",
		"NonExistentMesh",
		"Strange_Mesh_Name"
	]
	
	for mesh_name in test_names:
		var mapped_id = nn.map_mesh_name_to_structure_id(mesh_name)
		print("Mesh name '" + mesh_name + "' maps to: " + (mapped_id if not mapped_id.is_empty() else "NOT FOUND"))
	
	# Test adding a mapping
	print("\nAdding new mapping...")
	nn.add_structure_mapping("Test_Mesh", "Thalamus")
	var new_mapping = nn.map_mesh_name_to_structure_id("Test_Mesh")
	print("New mapping result: " + new_mapping)
	
	# Cleanup
	nn.free()
	print("----- NeuralNet Test Complete -----")

func test_ui_diagnostic() -> void:
	print("\n----- Testing UIDiagnostic script -----")
	
	# We can't fully test UIDiagnostic since it needs a running scene
	# But we can check if the script compiles and basic object creation works
	
	var ui_diag = UIDiagnostic.new()
	print("UIDiagnostic created successfully")
	
	# Try to access some methods and properties
	if ui_diag.has_method("run_diagnostics"):
		print("Has run_diagnostics method")
	else:
		print("WARNING: run_diagnostics method not found")
		
	if ui_diag.has_method("check_info_panel"):
		print("Has check_info_panel method")
	else:
		print("WARNING: check_info_panel method not found")
	
	# Check node tree printing (should work even without a scene)
	if ui_diag.has_method("_print_node_tree"):
		print("Has _print_node_tree method")
		
		# Create a simple node hierarchy to test
		var root = Node.new()
		root.name = "TestRoot"
		
		var child1 = Node.new()
		child1.name = "Child1"
		root.add_child(child1)
		
		var child2 = Node.new()
		child2.name = "Child2"
		root.add_child(child2)
		
		print("\nTesting _print_node_tree with a simple hierarchy:")
		# Use reflection to call the private method
		var print_tree_method = ui_diag.get("_print_node_tree")
		if print_tree_method != null and print_tree_method.is_valid():
			print_tree_method.call(root)
		else:
			print("WARNING: Couldn't call _print_node_tree method")
		
		# Cleanup test hierarchy
		child1.free()
		child2.free()
		root.free()
	else:
		print("WARNING: _print_node_tree method not found")
	
	# Cleanup
	ui_diag.free()
	print("----- UIDiagnostic Test Complete -----")