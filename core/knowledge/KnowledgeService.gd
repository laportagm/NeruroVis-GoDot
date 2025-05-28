## KnowledgeService.gd
## Centralized knowledge base and anatomical data management service
##
## This autoload singleton provides unified access to anatomical data,
## structure information, and educational content throughout NeuroVis.
##
## Access via: KnowledgeService.method_name()
## @autoload: KnowledgeService

extends Node

# === CONSTANTS ===
const SINGLETON_NAME: String = "KnowledgeService"
const VERSION: String = "1.0.0"
const DATA_FILE_PATH: String = "res://assets/data/anatomical_data.json"

# === SIGNALS ===
## Emitted when the singleton is fully initialized
signal initialized()

## Emitted when data is successfully loaded
signal data_loaded(structure_count: int)

## Emitted when a structure is requested
signal structure_requested(structure_id: String)

## Emitted when critical error occurs
signal error_occurred(error_message: String)

# === CONFIGURATION ===
## Enable debug logging
var debug_mode: bool = OS.is_debug_build()

## Enable performance monitoring
var monitor_performance: bool = false

# === STATE VARIABLES ===
var _is_initialized: bool = false
var _initialization_time: float = 0.0
var _error_count: int = 0

# === DATA STORAGE ===
var _anatomical_data: Dictionary = {}
var _structure_index: Dictionary = {}
var _search_cache: Dictionary = {}
var _settings: Dictionary = {}

# === LIFECYCLE METHODS ===
func _ready() -> void:
	"""Initialize the singleton on startup"""
	name = SINGLETON_NAME
	_initialize_singleton()

func _exit_tree() -> void:
	"""Clean up singleton resources"""
	_cleanup_singleton()

# === INITIALIZATION ===
func _initialize_singleton() -> void:
	"""Initialize the singleton with default configuration"""
	
	_log_debug("Initializing " + SINGLETON_NAME + " singleton...")
	var start_time = Time.get_ticks_msec()
	
	# Load configuration
	_load_configuration()
	
	# Initialize subsystems
	_initialize_subsystems()
	
	# Setup monitoring if enabled
	if monitor_performance:
		_setup_performance_monitoring()
	
	# Mark as initialized
	_is_initialized = true
	_initialization_time = (Time.get_ticks_msec() - start_time) / 1000.0
	
	emit_signal("initialized")
	_log_debug(SINGLETON_NAME + " initialized in " + str(_initialization_time) + "s")

func _load_configuration() -> void:
	"""Load singleton configuration from settings"""
	
	# Default settings for knowledge service
	_settings = {
		"debug_mode": OS.is_debug_build(),
		"cache_enabled": true,
		"preload_all": true,
		"search_fuzzy": true
	}
	
	# Apply settings
	debug_mode = _settings.get("debug_mode", false)

func _load_project_settings() -> void:
	"""Load settings from project configuration"""
	
	var setting_prefix = "{{SINGLETON_NAME_LOWER}}"
	
	for key in _settings.keys():
		var setting_path = setting_prefix + "/" + key
		if ProjectSettings.has_setting(setting_path):
			_settings[key] = ProjectSettings.get_setting(setting_path)

func _initialize_subsystems() -> void:
	"""Initialize knowledge management subsystems"""
	
	# Load anatomical data
	_load_anatomical_data()
	
	# Build search index
	_build_structure_index()
	
	# Initialize search cache
	_search_cache.clear()

func _load_anatomical_data() -> void:
	"""Load anatomical data from JSON file"""
	
	if not FileAccess.file_exists(DATA_FILE_PATH):
		_handle_error("Anatomical data file not found: " + DATA_FILE_PATH)
		return
	
	var file = FileAccess.open(DATA_FILE_PATH, FileAccess.READ)
	if not file:
		_handle_error("Failed to open anatomical data file")
		return
	
	var json_text = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_text)
	
	if parse_result != OK:
		_handle_error("Failed to parse anatomical data JSON")
		return
	
	_anatomical_data = json.data
	data_loaded.emit(_anatomical_data.size())
	_log_debug("Loaded " + str(_anatomical_data.size()) + " anatomical structures")

func _build_structure_index() -> void:
	"""Build searchable index of anatomical structures"""
	
	_structure_index.clear()
	
	for structure_id in _anatomical_data.keys():
		var structure = _anatomical_data[structure_id]
		if structure.has("displayName"):
			# Index by ID and name for fast lookup
			_structure_index[structure_id] = structure
			_structure_index[structure["displayName"].to_lower()] = structure

# === PUBLIC API ===
## Get structure data by ID or name
func get_structure(identifier: String) -> Dictionary:
	"""Get anatomical structure data by ID or display name"""
	
	if identifier.is_empty():
		return {}
	
	structure_requested.emit(identifier)
	
	# Direct ID lookup
	if _anatomical_data.has(identifier):
		return _anatomical_data[identifier]
	
	# Index lookup (case-insensitive)
	var lower_id = identifier.to_lower()
	if _structure_index.has(lower_id):
		return _structure_index[lower_id]
	
	_log_debug("Structure not found: " + identifier)
	return {}

## Search structures by keyword
func search_structures(query: String, limit: int = 10) -> Array:
	"""Search anatomical structures by keyword"""
	
	if query.is_empty():
		return []
	
	# Check cache first
	var cache_key = query.to_lower() + "_" + str(limit)
	if _search_cache.has(cache_key):
		return _search_cache[cache_key]
	
	var results = []
	var query_lower = query.to_lower()
	
	for structure in _anatomical_data.values():
		if _matches_search(structure, query_lower):
			results.append(structure)
			if results.size() >= limit:
				break
	
	# Cache results
	_search_cache[cache_key] = results
	return results

## Get all structure IDs
func get_all_structure_ids() -> Array:
	"""Get array of all available structure IDs"""
	return _anatomical_data.keys()

## Get total structure count
func get_structure_count() -> int:
	"""Get total number of anatomical structures"""
	return _anatomical_data.size()

# === PRIVATE METHODS ===
func _matches_search(structure: Dictionary, query: String) -> bool:
	"""Check if structure matches search query"""
	
	# Check display name
	if structure.has("displayName"):
		if structure["displayName"].to_lower().contains(query):
			return true
	
	# Check description
	if structure.has("shortDescription"):
		if structure["shortDescription"].to_lower().contains(query):
			return true
	
	# Check functions
	if structure.has("functions"):
		for func_item in structure["functions"]:
			if func_item.to_lower().contains(query):
				return true
	
	return false

# === UTILITY METHODS ===
## Check if singleton is initialized
func is_initialized() -> bool:
	"""Check if the knowledge service is fully initialized"""
	return _is_initialized

## Get singleton version
func get_version() -> String:
	"""Get the knowledge service version"""
	return VERSION

## Clear search cache
func clear_search_cache() -> void:
	"""Clear the search results cache"""
	_search_cache.clear()
	_log_debug("Search cache cleared")

# === ERROR HANDLING ===
func _handle_error(message: String) -> void:
	"""Handle error with logging and signal emission"""
	
	_error_count += 1
	var full_message = "[" + SINGLETON_NAME + "] " + message
	
	push_error(full_message)
	error_occurred.emit(message)

# === LOGGING ===
func _log_debug(message: String) -> void:
	"""Log debug message if debug mode is enabled"""
	if debug_mode:
		print("[" + SINGLETON_NAME + "] " + message)

# === CLEANUP ===
func _cleanup_singleton() -> void:
	"""Clean up singleton resources"""
	
	# Clear all data
	_anatomical_data.clear()
	_structure_index.clear()
	_search_cache.clear()
	_settings.clear()
	
	_is_initialized = false
	_log_debug(SINGLETON_NAME + " cleaned up")
