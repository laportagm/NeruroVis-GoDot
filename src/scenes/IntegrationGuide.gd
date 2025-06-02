## IntegrationGuide.gd
## Practical integration guide for adding new architecture to existing scene
##
## This script provides step-by-step integration of the new scene-based
## architecture with your existing main scene. Use this as a reference
## and validation tool for proper integration.
##
## @tutorial: Practical integration patterns
## @version: 3.0

extends Node

# === INTEGRATION STATUS ===
var integration_steps_completed: Array[String] = []
var integration_issues: Array[Dictionary] = []
var existing_scene_validated: bool = false

func _ready() -> void:
	print("\\n[IntegrationGuide] Starting integration validation...")
	print("This guide will help you integrate the new architecture with your existing scene")
	print("Press F4 to run integration validation")

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F4:
		run_integration_validation()
		get_viewport().set_input_as_handled()

# === INTEGRATION VALIDATION ===
func run_integration_validation() -> Dictionary:
	"""Validate existing scene and provide integration guidance"""
	print("\\n" + "="*70)
	print("   NEW ARCHITECTURE INTEGRATION VALIDATION")
	print("="*70)
	
	integration_steps_completed.clear()
	integration_issues.clear()
	
	# Step 1: Validate existing scene structure
	_validate_existing_scene()
	
	# Step 2: Check for required components
	_check_required_components()
	
	# Step 3: Test integration compatibility
	_test_integration_compatibility()
	
	# Step 4: Provide integration instructions
	_provide_integration_instructions()
	
	# Step 5: Show next steps
	_show_next_steps()
	
	return {
		"steps_completed": integration_steps_completed,
		"issues_found": integration_issues,
		"scene_validated": existing_scene_validated
	}

func _validate_existing_scene() -> void:
	"""Validate the existing main scene has required nodes"""
	print("\\n🔍 Step 1: Validating Existing Scene Structure...")
	
	var main_scene = get_parent()
	if not main_scene:
		_add_issue("critical", "Cannot access main scene", "Integration script must be child of main scene")
		return
	
	# Check for required nodes
	var required_nodes = {
		"Camera3D": "Camera for 3D visualization",
		"BrainModel": "Parent node for brain models",
		"UI_Layer": "Canvas layer for UI elements"
	}
	
	var found_nodes = {}
	var missing_nodes = []
	
	for node_name in required_nodes.keys():
		var node = main_scene.get_node_or_null(node_name)
		if node:
			found_nodes[node_name] = node
			print("  ✅ Found: %s (%s)" % [node_name, node.get_class()])
		else:
			missing_nodes.append(node_name)
			print("  ❌ Missing: %s - %s" % [node_name, required_nodes[node_name]])
	
	if missing_nodes.is_empty():
		existing_scene_validated = true
		integration_steps_completed.append("scene_validation")
		print("  🎉 Scene structure validation: PASSED")
	else:
		_add_issue("critical", "Missing required nodes", "Nodes missing: " + ", ".join(missing_nodes))
		print("  🚨 Scene structure validation: FAILED")

func _check_required_components() -> void:
	"""Check if new architecture components can be loaded"""
	print("\\n🧩 Step 2: Checking New Architecture Components...")
	
	var components_to_check = {
		"SelectionSystem": "res://src/scenes/visualization_systems/SelectionSystem.tscn",
		"BrainVisualization": "res://src/scenes/visualization_systems/BrainVisualization.tscn",
		"EducationalUI": "res://src/scenes/interface_systems/EducationalUI.tscn",
		"EducationalCoordinator": "res://src/scenes/educational_systems/EducationalCoordinator.tscn",
		"EventBus": "res://src/scenes/coordination/EventBus.gd"
	}
	
	var component_status = {}
	var failed_components = []
	
	for component_name in components_to_check.keys():
		var component_path = components_to_check[component_name]
		var can_load = false
		
		try:
			var resource = load(component_path)
			if resource:
				can_load = true
				component_status[component_name] = "available"
				print("  ✅ %s: Available" % component_name)
			else:
				failed_components.append(component_name)
				component_status[component_name] = "load_failed"
				print("  ❌ %s: Load failed" % component_name)
		except:
			failed_components.append(component_name)
			component_status[component_name] = "error"
			print("  ❌ %s: Error loading" % component_name)
	
	if failed_components.is_empty():
		integration_steps_completed.append("component_check")
		print("  🎉 Component availability check: PASSED")
	else:
		_add_issue("high", "Components unavailable", "Failed to load: " + ", ".join(failed_components))
		print("  🚨 Component availability check: FAILED")

func _test_integration_compatibility() -> void:
	"""Test that new architecture can integrate with existing scene"""
	print("\\n🔗 Step 3: Testing Integration Compatibility...")
	
	if not existing_scene_validated:
		print("  ⏭️  Skipping compatibility test - scene validation failed")
		return
	
	var main_scene = get_parent()
	var camera = main_scene.get_node_or_null("Camera3D")
	var brain_model = main_scene.get_node_or_null("BrainModel")
	
	# Test creating EducationalCoordinator
	var compatibility_success = false
	try:
		var CoordinatorScene = load("res://src/scenes/educational_systems/EducationalCoordinator.tscn")
		var coordinator = CoordinatorScene.instantiate()
		coordinator.name = "CompatibilityTest"
		add_child(coordinator)
		
		# Wait for initialization
		await get_tree().process_frame
		await get_tree().process_frame
		
		# Test initialization with existing components
		if camera and brain_model:
			var init_success = coordinator.initialize_with_components(camera, brain_model)
			if init_success:
				compatibility_success = true
				print("  ✅ Integration test: NEW ARCHITECTURE COMPATIBLE")
			else:
				print("  ❌ Integration test: Initialization failed")
		else:
			print("  ❌ Integration test: Missing Camera3D or BrainModel")
		
		# Clean up test
		coordinator.queue_free()
		
	except:
		print("  ❌ Integration test: Exception during testing")
	
	if compatibility_success:
		integration_steps_completed.append("compatibility_test")
		print("  🎉 Compatibility test: PASSED")
	else:
		_add_issue("high", "Integration compatibility failed", "New architecture cannot integrate with existing scene")
		print("  🚨 Compatibility test: FAILED")

func _provide_integration_instructions() -> void:
	"""Provide step-by-step integration instructions"""
	print("\\n📋 Step 4: Integration Instructions...")
	
	if integration_issues.is_empty():
		print("\\n🎯 READY FOR INTEGRATION!")
		print("\\nFollow these steps to add the new architecture:")
		print("\\n1️⃣  Add Architecture Demo (Easiest):")
		print("   • In Godot editor, open your main scene")
		print("   • Add a new Node as child of MainScene")
		print("   • Attach script: res://scenes/ArchitectureDemo.gd")
		print("   • Run the project")
		print("   • Press F2 for demo instructions")
		
		print("\\n2️⃣  Add Architecture Tester (Recommended):")
		print("   • Add another Node as child of MainScene")
		print("   • Attach script: res://scenes/ArchitectureTester.gd")
		print("   • Press F3 to run comprehensive tests")
		
		print("\\n3️⃣  Test the New Features:")
		print("   • Right-click brain structures (new selection system)")
		print("   • Ctrl+right-click for multi-selection")
		print("   • Watch console for educational events")
		print("   • Use F1 debug commands for more testing")
		
		print("\\n4️⃣  Gradual Migration (When Ready):")
		print("   • Start using new systems for new features")
		print("   • Gradually migrate old functionality")
		print("   • Eventually replace old monolithic system")
		
	else:
		print("\\n🚨 INTEGRATION BLOCKED!")
		print("\\nResolve these issues before integrating:")
		for i, issue in enumerate(integration_issues):
			print("\\n%d. %s (Priority: %s)" % [i+1, issue.title, issue.priority])
			print("   Problem: %s" % issue.description)
			if issue.has("solution"):
				print("   Solution: %s" % issue.solution)

func _show_next_steps() -> void:
	"""Show recommended next steps based on validation results"""
	print("\\n🚀 Step 5: Recommended Next Steps...")
	
	var completed_count = integration_steps_completed.size()
	var total_steps = 3  # scene_validation, component_check, compatibility_test
	
	print("\\n📊 Integration Readiness: %d/%d steps completed" % [completed_count, total_steps])
	
	if completed_count == total_steps:
		print("\\n🎉 EXCELLENT! Your project is ready for the new architecture!")
		print("\\n✨ What you can do now:")
		print("   • Experience improved development workflow")
		print("   • Add educational features easily")
		print("   • Benefit from AI-friendly modular design")
		print("   • Enjoy better performance and maintainability")
		
		print("\\n📚 Learn more:")
		print("   • Read: scenes/README_NEW_ARCHITECTURE.md")
		print("   • Explore: scenes/ directory for all components")
		print("   • Test: Use F3 for comprehensive testing")
		
	elif completed_count >= 2:
		print("\\n👍 GOOD! Almost ready - just minor issues to resolve")
		print("\\n🔧 Priority actions:")
		for issue in integration_issues:
			if issue.priority in ["critical", "high"]:
				print("   • Fix: %s" % issue.title)
		
	else:
		print("\\n⚠️  NEEDS WORK! Significant issues need resolution")
		print("\\n🚨 Critical actions:")
		for issue in integration_issues:
			if issue.priority == "critical":
				print("   • URGENT: %s" % issue.title)
	
	print("\\n" + "="*70 + "\\n")

# === UTILITY METHODS ===
func _add_issue(priority: String, title: String, description: String, solution: String = "") -> void:
	"""Add an integration issue to track"""
	var issue = {
		"priority": priority,
		"title": title,
		"description": description,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	if not solution.is_empty():
		issue["solution"] = solution
	
	integration_issues.append(issue)

# === PUBLIC API ===
func get_integration_status() -> Dictionary:
	"""Get current integration status"""
	return {
		"validated": existing_scene_validated,
		"steps_completed": integration_steps_completed.size(),
		"total_steps": 3,
		"issues_count": integration_issues.size(),
		"ready_for_integration": integration_issues.is_empty() and existing_scene_validated
	}

func get_integration_issues() -> Array[Dictionary]:
	"""Get list of integration issues"""
	return integration_issues.duplicate()

func is_ready_for_integration() -> bool:
	"""Check if scene is ready for new architecture integration"""
	return integration_issues.is_empty() and existing_scene_validated

# === AUTOMATED INTEGRATION (EXPERIMENTAL) ===
func auto_add_architecture_demo() -> bool:
	"""Automatically add architecture demo to main scene"""
	print("\\n🤖 Auto-adding Architecture Demo...")
	
	if not existing_scene_validated:
		print("  ❌ Cannot auto-add - scene validation failed")
		return false
	
	var main_scene = get_parent()
	if not main_scene:
		print("  ❌ Cannot access main scene")
		return false
	
	# Check if demo already exists
	var existing_demo = main_scene.get_node_or_null("ArchitectureDemo")
	if existing_demo:
		print("  ⚠️  Architecture demo already exists")
		return true
	
	try:
		# Create demo node
		var demo_node = Node.new()
		demo_node.name = "ArchitectureDemo"
		
		# Load and attach demo script
		var demo_script = load("res://src/scenes/ArchitectureDemo.gd")
		demo_node.set_script(demo_script)
		
		# Add to main scene
		main_scene.add_child(demo_node)
		
		print("  ✅ Architecture demo added successfully!")
		print("  🎮 Press F2 to see demo instructions")
		return true
		
	except:
		print("  ❌ Failed to auto-add architecture demo")
		return false

func auto_add_architecture_tester() -> bool:
	"""Automatically add architecture tester to main scene"""
	print("\\n🧪 Auto-adding Architecture Tester...")
	
	if not existing_scene_validated:
		print("  ❌ Cannot auto-add - scene validation failed")
		return false
	
	var main_scene = get_parent()
	if not main_scene:
		print("  ❌ Cannot access main scene")
		return false
	
	# Check if tester already exists
	var existing_tester = main_scene.get_node_or_null("ArchitectureTester")
	if existing_tester:
		print("  ⚠️  Architecture tester already exists")
		return true
	
	try:
		# Create tester node
		var tester_node = Node.new()
		tester_node.name = "ArchitectureTester"
		
		# Load and attach tester script
		var tester_script = load("res://src/scenes/ArchitectureTester.gd")
		tester_node.set_script(tester_script)
		
		# Add to main scene
		main_scene.add_child(tester_node)
		
		print("  ✅ Architecture tester added successfully!")
		print("  🧪 Press F3 to run comprehensive tests")
		return true
		
	except:
		print("  ❌ Failed to auto-add architecture tester")
		return false

# === DEBUG COMMANDS ===
func register_debug_commands() -> void:
	"""Register debug commands for integration"""
	if DebugCmd:
		DebugCmd.register_command("integration_validate", run_integration_validation, "Validate integration readiness")
		DebugCmd.register_command("integration_status", func(): print(get_integration_status()), "Show integration status")
		DebugCmd.register_command("integration_auto_demo", auto_add_architecture_demo, "Auto-add architecture demo")
		DebugCmd.register_command("integration_auto_test", auto_add_architecture_tester, "Auto-add architecture tester")
		DebugCmd.register_command("integration_help", _show_integration_help, "Show integration help")

func _show_integration_help() -> void:
	"""Show integration help information"""
	print("\\n=== NEW ARCHITECTURE INTEGRATION HELP ===")
	print("\\nValidation Commands:")
	print("  F4 - Run integration validation")
	print("  integration_validate - Same as F4")
	print("  integration_status - Show current status")
	print("\\nAuto-Setup Commands:")
	print("  integration_auto_demo - Add demo automatically")
	print("  integration_auto_test - Add tester automatically")
	print("\\nTesting Commands:")
	print("  F2 - Show demo instructions (after adding demo)")
	print("  F3 - Run architecture tests (after adding tester)")
	print("\\nManual Setup:")
	print("  1. Add Node to main scene")
	print("  2. Attach ArchitectureDemo.gd script")
	print("  3. Run project and press F2")
	print("\\nDocumentation:")
	print("  scenes/README_NEW_ARCHITECTURE.md")
	print("==========================================\\n")