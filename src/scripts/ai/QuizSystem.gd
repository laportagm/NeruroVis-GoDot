## QuizSystem.gd
## Interactive quiz system for NeuroVis educational platform
##
## This system generates and manages quizzes to test user knowledge
## of brain anatomy and functions with adaptive difficulty.
##
## @tutorial: Educational assessment system
## @version: 1.0

class_name QuizSystem
extends Node

# === SIGNALS ===
signal quiz_started(quiz_data: Dictionary)
signal question_answered(correct: bool, question_id: String)
signal quiz_completed(score: float, topic: String)
signal hint_requested(hint: String)

# === ENUMS ===
enum QuestionType {
	MULTIPLE_CHOICE,
	TRUE_FALSE,
	IDENTIFICATION,
	CLINICAL_CASE
}

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	EXPERT
}

# === CONSTANTS ===
const QUIZ_DATA_FILE = "res://data/quiz_database.json"
const MIN_QUESTIONS_PER_QUIZ = 5
const MAX_QUESTIONS_PER_QUIZ = 10
const HINT_PENALTY = 0.25  # Score reduction for using hints

# === PRIVATE VARIABLES ===
var _quiz_database: Dictionary = {}
var _active_quiz: Dictionary = {}
var _current_question_index: int = 0
var _quiz_results: Array = []
var _hints_used: int = 0

# === INITIALIZATION ===
func _ready() -> void:
	print("[QuizSystem] Initializing quiz system")
	_load_quiz_database()
	_initialize_default_questions()

func _load_quiz_database() -> void:
	## Load quiz questions from file
	if FileAccess.file_exists(QUIZ_DATA_FILE):
		var file = FileAccess.open(QUIZ_DATA_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				_quiz_database = json.data
				print("[QuizSystem] Loaded quiz database")
			else:
				push_error("[QuizSystem] Failed to parse quiz database")
	else:
		print("[QuizSystem] No quiz database found, using defaults")

func _initialize_default_questions() -> void:
	## Initialize default quiz questions if none loaded
	if _quiz_database.is_empty():
		_quiz_database = {
			"hippocampus": {
				"questions": [
					{
						"id": "hipp_001",
						"type": QuestionType.MULTIPLE_CHOICE,
						"difficulty": Difficulty.EASY,
						"question": "What is the primary function of the hippocampus?",
						"options": ["Memory formation", "Motor control", "Vision processing", "Hormone production"],
						"correct": 0,
						"explanation": "The hippocampus is crucial for forming new memories and spatial navigation.",
						"hint": "Think about what you need to remember locations..."
					},
					{
						"id": "hipp_002",
						"type": QuestionType.TRUE_FALSE,
						"difficulty": Difficulty.MEDIUM,
						"question": "The hippocampus is part of the limbic system.",
						"correct": true,
						"explanation": "Yes, the hippocampus is a major component of the limbic system.",
						"hint": "The limbic system deals with emotions and memory..."
					},
					{
						"id": "hipp_003",
						"type": QuestionType.CLINICAL_CASE,
						"difficulty": Difficulty.HARD,
						"question": "A patient with bilateral hippocampal damage would most likely experience:",
						"options": ["Anterograde amnesia", "Blindness", "Paralysis", "Loss of speech"],
						"correct": 0,
						"explanation": "Bilateral hippocampal damage causes severe anterograde amnesia (inability to form new memories).",
						"hint": "Consider the case of patient H.M..."
					}
				]
			},
			"frontal_lobe": {
				"questions": [
					{
						"id": "front_001",
						"type": QuestionType.MULTIPLE_CHOICE,
						"difficulty": Difficulty.EASY,
						"question": "Which area in the frontal lobe is responsible for speech production?",
						"options": ["Broca's area", "Wernicke's area", "Primary motor cortex", "Prefrontal cortex"],
						"correct": 0,
						"explanation": "Broca's area in the left frontal lobe is responsible for speech production.",
						"hint": "This area is named after a French physician..."
					},
					{
						"id": "front_002",
						"type": QuestionType.IDENTIFICATION,
						"difficulty": Difficulty.MEDIUM,
						"question": "Identify the gyrus immediately anterior to the central sulcus.",
						"correct": "precentral gyrus",
						"explanation": "The precentral gyrus contains the primary motor cortex.",
						"hint": "This gyrus controls voluntary movements..."
					}
				]
			},
			"general": {
				"questions": [
					{
						"id": "gen_001",
						"type": QuestionType.MULTIPLE_CHOICE,
						"difficulty": Difficulty.EASY,
						"question": "How many lobes does each cerebral hemisphere have?",
						"options": ["3", "4", "5", "6"],
						"correct": 1,
						"explanation": "Each hemisphere has 4 lobes: frontal, parietal, temporal, and occipital.",
						"hint": "Count the major divisions you can see on the lateral surface..."
					}
				]
			}
		}

# === PUBLIC API ===
func generate_quiz(topic: String, level: int, num_questions: int = 5) -> Dictionary:
	## Generate a quiz based on topic and difficulty level
	var questions = _get_questions_for_topic(topic, level)
	
	# Shuffle and limit questions
	questions.shuffle()
	if questions.size() > num_questions:
		questions = questions.slice(0, num_questions)
	
	# Create quiz data
	var quiz = {
		"topic": topic,
		"difficulty": level,
		"questions": questions,
		"created_at": Time.get_ticks_msec(),
		"time_limit": num_questions * 60  # 1 minute per question
	}
	
	return quiz

func present_quiz(quiz_data: Dictionary) -> void:
	## Start presenting a quiz to the user
	_active_quiz = quiz_data
	_current_question_index = 0
	_quiz_results.clear()
	_hints_used = 0
	
	quiz_started.emit(quiz_data)
	
	# Present first question
	if not _active_quiz.questions.is_empty():
		_present_current_question()

func answer_question(answer) -> void:
	## Process user's answer to current question
	if _active_quiz.is_empty() or _current_question_index >= _active_quiz.questions.size():
		return
	
	var question = _active_quiz.questions[_current_question_index]
	var is_correct = _check_answer(question, answer)
	
	# Record result
	_quiz_results.append({
		"question_id": question.id,
		"correct": is_correct,
		"user_answer": answer,
		"time_taken": Time.get_ticks_msec() - question.get("presented_at", 0),
		"hints_used": question.get("hints_used", 0) > 0
	})
	
	question_answered.emit(is_correct, question.id)
	
	# Move to next question or complete quiz
	_current_question_index += 1
	if _current_question_index < _active_quiz.questions.size():
		_present_current_question()
	else:
		_complete_quiz()

func request_hint() -> void:
	## Provide a hint for the current question
	if _active_quiz.is_empty() or _current_question_index >= _active_quiz.questions.size():
		return
	
	var question = _active_quiz.questions[_current_question_index]
	var hint = question.get("hint", "No hint available for this question.")
	
	# Track hint usage
	_hints_used += 1
	question["hints_used"] = question.get("hints_used", 0) + 1
	
	hint_requested.emit(hint)

func skip_question() -> void:
	## Skip current question (counts as incorrect)
	answer_question(null)

func get_current_question() -> Dictionary:
	## Get the current question being presented
	if _active_quiz.is_empty() or _current_question_index >= _active_quiz.questions.size():
		return {}
	
	return _active_quiz.questions[_current_question_index]

func get_quiz_progress() -> Dictionary:
	## Get current quiz progress
	return {
		"current": _current_question_index + 1,
		"total": _active_quiz.questions.size() if not _active_quiz.is_empty() else 0,
		"answered": _quiz_results.size(),
		"correct": _quiz_results.filter(func(r): return r.correct).size()
	}

# === PRIVATE METHODS ===
func _get_questions_for_topic(topic: String, level: int) -> Array:
	## Get questions for a specific topic and difficulty
	var questions = []
	
	# Get topic-specific questions
	if _quiz_database.has(topic):
		var topic_questions = _quiz_database[topic].get("questions", [])
		for q in topic_questions:
			if q.get("difficulty", 0) <= level:
				questions.append(q.duplicate(true))
	
	# Add general questions if needed
	if questions.size() < MIN_QUESTIONS_PER_QUIZ and _quiz_database.has("general"):
		var general_questions = _quiz_database["general"].get("questions", [])
		for q in general_questions:
			if q.get("difficulty", 0) <= level:
				questions.append(q.duplicate(true))
	
	# Generate dynamic questions if still not enough
	while questions.size() < MIN_QUESTIONS_PER_QUIZ:
		questions.append(_generate_dynamic_question(topic, level))
	
	return questions

func _generate_dynamic_question(topic: String, level: int) -> Dictionary:
	## Generate a question dynamically based on topic
	# Simple dynamic question generation
	var templates = [
		{
			"template": "What is the main function of the %s?",
			"type": QuestionType.MULTIPLE_CHOICE,
			"options_template": ["Function A", "Function B", "Function C", "Function D"]
		},
		{
			"template": "The %s is located in which part of the brain?",
			"type": QuestionType.MULTIPLE_CHOICE,
			"options_template": ["Frontal lobe", "Parietal lobe", "Temporal lobe", "Occipital lobe"]
		}
	]
	
	var template = templates[randi() % templates.size()]
	
	return {
		"id": "dynamic_%d" % Time.get_ticks_msec(),
		"type": template.type,
		"difficulty": level,
		"question": template.template % topic.capitalize().replace("_", " "),
		"options": template.options_template,
		"correct": randi() % 4,
		"explanation": "This is a dynamically generated question.",
		"hint": "Think about what you've learned about the %s." % topic
	}

func _present_current_question() -> void:
	## Present the current question to the user
	var question = _active_quiz.questions[_current_question_index]
	question["presented_at"] = Time.get_ticks_msec()
	
	# Emit signal or update UI
	# This would typically update a UI panel with the question
	print("[QuizSystem] Presenting question: %s" % question.question)

func _check_answer(question: Dictionary, answer) -> bool:
	## Check if the answer is correct
	match question.type:
		QuestionType.MULTIPLE_CHOICE:
			return answer == question.correct
		QuestionType.TRUE_FALSE:
			return answer == question.correct
		QuestionType.IDENTIFICATION:
			# Case-insensitive string comparison
			if answer is String and question.correct is String:
				return answer.to_lower().strip_edges() == question.correct.to_lower()
		QuestionType.CLINICAL_CASE:
			return answer == question.correct
	
	return false

func _complete_quiz() -> void:
	## Complete the current quiz and calculate score
	if _active_quiz.is_empty():
		return
	
	# Calculate score
	var correct_count = 0
	var total_score = 0.0
	
	for result in _quiz_results:
		if result.correct:
			correct_count += 1
			# Reduce score if hints were used
			var score = 1.0
			if result.get("hints_used", false):
				score -= HINT_PENALTY
			total_score += score
	
	var final_score = total_score / max(_active_quiz.questions.size(), 1)
	
	# Create completion data
	var completion_data = {
		"topic": _active_quiz.topic,
		"score": final_score,
		"correct": correct_count,
		"total": _active_quiz.questions.size(),
		"hints_used": _hints_used,
		"time_taken": Time.get_ticks_msec() - _active_quiz.created_at,
		"results": _quiz_results
	}
	
	# Save to history
	_save_quiz_result(completion_data)
	
	# Emit completion signal
	quiz_completed.emit(final_score, _active_quiz.topic)
	
	# Clear active quiz
	_active_quiz.clear()

func _save_quiz_result(result: Dictionary) -> void:
	## Save quiz result to user progress
	var file_path = "user://quiz_history.json"
	var history = []
	
	# Load existing history
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				history = json.data
	
	# Add new result
	result["timestamp"] = Time.get_datetime_string_from_system()
	history.append(result)
	
	# Keep only last 100 results
	if history.size() > 100:
		history = history.slice(-100)
	
	# Save updated history
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		var json = JSON.new()
		file.store_string(json.stringify(history, "\t"))
		file.close()

# === UTILITY ===
func get_quiz_statistics(topic: String = "") -> Dictionary:
	## Get statistics for quiz performance
	var stats = {
		"total_quizzes": 0,
		"average_score": 0.0,
		"best_score": 0.0,
		"total_questions": 0,
		"correct_answers": 0,
		"hints_used": 0
	}
	
	# Load quiz history
	var file = FileAccess.open("user://quiz_history.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var history = json.data
			
			for result in history:
				if topic.is_empty() or result.get("topic", "") == topic:
					stats.total_quizzes += 1
					stats.average_score += result.get("score", 0.0)
					stats.best_score = max(stats.best_score, result.get("score", 0.0))
					stats.total_questions += result.get("total", 0)
					stats.correct_answers += result.get("correct", 0)
					stats.hints_used += result.get("hints_used", 0)
			
			if stats.total_quizzes > 0:
				stats.average_score /= stats.total_quizzes
	
	return stats