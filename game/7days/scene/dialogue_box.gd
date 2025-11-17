extends Control

@export var dialogue_data = [
	{"speaker": "Scribe", "text": "Lorem ipsum dolor sit amet, consectetur adipiscing elit."},
	{"speaker": "Scholar", "text": "Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."},
	{"speaker": "Scribe", "text": "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."},
	{"speaker": "Scholar", "text": "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."},
	{"speaker": "Scribe", "text": "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."}
]

@export var chars_per_second: float = 30.0
@export var pause_between_lines: float = 1.5

signal dialogue_finished

@onready var script_manager: Node = $ScriptManager
@onready var name_label: Label = $NameLabel
@onready var text_label: RichTextLabel = $RichTextLabel
@onready var type_timer: Timer = $Timer
@onready var pause_timer: Timer = $PuaseTimer

var _current_line_index: int = 0
var _is_typing: bool = false


func _ready() -> void:
	hide()
	
	type_timer.wait_time = 1.0 / chars_per_second
	pause_timer.wait_time = pause_between_lines
	pause_timer.one_shot = true
	
	type_timer.timeout.connect(_on_type_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)

func set_new_dialogue(key) -> void:
	if script_manager.dialogue_container.has(key):
		print(script_manager.dialogue_container[key])
		dialogue_data = script_manager.dialogue_container[key]
		start()

func _input(event: InputEvent) -> void:
	if visible and _is_typing:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			_skip_typing_effect()


func start() -> void:
	_current_line_index = 0
	show()
	_show_next_line()


func _show_next_line() -> void:
	if _current_line_index >= dialogue_data.size():
		dialogue_finished.emit()
		hide()
		return

	var line: Dictionary = dialogue_data[_current_line_index]
	
	name_label.text = line["speaker"]
	text_label.text = line["text"]
	
	text_label.visible_characters = 0
	_is_typing = true
	type_timer.start()


func _skip_typing_effect() -> void:
	_is_typing = false
	type_timer.stop()
	text_label.visible_characters = len(text_label.text)
	pause_timer.start()


func _on_type_timer_timeout() -> void:
	text_label.visible_characters += 1
	if text_label.visible_characters >= len(text_label.text):
		_is_typing = false
		type_timer.stop()
		pause_timer.start()


func _on_pause_timer_timeout() -> void:
	_current_line_index += 1
	_show_next_line()
