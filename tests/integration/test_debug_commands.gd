extends SceneTree

# Test script for debug console commands
func _init():
	print("\n" + "============================================================")
	print("NEUROVIS DEBUG CONSOLE TEST SUITE")
	print("Testing core systems in simplified mode")
	print("============================================================" + "\n")
	
	# Wait for scene to be ready
	await create_timer(1.0).timeout
	
	# Get DebugCmd singleton
	var debug_cmd = Engine.get_singleton("DebugCmd")
	if not debug_cmd:
		print("❌ ERROR: DebugCmd singleton not found!")
		quit()
		return
	
	print("✅ DebugCmd singleton found\n")
	
	# Test commands one by one
	var commands = [
		"test autoloads",
		"test ui_safety",
		"test infrastructure",
		"kb status",
		"flags_status",
		"registry_stats",
		"performance",
		"memory"
	]
	
	for cmd in commands:
		print("\n" + "--------------------------------------------------")
		print("🔍 EXECUTING: " + cmd)
		print("--------------------------------------------------")
		
		# Execute command
		if debug_cmd.has_method("execute_command"):
			debug_cmd.execute_command(cmd)
		else:
			print("⚠️  Cannot execute command directly, trying alternative method...")
			
		# Small delay between commands
		await create_timer(0.5).timeout
	
	print("\n" + "============================================================")
	print("DEBUG CONSOLE TEST COMPLETE")
	print("============================================================" + "\n")
	
	# Wait before quitting to see results
	await create_timer(2.0).timeout
	quit()