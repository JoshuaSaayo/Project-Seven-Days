extends Node

@onready var color_rect: ColorRect = $CanvasLayer/BlackScreen

var current_day : int = 1

var days : Dictionary = {
	1:{"action": "intro"},
	2:{"action": "random_anomaly"},
	3:{"action": "random_anomaly"},
	4:{"action": "random_anomaly"},
	5:{"action": "random_anomaly"},
	6:{"action": "random_anomaly"},
	7:{"action": "ending"},
}

var tween: Tween
var target_scene: PackedScene
var is_transitioning: bool = false
var was_paused: bool = false

func _ready():
	# Make sure the transition is visible but transparent at start
	color_rect.color = Color(0, 0, 0, 0)
	color_rect.visible = false

# Main scene change function using PackedScene
func _change_scene(scene: PackedScene, duration_transition: float = 1.0):
	if is_transitioning:
		push_warning("Transition already in progress!")
		return
	
	if scene == null:
		push_error("Scene is null!")
		return
	
	target_scene = scene
	is_transitioning = true
	
	# Store current pause state and unpause for transition
	was_paused = get_tree().paused
	get_tree().paused = false
	
	# Start the transition
	_start_transition(duration_transition)

# Overload for string path (backwards compatibility)
func _change_scene_path(scene_path: String, duration_transition: float = 1.0):
	var scene = load(scene_path) as PackedScene
	if scene:
		_change_scene(scene, duration_transition)
	else:
		push_error("Failed to load scene from path: " + scene_path)

func _start_transition(duration: float):
	color_rect.visible = true
	
	# Create new tween
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_parallel(false)  # Make sure animations happen in sequence
	
	# Fade in (half duration)
	tween.tween_method(_update_transparency, 0.0, 1.0, duration / 2.0)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# At halfway point, change scene
	tween.tween_callback(_change_scene_at_halfway)
	
	# Fade out (half duration)
	tween.tween_method(_update_transparency, 1.0, 0.0, duration / 2.0)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# Hide when complete
	tween.tween_callback(_on_transition_complete)

func _update_transparency(alpha: float):
	color_rect.color = Color(0, 0, 0, alpha)

func _change_scene_at_halfway():
	if target_scene:
		get_tree().change_scene_to_packed(target_scene)
	else:
		push_error("Target scene is null!")

func _on_transition_complete():
	color_rect.visible = false
	target_scene = null
	is_transitioning = false
	
	# Restore pause state if it was paused before transition
	if was_paused:
		get_tree().paused = true
	was_paused = false

# Additional utility functions for your global script
func get_current_day_action() -> String:
	if days.has(current_day):
		return days[current_day]["action"]
	return "random_anomaly"  # Default fallback

func advance_day():
	current_day += 1
	if current_day > days.size():
		current_day = days.size()  # Cap at last day
		print("Reached maximum day: ", current_day)

func reset_game():
	current_day = 1
	# Add any other reset logic here

# Optional: Simple fade functions for other uses (with pause handling)
func fade_in(duration: float = 1.0):
	color_rect.visible = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(_update_transparency, 0.0, 1.0, duration)
	tween.set_ease(Tween.EASE_IN_OUT)

func fade_out(duration: float = 1.0):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_method(_update_transparency, color_rect.color.a, 0.0, duration)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(_on_transition_complete)

# Function to safely pause/unpause the game
func set_game_paused(paused: bool):
	get_tree().paused = paused

func is_game_paused() -> bool:
	return get_tree().paused

# Function to change scene without affecting pause state (PackedScene version)
func _change_scene_keep_paused(scene: PackedScene, duration_transition: float = 1.0):
	if is_transitioning:
		push_warning("Transition already in progress!")
		return
	
	if scene == null:
		push_error("Scene is null!")
		return
	
	target_scene = scene
	is_transitioning = true
	
	# Start the transition without changing pause state
	_start_transition(duration_transition)

# Function to change scene without affecting pause state (string path version)
func _change_scene_keep_paused_path(scene_path: String, duration_transition: float = 1.0):
	var scene = load(scene_path) as PackedScene
	if scene:
		_change_scene_keep_paused(scene, duration_transition)
	else:
		push_error("Failed to load scene from path: " + scene_path)

# Preload common scenes for easier access
func preload_scene(scene_path: String) -> PackedScene:
	return load(scene_path) as PackedScene
