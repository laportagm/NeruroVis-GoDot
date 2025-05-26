extends Node

# A1-NeuroVis Development Console
# Enhanced debugging and development tools
# Available globally as DevConsole autoload

static var instance: Node
var console_visible = false
var console_history = []
var command_shortcuts = {}

func _init():
	instance = self
	_setup_shortcuts()

func _setup_shortcuts():
	# Register common development shortcuts
	command_shortcuts["perf"] = "ProjectProfiler.print_performance_report()"
	command_shortcuts["clear"] = "ProjectProfiler.clear_data()"
	command_shortcuts["models"] = "list_neural_models()"
	command_shortcuts["scenes"] = "list_scenes()"
	command_shortcuts["nodes"] = "print_scene_tree()"
	command_shortcuts["memory"] = "print_memory_usage()"

func _ready():
	print("🎮 DevConsole initialized - Press F1 for help")

func _input(event):
	if event.is_action_pressed("ui_accept") and Input.is_key_pressed(KEY_F1):
		toggle_console()

func toggle_console():
	console_visible = !console_visible
	print("🎮 DevConsole: ", "ON" if console_visible else "OFF")
	
	if console_visible:
		print_help()

func print_help():
	print("🎮 === A1-NeuroVis Dev Console ===")
	print("Available shortcuts:")
	for shortcut in command_shortcuts:
		print("  • ", shortcut, " - ", command_shortcuts[shortcut])
	print("Press F1 + Enter to toggle console")

static func execute_shortcut(shortcut: String):
	if not instance:
		print("⚠️ DevConsole not initialized")
		return
	
	if shortcut in instance.command_shortcuts:
		var command = instance.command_shortcuts[shortcut]
		print("🎮 Executing: ", command)
		
		# Execute the command
		match shortcut:
			"perf":
				ProjectProfiler.print_performance_report()
			"clear":
				ProjectProfiler.clear_data()
			"models":
				list_neural_models()
			"scenes":
				list_scenes()
			"nodes":
				print_scene_tree()
			"memory":
				print_memory_usage()
	else:
		print("⚠️ Unknown shortcut: ", shortcut)

static func list_neural_models():
	print("🧠 === Neural Models ===")
	var models_dir = "res://models/"
	if DirAccess.dir_exists_absolute(models_dir):
		var dir = DirAccess.open(models_dir)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".glb") or file_name.ends_with(".fbx"):
					print("  🧠 ", file_name)
				file_name = dir.get_next()
	else:
		print("  No models directory found")

static func list_scenes():
	print("🎭 === Scenes ===")
	var scenes_dir = "res://scenes/"
	if DirAccess.dir_exists_absolute(scenes_dir):
		var dir = DirAccess.open(scenes_dir)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if file_name.ends_with(".tscn"):
					print("  🎭 ", file_name)
				file_name = dir.get_next()

static func print_scene_tree():
	print("🌳 === Scene Tree ===")
	if instance and instance.get_tree():
		var root = instance.get_tree().root
		_print_node_recursive(root, 0)

static func _print_node_recursive(node: Node, depth: int):
	var indent = ""
	for i in depth:
		indent += "  "
	
	var node_info = str(node.name) + " (" + str(node.get_class()) + ")"
	if node is Node3D:
		node_info += " - Pos: " + str(node.global_position)
	
	print(indent + "├─ " + node_info)
	
	for child in node.get_children():
		_print_node_recursive(child, depth + 1)

static func print_memory_usage():
	print("💾 === Memory Usage ===")
	print("  Static Memory: ", OS.get_static_memory_usage())
	print("  Peak Memory: ", OS.get_static_memory_peak_usage())
	print("  Video Memory: ", RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_VIDEO_MEM_USED))
