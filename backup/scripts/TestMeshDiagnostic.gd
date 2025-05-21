@tool
extends EditorScript

# This script tests the MeshDiagnostic class in isolation

func _run() -> void:
	print("\n===== TESTING MESH DIAGNOSTIC =====")
	
	# Create a test MeshDiagnostic instance
	var mesh_diag = MeshDiagnostic.new()
	print("MeshDiagnostic created successfully")
	
	# Test methods
	if mesh_diag.has_method("_run_diagnostics"):
		print("Has _run_diagnostics method")
	else:
		print("WARNING: _run_diagnostics method not found")
	
	if mesh_diag.has_method("_collect_mesh_instances"):
		print("Has _collect_mesh_instances method")
	else:
		print("WARNING: _collect_mesh_instances method not found")
	
	if mesh_diag.has_method("_compare_with_knowledge_base"):
		print("Has _compare_with_knowledge_base method")
	else:
		print("WARNING: _compare_with_knowledge_base method not found")
	
	if mesh_diag.has_method("_check_neural_net_mapping"):
		print("Has _check_neural_net_mapping method")
	else:
		print("WARNING: _check_neural_net_mapping method not found")
	
	# Test collecting mesh instances function with a mock scene
	var root = Node3D.new()
	root.name = "TestRoot"
	
	var mesh1 = MeshInstance3D.new()
	mesh1.name = "Mesh1"
	root.add_child(mesh1)
	
	var container = Node3D.new()
	container.name = "Container"
	root.add_child(container)
	
	var mesh2 = MeshInstance3D.new()
	mesh2.name = "Mesh2"
	container.add_child(mesh2)
	
	var mesh_names = []
	var mesh_info = {}
	
	print("\nTesting _collect_mesh_instances with a mock scene:")
	mesh_diag._collect_mesh_instances(root, mesh_names, mesh_info)
	
	print("Found " + str(mesh_names.size()) + " mesh instances:")
	for mesh_name in mesh_names:
		var info = mesh_info[mesh_name]
		print(" - " + mesh_name + " (Parent: " + info.parent + ", Path: " + info.path + ")")
	
	# Clean up
	mesh1.free()
	mesh2.free()
	container.free()
	root.free()
	mesh_diag.free()
	
	print("===== MESH DIAGNOSTIC TEST COMPLETE =====\n")