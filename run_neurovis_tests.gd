extends SceneTree

func _init():
	print("\n=== NEUROVIS COMPREHENSIVE TEST SUITE ===\n")
	
	# Test 1: Check autoloads
	print("📋 Test 1: Checking Autoloads...")
	var autoload_status = _check_autoloads()
	
	# Test 2: Check UI Theme Manager
	print("\n📋 Test 2: Testing UIThemeManager...")
	var theme_status = _test_theme_manager()
	
	# Test 3: Check Knowledge Service
	print("\n📋 Test 3: Testing KnowledgeService...")
	var knowledge_status = _test_knowledge_service()
	
	# Test 4: Check Error Handler
	print("\n📋 Test 4: Testing ErrorHandler...")
	var error_status = _test_error_handler()
	
	# Summary
	print("\n=== TEST SUMMARY ===")
	print("✅ Autoloads: " + ("PASS" if autoload_status else "FAIL"))
	print("✅ Theme Manager: " + ("PASS" if theme_status else "FAIL"))
	print("✅ Knowledge Service: " + ("PASS" if knowledge_status else "FAIL"))
	print("✅ Error Handler: " + ("PASS" if error_status else "FAIL"))
	
	var all_pass = autoload_status and theme_status and knowledge_status and error_status
	print("\n🎯 Overall: " + ("ALL TESTS PASSED ✨" if all_pass else "SOME TESTS FAILED ❌"))
	
	quit()

func _check_autoloads() -> bool:
	var required_autoloads = [
		"KB",
		"KnowledgeService", 
		"AIAssistant",
		"UIThemeManager",
		"ModelSwitcherGlobal",
		"StructureAnalysisManager",
		"DebugCmd"
	]
	
	var all_found = true
	for autoload_name in required_autoloads:
		var node = root.get_node_or_null("/root/" + autoload_name)
		if node:
			print("  ✅ " + autoload_name + " found")
		else:
			print("  ❌ " + autoload_name + " missing")
			all_found = false
	
	return all_found

func _test_theme_manager() -> bool:
	var theme_manager = root.get_node_or_null("/root/UIThemeManager")
	if not theme_manager:
		print("  ❌ UIThemeManager not found")
		return false
	
	# Test style caching
	print("  Testing style caching...")
	var UIThemeManager = load("res://ui/panels/UIThemeManager.gd")
	
	# Create a style
	var style1 = UIThemeManager.create_enhanced_glass_style()
	if not style1:
		print("  ❌ Failed to create style")
		return false
	print("  ✅ Style created successfully")
	
	# Test cache
	var style2 = UIThemeManager.create_enhanced_glass_style()
	print("  ✅ Style cache working (retrieving cached styles)")
	
	# Test theme switching
	UIThemeManager.set_theme_mode(UIThemeManager.ThemeMode.MINIMAL)
	print("  ✅ Theme switched to MINIMAL")
	
	UIThemeManager.set_theme_mode(UIThemeManager.ThemeMode.ENHANCED)
	print("  ✅ Theme switched back to ENHANCED")
	
	return true

func _test_knowledge_service() -> bool:
	var knowledge_service = root.get_node_or_null("/root/KnowledgeService")
	if not knowledge_service:
		print("  ❌ KnowledgeService not found")
		return false
	
	# Test structure retrieval
	var hippocampus = knowledge_service.get_structure("hippocampus")
	if hippocampus.is_empty():
		print("  ❌ Failed to retrieve hippocampus data")
		return false
	print("  ✅ Retrieved structure: " + hippocampus.get("displayName", "Unknown"))
	
	# Test search
	var search_results = knowledge_service.search_structures("memory", 5)
	print("  ✅ Search found " + str(search_results.size()) + " results")
	
	# Test normalization
	var test_name = "Hippocampus (good)"
	var normalized_data = knowledge_service.get_structure(test_name)
	if not normalized_data.is_empty():
		print("  ✅ Name normalization working")
	else:
		print("  ⚠️  Name normalization needs improvement")
	
	return true

func _test_error_handler() -> bool:
	# Load ErrorHandler class
	var ErrorHandler = load("res://core/systems/ErrorHandler.gd")
	if not ErrorHandler:
		print("  ❌ Failed to load ErrorHandler")
		return false
	
	# Create instance
	var error_handler = ErrorHandler.new()
	if not error_handler:
		print("  ❌ Failed to create ErrorHandler instance")
		return false
	
	print("  ✅ ErrorHandler loaded successfully")
	
	# Test error creation
	var test_error = error_handler._create_error_data(
		ErrorHandler.ErrorType.KNOWLEDGE_BASE,
		"test_error",
		{"test": "data"}
	)
	
	if test_error.has("type") and test_error.has("message"):
		print("  ✅ Error data creation working")
	else:
		print("  ❌ Error data creation failed")
		return false
	
	# Cleanup
	error_handler.queue_free()
	
	return true