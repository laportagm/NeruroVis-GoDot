###############################################################################
# MESH NAME SCANNER - EDITOR TOOL
# 
# EDITOR USE ONLY: This script is designed to be executed from the Godot Editor
# via "Editor > Run Script..." and should NOT be attached to game nodes or 
# executed at runtime.
#
# Purpose: Extracts and displays mesh names from 3D model files (.glb/.gltf)
#          to assist with creating proper mappings between mesh names and 
#          structure IDs in the NeuralNet.gd script.
###############################################################################

@tool
extends EditorScript

func _run():
	# Load the models
	var models = [
		"res://assets/models/Half_Brain.glb",
		"res://assets/models/Internal_Structures.glb", 
		"res://assets/models/Brainstem(Solid).glb"
	]
	
	print("\n=== MESH NAME SCANNER STARTED ===")
	print("MESH SCANNER: Scanning brain models for mesh names...")
	var total_models = models.size()
	var successful_models = 0
	
	for model_path in models:
		print("\nMESH SCANNER: === " + model_path + " ===")
		
		# Check if the model exists
		if not ResourceLoader.exists(model_path):
			printerr("MESH SCANNER ERROR: Model file not found: " + model_path)
			continue
			
		# Load the scene
		var model_scene = load(model_path)
		if model_scene == null:
			printerr("MESH SCANNER ERROR: Failed to load model at " + model_path + ", file might be corrupt or not a valid scene.")
			continue
			
		# Verify it's a valid scene resource
		if not model_scene is PackedScene:
			printerr("MESH SCANNER ERROR: Resource at " + model_path + " is not a PackedScene. Got " + str(model_scene.get_class()) + " instead.")
			continue
			
		# Instantiate the scene
		var model_instance = model_scene.instantiate()
		if model_instance == null:
			printerr("MESH SCANNER ERROR: Failed to instantiate model " + model_path + ". The scene might be corrupt or incompatible.")
			continue
			
		# Extract all mesh names recursively
		var mesh_count = _scan_node_for_meshes(model_instance)
		
		print("MESH SCANNER: Found " + str(mesh_count) + " mesh instances in " + model_path.get_file())
		successful_models += 1
		
		# Clean up - use free() instead of queue_free() for immediate cleanup
		model_instance.free()
	
	print("\nMESH SCANNER: Scan complete. Successfully processed " + str(successful_models) + "/" + str(total_models) + " models.")
	print("=== MESH NAME SCANNER COMPLETE ===")

# Recursively scan for meshes
# Returns the number of mesh instances found
func _scan_node_for_meshes(node, indent = "  ", current_path = "", depth = 0, mesh_count = 0):
	# Safety check for null node (shouldn't happen but being defensive)
	if node == null:
		printerr("MESH SCANNER ERROR: Null node encountered during scan")
		return mesh_count
	
	# Build the current node path for better context
	var node_path = current_path + "/" + node.name if current_path else node.name
	
	# Check if this is a mesh instance
	if node is MeshInstance3D:
		print(indent + "MeshInstance: " + node.name + " (Path: " + node_path + ")")
		mesh_count += 1
	
	# Prevent excessive recursion
	if depth > 20:  # Safeguard against potentially circular references
		print(indent + "MESH SCANNER WARNING: Maximum recursion depth reached at " + node_path)
		return mesh_count
	
	# Check children recursively
	for child in node.get_children():
		mesh_count = _scan_node_for_meshes(child, indent + "  ", node_path, depth + 1, mesh_count)
	
	return mesh_count