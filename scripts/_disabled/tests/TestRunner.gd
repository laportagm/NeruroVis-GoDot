extends Node

# A1-NeuroVis Test Runner
# Automated testing for neural visualization systems
# Available globally as TestRunner autoload

static var instance: Node
var test_results = {}
var current_test_suite = ""

func _init():
	instance = self

func _ready():
	print("🧪 TestRunner ready - Use run_all_tests() to start")

static func run_all_tests():
	if not instance:
		print("⚠️ TestRunner not initialized")
		return
	
	print("🧪 === Running A1-NeuroVis Test Suite ===")
	
	# Run test suites
	instance.test_autoloads()
	instance.test_model_switcher()
	instance.test_knowledge_base()
	instance.test_debug_commands()
	instance.test_scene_integrity()
	
	# Print final results
	instance.print_test_results()

func test_autoloads():
	current_test_suite = "Autoloads"
	print("🔍 Testing Autoloads...")
	
	# Test KnowledgeBase
	var kb_test = KB != null
	record_test("KB Autoload", kb_test, "KnowledgeBase should be available globally")
	
	# Test ModelSwitcher
	var ms_test = ModelSwitcherGlobal != null
	record_test("ModelSwitcher Autoload", ms_test, "ModelSwitcher should be available globally")
	
	# Test DebugCommands
	var dc_test = DebugCmd != null
	record_test("DebugCmd Autoload", dc_test, "DebugCmd should be available globally")

func test_model_switcher():
	current_test_suite = "ModelSwitcher"
	print("🔍 Testing ModelSwitcher...")
	
	if not ModelSwitcherGlobal:
		record_test("ModelSwitcher Availability", false, "ModelSwitcher not available")
		return
	
	# Test if ModelSwitcher has required methods
	var has_switch_method = ModelSwitcherGlobal.has_method("switch_to_model")
	record_test("Switch Method", has_switch_method, "switch_to_model method should exist")
	
	var has_get_models_method = ModelSwitcherGlobal.has_method("get_available_models")
	record_test("Get Models Method", has_get_models_method, "get_available_models method should exist")

func test_knowledge_base():
	current_test_suite = "KnowledgeBase"
	print("🔍 Testing KnowledgeBase...")
	
	if not KB:
		record_test("KB Availability", false, "KnowledgeBase not available")
		return
	
	# Test KB methods
	var has_get_info = KB.has_method("get_info")
	record_test("Get Info Method", has_get_info, "get_info method should exist")
	
	var has_add_info = KB.has_method("add_info")
	record_test("Add Info Method", has_add_info, "add_info method should exist")

func test_debug_commands():
	current_test_suite = "DebugCommands"
	print("🔍 Testing Debug Commands...")
	
	if not DebugCmd:
		record_test("DebugCmd Availability", false, "DebugCmd not available")
		return
	
	# Test debug command methods
	var has_run_command = DebugCmd.has_method("run_command")
	record_test("Run Command Method", has_run_command, "run_command method should exist")
	
	var has_register_command = DebugCmd.has_method("register_command")
	record_test("Register Command Method", has_register_command, "register_command method should exist")

func test_scene_integrity():
	current_test_suite = "Scene Integrity"
	print("🔍 Testing Scene Integrity...")
	
	# Test main scene
	var main_scene_path = "res://scenes/node_3d.tscn"
	var main_scene_exists = ResourceLoader.exists(main_scene_path)
	record_test("Main Scene Exists", main_scene_exists, "Main scene should exist at " + main_scene_path)
	
	# Test debug scene
	var debug_scene_path = "res://scenes/debug_scene.tscn"
	var debug_scene_exists = ResourceLoader.exists(debug_scene_path)
	record_test("Debug Scene Exists", debug_scene_exists, "Debug scene should exist at " + debug_scene_path)

func record_test(test_name: String, passed: bool, description: String):
	if current_test_suite not in test_results:
		test_results[current_test_suite] = []
	
	test_results[current_test_suite].append({
		"name": test_name,
		"passed": passed,
		"description": description
	})
	
	var status = "✅" if passed else "❌"
	print("  ", status, " ", test_name, " - ", description)

func print_test_results():
	print("\n🧪 === Test Results Summary ===")
	var total_tests = 0
	var passed_tests = 0
	
	for suite_name in test_results:
		var suite_tests = test_results[suite_name]
		var suite_passed = 0
		
		for test in suite_tests:
			total_tests += 1
			if test.passed:
				passed_tests += 1
				suite_passed += 1
		
		var suite_status = "✅" if suite_passed == suite_tests.size() else "❌"
		print(suite_status, " ", suite_name, ": ", suite_passed, "/", suite_tests.size(), " tests passed")
	
	print("\n📊 Overall: ", passed_tests, "/", total_tests, " tests passed")
	var success_rate = (float(passed_tests) / float(total_tests)) * 100.0
	print("📈 Success Rate: ", success_rate, "%")
	
	if success_rate == 100.0:
		print("🎉 All tests passed! Your A1-NeuroVis project is healthy!")
	elif success_rate >= 80.0:
		print("✨ Good job! Most tests passed.")
	else:
		print("⚠️ Some issues detected. Check failed tests above.")

# Quick test functions for console
static func quick_test():
	if instance:
		run_all_tests()

static func test_performance():
	print("🔬 === Performance Test ===")
	ProjectProfiler.start_timer("performance_test")
	
	# Simulate some work
	for i in 1000:
		pass
	
	ProjectProfiler.end_timer("performance_test")
	ProjectProfiler.print_performance_report()
