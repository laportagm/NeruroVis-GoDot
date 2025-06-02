## LearningPathManager.gd
## Manages educational learning pathways and guided tours for NeuroVis
##
## This system provides structured learning experiences with predefined
## pathways that guide users through brain anatomy education.
##
## @tutorial: Structured learning path management
## @version: 1.0

class_name LearningPathManager
extends Node

# === SIGNALS ===
signal path_started(path_name: String)
signal path_completed(path_name: String)
signal milestone_reached(milestone: String)
signal path_progress_updated(progress: float)

# === CONSTANTS ===
const PATHS_DATA_FILE = "res://data/learning_paths.json"
const PROGRESS_SAVE_INTERVAL = 30.0  # seconds

# === PRIVATE VARIABLES ===
var _available_paths: Dictionary = {}
var _active_path: Dictionary = {}
var _path_progress: Dictionary = {}
var _completed_milestones: Array = []
var _save_timer: float = 0.0

# === INITIALIZATION ===
func _ready() -> void:
	print("[LearningPathManager] Initializing learning paths")
	_load_learning_paths()
	_initialize_default_paths()

func _process(delta: float) -> void:
	_save_timer += delta
	if _save_timer >= PROGRESS_SAVE_INTERVAL:
		_save_timer = 0.0
		_save_progress()

func _load_learning_paths() -> void:
	## Load learning paths from configuration
	if FileAccess.file_exists(PATHS_DATA_FILE):
		var file = FileAccess.open(PATHS_DATA_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				_available_paths = json.data
				print("[LearningPathManager] Loaded %d learning paths" % _available_paths.size())
			else:
				push_error("[LearningPathManager] Failed to parse learning paths JSON")
	else:
		print("[LearningPathManager] No learning paths file found, using defaults")

func _initialize_default_paths() -> void:
	## Initialize default learning paths if none loaded
	if _available_paths.is_empty():
		_available_paths = {
			"brain_overview": {
				"name": "Brain Overview",
				"description": "Introduction to major brain regions and structures",
				"difficulty": "beginner",
				"estimated_time": 15,
				"milestones": [
					{
						"id": "identify_lobes",
						"name": "Identify Brain Lobes",
						"steps": [
							{"structure": "frontal_lobe", "narration": "The frontal lobe controls executive functions, motor skills, and personality.", "duration": 5.0},
							{"structure": "parietal_lobe", "narration": "The parietal lobe processes sensory information and spatial awareness.", "duration": 5.0},
							{"structure": "temporal_lobe", "narration": "The temporal lobe handles auditory processing and memory formation.", "duration": 5.0},
							{"structure": "occipital_lobe", "narration": "The occipital lobe is responsible for visual processing.", "duration": 5.0}
						]
					},
					{
						"id": "explore_deep_structures",
						"name": "Explore Deep Brain Structures",
						"steps": [
							{"structure": "hippocampus", "narration": "The hippocampus is crucial for memory formation and spatial navigation.", "duration": 5.0},
							{"structure": "amygdala", "narration": "The amygdala processes emotions, particularly fear and pleasure.", "duration": 5.0},
							{"structure": "thalamus", "narration": "The thalamus relays sensory and motor signals to the cerebral cortex.", "duration": 5.0}
						]
					}
				]
			},
			"memory_circuit": {
				"name": "Memory Circuit Tour",
				"description": "Explore the neural structures involved in memory",
				"difficulty": "intermediate",
				"estimated_time": 20,
				"milestones": [
					{
						"id": "memory_formation",
						"name": "Memory Formation Pathway",
						"steps": [
							{"structure": "hippocampus", "narration": "Memory formation begins in the hippocampus, where new experiences are encoded.", "duration": 6.0},
							{"structure": "entorhinal_cortex", "narration": "The entorhinal cortex serves as the main interface between hippocampus and neocortex.", "duration": 6.0},
							{"structure": "fornix", "narration": "The fornix carries signals from the hippocampus to other brain regions.", "duration": 5.0},
							{"structure": "mammillary_bodies", "narration": "The mammillary bodies are important for recollective memory.", "duration": 5.0}
						]
					}
				]
			},
			"clinical_cases": {
				"name": "Clinical Case Studies",
				"description": "Learn through clinical scenarios and pathology",
				"difficulty": "advanced",
				"estimated_time": 30,
				"milestones": [
					{
						"id": "stroke_localization",
						"name": "Stroke Localization",
						"steps": [
							{"structure": "middle_cerebral_artery", "narration": "MCA strokes affect motor and sensory cortex, causing contralateral weakness.", "duration": 7.0},
							{"structure": "broca_area", "narration": "Left MCA strokes affecting Broca's area cause expressive aphasia.", "duration": 7.0},
							{"structure": "internal_capsule", "narration": "Lacunar strokes here cause pure motor or sensory deficits.", "duration": 6.0}
						]
					}
				]
			}
		}

# === PUBLIC API ===
func get_available_paths(difficulty: String = "") -> Array:
	## Get list of available learning paths
	var paths = []
	
	for path_id in _available_paths:
		var path = _available_paths[path_id]
		if difficulty.is_empty() or path.get("difficulty", "") == difficulty:
			paths.append({
				"id": path_id,
				"name": path.get("name", path_id),
				"description": path.get("description", ""),
				"difficulty": path.get("difficulty", "beginner"),
				"estimated_time": path.get("estimated_time", 0),
				"progress": get_path_progress(path_id)
			})
	
	return paths

func start_learning_path(path_id: String) -> bool:
	## Start a specific learning path
	if not _available_paths.has(path_id):
		push_error("[LearningPathManager] Unknown path: %s" % path_id)
		return false
	
	_active_path = _available_paths[path_id].duplicate(true)
	_active_path["id"] = path_id
	_active_path["current_milestone"] = 0
	_active_path["current_step"] = 0
	_active_path["started_at"] = Time.get_ticks_msec()
	
	# Initialize progress tracking
	if not _path_progress.has(path_id):
		_path_progress[path_id] = {
			"completed_milestones": [],
			"total_time": 0,
			"last_accessed": Time.get_datetime_string_from_system()
		}
	
	path_started.emit(_active_path.get("name", path_id))
	print("[LearningPathManager] Started path: %s" % path_id)
	
	return true

func get_current_step() -> Dictionary:
	## Get current step in active path
	if _active_path.is_empty():
		return {}
	
	var milestones = _active_path.get("milestones", [])
	var milestone_idx = _active_path.get("current_milestone", 0)
	
	if milestone_idx >= milestones.size():
		return {}
	
	var milestone = milestones[milestone_idx]
	var steps = milestone.get("steps", [])
	var step_idx = _active_path.get("current_step", 0)
	
	if step_idx >= steps.size():
		return {}
	
	var step = steps[step_idx].duplicate()
	step["milestone_name"] = milestone.get("name", "")
	step["step_number"] = step_idx + 1
	step["total_steps"] = steps.size()
	
	return step

func advance_step() -> bool:
	## Move to next step in learning path
	if _active_path.is_empty():
		return false
	
	var milestones = _active_path.get("milestones", [])
	var milestone_idx = _active_path.get("current_milestone", 0)
	
	if milestone_idx >= milestones.size():
		_complete_path()
		return false
	
	var milestone = milestones[milestone_idx]
	var steps = milestone.get("steps", [])
	var step_idx = _active_path.get("current_step", 0)
	
	# Advance step
	step_idx += 1
	
	if step_idx >= steps.size():
		# Complete milestone
		_complete_milestone(milestone)
		
		# Move to next milestone
		milestone_idx += 1
		step_idx = 0
		
		if milestone_idx >= milestones.size():
			_complete_path()
			return false
	
	_active_path["current_milestone"] = milestone_idx
	_active_path["current_step"] = step_idx
	
	# Update progress
	_update_path_progress()
	
	return true

func get_tour_steps(tour_type: String) -> Array:
	## Get steps for a guided tour
	# Map tour types to learning paths
	var tour_mapping = {
		"brain_overview": "brain_overview",
		"memory": "memory_circuit",
		"clinical": "clinical_cases"
	}
	
	var path_id = tour_mapping.get(tour_type, "brain_overview")
	
	if not _available_paths.has(path_id):
		return []
	
	var path = _available_paths[path_id]
	var all_steps = []
	
	# Flatten all milestones into a single tour
	for milestone in path.get("milestones", []):
		for step in milestone.get("steps", []):
			var tour_step = step.duplicate()
			tour_step["topic"] = path_id
			tour_step["milestone"] = milestone.get("name", "")
			all_steps.append(tour_step)
	
	return all_steps

func get_path_progress(path_id: String) -> float:
	## Get completion progress for a path (0.0 to 1.0)
	if not _path_progress.has(path_id):
		return 0.0
	
	if not _available_paths.has(path_id):
		return 0.0
	
	var path = _available_paths[path_id]
	var total_milestones = path.get("milestones", []).size()
	
	if total_milestones == 0:
		return 0.0
	
	var completed = _path_progress[path_id].get("completed_milestones", []).size()
	
	return float(completed) / float(total_milestones)

func get_recommended_path(level: String, interests: Array = []) -> String:
	## Get recommended path based on level and interests
	var candidates = []
	
	for path_id in _available_paths:
		var path = _available_paths[path_id]
		
		# Check difficulty match
		if path.get("difficulty", "") == level:
			var score = 1.0
			
			# Boost score for matching interests
			var description = path.get("description", "").to_lower()
			for interest in interests:
				if description.contains(interest.to_lower()):
					score += 0.5
			
			# Prefer incomplete paths
			var progress = get_path_progress(path_id)
			if progress < 1.0:
				score += (1.0 - progress)
			
			candidates.append({"id": path_id, "score": score})
	
	# Sort by score
	candidates.sort_custom(func(a, b): return a.score > b.score)
	
	if not candidates.is_empty():
		return candidates[0].id
	
	return "brain_overview"  # Default fallback

# === PRIVATE METHODS ===
func _complete_milestone(milestone: Dictionary) -> void:
	## Mark milestone as completed
	var milestone_id = milestone.get("id", "")
	if milestone_id and milestone_id not in _completed_milestones:
		_completed_milestones.append(milestone_id)
		milestone_reached.emit(milestone.get("name", milestone_id))
		
		# Update path progress
		var path_id = _active_path.get("id", "")
		if path_id and _path_progress.has(path_id):
			var completed = _path_progress[path_id].get("completed_milestones", [])
			if milestone_id not in completed:
				completed.append(milestone_id)
				_path_progress[path_id]["completed_milestones"] = completed

func _complete_path() -> void:
	## Complete the current learning path
	if _active_path.is_empty():
		return
	
	var path_id = _active_path.get("id", "")
	var duration = (Time.get_ticks_msec() - _active_path.get("started_at", 0)) / 1000.0
	
	# Update progress
	if _path_progress.has(path_id):
		_path_progress[path_id]["total_time"] += duration
		_path_progress[path_id]["last_accessed"] = Time.get_datetime_string_from_system()
		_path_progress[path_id]["completed"] = true
	
	path_completed.emit(_active_path.get("name", path_id))
	print("[LearningPathManager] Completed path: %s in %.1f seconds" % [path_id, duration])
	
	_active_path.clear()

func _update_path_progress() -> void:
	## Update progress for active path
	if _active_path.is_empty():
		return
	
	var total_steps = 0
	var completed_steps = 0
	
	var milestones = _active_path.get("milestones", [])
	var current_milestone = _active_path.get("current_milestone", 0)
	var current_step = _active_path.get("current_step", 0)
	
	# Count total steps
	for milestone in milestones:
		total_steps += milestone.get("steps", []).size()
	
	# Count completed steps
	for i in range(current_milestone):
		if i < milestones.size():
			completed_steps += milestones[i].get("steps", []).size()
	
	completed_steps += current_step
	
	var progress = float(completed_steps) / float(max(total_steps, 1))
	path_progress_updated.emit(progress)

func _save_progress() -> void:
	## Save learning path progress
	var save_data = {
		"path_progress": _path_progress,
		"completed_milestones": _completed_milestones,
		"last_saved": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open("user://learning_path_progress.json", FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(save_data, "\t"))
		file.close()

func load_progress() -> void:
	## Load saved progress
	var file = FileAccess.open("user://learning_path_progress.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.data
			_path_progress = data.get("path_progress", {})
			_completed_milestones = data.get("completed_milestones", [])
			print("[LearningPathManager] Loaded saved progress")