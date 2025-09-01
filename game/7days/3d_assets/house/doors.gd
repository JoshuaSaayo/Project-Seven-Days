extends Node3D

func _ready() -> void:
	add_to_group(name)
	name = "Door||"+name

func toggle_door() -> void:
	var pivot : Node3D = $door
	var tween = get_tree().create_tween()
	
	if pivot.position.x != 0:
		tween.tween_property(pivot, "position", Vector3(0,0,0), 1.5).set_trans(Tween.TRANS_SPRING)
	else:
		tween.tween_property(pivot, "position", Vector3(-4.361,0,0), 1.5).set_trans(Tween.TRANS_SPRING)
		
func init_action(text : String) ->void:
	toggle_door()
