extends Control

signal prompt_response(code: String, result : bool)

@onready var message_label = $Panel/Message
@onready var yes_button = $Panel/Confirm
@onready var no_button = $Panel/Decline
@onready var ok_button = $Panel/OK

var _code: String = ""

func _ready() -> void:
	hide_prompt()
	# Connect buttons
	yes_button.pressed.connect(_on_yes_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)
	ok_button.pressed.connect(_on_ok_button_pressed)

func setup(code: String, message: String, yes: String = "Yes", no: String = "No", ok: String = ""):
	_code = code
	message_label.text = message
	
	# Determine if this is a notification box or decision box
	if not ok.is_empty():
		# Notification box - only show OK button
		_setup_notification_box(ok)
	else:
		# Decision box - show Yes/No buttons
		_setup_decision_box(yes, no)

func _setup_notification_box(ok_text: String):
	yes_button.hide()
	no_button.hide()
	ok_button.show()
	ok_button.text = ok_text
	show_prompt()

func _setup_decision_box(yes_text: String, no_text: String):
	ok_button.hide()
	yes_button.show()
	no_button.show()
	
	yes_button.text = yes_text
	no_button.text = no_text
	show_prompt()
	
	# Set focus to default button (Yes)
	yes_button.grab_focus()

func show_prompt():
	show()
	# Re-grab focus when showing
	if yes_button.visible:
		yes_button.grab_focus()
	elif ok_button.visible:
		ok_button.grab_focus()

func hide_prompt():
	hide()

func _on_yes_button_pressed():
	prompt_response.emit(_code,true)
	hide_prompt()

func _on_no_button_pressed():
	prompt_response.emit(_code,false)
	hide_prompt()

func _on_ok_button_pressed():
	prompt_response.emit(_code,true)
	hide_prompt()
