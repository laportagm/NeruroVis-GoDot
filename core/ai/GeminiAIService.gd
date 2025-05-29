# GeminiAIService.gd
# Specialized service for Google Gemini AI integration
class_name GeminiAIService
extends Node

# === GEMINI SERVICE SIGNALS ===
signal api_key_validated(success: bool, message: String)
signal model_list_updated(available_models: Array)
signal config_changed(model_name: String, settings: Dictionary)
signal safety_settings_changed(settings: Dictionary)

# === GEMINI SERVICE CONFIG ===
enum GeminiModel {
    GEMINI_PRO,
    GEMINI_PRO_VISION,
    GEMINI_FLASH
}

const MODEL_NAMES = {
    GeminiModel.GEMINI_PRO: "gemini-pro",
    GeminiModel.GEMINI_PRO_VISION: "gemini-pro-vision",
    GeminiModel.GEMINI_FLASH: "gemini-flash"
}

# === CONFIGURATION ===
@export var api_key: String = ""
@export var model: GeminiModel = GeminiModel.GEMINI_PRO
@export var temperature: float = 0.7
@export var top_k: int = 40
@export var top_p: float = 0.95
@export var max_output_tokens: int = 2048
@export var enable_safety_settings: bool = true

# === HTTP CLIENT ===
var http_request: HTTPRequest

# === STATE ===
var is_initialized: bool = false
var available_models: Array = []
var safety_settings: Dictionary = {
    "HARASSMENT": 2,      # BLOCK_ONLY_HIGH
    "HATE_SPEECH": 2,     # BLOCK_ONLY_HIGH
    "SEXUALLY_EXPLICIT": 2, # BLOCK_ONLY_HIGH
    "DANGEROUS_CONTENT": 2  # BLOCK_ONLY_HIGH
}

func _ready() -> void:
    """Initialize the Gemini AI Service"""
    _initialize_service()

func _initialize_service() -> void:
    """Setup HTTP request and load configuration"""
    print("[GeminiAI] Initializing Gemini AI Service...")
    
    # Create HTTP request node
    http_request = HTTPRequest.new()
    add_child(http_request)
    http_request.request_completed.connect(_on_http_request_completed)
    
    # Load API key from user configuration
    _load_api_configuration()
    
    is_initialized = true
    print("[GeminiAI] Initialized with model: " + MODEL_NAMES[model])

func _load_api_configuration() -> void:
    """Load API key from user configuration"""
    var config = ConfigFile.new()
    var err = config.load("user://gemini_config.cfg")
    
    if err == OK:
        if config.has_section_key("credentials", "api_key"):
            api_key = config.get_value("credentials", "api_key")
            print("[GeminiAI] API key loaded from configuration")
            
        if config.has_section_key("settings", "model"):
            var model_value = config.get_value("settings", "model")
            if model_value in GeminiModel.values():
                model = model_value
            
        if config.has_section_key("settings", "temperature"):
            temperature = config.get_value("settings", "temperature")
            
        if config.has_section_key("settings", "max_output_tokens"):
            max_output_tokens = config.get_value("settings", "max_output_tokens")
        
        if config.has_section_key("settings", "enable_safety_settings"):
            enable_safety_settings = config.get_value("settings", "enable_safety_settings")
            
        if config.has_section_key("safety", "settings"):
            var saved_safety = config.get_value("safety", "settings")
            if saved_safety is Dictionary:
                safety_settings = saved_safety
    else:
        print("[GeminiAI] No configuration file found, using defaults")

# === PUBLIC API ===
func validate_api_key(key: String) -> void:
    """Validate API key by making a test request"""
    if key.strip_edges() == "":
        api_key_validated.emit(false, "API key cannot be empty")
        return
        
    print("[GeminiAI] Validating API key...")
    var test_url = "https://generativelanguage.googleapis.com/v1/models?key=" + key
    
    http_request.request(test_url, [], HTTPClient.METHOD_GET)
    # Results will be processed in _on_http_request_completed

func save_configuration(new_key: String = "", new_model: GeminiModel = -1) -> void:
    """Save API key and model configuration"""
    if new_key != "":
        api_key = new_key
        
    if new_model != -1:
        model = new_model
    
    var config = ConfigFile.new()
    
    # Save credentials
    config.set_value("credentials", "api_key", api_key)
    
    # Save settings
    config.set_value("settings", "model", model)
    config.set_value("settings", "temperature", temperature)
    config.set_value("settings", "max_output_tokens", max_output_tokens)
    config.set_value("settings", "enable_safety_settings", enable_safety_settings)
    
    # Save safety settings
    config.set_value("safety", "settings", safety_settings)
    
    var err = config.save("user://gemini_config.cfg")
    if err != OK:
        push_error("[GeminiAI] Failed to save configuration")
    else:
        print("[GeminiAI] Configuration saved successfully")
        config_changed.emit(MODEL_NAMES[model], {
            "temperature": temperature,
            "max_output_tokens": max_output_tokens,
            "enable_safety_settings": enable_safety_settings
        })

func set_model(model_name: String) -> bool:
    """Set the Gemini model by name"""
    for key in MODEL_NAMES:
        if MODEL_NAMES[key] == model_name:
            model = key
            print("[GeminiAI] Model set to: " + model_name)
            return true
    
    push_error("[GeminiAI] Unknown model name: " + model_name)
    return false

func get_model_name() -> String:
    """Get the current model name"""
    return MODEL_NAMES[model]

func update_available_models() -> void:
    """Update the list of available Gemini models"""
    if api_key.strip_edges() == "":
        push_error("[GeminiAI] Cannot fetch models without API key")
        return
        
    var url = "https://generativelanguage.googleapis.com/v1/models?key=" + api_key
    http_request.request(url, [], HTTPClient.METHOD_GET)
    # Results will be processed in _on_http_request_completed

func set_safety_settings(new_settings: Dictionary) -> void:
    """Update safety settings for content generation"""
    for key in new_settings:
        if key in safety_settings:
            safety_settings[key] = new_settings[key]
    
    safety_settings_changed.emit(safety_settings)
    print("[GeminiAI] Safety settings updated")

func generate_content(prompt: String) -> String:
    """Generate content from Gemini API"""
    if !is_api_key_valid():
        return "ERROR: API key not configured."
    
    var url = "https://generativelanguage.googleapis.com/v1/models/%s:generateContent?key=%s" % [
        MODEL_NAMES[model],
        api_key
    ]
    
    var headers = ["Content-Type: application/json"]
    
    var body = {
        "contents": [
            {
                "parts": [
                    {
                        "text": prompt
                    }
                ]
            }
        ],
        "generationConfig": {
            "temperature": temperature,
            "topK": top_k,
            "topP": top_p,
            "maxOutputTokens": max_output_tokens
        }
    }
    
    # Add safety settings if enabled
    if enable_safety_settings:
        var safety_settings_array = []
        for category in safety_settings:
            safety_settings_array.append({
                "category": category,
                "threshold": safety_settings[category]
            })
        body["safetySettings"] = safety_settings_array
    
    var json_body = JSON.stringify(body)
    http_request.request(url, headers, HTTPClient.METHOD_POST, json_body)
    
    return "PENDING"

func is_api_key_valid() -> bool:
    """Check if API key is valid"""
    return api_key.strip_edges() != ""

func get_service_status() -> Dictionary:
    """Get current service status"""
    return {
        "initialized": is_initialized,
        "model": get_model_name(),
        "api_key_configured": is_api_key_valid(),
        "safety_enabled": enable_safety_settings
    }

# === RESPONSE PROCESSING ===
func _on_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
    """Handle HTTP request completion"""
    if result != HTTPRequest.RESULT_SUCCESS:
        _handle_request_error("HTTP request failed with error: " + str(result))
        return
    
    if response_code != 200:
        _handle_request_error("API returned error code: " + str(response_code))
        return
    
    var json = JSON.new()
    var parse_result = json.parse(body.get_string_from_utf8())
    
    if parse_result != OK:
        _handle_request_error("Failed to parse API response")
        return
    
    var response_data = json.get_data()
    
    # Handle different request types based on response structure
    if response_data.has("models"):
        _process_models_list_response(response_data)
    elif response_data.has("candidates"):
        _process_generation_response(response_data)
    else:
        # Simple validation response (e.g., API key validation)
        api_key_validated.emit(true, "API key is valid")

func _process_models_list_response(data: Dictionary) -> void:
    """Process models list response"""
    available_models.clear()
    
    for model_info in data.get("models", []):
        if model_info.has("name"):
            # Extract model name from full path (like "models/gemini-pro")
            var full_name = model_info.name
            var model_name = full_name.split("/")[-1]
            available_models.append(model_name)
    
    model_list_updated.emit(available_models)
    print("[GeminiAI] Updated available models: ", available_models)

func _process_generation_response(data: Dictionary) -> void:
    """Process content generation response"""
    var candidates = data.get("candidates", [])
    if candidates.size() > 0:
        var candidate = candidates[0]
        if candidate.has("content") and candidate.content.has("parts"):
            var parts = candidate.content.parts
            for part in parts:
                if part.has("text"):
                    var ai_service = get_node_or_null("/root/AIAssistant")
                    if ai_service and ai_service.has_method("_on_gemini_response_received"):
                        ai_service._on_gemini_response_received(part.text)
                    break
    else:
        _handle_request_error("No content generated")

func _handle_request_error(message: String) -> void:
    """Handle API request errors"""
    push_error("[GeminiAI] " + message)
    
    var ai_service = get_node_or_null("/root/AIAssistant")
    if ai_service and ai_service.has_method("_on_ai_error"):
        ai_service._on_ai_error("Gemini API error: " + message)

# === UTILITY FUNCTIONS ===
func get_model_list() -> Array:
    """Get list of available Gemini models"""
    return available_models

func get_safety_settings() -> Dictionary:
    """Get current safety settings"""
    return safety_settings.duplicate()

func get_configuration() -> Dictionary:
    """Get current configuration"""
    return {
        "model": get_model_name(),
        "temperature": temperature,
        "max_output_tokens": max_output_tokens,
        "safety_enabled": enable_safety_settings
    }

func get_api_key() -> String:
    """Get API key (masked for UI display)"""
    if api_key.strip_edges() == "":
        return ""
    
    if api_key.length() <= 8:
        return "••••••••"
    
    return api_key.substr(0, 4) + "••••" + api_key.substr(api_key.length() - 4)