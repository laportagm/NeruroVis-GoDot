## validate_refactoring.gd
## Quick validation script to test refactored components

extends Node

func _ready():
	print("=== REFACTORING VALIDATION ===")
	await test_component_loading()
	print("=== VALIDATION COMPLETE ===")
	get_tree().quit()

func test_component_loading():
	"""Test that all refactored components can be loaded without parser errors"""
	print("\n1. Testing SystemBootstrap loading...")
	await test_system_bootstrap()
	
	print("\n2. Testing InputRouter loading...")
	await test_input_router()
	
	print("\n3. Testing MainSceneRefactored loading...")
	await test_main_scene()

func test_system_bootstrap():
	"""Test SystemBootstrap component"""
	var script_path = "res://scripts/core/SystemBootstrap.gd"
	
	if not ResourceLoader.exists(script_path):
		print("✗ SystemBootstrap script not found")
		return
	
	var script_resource = load(script_path)
	if not script_resource:
		print("✗ Failed to load SystemBootstrap script")
		return
	
	var bootstrap = script_resource.new()
	if bootstrap:
		print("✓ SystemBootstrap created successfully")
		print("  - Has initialize_all_systems method: ", bootstrap.has_method("initialize_all_systems"))
		print("  - Has get_knowledge_base method: ", bootstrap.has_method("get_knowledge_base"))
		print("  - Initialization complete: ", bootstrap.is_initialization_complete())
		bootstrap.queue_free()
	else:
		print("✗ Failed to create SystemBootstrap instance")

func test_input_router():
	"""Test InputRouter component"""
	var script_path = "res://scripts/interaction/InputRouter.gd"
	
	if not ResourceLoader.exists(script_path):
		print("✗ InputRouter script not found")
		return
	
	var script_resource = load(script_path)
	if not script_resource:
		print("✗ Failed to load InputRouter script")
		return
	
	var router = script_resource.new()
	if router:
		print("✓ InputRouter created successfully")
		print("  - Has initialize method: ", router.has_method("initialize"))
		print("  - Has is_input_enabled method: ", router.has_method("is_input_enabled"))
		print("  - Input enabled by default: ", router.is_input_enabled())
		router.queue_free()
	else:
		print("✗ Failed to create InputRouter instance")

func test_main_scene():
	"""Test MainSceneRefactored component"""
	var script_path = "res://scenes/node_3d.gd"
	
	if not ResourceLoader.exists(script_path):
		print("✗ MainSceneRefactored script not found")
		return
	
	var script_resource = load(script_path)
	if not script_resource:
		print("✗ Failed to load MainSceneRefactored script")
		return
	
	var scene = script_resource.new()
	if scene:
		print("✓ MainSceneRefactored created successfully")
		print("  - Has initialize_scene method: ", scene.has_method("initialize_scene"))
		print("  - Has _load_component_scripts method: ", scene.has_method("_load_component_scripts"))
		print("  - Initialization complete: ", scene.initialization_complete)
		
		# Test component script loading
		scene._load_component_scripts()
		print("  - Component scripts loaded: ", scene.SystemBootstrap != null and scene.InputRouter != null)
		
		scene.queue_free()
	else:
		print("✗ Failed to create MainSceneRefactored instance")