extends SceneTree

class_name GodotDebugRunner

var total_tests = 0
var passed_tests = 0
var failed_tests = 0
var debug_results = []

func _init():
	print("🔧 Godot Debug Test Runner Starting...")
	print("=" * 50)
	
	run_all_debug_tests()
	
	generate_debug_report()
	quit()

func run_all_debug_tests():
	print("🔍 Running Comprehensive Godot Debug Tests...")
	
	# Test 1: Basic Engine Information
	run_engine_info_test()
	
	# Test 2: Resource System Test
	run_resource_system_test()
	
	# Test 3: Autoload System Test
	run_autoload_system_test()
	
	# Test 4: Scene System Test
	run_scene_system_test()
	
	# Test 5: Script Compilation Test
	run_script_compilation_test()
	
	# Test 6: Asset Validation Test
	run_asset_validation_test()

func run_engine_info_test():
	print("\n🔧 Engine Information Test")
	print("-" * 30)
	
	var test_name = "Engine Information"
	var success = true
	var details = []
	
	var version_info = Engine.get_version_info()
	print("Engine Version: %s" % version_info)
	details.append("Version: %s" % version_info)
	
	var platform = OS.get_name()
	print("Platform: %s" % platform)
	details.append("Platform: %s" % platform)
	
	var debug_build = OS.is_debug_build()
	print("Debug Build: %s" % debug_build)
	details.append("Debug Build: %s" % debug_build)
	
	if version_info.major < 4:
		success = false
		details.append("ERROR: Requires Godot 4.x")
	
	record_test_result(test_name, success, details)

func run_resource_system_test():
	print("\n📦 Resource System Test")
	print("-" * 30)
	
	var test_name = "Resource System"
	var success = true
	var details = []
	
	# Test critical files
	var critical_files = [
		"res://project.godot",
		"res://assets/data/anatomical_data.json",
		"res://scenes/node_3d.tscn"
	]
	
	var found_files = 0
	for file_path in critical_files:
		if ResourceLoader.exists(file_path):
			found_files += 1
			print("✓ Found: %s" % file_path)
			details.append("Found: %s" % file_path.get_file())
		else:
			print("✗ Missing: %s" % file_path)
			details.append("Missing: %s" % file_path.get_file())
	
	if found_files < critical_files.size():
		success = false
	
	details.append("Files found: %d/%d" % [found_files, critical_files.size()])
	
	record_test_result(test_name, success, details)

func run_autoload_system_test():
	print("\n🔧 Autoload System Test") 
	print("-" * 30)
	
	var test_name = "Autoload System"
	var success = true
	var details = []
	
	var expected_autoloads = ["KB", "ModelSwitcherGlobal", "DebugCmd", "ProjectProfiler", "DevConsole", "TestRunner"]
	var available_autoloads = 0
	
	for autoload_name in expected_autoloads:
		if Engine.has_singleton(autoload_name):
			available_autoloads += 1
			print("✓ %s: Available" % autoload_name)
			details.append("%s: Available" % autoload_name)
			
			# Test accessibility
			var autoload = Engine.get_singleton(autoload_name)
			if not autoload:
				details.append("%s: Not accessible" % autoload_name)
		else:
			if autoload_name == "DebugCmd" and not OS.is_debug_build():
				print("- %s: Skipped (release build)" % autoload_name)
				details.append("%s: Skipped (release)" % autoload_name)
			else:
				print("✗ %s: Missing" % autoload_name)
				details.append("%s: Missing" % autoload_name)
	
	if available_autoloads < 3:
		success = false
	
	details.append("Available: %d/%d" % [available_autoloads, expected_autoloads.size()])
	
	record_test_result(test_name, success, details)

func run_scene_system_test():
	print("\n🎬 Scene System Test")
	print("-" * 30)
	
	var test_name = "Scene System"
	var success = true
	var details = []
	
	# Test main scene loading
	var main_scene_path = "res://scenes/node_3d.tscn"
	if ResourceLoader.exists(main_scene_path):
		var scene = load(main_scene_path)
		if scene:
			var instance = scene.instantiate()
			if instance:
				print("✓ Main scene loads and instantiates")
				details.append("Main scene: OK")
				
				# Check for key components
				var camera = instance.get_node_or_null("Camera3D")
				var ui_layer = instance.get_node_or_null("UI_Layer")
				var brain_model = instance.get_node_or_null("BrainModel")
				
				details.append("Camera3D: %s" % ("Present" if camera else "Missing"))
				details.append("UI_Layer: %s" % ("Present" if ui_layer else "Missing"))
				details.append("BrainModel: %s" % ("Present" if brain_model else "Missing"))
				
				instance.queue_free()
			else:
				success = false
				details.append("Main scene: Cannot instantiate")
		else:
			success = false
			details.append("Main scene: Cannot load")
	else:
		success = false
		details.append("Main scene: Not found")
	
	record_test_result(test_name, success, details)

func run_script_compilation_test():
	print("\n📜 Script Compilation Test")
	print("-" * 30)
	
	var test_name = "Script Compilation"
	var success = true
	var details = []
	
	var key_scripts = [
		"res://scripts/core/AnatomicalKnowledgeDatabase.gd",
		"res://scripts/models/ModelVisibilityManager.gd",
		"res://tests/framework/TestFramework.gd"
	]
	
	var compiled_scripts = 0
	for script_path in key_scripts:
		if ResourceLoader.exists(script_path):
			var script = load(script_path)
			if script:
				compiled_scripts += 1
				print("✓ Compiled: %s" % script_path.get_file())
				details.append("Compiled: %s" % script_path.get_file())
			else:
				print("✗ Compilation error: %s" % script_path.get_file())
				details.append("Error: %s" % script_path.get_file())
		else:
			print("✗ Not found: %s" % script_path.get_file())
			details.append("Missing: %s" % script_path.get_file())
	
	if compiled_scripts < key_scripts.size():
		success = false
	
	details.append("Compiled: %d/%d" % [compiled_scripts, key_scripts.size()])
	
	record_test_result(test_name, success, details)

func run_asset_validation_test():
	print("\n🎨 Asset Validation Test")
	print("-" * 30)
	
	var test_name = "Asset Validation"
	var success = true
	var details = []
	
	try:
		var model_assets = [
			"res://assets/models/Half_Brain.glb",
			"res://assets/models/Internal_Structures.glb",
			"res://assets/models/Brainstem(Solid).glb"
		]
		
		var valid_assets = 0
		for asset_path in model_assets:
			if ResourceLoader.exists(asset_path):
				var asset = load(asset_path)
				if asset:
					valid_assets += 1
					print("✓ Valid: %s" % asset_path.get_file())
					details.append("Valid: %s" % asset_path.get_file())
				else:
					print("✗ Cannot load: %s" % asset_path.get_file())
					details.append("Load error: %s" % asset_path.get_file())
			else:
				print("✗ Missing: %s" % asset_path.get_file())
				details.append("Missing: %s" % asset_path.get_file())
		
		if valid_assets < model_assets.size():
			success = false
		
		details.append("Valid assets: %d/%d" % [valid_assets, model_assets.size()])
		
	except:
		success = false
		details.append("ERROR: Asset validation failed")
	
	record_test_result(test_name, success, details)

func record_test_result(test_name: String, success: bool, details: Array):
	total_tests += 1
	
	if success:
		passed_tests += 1
		print("✅ %s: PASSED" % test_name)
	else:
		failed_tests += 1
		print("❌ %s: FAILED" % test_name)
	
	debug_results.append({
		"name": test_name,
		"success": success,
		"details": details
	})

func generate_debug_report():
	print("\n" + "=" * 50)
	print("🔍 GODOT DEBUG REPORT")
	print("=" * 50)
	
	print("Total Tests: %d" % total_tests)
	print("Passed: %d" % passed_tests)
	print("Failed: %d" % failed_tests)
	
	var success_rate = float(passed_tests) / float(total_tests) * 100.0 if total_tests > 0 else 0.0
	print("Success Rate: %.1f%%" % success_rate)
	
	# Health assessment
	if success_rate >= 90:
		print("🟢 Project Health: EXCELLENT")
	elif success_rate >= 75:
		print("🟡 Project Health: GOOD")
	elif success_rate >= 50:
		print("🟠 Project Health: NEEDS ATTENTION")
	else:
		print("🔴 Project Health: CRITICAL ISSUES")
	
	print("\nDetailed Results:")
	print("-" * 20)
	
	for result in debug_results:
		var status = "✅ PASS" if result.success else "❌ FAIL"
		print("%s %s" % [status, result.name])
		for detail in result.details:
			print("  - %s" % detail)
	
	# Save report to file
	var file = FileAccess.open("godot-debug-report.json", FileAccess.WRITE)
	if file:
		var report_data = {
			"timestamp": Time.get_datetime_string_from_system(),
			"godot_version": Engine.get_version_info(),
			"platform": OS.get_name(),
			"total_tests": total_tests,
			"passed_tests": passed_tests,
			"failed_tests": failed_tests,
			"success_rate": success_rate,
			"results": debug_results
		}
		file.store_string(JSON.stringify(report_data, "\t"))
		file.close()
		print("\n📄 Report saved: godot-debug-report.json")
	
	print("\n🎯 Debug testing completed!")

func try(callable: Callable):
	# Simple try-catch simulation
	return callable.call()