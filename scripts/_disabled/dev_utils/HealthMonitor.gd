extends Node

# A1-NeuroVis Real-time System Health Monitoring
# Continuously monitors system performance, memory usage, and component health

signal health_warning(component: String, issue: String, severity: float)
signal performance_degradation(metric: String, current_value: float, threshold: float)
signal memory_leak_detected(component: String, leak_rate: float)
signal system_healthy()

enum HealthStatus {
	EXCELLENT,
	GOOD, 
	WARNING,
	CRITICAL,
	FAILED
}

static var instance: HealthMonitor
var monitoring_enabled: bool = false  # Disabled for simplified systems
var monitoring_interval: float = 30.0  # Much longer interval
var health_data: Dictionary = {}
var performance_history: Dictionary = {}
var memory_baseline: Dictionary = {}
var component_health: Dictionary = {}
var last_warning_times: Dictionary = {}  # Track when warnings were last emitted
var system_startup_time: int = 0  # Track when monitoring started

# Health thresholds
var fps_warning_threshold: float = 45.0
var fps_critical_threshold: float = 30.0
var memory_leak_threshold: float = 1024 * 1024  # 1MB per minute
var gpu_memory_warning: float = 0.8  # 80% usage

func _init():
	instance = self

func _ready():
	print("💚 HealthMonitor initialized - Starting system monitoring")
	setup_baseline_metrics()
	start_monitoring()

static func get_health_status() -> Dictionary:
	if not instance:
		return {"status": "unavailable"}
	return instance.get_current_health()

func setup_baseline_metrics():
	memory_baseline = {
		"static_memory": OS.get_static_memory_usage(),
		"timestamp": Time.get_ticks_msec()
	}
	
	component_health = {
		"camera_system": HealthStatus.GOOD,
		"model_loader": HealthStatus.GOOD,
		"ui_system": HealthStatus.GOOD,
		"knowledge_base": HealthStatus.GOOD,
		"debug_system": HealthStatus.GOOD
	}
	
	performance_history = {
		"fps": [],
		"frame_time": [],
		"memory_usage": [],
		"gpu_memory": [],
		"model_count": [],
		"ui_responsiveness": []
	}

func start_monitoring():
	if monitoring_enabled:
		system_startup_time = Time.get_ticks_msec()
		_monitoring_loop()

func _monitoring_loop():
	while monitoring_enabled:
		await get_tree().create_timer(monitoring_interval).timeout
		_collect_health_metrics()
		_analyze_health_trends()
		_check_component_health()

func _collect_health_metrics():
	var current_time = Time.get_ticks_msec()
	
	# Performance metrics
	var fps = Engine.get_frames_per_second()
	var frame_time = 1.0 / float(fps) if fps > 0 else 0.0
	
	# Memory metrics
	var memory_usage = OS.get_static_memory_usage()
	var total_memory = memory_usage
	
	# GPU metrics (approximated)
	var gpu_memory_estimate = _estimate_gpu_memory_usage()
	
	# Model metrics
	var model_count = _count_loaded_models()
	
	# UI responsiveness (frame consistency)
	var ui_responsiveness = _measure_ui_responsiveness()
	
	# Store metrics
	_store_metric("fps", fps)
	_store_metric("frame_time", frame_time)
	_store_metric("memory_usage", total_memory)
	_store_metric("gpu_memory", gpu_memory_estimate)
	_store_metric("model_count", model_count)
	_store_metric("ui_responsiveness", ui_responsiveness)
	
	# Update health data
	health_data = {
		"timestamp": current_time,
		"fps": fps,
		"frame_time": frame_time,
		"memory_usage": total_memory,
		"memory_breakdown": {"static": memory_usage, "peak": OS.get_static_memory_peak_usage()},
		"gpu_memory_estimate": gpu_memory_estimate,
		"model_count": model_count,
		"ui_responsiveness": ui_responsiveness,
		"overall_status": _calculate_overall_health()
	}

func _store_metric(metric_name: String, value: float):
	if not performance_history.has(metric_name):
		performance_history[metric_name] = []
	
	performance_history[metric_name].append({
		"value": value,
		"timestamp": Time.get_ticks_msec()
	})
	
	# Keep only last 100 entries
	if performance_history[metric_name].size() > 100:
		performance_history[metric_name].pop_front()

func _analyze_health_trends():
	# FPS analysis
	var fps_trend = _analyze_metric_trend("fps")
	if fps_trend.current < fps_critical_threshold:
		_emit_health_warning("performance", "Critical FPS drop detected", 0.9)
		performance_degradation.emit("fps", fps_trend.current, fps_critical_threshold)
		if ErrorTracker:
			ErrorTracker.log_error(ErrorTracker.ErrorLevel.ERROR, 
				ErrorTracker.ErrorCategory.PERFORMANCE,
				"Critical FPS drop: %f" % fps_trend.current)
	elif fps_trend.current < fps_warning_threshold:
		_emit_health_warning("performance", "FPS below warning threshold", 0.6)
		performance_degradation.emit("fps", fps_trend.current, fps_warning_threshold)
	
	# Memory leak detection
	var memory_trend = _analyze_metric_trend("memory_usage")
	if memory_trend.trend > memory_leak_threshold:
		_emit_memory_leak_warning("system", memory_trend.trend)
	
	# GPU memory analysis
	var gpu_trend = _analyze_metric_trend("gpu_memory")
	if gpu_trend.current > gpu_memory_warning:
		_emit_health_warning("graphics", "High GPU memory usage", 0.7)

func _analyze_metric_trend(metric_name: String) -> Dictionary:
	var history = performance_history.get(metric_name, [])
	if history.size() < 2:
		return {"current": 0.0, "trend": 0.0, "stability": 1.0}
	
	var recent_values = history.slice(-10)  # Last 10 values
	var current = recent_values[-1].value
	var previous = recent_values[0].value
	var trend = current - previous
	
	# Calculate stability (lower variance = more stable)
	var mean = 0.0
	for entry in recent_values:
		mean += entry.value
	mean /= recent_values.size()
	
	var variance = 0.0
	for entry in recent_values:
		variance += pow(entry.value - mean, 2)
	variance /= recent_values.size()
	
	var stability = 1.0 / (1.0 + variance)  # Inverse relationship
	
	return {
		"current": current,
		"trend": trend,
		"stability": stability,
		"mean": mean,
		"variance": variance
	}

func _check_component_health():
	# Camera system health
	_check_camera_health()
	
	# Model loader health
	_check_model_loader_health()
	
	# UI system health
	_check_ui_health()
	
	# Knowledge base health
	_check_knowledge_base_health()
	
	# Debug system health
	_check_debug_system_health()

func _check_camera_health():
	var camera = get_tree().get_first_node_in_group("camera_controller")
	if not camera:
		component_health["camera_system"] = HealthStatus.FAILED
		_emit_health_warning("camera_system", "Camera controller not found", 1.0)
		return
	
	# Check camera health using improved health methods
	if camera.has_method("get_health_status"):
		var health_status = camera.get_health_status()
		if not health_status.get("camera_valid", false):
			component_health["camera_system"] = HealthStatus.CRITICAL
			_emit_health_warning("camera_system", "Camera reference invalid", 0.9)
		elif not health_status.get("position_valid", false):
			component_health["camera_system"] = HealthStatus.WARNING
			_emit_health_warning("camera_system", "Camera position unusual", 0.5)
		else:
			component_health["camera_system"] = HealthStatus.GOOD
	elif camera.has_method("get_camera_transform"):
		var transform = camera.get_camera_transform()
		if transform.origin.length() > 1000.0:  # Too far from origin
			component_health["camera_system"] = HealthStatus.WARNING
			_emit_health_warning("camera_system", "Camera position unusual", 0.5)
		else:
			component_health["camera_system"] = HealthStatus.GOOD
	else:
		component_health["camera_system"] = HealthStatus.WARNING

func _check_model_loader_health():
	if not ModelSwitcherGlobal:
		component_health["model_loader"] = HealthStatus.FAILED
		_emit_health_warning("model_loader", "ModelSwitcher not available", 1.0)
		return
	
	var available_models = ModelSwitcherGlobal.get_available_models()
	if available_models.size() == 0:
		component_health["model_loader"] = HealthStatus.CRITICAL
		_emit_health_warning("model_loader", "No models available", 0.8)
	else:
		component_health["model_loader"] = HealthStatus.GOOD

func _check_ui_health():
	var ui_layer = get_tree().get_first_node_in_group("ui_layer")
	if not ui_layer:
		component_health["ui_system"] = HealthStatus.WARNING
		_emit_health_warning("ui_system", "UI layer not found", 0.6)
		return
	
	# Check UI responsiveness with more context
	var responsiveness = health_data.get("ui_responsiveness", 1.0)
	var current_fps = health_data.get("fps", 60.0)
	
	# Don't check UI responsiveness too early in system startup
	var time_since_startup = Time.get_ticks_msec() - system_startup_time
	if time_since_startup < 10000:  # Give 10 seconds for system to stabilize
		component_health["ui_system"] = HealthStatus.GOOD
		return
	
	# Only warn about UI responsiveness if it's actually problematic
	if responsiveness < 0.3:
		component_health["ui_system"] = HealthStatus.CRITICAL
		var fps_context = " (Average FPS: %.1f)" % current_fps
		_emit_health_warning("ui_system", "UI severely unresponsive" + fps_context, 0.8)
	elif responsiveness < 0.5 and current_fps < fps_warning_threshold:
		component_health["ui_system"] = HealthStatus.WARNING
		var fps_context = " (Average FPS: %.1f)" % current_fps
		_emit_health_warning("ui_system", "UI responsiveness degraded" + fps_context, 0.6)
	else:
		component_health["ui_system"] = HealthStatus.GOOD

func _check_knowledge_base_health():
	if not KB:
		component_health["knowledge_base"] = HealthStatus.FAILED
		_emit_health_warning("knowledge_base", "Knowledge base not available", 1.0)
		return
	
	# Test knowledge base access
	if KB.has_method("get_structure_count"):
		var count = KB.get_structure_count()
		if count == 0:
			component_health["knowledge_base"] = HealthStatus.CRITICAL
			_emit_health_warning("knowledge_base", "No knowledge base data", 0.8)
		else:
			component_health["knowledge_base"] = HealthStatus.GOOD
	else:
		component_health["knowledge_base"] = HealthStatus.WARNING

func _check_debug_system_health():
	if not DebugCmd:
		component_health["debug_system"] = HealthStatus.WARNING
		return
	
	component_health["debug_system"] = HealthStatus.GOOD

func _estimate_gpu_memory_usage() -> float:
	# Rough estimation based on loaded models and textures
	var model_count = _count_loaded_models()
	var estimated_per_model = 50.0 * 1024 * 1024  # 50MB per model estimate
	return (model_count * estimated_per_model) / (1024.0 * 1024 * 1024)  # Convert to GB

func _count_loaded_models() -> int:
	var count = 0
	if ModelSwitcherGlobal:
		count = ModelSwitcherGlobal.get_available_models().size()
	return count

func _measure_ui_responsiveness() -> float:
	# Measure frame consistency as a proxy for UI responsiveness
	var fps_history = performance_history.get("fps", [])
	if fps_history.size() < 5:
		return 1.0
	
	var recent_fps = fps_history.slice(-5)
	var fps_variance = 0.0
	var mean_fps = 0.0
	
	for entry in recent_fps:
		mean_fps += entry.value
	mean_fps /= recent_fps.size()
	
	# If average FPS is too low, that's the main issue, not variance
	if mean_fps < fps_critical_threshold:
		return 0.3  # Poor responsiveness due to low FPS
	elif mean_fps < fps_warning_threshold:
		return 0.7  # Moderate responsiveness due to borderline FPS
	
	for entry in recent_fps:
		fps_variance += pow(entry.value - mean_fps, 2)
	fps_variance /= recent_fps.size()
	
	# Convert variance to responsiveness score (0-1) with more realistic thresholds
	# Variance of 400 (20 FPS swing) = 0.5 responsiveness 
	# Variance of 100 (10 FPS swing) = 0.75 responsiveness
	var variance_threshold = 400.0  # More realistic threshold
	var responsiveness = clamp(1.0 - (fps_variance / variance_threshold), 0.0, 1.0)
	
	# Don't penalize good FPS with minor variance
	if mean_fps > 50.0 and fps_variance < 25.0:  # Good FPS with low variance
		return max(responsiveness, 0.8)
	
	return responsiveness

func _calculate_overall_health() -> HealthStatus:
	var health_scores = []
	for component in component_health:
		health_scores.append(component_health[component])
	
	if health_scores.has(HealthStatus.FAILED):
		return HealthStatus.FAILED
	elif health_scores.has(HealthStatus.CRITICAL):
		return HealthStatus.CRITICAL
	elif health_scores.has(HealthStatus.WARNING):
		return HealthStatus.WARNING
	else:
		var good_count = health_scores.count(HealthStatus.GOOD)
		var excellent_count = health_scores.count(HealthStatus.EXCELLENT)
		
		# Emit system healthy signal when all components are good or excellent
		system_healthy.emit()
		
		if excellent_count > good_count:
			return HealthStatus.EXCELLENT
		else:
			return HealthStatus.GOOD

func _emit_health_warning(component: String, issue: String, severity: float):
	# Throttle warnings to prevent spam (max once per 30 seconds for same issue)
	var warning_key = component + ":" + issue.split(" ")[0]  # Use first word to group similar issues
	var current_time = Time.get_ticks_msec()
	var throttle_duration = 30000  # 30 seconds in milliseconds
	
	if last_warning_times.has(warning_key):
		var time_since_last = current_time - last_warning_times[warning_key]
		if time_since_last < throttle_duration:
			return  # Skip this warning, too soon since last one
	
	last_warning_times[warning_key] = current_time
	
	health_warning.emit(component, issue, severity)
	
	if ErrorTracker:
		var level = ErrorTracker.ErrorLevel.WARNING
		if severity > 0.8:
			level = ErrorTracker.ErrorLevel.ERROR
		
		ErrorTracker.log_error(level, ErrorTracker.ErrorCategory.SYSTEM,
			"Health warning in %s: %s" % [component, issue],
			{"severity": severity, "component": component})

func _emit_memory_leak_warning(component: String, leak_rate: float):
	memory_leak_detected.emit(component, leak_rate)
	
	if ErrorTracker:
		ErrorTracker.log_error(ErrorTracker.ErrorLevel.WARNING,
			ErrorTracker.ErrorCategory.PERFORMANCE,
			"Memory leak detected in %s" % component,
			{"leak_rate_mb": leak_rate / (1024.0 * 1024.0)})

# Public API
static func get_performance_report() -> Dictionary:
	if not instance:
		return {}
	
	return {
		"current_health": instance.health_data,
		"component_status": instance.component_health,
		"performance_trends": instance._get_performance_trends(),
		"recommendations": instance._generate_recommendations()
	}

func get_current_health() -> Dictionary:
	return health_data

# Alias for compatibility with test framework
func get_system_health() -> Dictionary:
	return get_current_health()

func _get_performance_trends() -> Dictionary:
	var trends = {}
	for metric in performance_history:
		trends[metric] = _analyze_metric_trend(metric)
	return trends

func _generate_recommendations() -> Array:
	var recommendations = []
	
	# FPS recommendations
	var fps_trend = _analyze_metric_trend("fps")
	if fps_trend.current < fps_warning_threshold:
		recommendations.append("Consider reducing model complexity or disabling effects")
	
	# Memory recommendations
	var memory_trend = _analyze_metric_trend("memory_usage")
	if memory_trend.trend > 0:
		recommendations.append("Monitor for memory leaks - memory usage increasing")
	
	# GPU recommendations
	var gpu_trend = _analyze_metric_trend("gpu_memory")
	if gpu_trend.current > 0.7:
		recommendations.append("GPU memory usage high - consider texture optimization")
	
	# Component recommendations
	for component in component_health:
		if component_health[component] >= HealthStatus.WARNING:
			recommendations.append("Check %s component - showing degraded performance" % component)
	
	return recommendations

# Debug command integration
func register_debug_commands():
	if DebugCmd:
		DebugCmd.register_command("health_status", _cmd_health_status, "Show system health status")
		DebugCmd.register_command("performance_report", _cmd_performance_report, "Show detailed performance report")
		DebugCmd.register_command("toggle_monitoring", _cmd_toggle_monitoring, "Toggle health monitoring")

static func _cmd_health_status(_args: Array):
	var report = get_performance_report()
	print_rich("[color=#00FF00]💚 System Health Status[/color]")
	print("Overall status: %s" % HealthStatus.keys()[report.current_health.get("overall_status", 0)])
	print("FPS: %d" % report.current_health.get("fps", 0))
	print("Memory: %.1f MB" % (report.current_health.get("memory_usage", 0) / (1024.0*1024.0)))
	print("Models loaded: %d" % report.current_health.get("model_count", 0))
	print("UI Responsiveness: %.2f" % report.current_health.get("ui_responsiveness", 1.0))
	
	# Show FPS history for debugging if verbose flag is used
	if _args.size() > 0 and _args[0] == "verbose":
		print("\n📈 FPS History (last 5):")
		if instance and instance.performance_history.has("fps"):
			var fps_history = instance.performance_history["fps"]
			var recent = fps_history.slice(-5) if fps_history.size() >= 5 else fps_history
			for i in range(recent.size()):
				print("  [%d] %.1f FPS" % [i, recent[i].value])
		else:
			print("  No FPS history available")

static func _cmd_performance_report(_args: Array):
	var report = get_performance_report()
	print_rich("[color=#4A90E2]📊 Performance Report[/color]")
	for component in report.component_status:
		var status = HealthStatus.keys()[report.component_status[component]]
		print("%s: %s" % [component, status])

static func _cmd_toggle_monitoring(_args: Array):
	if instance:
		instance.monitoring_enabled = not instance.monitoring_enabled
		print("Health monitoring %s" % ("enabled" if instance.monitoring_enabled else "disabled"))
