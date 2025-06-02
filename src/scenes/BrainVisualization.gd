## BrainVisualization.gd
## Educational 3D brain model management and visualization system
##
## This system manages the loading, display, and educational coordination of
## 3D brain models. Focused on educational outcomes and learning workflows.
## Designed as a clean, focused component for AI-friendly development.
##
## @tutorial: Educational 3D model management patterns
## @version: 3.0 - Clean Scene-Based Architecture

class_name BrainVisualization
extends Node3D

# === EDUCATIONAL EVENTS ===
## Emitted when educational models are loaded and ready for learning
signal educational_models_ready(model_data: Array)
## Emitted when model visibility changes for educational purposes
signal educational_model_visibility_changed(model_name: String, visible: bool, learning_context: String)
## Emitted when model loading fails (educational content unavailable)
signal educational_model_load_failed(model_name: String, error_message: String)
## Emitted when focus changes to support learning workflow
signal educational_focus_changed(focus_data: Dictionary)

# === CONFIGURATION ===
@export_group("Educational Models")
@export var models_directory: String = "res://assets/models/"
@export var auto_load_models: bool = true
@export var enable_educational_layering: bool = true

@export_group("Learning Support")
@export var track_model_interactions: bool = true
@export var enable_progressive_disclosure: bool = true
@export var default_learning_mode: String = "exploration"  # exploration, guided, assessment

@export_group("Performance")
@export var max_concurrent_models: int = 3
@export var enable_lod_optimization: bool = true
@export var memory_usage_limit_mb: int = 500

# === MODEL MANAGEMENT ===
var _model_parent: Node3D
var _loaded_models: Dictionary = {}  # model_name -> {node: Node3D, metadata: Dictionary}
var _model_metadata: Dictionary = {}  # Educational information about each model
var _visibility_states: Dictionary = {}  # Current visibility for learning workflows
var _learning_sequences: Dictionary = {}  # Predefined learning progressions
var _is_initialized: bool = false

# === EDUCATIONAL STATE ===
var _current_learning_mode: String = "exploration"
var _active_learning_sequence: String = ""
var _progressive_disclosure_level: int = 0
var _interaction_analytics: Array[Dictionary] = []

# === LIFECYCLE METHODS ===
func _ready() -> void:
	print("[BrainVisualization] Initializing educational 3D visualization system...")
	_setup_learning_sequences()
	_setup_model_metadata()
	
	if auto_load_models:
		call_deferred("load_educational_models")

func initialize(model_parent: Node3D) -> bool:
	"""Initialize the brain visualization system with 3D parent node"""
	if _is_initialized:
		push_warning("[BrainVisualization] Already initialized")
		return false
	
	if not model_parent:
		push_error("[BrainVisualization] Model parent required for initialization")
		return false
	
	_model_parent = model_parent
	_is_initialized = true
	
	print("[BrainVisualization] ✓ Educational 3D system ready")
	return true

# === EDUCATIONAL MODEL LOADING ===
func load_educational_models() -> void:
	"""Load brain models for educational use"""
	if not _model_parent:
		push_error("[BrainVisualization] Not initialized - cannot load models")
		return
	
	print("[BrainVisualization] Loading educational brain models...")
	
	# Define educational model priority order
	var educational_models = [
		{
			"file": "Half_Brain.glb",
			"name": "Half_Brain",
			"educational_level": "beginner",
			"learning_objectives": ["Basic brain anatomy", "Left-right symmetry", "Overall structure"],
			"default_visible": true
		},
		{
			"file": "Internal_Structures.glb", 
			"name": "Internal_Structures",
			"educational_level": "intermediate",
			"learning_objectives": ["Deep brain anatomy", "Functional systems", "Structure relationships"],
			"default_visible": false
		},
		{
			"file": "Brainstem(Solid).glb",
			"name": "Brainstem_Solid",
			"educational_level": "advanced",
			"learning_objectives": ["Brainstem anatomy", "Vital functions", "Neural pathways"],
			"default_visible": false
		}
	]
	
	var loaded_count = 0
	var failed_models = []
	
	for model_info in educational_models:
		var success = _load_single_educational_model(model_info)
		if success:
			loaded_count += 1
		else:
			failed_models.append(model_info.name)
	
	print("[BrainVisualization] ✓ Loaded %d educational models" % loaded_count)
	
	if not failed_models.is_empty():
		print("[BrainVisualization] ⚠ Failed to load: %s" % ", ".join(failed_models))
	
	# Emit educational readiness event
	var model_data = _get_educational_model_data()
	educational_models_ready.emit(model_data)
	
	# Track loading analytics
	if track_model_interactions:
		_track_educational_interaction("models_loaded", {
			"loaded_count": loaded_count,
			"failed_count": failed_models.size(),
			"learning_mode": _current_learning_mode
		})

func _load_single_educational_model(model_info: Dictionary) -> bool:
	"""Load a single educational model with metadata"""
	var model_path = models_directory + model_info.file
	var model_name = model_info.name
	
	# Check if already loaded
	if _loaded_models.has(model_name):
		print("[BrainVisualization] Model already loaded: %s" % model_name)
		return true
	
	# Load the model file
	var model_scene = load(model_path)
	if not model_scene:
		push_error("[BrainVisualization] Failed to load model file: %s" % model_path)
		educational_model_load_failed.emit(model_name, "File not found: " + model_path)
		return false
	
	# Instantiate the model
	var model_instance = model_scene.instantiate()
	if not model_instance:
		push_error("[BrainVisualization] Failed to instantiate model: %s" % model_name)
		educational_model_load_failed.emit(model_name, "Instantiation failed")
		return false
	
	# Setup educational model properties
	model_instance.name = model_name
	_model_parent.add_child(model_instance)
	
	# Store model data with educational metadata
	_loaded_models[model_name] = {
		"node": model_instance,
		"metadata": model_info,
		"load_time": Time.get_unix_time_from_system()
	}
	
	# Set initial visibility based on educational progression
	var initial_visibility = model_info.get("default_visible", false)
	if enable_progressive_disclosure:
		initial_visibility = _should_model_be_visible_for_disclosure_level(model_info)
	
	set_educational_model_visibility(model_name, initial_visibility, "initial_load")
	
	print("[BrainVisualization] ✓ Loaded educational model: %s" % model_name)
	return true

# === EDUCATIONAL VISIBILITY MANAGEMENT ===
func set_educational_model_visibility(model_name: String, visible: bool, learning_context: String = "user_interaction") -> bool:
	"""Set model visibility with educational context tracking"""
	if not _loaded_models.has(model_name):
		push_warning("[BrainVisualization] Model not loaded: %s" % model_name)
		return false
	
	var model_data = _loaded_models[model_name]
	var model_node = model_data.node
	
	# Update visibility
	model_node.visible = visible
	_visibility_states[model_name] = visible
	
	# Emit educational event
	educational_model_visibility_changed.emit(model_name, visible, learning_context)
	
	# Track educational analytics
	if track_model_interactions:
		_track_educational_interaction("model_visibility_changed", {
			"model_name": model_name,
			"visible": visible,
			"learning_context": learning_context,
			"learning_mode": _current_learning_mode
		})
	
	print("[BrainVisualization] %s visibility: %s (%s)" % [model_name, "visible" if visible else "hidden", learning_context])
	return true

func toggle_educational_model_visibility(model_name: String, learning_context: String = "user_toggle") -> bool:
	"""Toggle model visibility for educational interaction"""
	if not _visibility_states.has(model_name):
		return false
	
	var current_visibility = _visibility_states[model_name]
	return set_educational_model_visibility(model_name, not current_visibility, learning_context)

func set_learning_mode(mode: String) -> void:
	"""Set the current learning mode (exploration, guided, assessment)"""
	var previous_mode = _current_learning_mode
	_current_learning_mode = mode
	
	print("[BrainVisualization] Learning mode: %s -> %s" % [previous_mode, mode])
	
	# Adjust model visibility based on learning mode
	_apply_learning_mode_visibility()
	
	# Track mode change
	if track_model_interactions:
		_track_educational_interaction("learning_mode_changed", {
			"previous_mode": previous_mode,
			"new_mode": mode
		})

func start_learning_sequence(sequence_name: String) -> bool:
	"""Start a predefined educational learning sequence"""
	if not _learning_sequences.has(sequence_name):
		push_warning("[BrainVisualization] Unknown learning sequence: %s" % sequence_name)
		return false
	
	_active_learning_sequence = sequence_name
	var sequence = _learning_sequences[sequence_name]
	
	print("[BrainVisualization] Starting learning sequence: %s" % sequence_name)
	
	# Apply sequence visibility settings
	for step in sequence.steps:
		for model_name in step.visible_models:
			set_educational_model_visibility(model_name, true, "learning_sequence")
		for model_name in step.hidden_models:
			set_educational_model_visibility(model_name, false, "learning_sequence")
	
	return true

# === PROGRESSIVE DISCLOSURE ===
func set_progressive_disclosure_level(level: int) -> void:
	"""Set progressive disclosure level for educational scaffolding"""
	if not enable_progressive_disclosure:
		print("[BrainVisualization] Progressive disclosure disabled")
		return
	
	var previous_level = _progressive_disclosure_level
	_progressive_disclosure_level = clamp(level, 0, 3)
	
	print("[BrainVisualization] Progressive disclosure: level %d -> %d" % [previous_level, _progressive_disclosure_level])
	
	# Update model visibility based on disclosure level
	for model_name in _loaded_models.keys():
		var model_info = _loaded_models[model_name].metadata
		var should_be_visible = _should_model_be_visible_for_disclosure_level(model_info)
		set_educational_model_visibility(model_name, should_be_visible, "progressive_disclosure")

func _should_model_be_visible_for_disclosure_level(model_info: Dictionary) -> bool:
	"""Determine if model should be visible at current disclosure level"""
	var educational_level = model_info.get("educational_level", "beginner")
	
	match _progressive_disclosure_level:
		0: return educational_level == "beginner"  # Basic anatomy only
		1: return educational_level in ["beginner", "intermediate"]  # + Internal structures
		2: return true  # All models visible
		_: return true

# === EDUCATIONAL FOCUS MANAGEMENT ===
func focus_on_educational_structure(structure_name: String, learning_context: String = "user_focus") -> void:
	"""Focus visualization on a specific educational structure"""
	# Find which model contains this structure
	var target_model = _find_model_containing_structure(structure_name)
	if target_model.is_empty():
		print("[BrainVisualization] Structure not found in any model: %s" % structure_name)
		return
	
	# Ensure target model is visible
	var model_name = target_model.name
	set_educational_model_visibility(model_name, true, learning_context)
	
	# Emit focus event for camera/UI coordination
	var focus_data = {
		"structure_name": structure_name,
		"model_name": model_name,
		"learning_context": learning_context,
		"target_node": target_model.node
	}
	
	educational_focus_changed.emit(focus_data)
	
	print("[BrainVisualization] Educational focus: %s in %s" % [structure_name, model_name])

# === LEARNING SEQUENCE SETUP ===
func _setup_learning_sequences() -> void:
	"""Setup predefined educational learning sequences"""
	_learning_sequences = {
		"basic_anatomy": {
			"name": "Basic Brain Anatomy",
			"description": "Introduction to overall brain structure",
			"steps": [
				{
					"name": "Overview",
					"visible_models": ["Half_Brain"],
					"hidden_models": ["Internal_Structures", "Brainstem_Solid"],
					"learning_objectives": ["Identify major brain regions", "Understand left-right symmetry"]
				}
			]
		},
		"deep_exploration": {
			"name": "Deep Brain Exploration", 
			"description": "Detailed internal brain anatomy",
			"steps": [
				{
					"name": "Internal Systems",
					"visible_models": ["Half_Brain", "Internal_Structures"],
					"hidden_models": ["Brainstem_Solid"],
					"learning_objectives": ["Explore internal structures", "Understand functional systems"]
				}
			]
		},
		"complete_anatomy": {
			"name": "Complete Neuroanatomy",
			"description": "Full brain anatomy for advanced learning",
			"steps": [
				{
					"name": "All Systems",
					"visible_models": ["Half_Brain", "Internal_Structures", "Brainstem_Solid"],
					"hidden_models": [],
					"learning_objectives": ["Master complete neuroanatomy", "Integrate all brain systems"]
				}
			]
		}
	}

func _setup_model_metadata() -> void:
	"""Setup educational metadata for models"""
	_model_metadata = {
		"Half_Brain": {
			"educational_focus": "Overall brain structure and major regions",
			"clinical_relevance": "Understanding brain lateralization and major functional areas",
			"common_structures": ["frontal_lobe", "parietal_lobe", "temporal_lobe", "occipital_lobe"]
		},
		"Internal_Structures": {
			"educational_focus": "Deep brain anatomy and limbic system",
			"clinical_relevance": "Memory, emotion, and subcortical function",
			"common_structures": ["hippocampus", "amygdala", "thalamus", "hypothalamus"]
		},
		"Brainstem_Solid": {
			"educational_focus": "Brainstem anatomy and vital functions",
			"clinical_relevance": "Life-sustaining functions and consciousness",
			"common_structures": ["medulla", "pons", "midbrain", "cerebellum"]
		}
	}

# === UTILITY METHODS ===
func _find_model_containing_structure(structure_name: String) -> Dictionary:
	"""Find which loaded model contains a specific structure"""
	for model_name in _loaded_models.keys():
		var model_data = _loaded_models[model_name]
		var model_node = model_data.node
		
		# Search for structure in model hierarchy
		var found_structure = _find_structure_in_node(model_node, structure_name)
		if found_structure:
			return {"name": model_name, "node": found_structure}
	
	return {}

func _find_structure_in_node(node: Node, structure_name: String) -> Node:
	"""Recursively find structure in node hierarchy"""
	if node.name.to_lower().contains(structure_name.to_lower()):
		return node
	
	for child in node.get_children():
		var result = _find_structure_in_node(child, structure_name)
		if result:
			return result
	
	return null

func _apply_learning_mode_visibility() -> void:
	"""Apply model visibility settings based on current learning mode"""
	match _current_learning_mode:
		"exploration":
			# Free exploration - user controls visibility
			pass  # No automatic changes
		"guided":
			# Guided mode - progressive disclosure
			set_progressive_disclosure_level(1)
		"assessment":
			# Assessment mode - minimal visual aids
			for model_name in _loaded_models.keys():
				set_educational_model_visibility(model_name, false, "assessment_mode")

func _track_educational_interaction(interaction_type: String, data: Dictionary) -> void:
	"""Track educational interactions for analytics"""
	if not track_model_interactions:
		return
	
	var interaction_record = {
		"timestamp": Time.get_unix_time_from_system(),
		"interaction_type": interaction_type,
		"data": data,
		"learning_mode": _current_learning_mode,
		"disclosure_level": _progressive_disclosure_level
	}
	
	_interaction_analytics.append(interaction_record)
	
	# Limit analytics history size
	if _interaction_analytics.size() > 100:
		_interaction_analytics.pop_front()

func _get_educational_model_data() -> Array:
	"""Get educational model data for event emission"""
	var model_data = []
	for model_name in _loaded_models.keys():
		var model_info = _loaded_models[model_name]
		model_data.append({
			"name": model_name,
			"metadata": model_info.metadata,
			"visible": _visibility_states.get(model_name, false),
			"educational_level": model_info.metadata.get("educational_level", "basic")
		})
	return model_data

# === PUBLIC API ===
func get_loaded_models() -> Array[String]:
	"""Get list of loaded model names"""
	return _loaded_models.keys()

func is_model_visible(model_name: String) -> bool:
	"""Check if model is currently visible"""
	return _visibility_states.get(model_name, false)

func get_educational_metadata(model_name: String) -> Dictionary:
	"""Get educational metadata for a model"""
	return _model_metadata.get(model_name, {})

func get_interaction_analytics() -> Array[Dictionary]:
	"""Get educational interaction analytics"""
	return _interaction_analytics.duplicate()

func get_current_learning_mode() -> String:
	"""Get current learning mode"""
	return _current_learning_mode