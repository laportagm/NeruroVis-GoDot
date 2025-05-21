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
func register_command(command_id: String, callback: Callable, description: String = "") -> void:
	registered_commands[command_id] = {
		"callback": callback,
		"description": description
	}
	print_debug("Registered command: " + command_id)

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
		print("[" + str(i+1) + "] " + command_history[i])

# Utility methods for logging
func log_error(message: String) -> void:
	print("[color=#" + error_color + "]ERROR: " + message + "[/color]")

func log_success(message: String) -> void:
	print("[color=#" + success_color + "]" + message + "[/color]")

func log_info(message: String) -> void:
	print("[color=#" + info_color + "]" + message + "[/color]")

func log_warning(message: String) -> void:
	print("[color=#" + warning_color + "]WARNING: " + message + "[/color]")

# Register built-in commands
func _ready() -> void:
	# Toggle debug mode
	register_command("debug_toggle", func(): 
		if has_node("/root/VisualDebugger"):
			VisualDebugger.toggle()
			log_info("Debug mode " + ("enabled" if VisualDebugger.is_debugger_active else "disabled"))
		else:
			log_error("VisualDebugger not found"),
		"Toggle debug visualization mode")
	
	# Show scene tree
	register_command("tree", func(node_path: String = "/root"): 
		var node = get_node_or_null(node_path)
		if node:
			log_info("Scene tree for " + node_path + ":")
			VisualDebugger.print_node_tree(node)
		else:
			log_error("Node not found: " + node_path),
		"Print scene tree from specified node (default: /root)")
	
	# Show collision shapes
	register_command("collision", func(node_path: String = "/root"): 
		var node = get_node_or_null(node_path)
		if node:
			VisualDebugger.visualize_collision_shapes(node)
			log_success("Visualizing collision shapes for " + node_path)
		else:
			log_error("Node not found: " + node_path),
		"Visualize collision shapes in the scene")
	
	# Label nodes
	register_command("label", func(node_path: String = "/root", filter_class: String = ""): 
		var node = get_node_or_null(node_path)
		if node and node is Node3D:
			VisualDebugger.label_all_nodes(node, true, filter_class)
			log_success("Added labels to nodes in " + node_path + 
				(" with class " + filter_class if filter_class != "" else ""))
		else:
			log_error("Node not found or not a Node3D: " + node_path),
		"Add labels to all nodes (optionally filter by class)")
	
	# Clear debug visuals
	register_command("clear_debug", func(): 
		VisualDebugger.clear_all()
		log_success("Cleared all debug visualizations"),
		"Clear all debug visualizations")
	
	# Run tests
	register_command("test", func(test_name: String = "all"): 
		if test_name == "all":
			log_info("Running all tests...")
			# Find and run tests here
		elif test_name == "model_switcher":
			log_info("Running model switcher test...")
			# Run specific test
		else:
			log_error("Unknown test: " + test_name),
		"Run tests (all or specific test name)")
	
	log_info("Debug commands initialized")
