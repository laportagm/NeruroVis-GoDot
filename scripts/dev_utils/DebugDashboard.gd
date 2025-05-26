extends Control

# A1-NeuroVis Visual Debug Dashboard
# Real-time visual debugging interface with performance graphs and system monitoring

signal dashboard_toggled(visible: bool)

@onready var panel_container = $PanelContainer
@onready var toggle_button = $PanelContainer/VBoxContainer/HeaderContainer/ToggleButton
@onready var tab_container = $PanelContainer/VBoxContainer/TabContainer

# Performance tab
@onready var fps_value = $PanelContainer/VBoxContainer/TabContainer/Performance/VBoxContainer/FPSContainer/FPSValue
@onready var memory_value = $PanelContainer/VBoxContainer/TabContainer/Performance/VBoxContainer/MemoryContainer/MemoryValue
@onready var performance_graph = $PanelContainer/VBoxContainer/TabContainer/Performance/VBoxContainer/PerformanceGraph

# Error tab
@onready var error_count_value = $PanelContainer/VBoxContainer/TabContainer/Errors/VBoxContainer/ErrorSummary/ErrorCountValue
@onready var error_log = $PanelContainer/VBoxContainer/TabContainer/Errors/VBoxContainer/ScrollContainer/ErrorLog

# Health tab
@onready var health_status = $PanelContainer/VBoxContainer/TabContainer/Health/VBoxContainer/OverallHealth/HealthStatus
@onready var component_health = $PanelContainer/VBoxContainer/TabContainer/Health/VBoxContainer/ComponentHealth

# Test tab
@onready var run_tests_button = $PanelContainer/VBoxContainer/TabContainer/Tests/VBoxContainer/TestControls/RunTestsButton
@onready var stress_test_button = $PanelContainer/VBoxContainer/TabContainer/Tests/VBoxContainer/TestControls/StressTestButton
@onready var test_log = $PanelContainer/VBoxContainer/TabContainer/Tests/VBoxContainer/TestResults/TestLog

var is_minimized: bool = false
var update_timer: Timer
var performance_history: Array = []
var max_history_points: int = 60

func _ready():
	print("📊 DebugDashboard initialized - Visual debugging interface ready")
	setup_dashboard()
	connect_signals()
	start_monitoring()

func setup_dashboard():
	# Set up toggle button
	toggle_button.pressed.connect(_on_toggle_pressed)
	
	# Set up test buttons
	run_tests_button.pressed.connect(_on_run_tests_pressed)
	stress_test_button.pressed.connect(_on_stress_test_pressed)
	
	# Set up update timer
	update_timer = Timer.new()
	update_timer.wait_time = 1.0  # Update every second
	update_timer.timeout.connect(_update_dashboard)
	add_child(update_timer)
	
	# Set initial state
	visible = false

func connect_signals():
	# Connect to debugging system signals
	if ErrorTracker:
		ErrorTracker.error_logged.connect(_on_error_logged)
		ErrorTracker.critical_error_detected.connect(_on_critical_error)
	
	if HealthMonitor:
		HealthMonitor.health_warning.connect(_on_health_warning)
		HealthMonitor.performance_degradation.connect(_on_performance_degradation)
	
	if TestFramework:
		TestFramework.test_completed.connect(_on_test_completed)
		TestFramework.test_suite_completed.connect(_on_test_suite_completed)

func start_monitoring():
	update_timer.start()
	_update_dashboard()

func _update_dashboard():
	_update_performance_tab()
	_update_health_tab()
	_update_error_tab()

func _update_performance_tab():
	# Update FPS
	var current_fps = Engine.get_frames_per_second()
	fps_value.text = str(current_fps)
	
	# Color code based on performance
	if current_fps >= 55:
		fps_value.modulate = Color.GREEN
	elif current_fps >= 30:
		fps_value.modulate = Color.YELLOW
	else:
		fps_value.modulate = Color.RED
	
	# Update memory
	var memory_mb = OS.get_static_memory_usage() / (1024 * 1024)
	memory_value.text = "%.1f MB" % memory_mb
	
	# Store performance history
	performance_history.append({
		"fps": current_fps,
		"memory": memory_mb,
		"timestamp": Time.get_ticks_msec()
	})
	
	# Limit history size
	if performance_history.size() > max_history_points:
		performance_history.pop_front()
	
	# Update performance graph
	_draw_performance_graph()

func _update_health_tab():
	if not HealthMonitor:
		health_status.text = "UNAVAILABLE"
		health_status.modulate = Color.GRAY
		return
	
	var health_data = HealthMonitor.get_health_status()
	if health_data.has("overall_status"):
		var status = health_data.overall_status
		health_status.text = HealthMonitor.HealthStatus.keys()[status]
		
		# Color code health status
		match status:
			HealthMonitor.HealthStatus.EXCELLENT:
				health_status.modulate = Color.CYAN
			HealthMonitor.HealthStatus.GOOD:
				health_status.modulate = Color.GREEN
			HealthMonitor.HealthStatus.WARNING:
				health_status.modulate = Color.YELLOW
			HealthMonitor.HealthStatus.CRITICAL:
				health_status.modulate = Color.ORANGE
			HealthMonitor.HealthStatus.FAILED:
				health_status.modulate = Color.RED
	
	# Update component health
	_update_component_health_display()

func _update_component_health_display():
	# Clear existing component displays
	for child in component_health.get_children():
		child.queue_free()
	
	if not HealthMonitor:
		return
	
	var health_report = HealthMonitor.get_performance_report()
	if health_report.has("component_status"):
		var components = health_report.component_status
		
		for component_name in components:
			var status = components[component_name]
			var container = HBoxContainer.new()
			
			var label = Label.new()
			label.text = component_name.capitalize().replace("_", " ") + ":"
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var status_label = Label.new()
			status_label.text = HealthMonitor.HealthStatus.keys()[status]
			status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			
			# Color code component status
			match status:
				HealthMonitor.HealthStatus.EXCELLENT, HealthMonitor.HealthStatus.GOOD:
					status_label.modulate = Color.GREEN
				HealthMonitor.HealthStatus.WARNING:
					status_label.modulate = Color.YELLOW
				HealthMonitor.HealthStatus.CRITICAL:
					status_label.modulate = Color.ORANGE
				HealthMonitor.HealthStatus.FAILED:
					status_label.modulate = Color.RED
			
			container.add_child(label)
			container.add_child(status_label)
			component_health.add_child(container)

func _update_error_tab():
	if not ErrorTracker:
		error_count_value.text = "N/A"
		return
	
	var error_summary = ErrorTracker.get_error_summary()
	if error_summary.has("total_errors"):
		error_count_value.text = str(error_summary.total_errors)
		
		# Color code based on error count
		var total = error_summary.total_errors
		if total == 0:
			error_count_value.modulate = Color.GREEN
		elif total < 10:
			error_count_value.modulate = Color.YELLOW
		else:
			error_count_value.modulate = Color.RED

func _draw_performance_graph():
	if performance_history.size() < 2:
		return
	
	performance_graph.queue_redraw()
	
	# Connect the custom draw function if not already connected
	if not performance_graph.draw.is_connected(_on_performance_graph_draw):
		performance_graph.draw.connect(_on_performance_graph_draw)

func _on_performance_graph_draw():
	if performance_history.size() < 2:
		return
	
	var graph_size = performance_graph.size
	var margin = 10.0
	
	# Draw background
	performance_graph.draw_rect(Rect2(Vector2.ZERO, graph_size), Color(0.1, 0.1, 0.1, 0.8))
	
	# Draw FPS line
	var fps_points = PackedVector2Array()
	var max_fps = 120.0
	
	for i in range(performance_history.size()):
		var history = performance_history[i]
		var x = margin + (i / float(performance_history.size() - 1)) * (graph_size.x - 2 * margin)
		var y = graph_size.y - margin - (history.fps / max_fps) * (graph_size.y - 2 * margin)
		fps_points.append(Vector2(x, y))
	
	# Draw FPS line
	if fps_points.size() > 1:
		for i in range(fps_points.size() - 1):
			performance_graph.draw_line(fps_points[i], fps_points[i + 1], Color.GREEN, 2.0)
	
	# Draw FPS reference lines
	var reference_fps = [30, 60]
	for ref_fps in reference_fps:
		var y = graph_size.y - margin - (ref_fps / max_fps) * (graph_size.y - 2 * margin)
		performance_graph.draw_line(
			Vector2(margin, y), 
			Vector2(graph_size.x - margin, y), 
			Color.WHITE, 1.0, true
		)
		
		# Draw FPS label
		var font = ThemeDB.fallback_font
		performance_graph.draw_string(font, Vector2(margin + 5, y - 5), str(ref_fps), HORIZONTAL_ALIGNMENT_LEFT, -1, 12)

func _on_toggle_pressed():
	is_minimized = !is_minimized
	
	if is_minimized:
		tab_container.visible = false
		toggle_button.text = "▲"
		panel_container.custom_minimum_size.y = 50
	else:
		tab_container.visible = true
		toggle_button.text = "▼"
		panel_container.custom_minimum_size.y = 300
	
	dashboard_toggled.emit(!is_minimized)

func _on_run_tests_pressed():
	if TestFramework:
		TestFramework.run_comprehensive_tests()
		_add_test_log_entry("🧪 Running comprehensive test suite...")

func _on_stress_test_pressed():
	if TestFramework:
		TestFramework.run_test_category(TestFramework.TestType.STRESS)
		_add_test_log_entry("💪 Running stress tests...")

func _on_error_logged(error_data: Dictionary):
	_add_error_log_entry(error_data)

func _on_critical_error(error_data: Dictionary):
	_add_error_log_entry(error_data, true)
	
	# Flash the error tab to draw attention
	_flash_tab("Errors")

func _on_health_warning(component: String, issue: String, severity: float):
	_add_error_log_entry({
		"level": "WARNING",
		"category": "HEALTH",
		"message": "Health warning in %s: %s" % [component, issue],
		"timestamp": Time.get_datetime_string_from_system()
	})

func _on_performance_degradation(metric: String, current_value: float, threshold: float):
	_add_error_log_entry({
		"level": "WARNING",
		"category": "PERFORMANCE",
		"message": "Performance degradation: %s = %.2f (threshold: %.2f)" % [metric, current_value, threshold],
		"timestamp": Time.get_datetime_string_from_system()
	})

func _on_test_completed(test_name: String, success: bool, duration: float):
	var status = "✅" if success else "❌"
	_add_test_log_entry("%s %s (%.2fs)" % [status, test_name, duration])

func _on_test_suite_completed(suite_name: String, results: Dictionary):
	_add_test_log_entry("📋 %s suite completed" % suite_name)

func _add_error_log_entry(error_data: Dictionary, is_critical: bool = false):
	var entry = Label.new()
	var level = error_data.get("level", "UNKNOWN")
	var message = error_data.get("message", "No message")
	var timestamp = error_data.get("timestamp", "").split("T")[1].split(".")[0] if error_data.has("timestamp") else ""
	
	entry.text = "[%s] %s: %s" % [timestamp, level, message]
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	# Color code by level
	match level:
		"DEBUG":
			entry.modulate = Color.GRAY
		"INFO":
			entry.modulate = Color.CYAN
		"WARNING":
			entry.modulate = Color.YELLOW
		"ERROR":
			entry.modulate = Color.ORANGE
		"CRITICAL":
			entry.modulate = Color.RED
	
	error_log.add_child(entry)
	
	# Limit log entries
	if error_log.get_child_count() > 50:
		error_log.get_child(0).queue_free()
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll_container = error_log.get_parent()
	if scroll_container is ScrollContainer:
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _add_test_log_entry(message: String):
	var entry = Label.new()
	var timestamp = Time.get_datetime_string_from_system().split("T")[1].split(".")[0]
	entry.text = "[%s] %s" % [timestamp, message]
	entry.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	test_log.add_child(entry)
	
	# Limit log entries
	if test_log.get_child_count() > 30:
		test_log.get_child(0).queue_free()
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll_container = test_log.get_parent()
	if scroll_container is ScrollContainer:
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value

func _flash_tab(tab_name: String):
	# Find and flash the specified tab
	for i in range(tab_container.get_tab_count()):
		if tab_container.get_tab_title(i) == tab_name:
			var original_color = tab_container.get_tab_metadata(i) if tab_container.get_tab_metadata(i) else Color.WHITE
			
			# Flash red briefly
			var tween = create_tween()
			tween.tween_method(_set_tab_color.bind(i), Color.WHITE, Color.RED, 0.2)
			tween.tween_method(_set_tab_color.bind(i), Color.RED, original_color, 0.3)
			break

func _set_tab_color(tab_index: int, color: Color):
	# Note: This would need theme customization in a real implementation
	pass

# Public API
func show_dashboard():
	visible = true
	start_monitoring()

func hide_dashboard():
	visible = false
	if update_timer:
		update_timer.stop()

func toggle_dashboard():
	if visible:
		hide_dashboard()
	else:
		show_dashboard()

# Debug command integration
func register_debug_commands():
	if DebugCmd:
		DebugCmd.register_command("show_dashboard", func(): show_dashboard(), "Show debug dashboard")
		DebugCmd.register_command("hide_dashboard", func(): hide_dashboard(), "Hide debug dashboard")
		DebugCmd.register_command("toggle_dashboard", func(): toggle_dashboard(), "Toggle debug dashboard")