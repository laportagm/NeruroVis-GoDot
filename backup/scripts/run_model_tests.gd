@tool
extends EditorScript

# This script can be run from the Godot editor to test the model switcher
# Go to Script -> Run to execute this script

func _run() -> void:
	print("\n=== STARTING MODEL SWITCHER TESTS ===")
	
	# Get the current scene
	var edited_scene = EditorInterface.get_edited_scene_root()
	if not edited_scene:
		printerr("No scene is currently open in the editor")
		return
		
	# Check if the scene is the main Node3D scene
	if not edited_scene is Node3D:
		printerr("The open scene is not the main Node3D scene")
		return
		
	# Check if test is already running
	for child in edited_scene.get_children():
		if child is ModelSwitcherTest:
			printerr("Test is already running, removing existing test node")
			edited_scene.remove_child(child)
			child.queue_free()
			break
	
	# Add the test node
	var TestClass = load("res://scripts/tests/ModelSwitcherTest.gd")
	if TestClass:
		var test_node = TestClass.new()
		test_node.name = "ModelSwitcherTest"
		edited_scene.add_child(test_node)
		
		# Make it part of the edited scene so it persists
		test_node.owner = edited_scene
	else:
		printerr("Failed to load ModelSwitcherTest class")
		return
	
	print("Test node added to scene. Tests will run automatically.")
	print("Check console for test results.")