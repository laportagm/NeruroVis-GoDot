class_name KnowledgeBase
extends Node

# Path to the knowledge base file
const KNOWLEDGE_BASE_PATH = "res://assets/data/anatomical_data.json"

# Structure data
var structures: Dictionary = {}
var version: String = ""
var last_updated: String = ""

# Status tracking
var is_loaded: bool = false
var load_error: String = ""
var warnings: Array = []

func _ready() -> void:
	# Attempt to load the knowledge base on startup
	load_knowledge_base()
		
func load_knowledge_base() -> bool:
	print("Loading knowledge base from: " + KNOWLEDGE_BASE_PATH)
	
	# Reset status variables
	is_loaded = false
	load_error = ""
	warnings.clear()
	structures.clear()
	
	# Check if file exists
	if not FileAccess.file_exists(KNOWLEDGE_BASE_PATH):
		load_error = "KnowledgeBase Error: KNOWLEDGE_BASE_PATH not found at " + KNOWLEDGE_BASE_PATH
		printerr(load_error)
		return false
	
	# Create a new file access object
	var file = FileAccess.open(KNOWLEDGE_BASE_PATH, FileAccess.READ)
	
	# Check if the file was opened successfully
	if file == null:
		var file_open_error_code = FileAccess.get_open_error()
		load_error = "KnowledgeBase Error: Failed to open knowledge base file. Error code: " + str(file_open_error_code)
		printerr(load_error)
		return false
	
	# Read the file content
	var json_text = file.get_as_text()
	file.close()
	
	# Check if file content is empty
	if json_text.strip_edges() == "":
		load_error = "KnowledgeBase Error: Knowledge base file is empty."
		printerr(load_error)
		return false
	
	# Parse the JSON
	var json = JSON.new()
	var json_parse_result = json.parse(json_text)
	
	if json_parse_result != OK:
		load_error = "KnowledgeBase Error: Failed to parse knowledge base JSON. Error at line " + str(json.get_error_line()) + ": " + json.get_error_message()
		printerr(load_error)
		return false
	
	# Get the data
	var data = json.get_data()
	
	# Validate the data is a Dictionary
	if not data is Dictionary:
		load_error = "KnowledgeBase Error: Knowledge base data is not a Dictionary. Got " + str(typeof(data)) + " instead."
		printerr(load_error)
		return false
	
	# Validate required top-level fields
	var missing_fields = []
	if not data.has("version"):
		missing_fields.append("version")
	if not data.has("lastUpdated"):
		missing_fields.append("lastUpdated")
	if not data.has("structures"):
		missing_fields.append("structures")
	
	if missing_fields.size() > 0:
		load_error = "KnowledgeBase Error: Knowledge base data is missing required fields: " + str(missing_fields)
		printerr(load_error)
		return false
	
	# Validate that structures is an array
	if not data.structures is Array:
		load_error = "KnowledgeBase Error: 'structures' field must be an Array. Got " + str(typeof(data.structures)) + " instead."
		printerr(load_error)
		return false
	
	# Store the metadata
	version = data.version
	last_updated = data.lastUpdated
	
	# Process structures and create lookup by ID
	var valid_structures_count = 0
	var skipped_structures_count = 0
	
	for structure in data.structures:
		# Verify each structure is a Dictionary
		if not structure is Dictionary:
			var warning = "KnowledgeBase Warning: Skipping non-Dictionary structure entry. Got " + str(typeof(structure)) + " instead."
			printerr(warning)
			warnings.append(warning)
			skipped_structures_count += 1
			continue
		
		# Verify each structure has an id field
		if not structure.has("id") or structure.id.strip_edges() == "":
			var warning = "KnowledgeBase Warning: Skipping structure without valid 'id' field: " + str(structure)
			printerr(warning)
			warnings.append(warning)
			skipped_structures_count += 1
			continue
		
		# Add valid structure to our dictionary
		structures[structure.id] = structure
		valid_structures_count += 1
	
	# Check if we loaded any valid structures
	if valid_structures_count == 0:
		load_error = "KnowledgeBase Error: No valid structures found in knowledge base."
		printerr(load_error)
		return false
	
	# Mark as successfully loaded
	is_loaded = true
	print("Knowledge base loaded successfully. Version: " + version + ", Last Updated: " + last_updated)
	print("Loaded " + str(valid_structures_count) + " anatomical structures.")
	
	if skipped_structures_count > 0:
		print("Warning: Skipped " + str(skipped_structures_count) + " invalid structure entries.")
	
	return true

# Get a structure by ID
func get_structure(id: String) -> Dictionary:
	if not is_loaded:
		printerr("KnowledgeBase Warning: Attempting to get structure before knowledge base is loaded.")
		return {}
	
	if structures.has(id):
		return structures[id]
	else:
		printerr("KnowledgeBase Warning: Structure with ID '" + id + "' not found in knowledge base.")
		return {}

# Get all structure IDs
func get_all_structure_ids() -> Array:
	if not is_loaded:
		printerr("KnowledgeBase Warning: Attempting to get structure IDs before knowledge base is loaded.")
		return []
	return structures.keys()

# Check if a structure ID exists
func has_structure(id: String) -> bool:
	if not is_loaded:
		printerr("KnowledgeBase Warning: Checking for structure before knowledge base is loaded.")
		return false
	return structures.has(id)

# Get knowledge base metadata
func get_metadata() -> Dictionary:
	return {
		"version": version,
		"lastUpdated": last_updated,
		"structureCount": structures.size(),
		"isLoaded": is_loaded,
		"loadError": load_error,
		"warnings": warnings
	}
