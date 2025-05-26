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
	return load("res://scripts/visualization/VisualDebugger.gd")

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
