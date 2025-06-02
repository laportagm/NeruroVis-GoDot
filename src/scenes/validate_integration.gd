## validate_integration.gd
## Simple integration validation script
##
## Run this script to validate that the new architecture can integrate
## with your existing scene. Use as a standalone test or attach to a node.

extends Node

func _ready() -> void:
	print("\\n[ValidationScript] Running integration validation...")
	validate_integration()

func validate_integration() -> bool:
	"""Validate integration compatibility"""
	var success = true
	
	print("\\n=== NEW ARCHITECTURE INTEGRATION VALIDATION ===")
	
	# Check if we're in a proper scene
	var parent = get_parent()
	if not parent:
		print("❌ No parent scene found")
		return false
	
	print("✅ Parent scene found: %s" % parent.name)
	
	# Check for required nodes
	var camera = parent.get_node_or_null("Camera3D")
	var brain_model = parent.get_node_or_null("BrainModel")
	var ui_layer = parent.get_node_or_null("UI_Layer")
	
	if camera:
		print("✅ Camera3D found: %s" % camera.get_class())
	else:
		print("❌ Camera3D not found")
		success = false
	
	if brain_model:
		print("✅ BrainModel found: %s" % brain_model.get_class())
	else:
		print("❌ BrainModel not found")
		success = false
	
	if ui_layer:
		print("✅ UI_Layer found: %s" % ui_layer.get_class())
	else:
		print("❌ UI_Layer not found")
		success = false
	
	# Test loading new architecture components
	print("\\n--- Testing New Architecture Components ---")
	
	var component_tests = {
		"SelectionSystem": "res://src/scenes/visualization_systems/SelectionSystem.tscn",
		"BrainVisualization": "res://src/scenes/visualization_systems/BrainVisualization.tscn",
		"EducationalUI": "res://src/scenes/interface_systems/EducationalUI.tscn",
		"EducationalCoordinator": "res://src/scenes/educational_systems/EducationalCoordinator.tscn"
	}
	
	for component_name in component_tests.keys():
		var component_path = component_tests[component_name]
		var component_scene = load(component_path)
		
		if component_scene:
			print("✅ %s loads successfully" % component_name)
		else:
			print("❌ %s failed to load" % component_name)
			success = false
	
	# Test integration
	if success and camera and brain_model:
		print("\\n--- Testing Integration ---")
		success = _test_coordinator_integration(camera, brain_model)
	
	# Report results
	print("\\n=== VALIDATION RESULTS ===")
	if success:
		print("🎉 INTEGRATION VALIDATION PASSED!")
		print("✨ Your scene is ready for the new architecture")
		print("\\n📋 Next steps:")
		print("  1. Add ArchitectureDemo.gd as child node script")
		print("  2. Run project and press F2 for demo")
		print("  3. Test with right-click on brain structures")
	else:
		print("🚨 INTEGRATION VALIDATION FAILED!")
		print("⚠️  Please fix the issues above before proceeding")
	
	print("=======================================\\n")
	
	return success

func _test_coordinator_integration(camera: Camera3D, brain_model: Node3D) -> bool:
	"""Test that EducationalCoordinator can integrate with existing components"""
	try:
		var CoordinatorScene = load("res://src/scenes/educational_systems/EducationalCoordinator.tscn")
		var coordinator = CoordinatorScene.instantiate()
		coordinator.name = "TestCoordinator"
		add_child(coordinator)
		
		# Wait for initialization
		await get_tree().process_frame
		await get_tree().process_frame
		
		# Test initialization
		var init_success = coordinator.initialize_with_components(camera, brain_model)
		
		if init_success:
			print("✅ EducationalCoordinator integration successful")
		else:
			print("❌ EducationalCoordinator integration failed")
		
		# Clean up
		coordinator.queue_free()
		
		return init_success
		
	except:
		print("❌ Exception during integration testing")
		return false

# You can also run this as a standalone script
func run_validation_standalone():
	"""Run validation without being in a scene tree"""
	print("\\n[ValidationScript] Running standalone validation...")
	
	# Test component loading only
	var component_tests = {
		"SelectionSystem": "res://src/scenes/visualization_systems/SelectionSystem.tscn",
		"BrainVisualization": "res://src/scenes/visualization_systems/BrainVisualization.tscn", 
		"EducationalUI": "res://src/scenes/interface_systems/EducationalUI.tscn",
		"EducationalCoordinator": "res://src/scenes/educational_systems/EducationalCoordinator.tscn"
	}
	
	var all_success = true
	
	print("\\n=== COMPONENT LOADING TEST ===")
	for component_name in component_tests.keys():
		var component_path = component_tests[component_name]
		var component_scene = load(component_path)
		
		if component_scene:
			print("✅ %s" % component_name)
		else:
			print("❌ %s" % component_name)
			all_success = false
	
	if all_success:
		print("\\n🎉 All components load successfully!")
		print("✨ New architecture is ready to use")
	else:
		print("\\n🚨 Some components failed to load")
		print("⚠️  Check file paths and ensure all architecture files exist")
	
	return all_success