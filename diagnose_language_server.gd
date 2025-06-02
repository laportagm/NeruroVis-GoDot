extends Node

# Godot Language Server Diagnostic Tool
# This script helps diagnose Language Server connection issues

func _ready():
	print("\n=== Godot Language Server Diagnostic ===\n")
	
	# Check if running in editor
	if OS.has_feature("editor"):
		print("✅ Running in Godot Editor")
	else:
		print("❌ Not running in editor - Language Server only works in editor")
		return
	
	# Check debug settings
	var debug_settings = ProjectSettings.get_setting("debug/settings/gdscript/include_language_server", false)
	if debug_settings:
		print("✅ Language Server enabled in project settings")
	else:
		print("❌ Language Server disabled in project settings")
	
	# Check if external editor is configured
	if OS.has_feature("debug"):
		print("✅ Debug mode enabled")
	
	# Print connection info
	print("\nExpected Language Server connection:")
	print("  Host: 127.0.0.1")
	print("  Port: 6005")
	
	print("\nTo enable Language Server:")
	print("1. Go to: Editor → Editor Settings")
	print("2. Navigate to: Network → Language Server")
	print("3. Enable: ✅ Enable Language Server")
	print("4. Keep Godot open while using VS Code")
	
	print("\nVS Code should connect automatically when you open a .gd file")
	print("Check VS Code Output panel → 'Godot Tools' for connection status")
	
	# Self-destruct after diagnosis
	queue_free()
