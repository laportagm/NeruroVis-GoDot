# Godot Operations Script for MCP Server
# Handles scene and node operations that require Godot engine access
extends SceneTree

var operation_handlers = {
	"create_scene": create_scene,
	"add_node": add_node_to_scene,
	"modify_node": modify_node_properties,
	"load_sprite": load_sprite_texture,
	"analyze_scene": analyze_scene_structure
}

func _init():
	var args = OS.get_cmdline_args()
	var operation_json = ""
	
	# Find the JSON argument (after --)
	var found_separator = false
	for arg in args:
		if found_separator:
			operation_json = arg
			break
		if arg == "--":
			found_separator = true
	
	if operation_json.is_empty():
		print_error("No operation JSON provided")
		quit(1)
		return
	
	var json = JSON.new()
	var parse_result = json.parse(operation_json)
	
	if parse_result != OK:
		print_error("Failed to parse JSON: " + json.get_error_message())
		quit(1)
		return
	
	var operation = json.data
	
	# Execute operation
	if operation.has("type") and operation_handlers.has(operation.type):
		call(operation_handlers[operation.type], operation)
	else:
		print_error("Unknown operation type: " + str(operation.get("type", "undefined")))
		quit(1)

func create_scene(op: Dictionary) -> void:
	var scene = PackedScene.new()
	var root_node
	
	# Create root node
	var node_type = op.get("root_node_type", "Node2D")
	if ClassDB.class_exists(node_type):
		root_node = ClassDB.instantiate(node_type)
		root_node.name = "Root"
	else:
		print_error("Invalid node type: " + node_type)
		quit(1)
		return
	
	# Pack and save
	scene.pack(root_node)
	var save_path = "res://" + op.scene_path
	
	# Ensure directory exists
	var dir = save_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	
	var error = ResourceSaver.save(scene, save_path)
	
	if error == OK:
		print("Scene created successfully: " + save_path)
	else:
		print_error("Failed to save scene: " + str(error))
		quit(1)
	
	quit()

func add_node_to_scene(op: Dictionary) -> void:
	var scene_path = "res://" + op.scene_path
	
	# Load scene
	if not ResourceLoader.exists(scene_path):
		print_error("Scene not found: " + scene_path)
		quit(1)
		return
	
	var scene = ResourceLoader.load(scene_path) as PackedScene
	if not scene:
		print_error("Failed to load scene")
		quit(1)
		return
	
	var root = scene.instantiate()
	
	# Find parent node
	var parent_node
	if op.parent_node_path == "." or op.parent_node_path == "root":
		parent_node = root
	else:
		parent_node = root.get_node_or_null(op.parent_node_path)
		if not parent_node:
			print_error("Parent node not found: " + op.parent_node_path)
			quit(1)
			return
	
	# Create new node
	if not ClassDB.class_exists(op.node_type):
		print_error("Invalid node type: " + op.node_type)
		quit(1)
		return
	
	var new_node = ClassDB.instantiate(op.node_type)
	new_node.name = op.node_name
	
	# Set properties
	if op.has("properties") and op.properties is Dictionary:
		for prop_name in op.properties:
			if prop_name in new_node:
				new_node.set(prop_name, op.properties[prop_name])
	
	# Add to parent
	parent_node.add_child(new_node)
	new_node.owner = root
	
	# Save scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	var error = ResourceSaver.save(packed_scene, scene_path)
	
	if error == OK:
		print("Node added successfully")
	else:
		print_error("Failed to save scene")
		quit(1)
	
	quit()

func modify_node_properties(op: Dictionary) -> void:
	var scene_path = "res://" + op.scene_path
	
	# Load scene
	var scene = ResourceLoader.load(scene_path) as PackedScene
	if not scene:
		print_error("Failed to load scene")
		quit(1)
		return
	
	var root = scene.instantiate()
	var target_node = root if op.node_path == "." else root.get_node_or_null(op.node_path)
	
	if not target_node:
		print_error("Node not found: " + op.node_path)
		quit(1)
		return
	
	# Modify properties
	for prop_name in op.properties:
		if prop_name in target_node:
			target_node.set(prop_name, op.properties[prop_name])
	
	# Save scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	var error = ResourceSaver.save(packed_scene, scene_path)
	
	if error == OK:
		print("Properties modified successfully")
	else:
		print_error("Failed to save scene")
		quit(1)
	
	quit()

func load_sprite_texture(op: Dictionary) -> void:
	var scene_path = "res://" + op.scene_path
	var texture_path = "res://" + op.texture_path
	
	# Verify texture exists
	if not ResourceLoader.exists(texture_path):
		print_error("Texture not found: " + texture_path)
		quit(1)
		return
	
	# Load scene
	var scene = ResourceLoader.load(scene_path) as PackedScene
	if not scene:
		print_error("Failed to load scene")
		quit(1)
		return
	
	var root = scene.instantiate()
	var sprite_node = root.get_node_or_null(op.node_path)
	
	if not sprite_node:
		print_error("Sprite node not found: " + op.node_path)
		quit(1)
		return
	
	if not sprite_node is Sprite2D and not sprite_node is Sprite3D:
		print_error("Node is not a Sprite2D or Sprite3D")
		quit(1)
		return
	
	# Load and set texture
	var texture = ResourceLoader.load(texture_path)
	sprite_node.texture = texture
	
	# Save scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(root)
	var error = ResourceSaver.save(packed_scene, scene_path)
	
	if error == OK:
		print("Texture loaded successfully")
	else:
		print_error("Failed to save scene")
		quit(1)
	
	quit()

func analyze_scene_structure(op: Dictionary) -> void:
	var scene_path = "res://" + op.scene_path
	
	var scene = ResourceLoader.load(scene_path) as PackedScene
	if not scene:
		print_error("Failed to load scene")
		quit(1)
		return
	
	var root = scene.instantiate()
	var structure = _analyze_node_recursive(root)
	
	var json = JSON.new()
	print(json.stringify(structure))
	
	quit()

func _analyze_node_recursive(node: Node) -> Dictionary:
	var info = {
		"name": node.name,
		"type": node.get_class(),
		"children": []
	}
	
	# Add position info for 2D/3D nodes
	if node is Node2D:
		info["position"] = {"x": node.position.x, "y": node.position.y}
		info["rotation"] = node.rotation
		info["scale"] = {"x": node.scale.x, "y": node.scale.y}
	elif node is Node3D:
		info["position"] = {"x": node.position.x, "y": node.position.y, "z": node.position.z}
		info["rotation"] = {"x": node.rotation.x, "y": node.rotation.y, "z": node.rotation.z}
		info["scale"] = {"x": node.scale.x, "y": node.scale.y, "z": node.scale.z}
	
	# Add script info
	if node.get_script():
		var script = node.get_script()
		if script.resource_path:
			info["script"] = script.resource_path
	
	# Process children
	for child in node.get_children():
		info.children.append(_analyze_node_recursive(child))
	
	return info

func print_error(message: String) -> void:
	push_error(message)
	print(message)
