extends Control

@export var text_sequence: Array[String] = [
	"",
	"",
	"",
	""
]

@export var chars_per_second: float = 20.0
@export var pause_between_texts: float = 2.0

signal sequence_finished

@onready var rich_text_label: RichTextLabel = $Main/RichTextLabel
@onready var type_timer: Timer = $Main/Timer
@onready var pause_timer: Timer = $Main/PauseTimer

var _current_text_index: int = 0


func _ready() -> void:
	type_timer.wait_time = 1.0 / chars_per_second
	pause_timer.wait_time = pause_between_texts
	pause_timer.one_shot = true
	
	type_timer.timeout.connect(_on_type_timer_timeout)
	pause_timer.timeout.connect(_on_pause_timer_timeout)
	
	start()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		if not type_timer.is_stopped():
			_skip_typing_effect()


func start() -> void:
	_current_text_index = 0
	_show_next_message()


func _show_message(text: String) -> void:
	rich_text_label.text = text
	rich_text_label.visible_characters = 0
	type_timer.start()


func _skip_typing_effect() -> void:
	type_timer.stop()
	rich_text_label.visible_characters = len(rich_text_label.text)
	pause_timer.start()


func _on_type_timer_timeout() -> void:
	rich_text_label.visible_characters += 1
	
	if rich_text_label.visible_characters >= len(rich_text_label.text):
		type_timer.stop()
		pause_timer.start()


func _on_pause_timer_timeout() -> void:
	_show_next_message()


func _show_next_message() -> void:
	if _current_text_index < text_sequence.size():
		var next_text = text_sequence[_current_text_index]
		_show_message(next_text)
		_current_text_index += 1
	else:
		print("Text sequence finished.")
		sequence_finished.emit()
