extends Node3D

@onready var slide_sound: AudioStreamPlayer3D = $SlideSound

func _ready() -> void:
	add_to_group(name)
	name = "Door||"+name

func toggle_door() -> void:
	var pivot : Node3D = $door
	var tween = get_tree().create_tween()
	slide_sound.play()
	if pivot.position.x != 0:
		tween.tween_property(pivot, "position", Vector3(0,0,0), 2.2).set_trans(Tween.TRANS_SPRING)
	else:
		tween.tween_property(pivot, "position", Vector3(-4.361,0,0), 2.2).set_trans(Tween.TRANS_SPRING)
		
func init_action(text : String) ->void:
	toggle_door()
