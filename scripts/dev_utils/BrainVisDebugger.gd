extends Node

# A1-NeuroVis Brain Visualization Specialized Debugger
# Specialized debugging tools for neural visualization, model integrity, and brain-specific systems

signal model_integrity_checked(model_name: String, issues: Array)
signal mesh_analysis_completed(mesh_name: String, analysis: Dictionary)
signal selection_accuracy_tested(results: Dictionary)

static var instance
var validation_results: Dictionary = {}
var mesh_analysis_cache: Dictionary = {}

func _init():
	instance = self

func _ready():
	print("🧠 BrainVisDebugger initialized - Neural visualization debugging ready")

# Model Integrity Validation
static func validate_all_models():
	if not instance:
		print("❌ BrainVisDebugger not initialized")
		return
	
	print("🔍 Validating all brain models...")
	instance._validate_all_models_internal()

func _validate_all_models_internal():
	if not ModelSwitcherGlobal:
		print("❌ ModelSwitcher not available")
		return
	
	var models = ModelSwitcherGlobal.get_available_models()
	var total_issues = 0
	
	for model_name in models:
		var issues = _validate_single_model(model_name)
		validation_results[model_name] = issues
		total_issues += issues.size()
		
		model_integrity_checked.emit(model_name, issues)
		
		# Log results
		if issues.size() == 0:
			print("✅ %s: No issues found" % model_name)
		else:
			print("⚠️ %s: %d issues found" % [model_name, issues.size()])
			for issue in issues:
				print("  - %s" % issue)
	
	print("📊 Model validation complete: %d total issues across %d models" % [total_issues, models.size()])

func _validate_single_model(model_name: String) -> Array:
	var issues = []
	
	# Get model node
	var model_node = _get_model_node(model_name)
	if not model_node:
		issues.append("Model node not found")
		return issues
	
	# Check model structure
	issues.append_array(_check_model_structure(model_node, model_name))
	
	# Check mesh integrity
	issues.append_array(_check_mesh_integrity(model_node, model_name))
	
	# Check collision shapes
	issues.append_array(_check_collision_shapes(model_node, model_name))
	
	# Check materials
	issues.append_array(_check_materials(model_node, model_name))
	
	return issues

func _get_model_node(model_name: String) -> Node3D:
	# Try to find the model in the scene tree
	var scene_tree = Engine.get_main_loop()
	if scene_tree and scene_tree.current_scene:
		return _find_model_recursive(scene_tree.current_scene, model_name)
	return null

func _find_model_recursive(node: Node, model_name: String) -> Node3D:
	# Check if this node matches the model
	if node.name.contains(model_name.replace("_", " ")) or node.name.contains(model_name):
		return node as Node3D
	
	# Search children
	for child in node.get_children():
		var result = _find_model_recursive(child, model_name)
		if result:
			return result
	
	return null

func _check_model_structure(model_node: Node3D, _model_name: String) -> Array:
	var issues = []
	
	# Check if model has children
	if model_node.get_child_count() == 0:
		issues.append("Model has no child nodes")
	
	# Check for MeshInstance3D nodes
	var mesh_instances = _get_mesh_instances(model_node)
	if mesh_instances.size() == 0:
		issues.append("No MeshInstance3D nodes found")
	
	# Check model transform
	if model_node.transform.origin.length() > 1000.0:
		issues.append("Model position is unusually far from origin")
	
	if model_node.scale.x <= 0 or model_node.scale.y <= 0 or model_node.scale.z <= 0:
		issues.append("Model has invalid scale")
	
	return issues

func _check_mesh_integrity(model_node: Node3D, _model_name: String) -> Array:
	var issues = []
	var mesh_instances = _get_mesh_instances(model_node)
	
	for mesh_instance in mesh_instances:
		var mesh = mesh_instance.mesh
		if not mesh:
			issues.append("MeshInstance3D '%s' has no mesh" % mesh_instance.name)
			continue
		
		# Check surface count
		var surface_count = mesh.get_surface_count()
		if surface_count == 0:
			issues.append("Mesh '%s' has no surfaces" % mesh_instance.name)
		elif surface_count > 20:
			issues.append("Mesh '%s' has unusually high surface count: %d" % [mesh_instance.name, surface_count])
		
		# Check vertex count (if possible)
		for i in range(surface_count):
			var arrays = mesh.surface_get_arrays(i)
			if arrays[Mesh.ARRAY_VERTEX]:
				var vertex_count = arrays[Mesh.ARRAY_VERTEX].size()
				if vertex_count > 100000:
					issues.append("Mesh '%s' surface %d has very high vertex count: %d" % [mesh_instance.name, i, vertex_count])
	
	return issues

func _check_collision_shapes(model_node: Node3D, _model_name: String) -> Array:
	var issues = []
	var mesh_instances = _get_mesh_instances(model_node)
	var collision_count = 0
	
	for mesh_instance in mesh_instances:
		# Check for StaticBody3D children with CollisionShape3D
		for child in mesh_instance.get_children():
			if child is StaticBody3D:
				var has_collision_shape = false
				for grandchild in child.get_children():
					if grandchild is CollisionShape3D:
						collision_count += 1
						has_collision_shape = true
						
						# Check if collision shape has a valid shape
						if not grandchild.shape:
							issues.append("CollisionShape3D in '%s' has no shape" % mesh_instance.name)
				
				if not has_collision_shape:
					issues.append("StaticBody3D in '%s' has no CollisionShape3D" % mesh_instance.name)
	
	if collision_count == 0:
		issues.append("Model has no collision shapes")
	
	return issues

func _check_materials(model_node: Node3D, _model_name: String) -> Array:
	var issues = []
	var mesh_instances = _get_mesh_instances(model_node)
	
	for mesh_instance in mesh_instances:
		var mesh = mesh_instance.mesh
		if not mesh:
			continue
		
		var surface_count = mesh.get_surface_count()
		var _materials_with_issues = 0
		
		for i in range(surface_count):
			var material = mesh.surface_get_material(i)
			if not material:
				issues.append("Mesh '%s' surface %d has no material" % [mesh_instance.name, i])
				_materials_with_issues += 1
			elif material is StandardMaterial3D:
				# Check material properties
				var std_material = material as StandardMaterial3D
				if std_material.albedo_color.a < 0.1:
					issues.append("Material in '%s' surface %d is nearly transparent" % [mesh_instance.name, i])
	
	return issues

func _get_mesh_instances(node: Node) -> Array:
	var mesh_instances = []
	
	if node is MeshInstance3D:
		mesh_instances.append(node)
	
	for child in node.get_children():
		mesh_instances.append_array(_get_mesh_instances(child))
	
	return mesh_instances

# Mesh Analysis and Diagnostics
static func analyze_mesh_performance(mesh_name: String = ""):
	if not instance:
		print("❌ BrainVisDebugger not initialized")
		return
	
	instance._analyze_mesh_performance_internal(mesh_name)

func _analyze_mesh_performance_internal(mesh_name: String):
	print("📊 Analyzing mesh performance...")
	
	if mesh_name != "":
		_analyze_single_mesh(mesh_name)
	else:
		# Analyze all meshes
		var scene_tree = Engine.get_main_loop()
		if scene_tree and scene_tree.current_scene:
			_analyze_all_meshes_recursive(scene_tree.current_scene)

func _analyze_single_mesh(mesh_name: String):
	var mesh_instance = _find_mesh_by_name(mesh_name)
	if not mesh_instance:
		print("❌ Mesh '%s' not found" % mesh_name)
		return
	
	var analysis = _perform_mesh_analysis(mesh_instance)
	mesh_analysis_cache[mesh_name] = analysis
	
	print("📈 Analysis for '%s':" % mesh_name)
	for key in analysis:
		print("  %s: %s" % [key, str(analysis[key])])
	
	mesh_analysis_completed.emit(mesh_name, analysis)

func _analyze_all_meshes_recursive(node: Node):
	if node is MeshInstance3D:
		var analysis = _perform_mesh_analysis(node)
		mesh_analysis_cache[node.name] = analysis
		
		print("📈 %s: vertices=%d, surfaces=%d, materials=%d" % [
			node.name,
			analysis.get("vertex_count", 0),
			analysis.get("surface_count", 0),
			analysis.get("material_count", 0)
		])
	
	for child in node.get_children():
		_analyze_all_meshes_recursive(child)

func _perform_mesh_analysis(mesh_instance: MeshInstance3D) -> Dictionary:
	var analysis = {
		"name": mesh_instance.name,
		"vertex_count": 0,
		"triangle_count": 0,
		"surface_count": 0,
		"material_count": 0,
		"has_collision": false,
		"bounds_size": Vector3.ZERO,
		"performance_rating": "UNKNOWN"
	}
	
	var mesh = mesh_instance.mesh
	if not mesh:
		return analysis
	
	analysis.surface_count = mesh.get_surface_count()
	
	# Count vertices and triangles
	for i in range(analysis.surface_count):
		var arrays = mesh.surface_get_arrays(i)
		if arrays[Mesh.ARRAY_VERTEX]:
			analysis.vertex_count += arrays[Mesh.ARRAY_VERTEX].size()
		if arrays[Mesh.ARRAY_INDEX]:
			analysis.triangle_count += arrays[Mesh.ARRAY_INDEX].size() / 3.0
		
		if mesh.surface_get_material(i):
			analysis.material_count += 1
	
	# Check for collision
	analysis.has_collision = _has_collision_shape(mesh_instance)
	
	# Calculate bounds
	if mesh_instance.get_aabb:
		var aabb = mesh_instance.get_aabb()
		analysis.bounds_size = aabb.size
	
	# Performance rating
	analysis.performance_rating = _calculate_performance_rating(analysis)
	
	return analysis

func _find_mesh_by_name(mesh_name: String) -> MeshInstance3D:
	var scene_tree = Engine.get_main_loop()
	if scene_tree and scene_tree.current_scene:
		return _find_mesh_recursive(scene_tree.current_scene, mesh_name)
	return null

func _find_mesh_recursive(node: Node, mesh_name: String) -> MeshInstance3D:
	if node is MeshInstance3D and node.name.contains(mesh_name):
		return node
	
	for child in node.get_children():
		var result = _find_mesh_recursive(child, mesh_name)
		if result:
			return result
	
	return null

func _has_collision_shape(mesh_instance: MeshInstance3D) -> bool:
	for child in mesh_instance.get_children():
		if child is StaticBody3D:
			for grandchild in child.get_children():
				if grandchild is CollisionShape3D:
					return true
	return false

func _calculate_performance_rating(analysis: Dictionary) -> String:
	var vertex_count = analysis.get("vertex_count", 0)
	var surface_count = analysis.get("surface_count", 0)
	
	if vertex_count > 50000 or surface_count > 15:
		return "POOR"
	elif vertex_count > 20000 or surface_count > 8:
		return "FAIR"
	elif vertex_count > 5000 or surface_count > 3:
		return "GOOD"
	else:
		return "EXCELLENT"

# Selection System Testing
static func test_selection_accuracy():
	if not instance:
		print("❌ BrainVisDebugger not initialized")
		return
	
	print("🎯 Testing selection system accuracy...")
	instance._test_selection_accuracy_internal()

func _test_selection_accuracy_internal():
	var results = {
		"total_tests": 0,
		"successful_selections": 0,
		"failed_selections": 0,
		"accuracy_percentage": 0.0,
		"test_points": []
	}
	
	# Test selection at various points
	var test_points = [
		Vector3(0, 0, 0),      # Center
		Vector3(5, 0, 0),      # Right
		Vector3(-5, 0, 0),     # Left
		Vector3(0, 5, 0),      # Up
		Vector3(0, -5, 0),     # Down
		Vector3(0, 0, 5),      # Forward
		Vector3(0, 0, -5)      # Back
	]
	
	for test_point in test_points:
		var test_result = _test_selection_at_point(test_point)
		results.test_points.append(test_result)
		results.total_tests += 1
		
		if test_result.success:
			results.successful_selections += 1
		else:
			results.failed_selections += 1
	
	# Calculate accuracy
	if results.total_tests > 0:
		results.accuracy_percentage = (float(results.successful_selections) / float(results.total_tests)) * 100.0
	
	print("🎯 Selection accuracy test results:")
	print("  Total tests: %d" % results.total_tests)
	print("  Successful: %d" % results.successful_selections)
	print("  Failed: %d" % results.failed_selections)
	print("  Accuracy: %.1f%%" % results.accuracy_percentage)
	
	selection_accuracy_tested.emit(results)

func _test_selection_at_point(world_position: Vector3) -> Dictionary:
	var result = {
		"position": world_position,
		"success": false,
		"selected_object": null,
		"distance": 0.0
	}
	
	# Get camera
	var camera = get_viewport().get_camera_3d() if get_viewport() else null
	if not camera:
		return result
	
	# Project world position to screen
	var _screen_pos = camera.unproject_position(world_position)
	
	# Perform raycast from camera
	var world = camera.get_world_3d() if camera else null
	var space_state = world.direct_space_state if world else null
	if not space_state:
		return result
	
	var from = camera.global_position
	var to = world_position
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var ray_result = space_state.intersect_ray(query)
	
	if ray_result:
		result.success = true
		result.selected_object = ray_result.collider
		result.distance = from.distance_to(ray_result.position)
	
	return result

# Material and Texture Analysis
static func analyze_materials():
	if not instance:
		print("❌ BrainVisDebugger not initialized")
		return
	
	print("🎨 Analyzing materials and textures...")
	instance._analyze_materials_internal()

func _analyze_materials_internal():
	var material_stats = {
		"total_materials": 0,
		"standard_materials": 0,
		"shader_materials": 0,
		"materials_with_textures": 0,
		"texture_memory_estimate": 0
	}
	
	var scene_tree = Engine.get_main_loop()
	if scene_tree and scene_tree.current_scene:
		_analyze_materials_recursive(scene_tree.current_scene, material_stats)
	
	print("🎨 Material analysis results:")
	for key in material_stats:
		print("  %s: %s" % [key.replace("_", " ").capitalize(), str(material_stats[key])])

func _analyze_materials_recursive(node: Node, stats: Dictionary):
	if node is MeshInstance3D:
		var mesh_instance = node as MeshInstance3D
		var mesh = mesh_instance.mesh
		
		if mesh:
			for i in range(mesh.get_surface_count()):
				var material = mesh.surface_get_material(i)
				if material:
					stats.total_materials += 1
					
					if material is StandardMaterial3D:
						stats.standard_materials += 1
						var std_mat = material as StandardMaterial3D
						
						# Check for textures
						if std_mat.albedo_texture:
							stats.materials_with_textures += 1
							# Estimate texture memory (very rough)
							stats.texture_memory_estimate += 1024 * 1024  # Assume 1MB per texture
					elif material is ShaderMaterial:
						stats.shader_materials += 1
	
	for child in node.get_children():
		_analyze_materials_recursive(child, stats)

# Public API Methods
static func get_validation_results() -> Dictionary:
	if instance:
		return instance.validation_results
	return {}

static func get_mesh_analysis_cache() -> Dictionary:
	if instance:
		return instance.mesh_analysis_cache
	return {}

static func clear_analysis_cache():
	if instance:
		instance.mesh_analysis_cache.clear()
		instance.validation_results.clear()
		print("🧹 Analysis cache cleared")

# Debug command integration
func register_debug_commands():
	if DebugCmd:
		DebugCmd.register_command("validate_models", func(): validate_all_models(), "Validate all brain models")
		DebugCmd.register_command("analyze_mesh", func(mesh_name: String = ""): analyze_mesh_performance(mesh_name), "Analyze mesh performance")
		DebugCmd.register_command("test_selection", func(): test_selection_accuracy(), "Test selection system accuracy")
		DebugCmd.register_command("analyze_materials", func(): analyze_materials(), "Analyze materials and textures")
		DebugCmd.register_command("clear_brain_cache", func(): clear_analysis_cache(), "Clear brain analysis cache")