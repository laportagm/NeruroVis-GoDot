extends Node

# A1-NeuroVis Performance Profiler
# Tracks performance metrics for neural visualization
# Available globally as ProjectProfiler autoload

static var instance: Node
var performance_data = {}
var active_timers = {}

func _init():
	instance = self

static func start_timer(operation_name: String):
	if not instance:
		print("⚠️ ProjectProfiler not initialized")
		return
	
	instance.active_timers[operation_name] = Time.get_time_dict_from_system()
	print("⏱️ Timer started: ", operation_name)

static func end_timer(operation_name: String):
	if not instance:
		print("⚠️ ProjectProfiler not initialized") 
		return
		
	if operation_name not in instance.active_timers:
		print("⚠️ Timer not found: ", operation_name)
		return
	
	var start_time = instance.active_timers[operation_name]
	var end_time = Time.get_time_dict_from_system()
	var duration = end_time["unix"] - start_time["unix"]
	
	# Store performance data
	if operation_name not in instance.performance_data:
		instance.performance_data[operation_name] = []
	
	instance.performance_data[operation_name].append(duration)
	instance.active_timers.erase(operation_name)
	
	print("⏱️ Timer ended: ", operation_name, " - Duration: ", duration, "s")
	return duration

static func get_average_time(operation_name: String) -> float:
	if not instance or operation_name not in instance.performance_data:
		return 0.0
	
	var times = instance.performance_data[operation_name]
	var total = 0.0
	for time in times:
		total += time
	
	return total / float(times.size())

static func print_performance_report():
	if not instance:
		print("⚠️ ProjectProfiler not initialized")
		return
	
	print("📊 === A1-NeuroVis Performance Report ===")
	for operation_name in instance.performance_data:
		var times = instance.performance_data[operation_name]
		var avg_time = get_average_time(operation_name)
		print("  🔹 ", operation_name, ":")
		print("    - Average: ", avg_time, "s")
		print("    - Total calls: ", times.size())
		print("    - Last: ", times[-1] if times.size() > 0 else "N/A", "s")

static func clear_data():
	if instance:
		instance.performance_data.clear()
		instance.active_timers.clear()
		print("🧹 Performance data cleared")
