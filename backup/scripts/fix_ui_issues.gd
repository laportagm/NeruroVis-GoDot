@tool
extends EditorScript

###############################################################################
# UI ISSUE DIAGNOSTIC AND FIX TOOL 
# 
# EDITOR USE ONLY: This script is designed to be executed from the Godot Editor
# via "Editor > Run Script..." and should NOT be attached to game nodes or 
# executed at runtime.
#
# Purpose: Diagnoses UI panel structure and connection issues between scenes.
# Author: Development Team
###############################################################################

func _run():
	print("\n=== UI ISSUE DIAGNOSTIC AND FIX TOOL STARTED ===")
	
	# Step 1: Find and analyze the info panel scene
	var ui_panel_scene_path = "res://scenes/ui_info_panel.tscn"
	var ui_panel_script_path = "res://scenes/ui_info_panel.gd"
	var ui_panel_alt_script_path = "res://scripts/ui/InformationPanelController.gd"
	
	print("UI DIAGNOSTIC: Step 1: Analyzing UI panel files...")
	
	# Check if scene exists
	if not ResourceLoader.exists(ui_panel_scene_path):
		printerr("UI DIAGNOSTIC ERROR: UI panel scene not found at " + ui_panel_scene_path)
		return
	
	# Check script references
	var scene_script_exists = ResourceLoader.exists(ui_panel_script_path)
	var alt_script_exists = ResourceLoader.exists(ui_panel_alt_script_path)
	
	print("UI DIAGNOSTIC: Scene script exists: " + str(scene_script_exists) + " (" + ui_panel_script_path + ")")
	print("UI DIAGNOSTIC: Alternative script exists: " + str(alt_script_exists) + " (" + ui_panel_alt_script_path + ")")
	
	# Load the scene to check its structure
	var packed_scene = load(ui_panel_scene_path)
	if packed_scene == null:
		printerr("UI DIAGNOSTIC ERROR: Failed to load UI panel scene at " + ui_panel_scene_path + ", even though it exists. File might be corrupt or invalid.")
		return
	
	# Verify it's a PackedScene
	if not packed_scene is PackedScene:
		printerr("UI DIAGNOSTIC ERROR: Resource at " + ui_panel_scene_path + " is not a PackedScene. Got " + str(packed_scene.get_class()) + " instead.")
		return
	
	# Instantiate the scene
	var scene_instance = packed_scene.instantiate()
	if scene_instance == null:
		printerr("UI DIAGNOSTIC ERROR: Failed to instantiate UI panel scene. The scene might be corrupt or incompatible.")
		return
	
	print("UI DIAGNOSTIC: Scene root node: " + scene_instance.name + " (" + scene_instance.get_class() + ")")
	
	# Check what script the scene is using
	var scene_script = scene_instance.get_script()
	print("UI DIAGNOSTIC: Scene script path: " + str(scene_script.resource_path if scene_script != null else "None"))
	
	# Check node paths that are referenced in scripts
	print("\nUI DIAGNOSTIC: Checking node paths:")
	
	# Check structure expected by scenes/ui_info_panel.gd
	var expected_paths_scene_script = [
		"MarginContainer/VBoxContainer/TitleBar/StructureName",
		"MarginContainer/VBoxContainer/TitleBar/CloseButton",
		"MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/DescriptionSection/DescriptionText",
		"MarginContainer/VBoxContainer/ScrollContainer/VBoxContainer/FunctionsSection/FunctionsList"
	]
	
	# Check structure expected by scripts/ui/InformationPanelController.gd
	var expected_paths_alt_script = [
		"PanelContainer/MarginContainer/VBoxContainer/StructureNameLabel",
		"PanelContainer/MarginContainer/VBoxContainer/DescriptionLabel",
		"PanelContainer/MarginContainer/VBoxContainer/FunctionsContainer/FunctionsList",
		"PanelContainer/MarginContainer/VBoxContainer/CloseButton"
	]
	
	print("UI DIAGNOSTIC: Checking paths required by scene script:")
	for path in expected_paths_scene_script:
		var has_node = scene_instance.has_node(path)
		print("  - " + path + ": " + ("FOUND" if has_node else "MISSING"))
	
	print("UI DIAGNOSTIC: Checking paths required by alternative script:")
	for path in expected_paths_alt_script:
		var has_node = scene_instance.has_node(path)
		print("  - " + path + ": " + ("FOUND" if has_node else "MISSING"))
	
	# Analyze MainScene's reference to the info panel
	print("\nUI DIAGNOSTIC: Step 2: Analyzing MainScene references...")
	var main_scene_path = "res://scenes/node_3d.tscn"
	
	if not ResourceLoader.exists(main_scene_path):
		printerr("UI DIAGNOSTIC ERROR: Main scene not found at " + main_scene_path)
		scene_instance.free()
		return
	
	var main_packed_scene = load(main_scene_path)
	if main_packed_scene == null:
		printerr("UI DIAGNOSTIC ERROR: Failed to load main scene at " + main_scene_path + ", even though it exists. File might be corrupt or invalid.")
		scene_instance.free()
		return
	
	# Verify it's a PackedScene
	if not main_packed_scene is PackedScene:
		printerr("UI DIAGNOSTIC ERROR: Resource at " + main_scene_path + " is not a PackedScene. Got " + str(main_packed_scene.get_class()) + " instead.")
		scene_instance.free()
		return
	
	var main_scene = main_packed_scene.instantiate()
	if main_scene == null:
		printerr("UI DIAGNOSTIC ERROR: Failed to instantiate main scene. The scene might be corrupt or incompatible.")
		scene_instance.free()
		return
	
	# Safe checks before proceeding
	var ui_layer = main_scene.get_node_or_null("UI_Layer")
	
	if ui_layer == null:
		printerr("UI DIAGNOSTIC ERROR: UI_Layer not found in main scene")
	else:
		print("UI DIAGNOSTIC: UI_Layer found. Checking for StructureInfoPanel...")
		var info_panel = ui_layer.get_node_or_null("StructureInfoPanel")
		
		if info_panel == null:
			printerr("UI DIAGNOSTIC ERROR: StructureInfoPanel not found in UI_Layer")
		else:
			print("UI DIAGNOSTIC: StructureInfoPanel found.")
			print("UI DIAGNOSTIC: Panel class: " + info_panel.get_class())
			
			var panel_script = info_panel.get_script()
			if panel_script != null:
				print("UI DIAGNOSTIC: Panel script: " + str(panel_script.resource_path))
			else:
				printerr("UI DIAGNOSTIC ERROR: StructureInfoPanel has no script attached")
	
	print("\nUI DIAGNOSTIC: Step 3: Recommended fixes:")
	print("UI DIAGNOSTIC: 1. Ensure the UI_Layer in node_3d.tscn is properly configured:")
	print("UI DIAGNOSTIC:    - Set transform to identity (1, 0, 0, 1, 0, 0)")
	print("UI DIAGNOSTIC:    - Ensure 'visible' property is true")
	print("UI DIAGNOSTIC:    - Make sure the StructureInfoPanel is a direct child of UI_Layer")
	
	print("UI DIAGNOSTIC: 2. In ui_info_panel.tscn, the script path should point to:")
	print("UI DIAGNOSTIC:    - res://scripts/ui/InformationPanelController.gd (current version)")
	
	print("UI DIAGNOSTIC: 3. Make sure node paths in the script match the scene:")
	print("UI DIAGNOSTIC:    - Ensure all @onready var nodes match the actual scene structure")
	
	print("UI DIAGNOSTIC: 4. Delete or rename the duplicate script at " + ui_panel_alt_script_path)
	
	print("UI DIAGNOSTIC: 5. Check MainScene script in node_3d.gd:")
	print("UI DIAGNOSTIC:    - Verify @onready var info_panel = $UI_Layer/StructureInfoPanel")
	print("UI DIAGNOSTIC:    - Make sure it's accessing the right methods on the panel")
	
	# Cleanup instantiated scenes to prevent memory leaks
	if scene_instance != null:
		scene_instance.free()
	
	if main_scene != null:
		main_scene.free()
	
	print("=== UI DIAGNOSTIC TOOL COMPLETE ===")