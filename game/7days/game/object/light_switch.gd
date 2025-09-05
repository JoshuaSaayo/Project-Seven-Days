extends Node3D

signal light_action

@export var room : String
@export var light_target : String
@onready var on: AudioStreamPlayer3D = $Main/On
@onready var off: AudioStreamPlayer3D = $Main/Off

var light_on : bool = true

func _ready() -> void:
	add_to_group(name)
	name = "Light||"+name

func init_action(text : String) ->void:
	toggle_light()

func toggle_light() -> void:
	light_on = !light_on
	
	if light_on:
		$Main/Anim.play("on")
		on.play()
	else:
		$Main/Anim.play_backwards("on")
		off.play()
	
	emit_signal("light_action",room,light_target,light_on)
		
