## EducationalTutor.gd
## Intelligent Educational Tutor System for NeuroVis
##
## This system provides context-aware AI tutoring that adapts to user learning
## patterns and integrates with 3D visualization for enhanced medical education.
##
## @tutorial: AI-powered educational guidance
## @version: 1.0

class_name EducationalTutor
extends Node

# === SIGNALS ===
signal learning_objective_completed(objective: String)
signal quiz_completed(score: float, topic: String)
signal guidance_provided(message: String, structure: String)
signal tour_started(pathway: String)
signal tour_step_completed(step: int, total: int)

# === ENUMS ===
enum LearningLevel {
	BEGINNER,
	INTERMEDIATE,
	ADVANCED,
	EXPERT
}

enum TutorMode {
	PASSIVE,      # Responds to questions only
	GUIDED,       # Provides hints and suggestions
	INTERACTIVE,  # Full tutoring with quizzes
	ADAPTIVE      # Adjusts to user performance
}

# === CONSTANTS ===
const LEARNING_DATA_PATH = "user://learning_progress.json"
const MIN_CONFIDENCE_THRESHOLD = 0.7
const QUIZ_PASS_THRESHOLD = 0.8

# === EXPORTS ===
@export var tutor_mode: TutorMode = TutorMode.ADAPTIVE
@export var initial_level: LearningLevel = LearningLevel.BEGINNER
@export var enable_visual_highlights: bool = true
@export var enable_progress_tracking: bool = true

# === PRIVATE VARIABLES ===
var _current_level: LearningLevel
var _learning_progress: Dictionary = {}
var _current_context: Dictionary = {}
var _active_objectives: Array = []
var _quiz_history: Array = []
var _is_tour_active: bool = false
var _tour_steps: Array = []
var _current_tour_step: int = 0

# === SERVICES ===
var ai_assistant: AIAssistantService
var knowledge_service: KnowledgeService
var selection_manager: BrainStructureSelectionManager
var learning_path_manager: LearningPathManager
var quiz_system: QuizSystem
var progress_tracker: ProgressTracker

# === INITIALIZATION ===
func _ready() -> void:
	print("[EducationalTutor] Initializing intelligent tutoring system")
	_current_level = initial_level
	_setup_services()
	_load_learning_progress()
	_initialize_learning_objectives()

func _setup_services() -> void:
	## Connect to required educational services
	# Get AI Assistant
	ai_assistant = get_node_or_null("/root/AIAssistant")
	if not ai_assistant:
		push_error("[EducationalTutor] AIAssistant service not found")
	
	# Get Knowledge Service
	knowledge_service = get_node_or_null("/root/KnowledgeService")
	if not knowledge_service:
		push_error("[EducationalTutor] KnowledgeService not found")
	
	# Initialize subsystems
	learning_path_manager = LearningPathManager.new()
	add_child(learning_path_manager)
	
	quiz_system = QuizSystem.new()
	add_child(quiz_system)
	quiz_system.quiz_completed.connect(_on_quiz_completed)
	
	progress_tracker = ProgressTracker.new()
	add_child(progress_tracker)

func _initialize_learning_objectives() -> void:
	## Set up initial learning objectives based on level
	match _current_level:
		LearningLevel.BEGINNER:
			_active_objectives = [
				"Identify major brain regions",
				"Understand basic brain anatomy",
				"Learn primary functions of each lobe"
			]
		LearningLevel.INTERMEDIATE:
			_active_objectives = [
				"Understand neural pathways",
				"Identify subcortical structures",
				"Learn clinical correlations"
			]
		LearningLevel.ADVANCED:
			_active_objectives = [
				"Master complex anatomical relationships",
				"Understand pathological conditions",
				"Apply knowledge to clinical cases"
			]

# === PUBLIC API ===
func start_learning_session(user_id: String = "default") -> void:
	## Begin a new learning session
	print("[EducationalTutor] Starting learning session for user: %s" % user_id)
	progress_tracker.start_session(user_id)
	_update_context()
	
	# Provide initial guidance
	var welcome_msg = _generate_welcome_message()
	guidance_provided.emit(welcome_msg, "")

func ask_tutor(question: String) -> void:
	## Process a question with educational context
	if not ai_assistant:
		push_error("[EducationalTutor] AI Assistant not available")
		return
	
	# Enhance question with educational context
	var enhanced_question = _enhance_question_with_context(question)
	
	# Track the question for learning analytics
	progress_tracker.record_question(question, _current_context)
	
	# Get AI response
	ai_assistant.ask_educational_question(enhanced_question, _current_context)
	ai_assistant.response_received.connect(_on_ai_response, CONNECT_ONE_SHOT)

func start_guided_tour(topic: String = "brain_overview") -> void:
	## Start an interactive guided tour
	print("[EducationalTutor] Starting guided tour: %s" % topic)
	
	_tour_steps = learning_path_manager.get_tour_steps(topic)
	_current_tour_step = 0
	_is_tour_active = true
	
	tour_started.emit(topic)
	_execute_tour_step()

func request_quiz(topic: String = "") -> void:
	## Generate and present a quiz based on current context
	if topic.is_empty() and _current_context.has("structure"):
		topic = _current_context.structure
	
	var quiz_data = quiz_system.generate_quiz(topic, _current_level)
	quiz_system.present_quiz(quiz_data)

func provide_hint() -> void:
	## Provide a contextual hint based on current activity
	var hint = _generate_contextual_hint()
	guidance_provided.emit(hint, _current_context.get("structure", ""))

func adjust_difficulty(performance_score: float) -> void:
	## Adjust learning level based on performance
	if performance_score > 0.9 and _current_level < LearningLevel.EXPERT:
		_current_level += 1
		print("[EducationalTutor] Level increased to: %s" % LearningLevel.keys()[_current_level])
	elif performance_score < 0.5 and _current_level > LearningLevel.BEGINNER:
		_current_level -= 1
		print("[EducationalTutor] Level decreased to: %s" % LearningLevel.keys()[_current_level])
	
	_initialize_learning_objectives()

# === CONTEXT MANAGEMENT ===
func update_selected_structure(structure_name: String, mesh: MeshInstance3D) -> void:
	## Update context when a structure is selected
	_current_context.structure = structure_name
	_current_context.mesh = mesh
	_current_context.timestamp = Time.get_ticks_msec()
	
	# Get educational info for the structure
	if knowledge_service:
		var info = knowledge_service.get_structure(structure_name)
		_current_context.educational_info = info
	
	# Provide contextual guidance if in guided mode
	if tutor_mode >= TutorMode.GUIDED:
		_provide_structure_guidance(structure_name)

func _update_context() -> void:
	## Update general learning context
	_current_context.level = _current_level
	_current_context.mode = tutor_mode
	_current_context.objectives = _active_objectives
	_current_context.session_duration = progress_tracker.get_session_duration()

# === EDUCATIONAL ENHANCEMENTS ===
func _enhance_question_with_context(question: String) -> String:
	## Add educational context to questions
	var enhanced = question
	
	# Add current structure context
	if _current_context.has("structure"):
		enhanced += "\n[Context: Currently viewing %s]" % _current_context.structure
	
	# Add learning level context
	enhanced += "\n[Learning Level: %s]" % LearningLevel.keys()[_current_level]
	
	# Add active objectives
	if not _active_objectives.is_empty():
		enhanced += "\n[Learning Objectives: %s]" % ", ".join(_active_objectives)
	
	return enhanced

func _generate_welcome_message() -> String:
	## Generate personalized welcome message
	var messages = {
		LearningLevel.BEGINNER: "Welcome! Let's start with the basics of brain anatomy. Select any structure to begin learning.",
		LearningLevel.INTERMEDIATE: "Welcome back! Ready to explore neural pathways and clinical correlations?",
		LearningLevel.ADVANCED: "Welcome! Let's dive into complex anatomical relationships and pathology.",
		LearningLevel.EXPERT: "Welcome, expert! Explore advanced topics and clinical case studies."
	}
	
	return messages.get(_current_level, "Welcome to NeuroVis!")

func _generate_contextual_hint() -> String:
	## Generate hints based on current context
	if _current_context.has("structure"):
		var structure = _current_context.structure
		
		# Get hint based on structure and level
		match _current_level:
			LearningLevel.BEGINNER:
				return "Try exploring the %s. Click on it to learn about its basic functions." % structure
			LearningLevel.INTERMEDIATE:
				return "Consider how the %s connects to other structures. What pathways pass through it?" % structure
			LearningLevel.ADVANCED:
				return "Think about clinical conditions affecting the %s. What symptoms would you expect?" % structure
	
	return "Select a brain structure to begin exploring."

func _provide_structure_guidance(structure_name: String) -> void:
	## Provide immediate guidance when structure is selected
	var guidance_msg = ""
	
	# Get structure info
	if knowledge_service:
		var info = knowledge_service.get_structure(structure_name)
		if not info.is_empty():
			guidance_msg = "You've selected the %s. " % info.get("displayName", structure_name)
			
			# Add level-appropriate guidance
			match _current_level:
				LearningLevel.BEGINNER:
					guidance_msg += "This structure is responsible for %s." % info.get("primaryFunction", "various functions")
				LearningLevel.INTERMEDIATE:
					var connections = info.get("connections", [])
					if not connections.is_empty():
						guidance_msg += "It connects to: %s." % ", ".join(connections.slice(0, 3))
				LearningLevel.ADVANCED:
					var clinical = info.get("clinicalRelevance", "")
					if clinical:
						guidance_msg += "Clinically important for: %s" % clinical
	
	if guidance_msg:
		guidance_provided.emit(guidance_msg, structure_name)

# === GUIDED TOUR SYSTEM ===
func _execute_tour_step() -> void:
	## Execute current step in guided tour
	if not _is_tour_active or _current_tour_step >= _tour_steps.size():
		_complete_tour()
		return
	
	var step = _tour_steps[_current_tour_step]
	
	# Highlight structure if visual highlights enabled
	if enable_visual_highlights and step.has("structure"):
		_highlight_structure(step.structure)
	
	# Provide narration
	guidance_provided.emit(step.get("narration", ""), step.get("structure", ""))
	
	# Wait for user interaction or timeout
	await get_tree().create_timer(step.get("duration", 5.0)).timeout
	
	tour_step_completed.emit(_current_tour_step + 1, _tour_steps.size())

func next_tour_step() -> void:
	## Move to next step in tour
	if _is_tour_active:
		_current_tour_step += 1
		_execute_tour_step()

func _complete_tour() -> void:
	## Complete the guided tour
	_is_tour_active = false
	print("[EducationalTutor] Tour completed")
	
	# Record completion
	progress_tracker.record_tour_completion(_tour_steps[0].get("topic", "unknown"))
	
	# Provide summary
	guidance_provided.emit("Tour completed! Great job exploring the brain structures.", "")

func _highlight_structure(structure_name: String) -> void:
	## Highlight a structure in the 3D view
	if selection_manager:
		selection_manager.highlight_structure_by_name(structure_name)

# === QUIZ HANDLING ===
func _on_quiz_completed(score: float, topic: String) -> void:
	## Handle quiz completion
	print("[EducationalTutor] Quiz completed - Topic: %s, Score: %.1f%%" % [topic, score * 100])
	
	_quiz_history.append({
		"topic": topic,
		"score": score,
		"level": _current_level,
		"timestamp": Time.get_ticks_msec()
	})
	
	# Adjust difficulty based on performance
	if tutor_mode == TutorMode.ADAPTIVE:
		adjust_difficulty(score)
	
	# Record progress
	progress_tracker.record_quiz_result(topic, score, _current_level)
	
	# Emit completion signal
	quiz_completed.emit(score, topic)
	
	# Provide feedback
	var feedback = _generate_quiz_feedback(score)
	guidance_provided.emit(feedback, "")

func _generate_quiz_feedback(score: float) -> String:
	## Generate feedback based on quiz performance
	if score >= 0.9:
		return "Excellent work! You've mastered this topic. Ready for more advanced content?"
	elif score >= QUIZ_PASS_THRESHOLD:
		return "Good job! You've demonstrated solid understanding. Let's reinforce with more practice."
	elif score >= 0.6:
		return "Not bad! Review the incorrect answers and try again when ready."
	else:
		return "Let's review this topic together. I'll provide more guidance as we go."

# === AI RESPONSE HANDLING ===
func _on_ai_response(question: String, response: String) -> void:
	## Process AI response with educational enhancements
	# Add educational annotations
	var enhanced_response = _add_educational_annotations(response)
	
	# Track learning progress
	progress_tracker.record_interaction(question, enhanced_response)
	
	# Check for learning objective completion
	_check_objective_completion(question, response)
	
	# Provide the enhanced response
	guidance_provided.emit(enhanced_response, _current_context.get("structure", ""))

func _add_educational_annotations(response: String) -> String:
	## Add educational annotations to AI responses
	var annotated = response
	
	# Add difficulty indicator
	annotated = "[%s] %s" % [LearningLevel.keys()[_current_level], annotated]
	
	# Add related learning objectives
	for objective in _active_objectives:
		if response.to_lower().contains(objective.to_lower().split(" ")[0]):
			annotated += "\n📚 Related objective: %s" % objective
			break
	
	# Add study tips based on level
	if _current_level == LearningLevel.BEGINNER:
		annotated += "\n💡 Tip: Focus on identifying and naming structures first."
	elif _current_level == LearningLevel.INTERMEDIATE:
		annotated += "\n💡 Tip: Consider how structures work together."
	
	return annotated

func _check_objective_completion(question: String, response: String) -> void:
	## Check if learning objectives are being met
	for objective in _active_objectives:
		var keywords = objective.split(" ")
		var matches = 0
		
		for keyword in keywords:
			if keyword.length() > 3:  # Skip short words
				if question.to_lower().contains(keyword.to_lower()) or \
				   response.to_lower().contains(keyword.to_lower()):
					matches += 1
		
		# If enough keywords match, consider objective addressed
		var match_ratio = float(matches) / float(keywords.size())
		if match_ratio > 0.6:
			progress_tracker.record_objective_progress(objective, 0.2)  # 20% progress
			
			# Check if objective is completed
			var progress = progress_tracker.get_objective_progress(objective)
			if progress >= 1.0:
				learning_objective_completed.emit(objective)
				_active_objectives.erase(objective)

# === PERSISTENCE ===
func _load_learning_progress() -> void:
	## Load saved learning progress
	var file = FileAccess.open(LEARNING_DATA_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			_learning_progress = json.data
			
			# Restore level
			if _learning_progress.has("current_level"):
				_current_level = _learning_progress.current_level
			
			# Restore objectives progress
			if _learning_progress.has("objectives_progress"):
				progress_tracker.restore_progress(_learning_progress.objectives_progress)
			
			print("[EducationalTutor] Loaded learning progress")
	else:
		print("[EducationalTutor] No previous learning progress found")

func save_learning_progress() -> void:
	## Save current learning progress
	_learning_progress = {
		"current_level": _current_level,
		"objectives_progress": progress_tracker.get_all_progress(),
		"quiz_history": _quiz_history,
		"last_saved": Time.get_datetime_string_from_system()
	}
	
	var file = FileAccess.open(LEARNING_DATA_PATH, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(_learning_progress, "\t"))
		file.close()
		print("[EducationalTutor] Saved learning progress")

# === UTILITY ===
func get_learning_stats() -> Dictionary:
	## Get comprehensive learning statistics
	return {
		"current_level": LearningLevel.keys()[_current_level],
		"session_duration": progress_tracker.get_session_duration(),
		"questions_asked": progress_tracker.get_question_count(),
		"objectives_completed": progress_tracker.get_completed_objectives().size(),
		"quiz_average": _calculate_quiz_average(),
		"tutor_mode": TutorMode.keys()[tutor_mode]
	}

func _calculate_quiz_average() -> float:
	## Calculate average quiz score
	if _quiz_history.is_empty():
		return 0.0
	
	var total = 0.0
	for quiz in _quiz_history:
		total += quiz.score
	
	return total / _quiz_history.size()

func _exit_tree() -> void:
	## Clean up when exiting
	save_learning_progress()