extends Node3D

@onready var door_map : Dictionary = {
	"Laundry"  : $LaundryDoorPivot,
	"BathroomB"  : $BathroomBDoorPivot,
	"BathroomA"  : $BathroomADoorPivot,
	"HallwayA"  : $HallwayADoorPivot,
	"BedroomB"  : $BedroomBDoorPivot,
	"BedroomA"  : $BedroomADoorPivot,
	"DiningDoor"  : $DiningDoorPivot8,
}


func toggle_door(door) -> void:
	print(door)
	if !door_map.has(door):
		return
	var pivot : Node3D = door_map[door]
	var tween = get_tree().create_tween()
	
	if pivot.rotation.y == 2:
		tween.tween_property(pivot, "rotation", Vector3(0,0,0), 1)
	else:
		tween.tween_property(pivot, "rotation", Vector3(0,2,0), 1)
		
func init_action(text : String) ->void:
	toggle_door(text)
