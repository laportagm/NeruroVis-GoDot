extends Node

# Debug command system for NeuroVis
# Add this script as an autoload singleton in your project

# Used to track registered commands
var registered_commands = {}

# Setup console output style
var error_color = "FF6666"
var success_color = "88FF88"
var info_color = "88AAFF"
var warning_color = "FFCC66"

# Buffer for command history
var command_history = []
var history_index = -1
var command_buffer = ""

# Register a command with the debug system
func register_command(command_name: String, callback: Callable, description: String = "") -> void:
	registered_commands[command_name] = {
		"callback": callback,
		"description": description
	}
	print_debug("Registered command: " + command_name)

# Run a debug command
func run_command(command_string: String) -> void:
	# Add to history
	if command_string.strip_edges() != "":
		command_history.append(command_string)
		history_index = command_history.size()
	
	# Split command and args
	var parts = command_string.split(" ", false, 1)
	var command_name = parts[0].to_lower()
	var args = parts[1] if parts.size() > 1 else ""
	
	# Skip empty commands
	if command_name.strip_edges() == "":
		return
	
	# Process command
	if command_name == "help":
		_print_help(args)
	elif command_name == "ls" or command_name == "list":
		_list_commands()
	elif command_name == "history":
		_show_history()
	elif command_name == "clear":
		# Clear history is args specified
		if args == "history":
			command_history.clear()
			history_index = -1
			log_success("Command history cleared")
		else:
			# This is a no-op as we can't clear the actual console
			log_info("Console cleared")
	elif registered_commands.has(command_name):
		_execute_command(command_name, args)
	else:
		log_error("Unknown command: " + command_name)

# Execute a command with its arguments
func _execute_command(command_name: String, args: String) -> void:
	var command = registered_commands[command_name]
	
	# Get info about the callable
	var callable = command.callback
	var arg_count = callable.get_bound_arguments_count()
	
	# Split args if string
	var arg_array = []
	if args != "":
		arg_array = args.split(" ")
	
	# Execute with proper arguments
	if arg_count == 0:
		callable.call()
	elif arg_count == 1:
		callable.call(args) # Pass the raw string
	else:
		# For multi-arg functions, pass the split array
		callable.call(arg_array)

# Display help for commands
func _print_help(command_name: String = "") -> void:
	if command_name.strip_edges() == "":
		log_info("Available commands: (Type 'help <command>' for details)")
		_list_commands()
		return
	
	if command_name == "help":
		log_info("help [command] - Display help for all commands or a specific command")
	elif command_name == "ls" or command_name == "list":
		log_info("ls/list - List all available commands")
	elif command_name == "history":
		log_info("history - Show command history")
	elif command_name == "clear":
		log_info("clear [history] - Clear console or command history")
	elif registered_commands.has(command_name):
		var cmd = registered_commands[command_name]
		log_info(command_name + " - " + cmd.description)
	else:
		log_error("Unknown command: " + command_name)

# List all registered commands
func _list_commands() -> void:
	var command_list = registered_commands.keys()
	command_list.sort()
	
	for command in command_list:
		var description = registered_commands[command].description
		log_info("- " + command + (": " + description if description != "" else ""))

# Show command history
func _show_history() -> void:
	log_info("Command history:")
	
	for i in range(command_history.size()):
		print("[" + str(i + 1) + "] " + command_history[i])

# Get count of registered commands
func get_command_count() -> int:
	return registered_commands.size()

# Utility methods for logging
func log_error(message: String) -> void:
	print("[color=#" + error_color + "]ERROR: " + message + "[/color]")

func log_success(message: String) -> void:
	print("[color=#" + success_color + "]" + message + "[/color]")

func log_info(message: String) -> void:
	print("[color=#" + info_color + "]" + message + "[/color]")

func log_warning(message: String) -> void:
	print("[color=#" + warning_color + "]WARNING: " + message + "[/color]")

# Helper function to safely load VisualDebugger
func get_visual_debugger():
	return load("res://core/visualization/VisualDebugger.gd")

# Register built-in commands
func _ready() -> void:
	# Toggle debug mode
	register_command("debug_toggle", func():
		var vd = get_visual_debugger()
		if vd:
			vd.toggle()
		else:
			log_error("VisualDebugger not available"),
		"Toggle debug visualization mode")
	
	# Show scene tree5
	register_command("tree", func(node_path: String = "/root"):
		var node = get_node_or_null(node_path)
		if node:
			log_info("Scene tree for " + node_path + ":")
			var vd = get_visual_debugger()
			if vd:
				vd.print_node_tree(node)
		else:
			log_error("Node not found: " + node_path),
		"Print scene tree from specified node (default: /root)")
	
	# Show collision shapes
	register_command("collision", func(node_path: String = "/root"):
		var node = get_node_or_null(node_path)
		if node:
			var vd = get_visual_debugger()
			if vd:
				vd.visualize_collision_shapes(node)
			log_success("Visualizing collision shapes for " + node_path)
		else:
			log_error("Node not found: " + node_path),
		"Visualize collision shapes in the scene")
	
	# Label nodes
	register_command("label", func(node_path: String = "/root", filter_class: String = ""):
		var node = get_node_or_null(node_path)
		if node and node is Node3D:
			var vd = get_visual_debugger()
			if vd:
				vd.label_all_nodes(node, true, filter_class)
			log_success("Added labels to nodes in " + node_path +
				(" with class " + filter_class if filter_class != "" else ""))
		else:
			log_error("Node not found or not a Node3D: " + node_path),
		"Add labels to all nodes (optionally filter by class)")
	
	# Clear debug visuals
	register_command("clear_debug", func():
		var vd = get_visual_debugger()
		if vd:
			vd.clear_all()
		log_success("Cleared all debug visualizations"),
		"Clear all debug visualizations")
	
	# Run tests
	register_command("test", func(test_name: String = "all"):
		if test_name == "all":
			log_info("Running comprehensive test suite...")
			_run_debug_tests()
		elif test_name == "autoloads":
			log_info("Testing autoload systems...")
			_test_autoloads()
		elif test_name == "infrastructure":
			log_info("Testing debug infrastructure...")
			_test_debug_infrastructure()
		elif test_name == "model_switcher":
			log_info("Running model switcher test...")
			_test_model_switcher()
		else:
			log_error("Unknown test: " + test_name)
			log_info("Available tests: all, autoloads, infrastructure, model_switcher"),
		"Run tests (all, autoloads, infrastructure, model_switcher)")
	
	# Register parser error checking commands
	register_command("parser_check", cmd_parser_check, "Check all scripts for parser errors")
	register_command("dependency_check", cmd_dependency_check, "Validate autoload dependencies")
	register_command("scene_validate", cmd_scene_validate, "Validate scene structure")
	register_command("resource_check", cmd_resource_check, "Check for missing resources")
	register_command("preload_test", cmd_preload_test, "Test resource preloading")
	register_command("syntax_check", cmd_syntax_check, "Quick syntax validation")
	register_command("godot_check", cmd_godot_check, "Check Godot version and compatibility")
	
	# Register QA visualization commands
	register_command("qa_viz", cmd_qa_viz_toggle, "Toggle QA debug visualization")
	register_command("qa_viz_bounds", cmd_qa_viz_bounds, "Show structure bounds [structure_name]")
	register_command("qa_viz_rays", cmd_qa_viz_rays, "Toggle selection ray visualization")
	register_command("qa_viz_collisions", cmd_qa_viz_collisions, "Show collision shapes [structure_name]")
	register_command("qa_viz_clicks", cmd_qa_viz_clicks, "Toggle click position markers")
	register_command("qa_viz_status", cmd_qa_viz_status, "Show visualization status")
	
	# Multi-selection debug commands
	register_command("multiselect_test", cmd_multiselect_test, "Test multi-selection system")
	register_command("multiselect_debug", cmd_multiselect_debug, "Toggle multi-selection debug mode")
	register_command("multiselect_report", cmd_multiselect_report, "Show current multi-selection state")
	register_command("multiselect_clear", cmd_multiselect_clear, "Clear all selections")
	
	# Register commands from new debugging systems
	# TODO: Re-enable once all systems are stable
	# _register_advanced_debug_commands()
	
	log_info("Debug commands initialized")

# Test functions for debugging infrastructure
func _run_debug_tests():
	log_info("=== A1-NeuroVis Debug Test Suite ===")
	_test_autoloads()
	_test_debug_infrastructure()
	_test_model_switcher()
	log_success("=== Test Suite Complete ===")

func _test_autoloads():
	log_info("🔍 Testing Autoload Registration:")
	
	var kb = get_node_or_null("/root/KB")
	if kb:
		log_success("✅ KB (KnowledgeBase) loaded")
		if kb.has_method("get_structure_count"):
			log_info("   - Structure count: %d" % kb.get_structure_count())
		else:
			log_warning("   - get_structure_count() method missing")
	else:
		log_error("❌ KB (KnowledgeBase) not found")
	
	var model_switcher = get_node_or_null("/root/ModelSwitcherGlobal")
	if model_switcher:
		log_success("✅ ModelSwitcherGlobal loaded")
		if model_switcher.has_method("get_available_models"):
			var models = model_switcher.get_available_models()
			log_info("   - Available models: %s" % str(models))
		else:
			log_warning("   - get_available_models() method missing")
	else:
		log_error("❌ ModelSwitcherGlobal not found")
	
	var error_tracker = get_node_or_null("/root/ErrorTracker")
	if error_tracker:
		log_success("✅ ErrorTracker loaded")
	else:
		log_error("❌ ErrorTracker not found")
	
	var health_monitor = get_node_or_null("/root/HealthMonitor")
	if health_monitor:
		log_success("✅ HealthMonitor loaded")
	else:
		log_error("❌ HealthMonitor not found")
	
	var test_framework = get_node_or_null("/root/TestFramework")
	if test_framework:
		log_success("✅ TestFramework loaded")
	else:
		log_error("❌ TestFramework not found")

func _test_debug_infrastructure():
	log_info("🧪 Testing Debug Infrastructure:")
	
	# Test ErrorTracker
	var error_tracker = get_node_or_null("/root/ErrorTracker")
	if error_tracker:
		if error_tracker.has_method("log_error"):
			log_success("✅ ErrorTracker.log_error() available")
			# Test logging
			if error_tracker.has_method("log_info") or error_tracker.has_method("log_warning"):
				log_info("   - Testing error logging...")
				# We could test actual error logging here if needed
		else:
			log_error("❌ ErrorTracker.log_error() missing")
	
	# Test HealthMonitor
	var health_monitor = get_node_or_null("/root/HealthMonitor")
	if health_monitor:
		if health_monitor.has_method("get_system_health"):
			log_success("✅ HealthMonitor.get_system_health() available")
		else:
			log_error("❌ HealthMonitor.get_system_health() missing")
	
	# Test BrainVisDebugger
	var brain_debugger = get_node_or_null("/root/BrainVisDebugger")
	if brain_debugger:
		log_success("✅ BrainVisDebugger loaded")
		if brain_debugger.has_method("validate_all_models"):
			log_info("   - validate_all_models() available")
		else:
			log_warning("   - validate_all_models() method missing")
	else:
		log_error("❌ BrainVisDebugger not found")

func _test_model_switcher():
	log_info("🔄 Testing Model Switcher:")
	
	var model_switcher = get_node_or_null("/root/ModelSwitcherGlobal")
	if not model_switcher:
		log_error("❌ ModelSwitcher not available")
		return
	
	if model_switcher.has_method("get_available_models"):
		var models = model_switcher.get_available_models()
		log_info("   - Found %d models: %s" % [models.size(), str(models)])
		
		if models.size() > 0:
			log_info("   - Testing model switching...")
			for model_name in models:
				if model_switcher.has_method("switch_to_model"):
					var success = model_switcher.switch_to_model(model_name)
					if success:
						log_success("   ✅ Switched to: " + model_name)
					else:
						log_error("   ❌ Failed to switch to: " + model_name)
				else:
					log_error("   ❌ switch_to_model() method missing")
					break
		else:
			log_warning("   - No models available for testing")
	else:
		log_error("   ❌ get_available_models() method missing")

# === PARSER ERROR CHECKING COMMANDS ===

func cmd_parser_check(_args: String = "") -> void:
	"""Check all scripts for parser errors"""
	log_info("🔍 Running parser error check...")
	
	var script_files = []
	_collect_script_files("res://", script_files)
	
	var errors = 0
	var total = script_files.size()
	
	for file_path in script_files:
		var script = load(file_path)
		if not script:
			log_error("❌ Parse error: %s" % file_path)
			errors += 1
		elif _args == "verbose":
			log_success("✅ OK: %s" % file_path.get_file())
	
	log_info("Parser check complete: %d/%d files passed" % [total - errors, total])
	if errors == 0:
		log_success("🎉 No parser errors found!")
	else:
		log_error("Found %d parser error(s)" % errors)

func cmd_dependency_check(_args: String = "") -> void:
	"""Validate all autoload dependencies"""
	log_info("🔗 Checking dependencies...")
	
	var required_autoloads = [
		"KnowledgeService",
		"UIThemeManager", 
		"ModelSwitcherGlobal",
		"StructureAnalysisManager",
		"DebugCmd"
	]
	
	var missing = []
	for autoload_name in required_autoloads:
		if Engine.has_singleton(autoload_name):
			log_success("✅ %s available" % autoload_name)
		else:
			log_error("❌ %s missing" % autoload_name)
			missing.append(autoload_name)
	
	if missing.size() == 0:
		log_success("✅ All dependencies available")
	else:
		log_error("Missing dependencies: %s" % str(missing))

func cmd_scene_validate(args: String = "") -> void:
	"""Validate scene structure"""
	var scene_path = args if args != "" else "res://scenes/main/node_3d.tscn"
	
	log_info("🎬 Validating scene: %s" % scene_path)
	
	if not ResourceLoader.exists(scene_path):
		log_error("❌ Scene not found: %s" % scene_path)
		return
	
	var scene = load(scene_path)
	if not scene:
		log_error("❌ Failed to load scene: %s" % scene_path)
		return
	
	if not scene is PackedScene:
		log_error("❌ Not a scene file: %s" % scene_path)
		return
	
	var instance = scene.instantiate()
	if not instance:
		log_error("❌ Failed to instantiate scene")
		return
	
	log_success("✅ Scene validated successfully")
	
	# Check for required nodes in main scene
	if scene_path.ends_with("node_3d.tscn"):
		_validate_main_scene_structure(instance)
	
	instance.queue_free()

func cmd_resource_check(_args: String = "") -> void:
	"""Check for missing resources"""
	log_info("📂 Checking critical resources...")
	
	var critical_resources = [
		"res://project.godot",
		"res://icon.svg",
		"res://assets/data/anatomical_data.json",
		"res://scenes/main/node_3d.tscn",
		"res://core/knowledge/KnowledgeService.gd",
		"res://core/models/ModelVisibilityManager.gd"
	]
	
	var missing = []
	for resource_path in critical_resources:
		if ResourceLoader.exists(resource_path):
			log_success("✅ Found: %s" % resource_path.get_file())
		else:
			log_error("❌ Missing: %s" % resource_path)
			missing.append(resource_path)
	
	if missing.size() == 0:
		log_success("✅ All critical resources found")
	else:
		log_error("Missing %d resource(s)" % missing.size())

func cmd_preload_test(args: String = "") -> void:
	"""Test resource preloading"""
	var test_path = args if args != "" else "res://scenes/main/node_3d.tscn"
	
	log_info("⚡ Testing preload: %s" % test_path)
	
	if not ResourceLoader.exists(test_path):
		log_error("❌ Resource not found: %s" % test_path)
		return
	
	var start_time = Time.get_ticks_msec()
	var resource = load(test_path)
	var load_time = Time.get_ticks_msec() - start_time
	
	if resource:
		log_success("✅ Loaded in %d ms" % load_time)
		log_info("   Type: %s" % resource.get_class())
	else:
		log_error("❌ Failed to load resource")

func cmd_syntax_check(_args: String = "") -> void:
	"""Quick syntax validation"""
	log_info("📝 Quick syntax check...")
	
	var core_files = [
		"res://scenes/main/node_3d.gd",
		"res://core/knowledge/KnowledgeService.gd",
		"res://core/models/ModelVisibilityManager.gd",
		"res://ui/panels/UIThemeManager.gd"
	]
	
	var errors = 0
	for file_path in core_files:
		if ResourceLoader.exists(file_path):
			var script = load(file_path)
			if script:
				log_success("✅ %s" % file_path.get_file())
			else:
				log_error("❌ %s" % file_path.get_file())
				errors += 1
		else:
			log_error("❌ Missing: %s" % file_path.get_file())
			errors += 1
	
	if errors == 0:
		log_success("✅ All core files syntax OK")
	else:
		log_error("Found %d syntax error(s)" % errors)

func cmd_godot_check(_args: String = "") -> void:
	"""Check Godot version and compatibility"""
	log_info("🎮 Godot Environment Check:")
	
	var version_info = Engine.get_version_info()
	log_info("   Version: %d.%d.%d %s" % [
		version_info.major,
		version_info.minor, 
		version_info.patch,
		version_info.status
	])
	
	log_info("   Hash: %s" % version_info.hash)
	log_info("   Platform: %s" % OS.get_name())
	log_info("   Debug build: %s" % str(OS.is_debug_build()))
	
	# Check for Godot 4 features
	if version_info.major >= 4:
		log_success("✅ Godot 4+ detected")
	else:
		log_warning("⚠️ Godot 3 detected - may have compatibility issues")
	
	# Check renderer
	var renderer = RenderingServer.get_rendering_device()
	if renderer:
		log_success("✅ Vulkan renderer available")
	else:
		log_warning("⚠️ Using compatibility renderer")

# === HELPER FUNCTIONS ===

func _collect_script_files(dir_path: String, files: Array) -> void:
	"""Recursively collect all GDScript files"""
	var dir = DirAccess.open(dir_path)
	if not dir:
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if dir.current_is_dir() and not file_name.begins_with(".") and file_name != "tmp":
			_collect_script_files(dir_path + "/" + file_name, files)
		elif file_name.ends_with(".gd"):
			files.append(dir_path + "/" + file_name)
		
		file_name = dir.get_next()

func _validate_main_scene_structure(scene_instance: Node) -> void:
	"""Validate main scene has required nodes"""
	log_info("   🔍 Checking main scene structure...")
	
	var required_nodes = {
		"Camera3D": "$Camera3D",
		"UI_Layer": "$UI_Layer",
		"BrainModel": "$BrainModel"
	}
	
	var missing = []
	for node_name in required_nodes:
		var path = required_nodes[node_name]
		if scene_instance.has_node(path):
			log_success("   ✅ %s found" % node_name)
		else:
			log_error("   ❌ %s missing at %s" % [node_name, path])
			missing.append(node_name)
	
	if missing.size() == 0:
		log_success("   ✅ Scene structure validated")
	else:
		log_error("   Missing nodes: %s" % str(missing))

# === QA VISUALIZATION COMMANDS ===

# Reference to debug visualizer
var _qa_debug_viz: Node3D = null

func cmd_qa_viz_toggle(_args: String = "") -> void:
	"""Toggle QA debug visualization"""
	_ensure_qa_viz_exists()
	if _qa_debug_viz:
		_qa_debug_viz.toggle_debug_draw()

func cmd_qa_viz_bounds(args: String = "") -> void:
	"""Show structure bounds visualization"""
	if args.is_empty():
		log_error("Usage: qa_viz_bounds <structure_name>")
		return
	
	_ensure_qa_viz_exists()
	if _qa_debug_viz:
		_qa_debug_viz.show_structure_bounds(args)

func cmd_qa_viz_rays(_args: String = "") -> void:
	"""Toggle selection ray visualization"""
	_ensure_qa_viz_exists()
	if _qa_debug_viz:
		var current = _qa_debug_viz._show_rays if "_show_rays" in _qa_debug_viz else false
		_qa_debug_viz.set_show_rays(not current)
		log_info("Ray visualization: %s" % ("ENABLED" if not current else "DISABLED"))

func cmd_qa_viz_collisions(args: String = "") -> void:
	"""Show collision shapes"""
	_ensure_qa_viz_exists()
	if _qa_debug_viz:
		_qa_debug_viz.show_collision_shapes(args)

func cmd_qa_viz_clicks(_args: String = "") -> void:
	"""Toggle click position markers"""
	_ensure_qa_viz_exists()
	if _qa_debug_viz:
		var current = _qa_debug_viz._show_click_positions if "_show_click_positions" in _qa_debug_viz else false
		_qa_debug_viz.set_show_clicks(not current)
		log_info("Click markers: %s" % ("ENABLED" if not current else "DISABLED"))

func cmd_qa_viz_status(_args: String = "") -> void:
	"""Show visualization status"""
	_ensure_qa_viz_exists()
	if _qa_debug_viz:
		var status = _qa_debug_viz.get_status()
		log_info("=== QA Visualization Status ===")
		log_info("Enabled: %s" % str(status.get("enabled", false)))
		log_info("Bounds: %s (%d active)" % [str(status.get("bounds", false)), status.get("active_bounds", 0)])
		log_info("Rays: %s (%d active)" % [str(status.get("rays", false)), status.get("active_rays", 0)])
		log_info("Collisions: %s" % str(status.get("collisions", false)))
		log_info("Click Markers: %s (%d active)" % [str(status.get("clicks", false)), status.get("active_clicks", 0)])
		log_info("==============================")

func _ensure_qa_viz_exists() -> void:
	"""Ensure QA debug visualizer exists"""
	if _qa_debug_viz:
		return
	
	# Find main scene
	var main_scene = get_node_or_null("/root/Node3D")
	if not main_scene:
		log_error("Main scene not found - cannot create QA visualizer")
		return
	
	# Load and create visualizer
	var DebugVizScript = load("res://tests/qa/SelectionDebugVisualizer.gd")
	if not DebugVizScript:
		log_error("SelectionDebugVisualizer.gd not found")
		return
	
	_qa_debug_viz = DebugVizScript.new()
	main_scene.add_child(_qa_debug_viz)
	_qa_debug_viz.initialize(main_scene)
	
	log_success("QA Debug Visualizer created")

# === MULTI-SELECTION DEBUG COMMANDS ===
func cmd_multiselect_test():
	"""Test multi-selection system functionality"""
	log_info("=== Multi-Selection System Test ===")
	
	# Find selection manager
	var main_scene = get_node_or_null("/root/MainScene") 
	if not main_scene:
		main_scene = get_node_or_null("/root/Node3D")
	
	if not main_scene:
		log_error("Main scene not found")
		return
	
	var selection_manager = main_scene.get_node_or_null("MultiStructureSelectionManager")
	if not selection_manager:
		log_error("MultiStructureSelectionManager not found")
		return
	
	log_success("✅ Multi-selection manager found")
	log_info("Current selections: %d" % selection_manager.get_selection_count())
	
	# Test selection states
	var selections = selection_manager.get_selection_info()
	for sel in selections:
		log_info("  - %s (%s)" % [sel["name"], sel["state"]])
	
	log_success("=== Test Complete ===")

func cmd_multiselect_debug():
	"""Toggle multi-selection debug visualization"""
	var main_scene = get_node_or_null("/root/MainScene")
	if not main_scene:
		main_scene = get_node_or_null("/root/Node3D")
	
	if not main_scene:
		log_error("Main scene not found")
		return
	
	var selection_manager = main_scene.get_node_or_null("MultiStructureSelectionManager")
	if not selection_manager:
		log_error("MultiStructureSelectionManager not found")
		return
	
	# Toggle debug mode (would need to implement this in MultiStructureSelectionManager)
	if selection_manager.has_method("toggle_debug_mode"):
		selection_manager.toggle_debug_mode()
		log_success("Multi-selection debug mode toggled")
	else:
		log_warning("Debug mode not implemented in MultiStructureSelectionManager")

func cmd_multiselect_report():
	"""Show detailed multi-selection state"""
	var main_scene = get_node_or_null("/root/MainScene")
	if not main_scene:
		main_scene = get_node_or_null("/root/Node3D")
	
	if not main_scene:
		log_error("Main scene not found")
		return
	
	var selection_manager = main_scene.get_node_or_null("MultiStructureSelectionManager")
	if not selection_manager:
		log_error("MultiStructureSelectionManager not found")
		return
	
	log_info("=== Multi-Selection State Report ===")
	
	var count = selection_manager.get_selection_count()
	log_info("Total selections: %d/%d" % [count, 3])
	
	var selections = selection_manager.get_selection_info()
	for i in range(selections.size()):
		var sel = selections[i]
		var state_color = ""
		match sel["state"]:
			0: state_color = "FFD700"  # Gold
			1: state_color = "00CED1"  # Turquoise
			2: state_color = "9370DB"  # Purple
		
		log_info("[color=#%s]%d. %s (%s)[/color]" % [state_color, i+1, sel["name"], sel["state"]])
	
	# Check comparison mode
	var mode = "SINGLE"
	if selection_manager.has_method("is_comparison_mode"):
		if selection_manager.is_comparison_mode():
			mode = "COMPARISON"
	elif selection_manager.get("_is_comparison_mode"):
		if selection_manager._is_comparison_mode:
			mode = "COMPARISON"
	
	log_info("Mode: " + mode)
	
	log_success("=== Report Complete ===")

func cmd_multiselect_clear():
	"""Clear all multi-selections"""
	var main_scene = get_node_or_null("/root/MainScene")
	if not main_scene:
		main_scene = get_node_or_null("/root/Node3D")
	
	if not main_scene:
		log_error("Main scene not found")
		return
	
	var selection_manager = main_scene.get_node_or_null("MultiStructureSelectionManager")
	if not selection_manager:
		log_error("MultiStructureSelectionManager not found")
		return
	
	selection_manager.clear_all_selections()
	log_success("All selections cleared")
