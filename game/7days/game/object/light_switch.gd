extends Node3D

signal light_action

@export var room : String
@export var light_target : String

var light_on : bool = true

func _ready() -> void:
	add_to_group(name)
	name = "Light||"+name

func init_action(text : String) ->void:
	print("here")
	toggle_light()

func toggle_light() -> void:
	light_on = !light_on
	
	if light_on:
		$Main/Anim.play("on")
	else:
		$Main/Anim.play_backwards("on")
	
	emit_signal("light_action",room,light_target,light_on)
		
