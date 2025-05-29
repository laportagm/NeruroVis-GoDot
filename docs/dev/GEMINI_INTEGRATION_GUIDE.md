# Google Gemini AI Integration Guide

This guide documents the integration of Google Gemini AI into the NeuroVis educational platform. The implementation provides an alternative AI provider option for the anatomical assistant features.

## Overview

Google Gemini AI integration adds a powerful alternative to the existing AI assistant functionality, allowing educators and students to utilize Google's advanced large language models for educational neuroanatomy assistance.

### Key Files

1. **`core/ai/GeminiAIService.gd`** - Core service that handles Gemini API communications
2. **`ui/panels/GeminiSetupDialog.gd`** - Configuration dialog for API keys and model settings  
3. **`ui/components/controls/GeminiModelSelector.gd`** - UI component for model selection
4. **Existing files with Gemini integration**:
   - `core/ai/AIAssistantService.gd` - Updated with Gemini integration
   - `ui/components/panels/AIAssistantPanel.gd` - Updated with provider selection UI

## Implementation Details

### GeminiAIService

The `GeminiAIService` class provides a dedicated service for interacting with Google's Gemini API. Key features include:

- API key validation and secure storage
- Model selection (Gemini Pro, Pro Vision, Flash)
- Safety settings configuration
- Temperature and output token control
- HTTP request handling and response parsing

```gdscript
# Example: Creating a standalone Gemini service instance
var gemini_service = GeminiAIService.new()
add_child(gemini_service)

# Example: Validating API key
gemini_service.validate_api_key("YOUR_API_KEY")  # Emits api_key_validated signal

# Example: Generating content
var response = gemini_service.generate_content("Explain the function of the hippocampus in memory formation")
```

### GeminiSetupDialog

The `GeminiSetupDialog` provides a user-friendly interface for configuring Gemini API settings:

- API key entry and validation
- Model selection
- Advanced options (temperature, max tokens)
- Safety settings configuration

```gdscript
# Example: Showing the setup dialog
var setup_dialog = GeminiSetupDialog.new()
add_child(setup_dialog)
setup_dialog.setup_completed.connect(_on_setup_completed)
setup_dialog.show_dialog()
```

### AIAssistantPanel Integration

The `AIAssistantPanel` has been enhanced to support provider switching between different AI backends:

- Provider selection dropdown
- Gemini-specific model selector
- Seamless integration with existing chat functionality
- Automatic dialog for first-time Gemini setup

## Configuration & Storage

### User Settings

The Gemini API configuration is stored in the user configuration directory:

- File: `user://gemini_config.cfg`
- Format: Godot ConfigFile
- Contents:
  - API key (encrypted in storage)
  - Selected model
  - Generation parameters
  - Safety settings

### Configuration Security

The API key is:
- Stored only on the user's local device
- Never transmitted except to Google's API
- Shown in masked form in the UI
- Loaded from environment variables when available

## Adding Gemini to Autoload (Optional)

For global access to the Gemini service, it can be added as an autoload in `project.godot`:

```
[autoload]
GeminiService="*res://core/ai/GeminiAIService.gd"
```

## Usage Guide

### For Educational Platform Users

1. Open the AI Assistant panel
2. Select "GOOGLE_GEMINI" from the provider dropdown
3. Enter your API key in the setup dialog that appears
4. Select desired model and settings
5. Begin asking questions about neuroanatomy

### For Developers

#### Accessing the Gemini Service

```gdscript
# Access as global singleton (if added to autoload)
var gemini = get_node("/root/GeminiService")

# Or create a local instance
var gemini = GeminiAIService.new()
add_child(gemini)

# Configure
gemini.set_model("gemini-pro")
gemini.temperature = 0.7
```

#### Using the Model Selector in Custom UI

```gdscript
# Add the model selector to your UI
var selector = GeminiModelSelector.new()
add_child(selector)

# Connect signals
selector.model_changed.connect(_on_model_changed)
selector.settings_requested.connect(_on_settings_requested)
```

## API Reference

### GeminiAIService

**Signals**:
- `api_key_validated(success, message)` - Emitted after key validation
- `model_list_updated(available_models)` - Emitted when model list is updated
- `config_changed(model_name, settings)` - Emitted when configuration is changed
- `safety_settings_changed(settings)` - Emitted when safety settings are updated

**Methods**:
- `validate_api_key(key)` - Validates API key with Google
- `save_configuration(new_key, new_model)` - Saves configuration to disk
- `set_model(model_name)` - Sets the Gemini model
- `generate_content(prompt)` - Sends prompt to Gemini API
- `is_api_key_valid()` - Checks if API key is configured
- `get_service_status()` - Gets current service status
- `get_model_name()` - Gets current model name
- `set_safety_settings(settings)` - Updates safety settings

### GeminiSetupDialog

**Signals**:
- `setup_completed(successful, api_key)` - Emitted when setup is completed
- `setup_cancelled()` - Emitted when setup is cancelled

**Methods**:
- `show_dialog()` - Shows the setup dialog

### GeminiModelSelector

**Signals**:
- `model_changed(model_name)` - Emitted when model is changed
- `settings_requested()` - Emitted when settings button is pressed

**Methods**:
- `get_current_model()` - Gets currently selected model
- `set_model(model_name)` - Sets model by name
- `refresh_status()` - Refreshes status indicator

## Error Handling

The integration includes robust error handling for common issues:

1. **API Key Validation Failures**
   - Invalid or expired keys
   - Rate limiting or quota exceeded
   - Network connectivity issues

2. **Content Generation Errors**
   - Safety filter blocks
   - Timeout issues
   - Malformed responses

3. **Configuration Issues**
   - Missing or corrupt configuration file
   - Permission problems in user directory

## Educational Context

This integration specifically enhances the educational capabilities of NeuroVis by:

1. **Improved Accuracy**: Gemini models offer advanced knowledge of neuroanatomy
2. **Tailored Educational Responses**: Customized for different learning levels
3. **Multimodal Future Potential**: Groundwork for future image-based queries with Gemini Pro Vision
4. **Educational Consistency**: Maintains educational context in responses

## Future Enhancements

Planned improvements to the Gemini integration include:

1. **Image Analysis**: Adding support for Gemini Pro Vision to analyze brain structure images
2. **Streaming Responses**: Implementing real-time streaming for more interactive responses
3. **Enhanced Educational Prompting**: More specialized prompts for different educational contexts
4. **User Preference Persistence**: Remembering preferred AI provider between sessions

## Troubleshooting

### Common Issues

1. **API Key Invalid**
   - Verify key was copied correctly
   - Check if key has the necessary permissions
   - Ensure key has not expired or reached quota limits

2. **No Response from API**
   - Check internet connection
   - Verify firewall settings
   - Check if rate limits are reached

3. **Model Not Available**
   - Some models may be region-restricted
   - Check if the model is deprecated or in limited preview

### Logging

Diagnostic information is logged with the prefix `[GeminiAI]` for easier filtering and troubleshooting.

---

## Educational Impact

The Google Gemini integration enhances NeuroVis as an educational platform by providing:

1. **Choice of AI providers** for different educational needs and preferences
2. **Advanced neuroanatomical knowledge** through state-of-the-art language models
3. **Configurable safety settings** for appropriate educational content
4. **Consistent educational experience** across different AI backends

This integration maintains the educational focus of NeuroVis while expanding its AI capabilities for more comprehensive neuroanatomy learning support.