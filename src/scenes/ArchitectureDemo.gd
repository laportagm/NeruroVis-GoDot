## ArchitectureDemo.gd
## Integration script to demonstrate new architecture alongside existing system
##
## Add this to the existing main scene as a child node to see the new
## scene-based architecture working in parallel with the old monolithic system.
##
## @tutorial: Architecture transition demonstration
## @version: 3.0

extends Node

# === DEMO COMPONENTS ===
var educational_coordinator: EducationalCoordinator
var demo_active: bool = false

func _ready() -> void:
	print("\\n[ArchitectureDemo] Starting architecture demonstration...")
	
	# Wait for main scene to initialize
	await get_tree().process_frame
	await get_tree().process_frame
	
	_setup_demo()

func _setup_demo() -> void:
	"""Setup the architecture demonstration"""
	# Load and create educational coordinator
	var CoordinatorScene = load("res://src/scenes/educational_systems/EducationalCoordinator.tscn")
	educational_coordinator = CoordinatorScene.instantiate()
	educational_coordinator.name = "EducationalCoordinator_Demo"
	add_child(educational_coordinator)
	
	# Try to integrate with existing main scene
	var main_scene = get_parent()
	if main_scene and main_scene.has_method("get_node"):
		var camera = main_scene.get_node_or_null("Camera3D")
		var brain_model = main_scene.get_node_or_null("BrainModel")
		
		if camera and brain_model:
			# Initialize new system with existing components
			var success = educational_coordinator.initialize_with_components(camera, brain_model)
			if success:
				demo_active = true
				_show_demo_instructions()
			else:
				print("[ArchitectureDemo] Failed to initialize with existing components")
		else:
			print("[ArchitectureDemo] Could not find Camera3D or BrainModel in main scene")
	else:
		print("[ArchitectureDemo] Could not access main scene components")

func _show_demo_instructions() -> void:
	"""Show instructions for the demo"""
	print("\\n" + "="*60)
	print("   NEW SCENE-BASED ARCHITECTURE DEMO ACTIVE")
	print("="*60)
	print("\\nThe new architecture is now running alongside the old system.")
	print("\\n🎯 Key Improvements:")
	print("  • Focused components (<300 lines each)")
	print("  • Educational event-driven communication")
	print("  • AI-friendly modular design")
	print("  • Clear separation of concerns")
	print("\\n🧪 Test the New System:")
	print("  • Right-click structures (new selection system)")
	print("  • Watch console for educational events")
	print("  • Notice cleaner, more focused code")
	print("\\n⌨️  Debug Commands (F1 console):")
	print("  • demo_architecture - Show this info")
	print("  • demo_comparison - Compare old vs new")
	print("  • demo_events - Show recent educational events")
	print("="*60 + "\\n")
	
	# Register debug commands
	_register_demo_commands()

func _register_demo_commands() -> void:
	"""Register demo debug commands"""
	if DebugCmd:
		DebugCmd.register_command("demo_architecture", 
			func(): educational_coordinator.demonstrate_new_architecture(),
			"Show new architecture demonstration"
		)
		DebugCmd.register_command("demo_comparison",
			func(): educational_coordinator.compare_with_old_system(),
			"Compare old vs new architecture"
		)
		DebugCmd.register_command("demo_events",
			_show_recent_events,
			"Show recent educational events"
		)

func _show_recent_events() -> void:
	"""Show recent educational events from the event bus"""
	var event_bus = educational_coordinator.get_event_bus()
	if event_bus and event_bus.has_method("get_recent_events"):
		var events = event_bus.get_recent_events(5)
		print("\\n=== RECENT EDUCATIONAL EVENTS ===")
		if events.is_empty():
			print("No recent events")
		else:
			for event in events:
				var timestamp = Time.get_datetime_string_from_unix_time(event.get("timestamp", 0))
				var event_type = event.get("event_type", "unknown")
				print("%s: %s" % [timestamp, event_type])
		print("=================================\\n")
	else:
		print("Event bus not available for demo")

func _input(event: InputEvent) -> void:
	"""Handle demo-specific input"""
	if not demo_active:
		return
	
	# F2 to show demo info
	if event is InputEventKey and event.pressed and event.keycode == KEY_F2:
		_show_demo_instructions()
		get_viewport().set_input_as_handled()

# === DEMO STATUS ===
func is_demo_active() -> bool:
	"""Check if demo is currently active"""
	return demo_active

func get_educational_coordinator() -> EducationalCoordinator:
	"""Get the educational coordinator for testing"""
	return educational_coordinator