extends Node3D

@onready var dialogue_box: Control = $DialogueBox

@onready var light_switches: Node3D = $Main/LightSwitches

func _ready() -> void:
	if Globals.current_day == 1:
		toggle_all_lights() 
		play_dialogue("intro")
	
func toggle_all_lights() -> void:
	var children = light_switches.get_children()
	for child in children:
		if child.has_method("toggle_light"):
			child.toggle_light()

func play_dialogue(dialog_key) -> void:
	dialogue_box.set_new_dialogue(dialog_key)
