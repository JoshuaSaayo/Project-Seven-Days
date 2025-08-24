extends Node3D

@onready var kitchen: Node3D = $Kitchen
@onready var living_room: Node3D = $LivingRoom
@onready var ground_floor_bathroom: Node3D = $GroundFloorBathroom
@onready var master_bedroom: Node3D = $MasterBedroom
@onready var closet: Node3D = $Closet
@onready var out_door_lights: Node3D = $OutDoorLights

@onready var rooms : Dictionary = {
	"kitchen" : kitchen,
	"living_room" : living_room,
	"ground_floor_bathroom" : ground_floor_bathroom,
	"master_bedroom" : master_bedroom,
	"closet" : closet,
	"out_door_lights" : out_door_lights,
}

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	_light_room("living_room","_all_",false)
	await get_tree().create_timer(1.0).timeout
	_light_room("living_room","_all_",true)
	
	_connect_light_switches()

func _connect_light_switches() -> void:
	var children = $"../LightSwitches".get_children()
	for child in children:
		child.light_action.connect(_light_room)

func _light_room(room : String, room_light_name : String, status: bool) -> void:
	var lights = []
	
	if !rooms.has(room):
		return
	print(rooms)
	lights = rooms[room].get_children()
	
	if room_light_name == "_all_":
		for light in  lights:
			light.visible = status
	else:
		for light in  lights:
			if light.name == room_light_name:
				light.visible = status
