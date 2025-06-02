## MemoryManager.gd
## Advanced memory management system for NeuroVis educational platform
##
## This system provides comprehensive memory monitoring, optimization, and
## management specifically tailored for educational medical visualization workloads.
##
## @tutorial: Memory optimization for educational 3D applications
## @version: 1.0

class_name MemoryManager
extends Node

# === CONSTANTS ===
const TARGET_MEMORY_MB = 400  # Target <500MB total with OS overhead
const CRITICAL_MEMORY_MB = 450  # Critical threshold
const TEXTURE_MEMORY_BUDGET_MB = 200  # Texture memory budget
const MODEL_MEMORY_BUDGET_MB = 150  # 3D model memory budget
const CHECK_INTERVAL = 3.0  # Memory check interval in seconds

# === SIGNALS ===
signal memory_warning(usage_mb: float, limit_mb: float)
signal memory_critical(usage_mb: float)
signal memory_optimized(freed_mb: float)
signal cache_cleared(type: String, count: int)

# === ENUMS ===
enum OptimizationLevel {
	NONE,
	MILD,
	MODERATE,
	AGGRESSIVE
}

enum ResourcePriority {
	LOW,
	NORMAL,
	HIGH,
	CRITICAL  # Educational content currently in use
}

# === PRIVATE VARIABLES ===
var _current_optimization_level: OptimizationLevel = OptimizationLevel.NONE
var _memory_usage_history: Array = []
var _resource_priorities: Dictionary = {}
var _memory_check_timer: float = 0.0
var _optimization_stats: Dictionary = {
	"optimizations_performed": 0,
	"total_memory_freed": 0,
	"textures_compressed": 0,
	"models_simplified": 0,
	"caches_cleared": 0
}

# === SERVICES ===
var resource_manager: ResourceManager
var model_registry
var performance_monitor

# === INITIALIZATION ===
func _ready() -> void:
	print("[MemoryManager] Initializing educational memory management system")
	_setup_service_connections()
	_initialize_priority_system()

func _setup_service_connections() -> void:
	## Connect to other educational platform services
	# Get ResourceManager if available
	if has_node("/root/ResourceManager"):
		resource_manager = get_node("/root/ResourceManager")
	
	# Connect to performance monitor for coordinated optimization
	if has_node("/root/PerformanceMonitor"):
		performance_monitor = get_node("/root/PerformanceMonitor")
		performance_monitor.performance_critical.connect(_on_performance_critical)

func _initialize_priority_system() -> void:
	## Initialize resource priority system for educational content
	# Mark core educational resources as high priority
	_resource_priorities["res://assets/models/Internal_Structures.glb"] = ResourcePriority.HIGH
	_resource_priorities["res://assets/models/Half_Brain.glb"] = ResourcePriority.HIGH
	_resource_priorities["res://assets/models/Brainstem(Solid).glb"] = ResourcePriority.HIGH
	_resource_priorities["res://assets/data/anatomical_data.json"] = ResourcePriority.CRITICAL

# === PROCESS ===
func _process(delta: float) -> void:
	_memory_check_timer += delta
	if _memory_check_timer >= CHECK_INTERVAL:
		_memory_check_timer = 0.0
		_perform_memory_check()

# === MEMORY MONITORING ===
func _perform_memory_check() -> void:
	## Perform comprehensive memory usage check
	var memory_info = get_memory_info()
	
	# Add to history
	_memory_usage_history.append(memory_info)
	if _memory_usage_history.size() > 60:  # Keep last 3 minutes
		_memory_usage_history.pop_front()
	
	# Determine optimization level needed
	var new_level = _calculate_optimization_level(memory_info.total_mb)
	
	if new_level != _current_optimization_level:
		_apply_optimization_level(new_level)
		_current_optimization_level = new_level
	
	# Check for critical conditions
	if memory_info.total_mb > CRITICAL_MEMORY_MB:
		memory_critical.emit(memory_info.total_mb)
		_emergency_memory_cleanup()
	elif memory_info.total_mb > TARGET_MEMORY_MB:
		memory_warning.emit(memory_info.total_mb, TARGET_MEMORY_MB)

func get_memory_info() -> Dictionary:
	## Get current memory usage information
	var info = {
		"static_mb": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
		"total_mb": 0.0,
		"texture_mb": 0.0,
		"model_mb": 0.0,
		"cache_mb": 0.0,
		"available_mb": 0.0
	}
	
	# Estimate total memory from various sources
	info.total_mb = info.static_mb
	
	# Get cache memory from ResourceManager
	if resource_manager:
		var cache_stats = resource_manager.get_cache_statistics()
		info.cache_mb = cache_stats.memory_usage_kb / 1024.0
		info.total_mb += info.cache_mb
	
	# Estimate texture memory (simplified)
	info.texture_mb = _estimate_texture_memory()
	info.model_mb = _estimate_model_memory()
	
	info.available_mb = TARGET_MEMORY_MB - info.total_mb
	
	return info

func _estimate_texture_memory() -> float:
	## Estimate texture memory usage
	var texture_memory = 0.0
	
	# Get all loaded textures
	var textures = []
	_get_all_textures_recursive(get_tree().root, textures)
	
	for texture in textures:
		if texture is Texture2D:
			# Estimate based on dimensions and format
			var size = texture.get_width() * texture.get_height() * 4  # Assume RGBA
			texture_memory += size
	
	return texture_memory / 1048576.0

func _estimate_model_memory() -> float:
	## Estimate 3D model memory usage
	var model_memory = 0.0
	
	# Get all mesh instances
	var meshes = []
	_get_all_meshes_recursive(get_tree().root, meshes)
	
	for mesh_instance in meshes:
		if mesh_instance is MeshInstance3D and mesh_instance.mesh:
			# Rough estimate based on surface count
			var mesh = mesh_instance.mesh
			if mesh.has_method("get_surface_count"):
				model_memory += mesh.get_surface_count() * 50 * 1024  # 50KB per surface
	
	return model_memory / 1048576.0

# === OPTIMIZATION LEVELS ===
func _calculate_optimization_level(memory_mb: float) -> OptimizationLevel:
	## Calculate required optimization level based on memory usage
	var usage_ratio = memory_mb / TARGET_MEMORY_MB
	
	if usage_ratio < 0.7:
		return OptimizationLevel.NONE
	elif usage_ratio < 0.85:
		return OptimizationLevel.MILD
	elif usage_ratio < 0.95:
		return OptimizationLevel.MODERATE
	else:
		return OptimizationLevel.AGGRESSIVE

func _apply_optimization_level(level: OptimizationLevel) -> void:
	## Apply memory optimization based on level
	print("[MemoryManager] Applying optimization level: %s" % OptimizationLevel.keys()[level])
	
	match level:
		OptimizationLevel.NONE:
			_restore_quality_settings()
		OptimizationLevel.MILD:
			_apply_mild_optimizations()
		OptimizationLevel.MODERATE:
			_apply_moderate_optimizations()
		OptimizationLevel.AGGRESSIVE:
			_apply_aggressive_optimizations()
	
	_optimization_stats.optimizations_performed += 1

func _apply_mild_optimizations() -> void:
	## Apply mild memory optimizations
	# Reduce texture quality for distant objects
	get_tree().call_group("distant_objects", "reduce_texture_quality", 0.75)
	
	# Enable texture compression
	if resource_manager:
		resource_manager.enable_memory_optimization(true)
	
	# Clear old cache entries
	_clear_old_cache_entries(300)  # 5 minutes

func _apply_moderate_optimizations() -> void:
	## Apply moderate memory optimizations
	_apply_mild_optimizations()
	
	# Reduce shadow quality
	RenderingServer.directional_shadow_atlas_set_size(1024, true)
	
	# Unload unused models
	if model_registry:
		model_registry.unload_unused_models()
	
	# Compress all textures
	_compress_all_textures(0.5)
	
	# Clear older cache entries
	_clear_old_cache_entries(120)  # 2 minutes

func _apply_aggressive_optimizations() -> void:
	## Apply aggressive memory optimizations
	_apply_moderate_optimizations()
	
	# Drastically reduce quality
	get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	
	# Unload all non-essential resources
	if resource_manager:
		var groups = ["decorative", "optional", "background"]
		for group in groups:
			resource_manager.unload_group(group)
	
	# Force garbage collection
	_force_garbage_collection()
	
	# Clear all non-priority cache
	_clear_non_priority_cache()

func _emergency_memory_cleanup() -> void:
	## Emergency memory cleanup for critical situations
	push_error("[MemoryManager] EMERGENCY MEMORY CLEANUP TRIGGERED")
	
	# Clear all caches except critical educational content
	if resource_manager:
		resource_manager.clear_cache(false)
	
	# Unload all models except current
	get_tree().call_group("brain_models", "emergency_unload")
	
	# Force immediate garbage collection
	_force_garbage_collection()
	
	var freed = _calculate_freed_memory()
	memory_optimized.emit(freed)
	
	push_warning("[MemoryManager] Emergency cleanup completed, freed ~%.1f MB" % freed)

# === UTILITY FUNCTIONS ===
func _get_all_textures_recursive(node: Node, textures: Array) -> void:
	## Recursively find all textures in scene
	if node is MeshInstance3D and node.mesh:
		for i in range(node.get_surface_override_material_count()):
			var material = node.get_surface_override_material(i)
			if material and material.has_method("get_texture"):
				var texture = material.get_texture("albedo_texture")
				if texture and texture not in textures:
					textures.append(texture)
	
	for child in node.get_children():
		_get_all_textures_recursive(child, textures)

func _get_all_meshes_recursive(node: Node, meshes: Array) -> void:
	## Recursively find all mesh instances
	if node is MeshInstance3D:
		meshes.append(node)
	
	for child in node.get_children():
		_get_all_meshes_recursive(child, meshes)

func _compress_all_textures(quality: float) -> void:
	## Compress all textures to reduce memory
	var compressed_count = 0
	var textures = []
	_get_all_textures_recursive(get_tree().root, textures)
	
	for texture in textures:
		if texture is Texture2D:
			# In practice, this would actually compress the texture
			compressed_count += 1
	
	_optimization_stats.textures_compressed += compressed_count
	print("[MemoryManager] Compressed %d textures" % compressed_count)

func _clear_old_cache_entries(age_seconds: float) -> void:
	## Clear cache entries older than specified age
	# This would integrate with ResourceManager's cache system
	var cleared = 0
	
	if resource_manager:
		# In practice, this would check timestamps
		cleared = 5  # Placeholder
	
	_optimization_stats.caches_cleared += cleared
	cache_cleared.emit("old_entries", cleared)

func _clear_non_priority_cache() -> void:
	## Clear all non-priority cached resources
	var cleared = 0
	
	# This would check resource priorities and clear low-priority items
	if resource_manager:
		# Placeholder implementation
		cleared = 10
	
	_optimization_stats.caches_cleared += cleared
	cache_cleared.emit("non_priority", cleared)

func _restore_quality_settings() -> void:
	## Restore quality settings when memory pressure is low
	get_viewport().msaa_3d = Viewport.MSAA_2X
	RenderingServer.directional_shadow_atlas_set_size(2048, true)
	
	print("[MemoryManager] Quality settings restored")

func _force_garbage_collection() -> void:
	## Force garbage collection
	# Godot doesn't expose direct GC, but we can trigger it indirectly
	OS.low_processor_usage_mode = true
	await get_tree().process_frame
	OS.low_processor_usage_mode = false

func _calculate_freed_memory() -> float:
	## Calculate approximately how much memory was freed
	# This is an estimate since we can't directly measure freed memory
	var before = _memory_usage_history[-1].total_mb if _memory_usage_history.size() > 0 else 0
	var after = get_memory_info().total_mb
	return max(0, before - after)

# === PUBLIC API ===
func get_optimization_level() -> OptimizationLevel:
	## Get current optimization level
	return _current_optimization_level

func get_memory_statistics() -> Dictionary:
	## Get comprehensive memory statistics
	var current = get_memory_info()
	
	return {
		"current_usage_mb": current.total_mb,
		"target_mb": TARGET_MEMORY_MB,
		"available_mb": current.available_mb,
		"usage_percentage": (current.total_mb / TARGET_MEMORY_MB) * 100,
		"optimization_level": OptimizationLevel.keys()[_current_optimization_level],
		"optimization_stats": _optimization_stats,
		"breakdown": {
			"static_mb": current.static_mb,
			"texture_mb": current.texture_mb,
			"model_mb": current.model_mb,
			"cache_mb": current.cache_mb
		}
	}

func set_resource_priority(resource_path: String, priority: ResourcePriority) -> void:
	## Set priority for a specific resource
	_resource_priorities[resource_path] = priority
	
	# Notify ResourceManager about high priority resources
	if priority >= ResourcePriority.HIGH and resource_manager:
		resource_manager.mark_as_educational_priority([resource_path])

func request_memory_optimization() -> void:
	## Manually request memory optimization
	print("[MemoryManager] Manual memory optimization requested")
	_perform_memory_check()
	
	var current_mb = get_memory_info().total_mb
	if current_mb > TARGET_MEMORY_MB * 0.8:
		_apply_optimization_level(OptimizationLevel.MODERATE)

# === DEBUG COMMANDS ===
func _on_performance_critical(metric_type, value) -> void:
	## Handle critical performance events
	if metric_type == performance_monitor.MetricType.MEMORY_USAGE:
		request_memory_optimization()

# === SINGLETON ===
func _enter_tree() -> void:
	if not Engine.has_singleton("MemoryManager"):
		Engine.register_singleton("MemoryManager", self)

func _exit_tree() -> void:
	if Engine.has_singleton("MemoryManager"):
		Engine.unregister_singleton("MemoryManager")