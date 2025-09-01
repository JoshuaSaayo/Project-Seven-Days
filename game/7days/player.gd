extends CharacterBody3D

@export var move_speed = 1000
@export var sprint_speed = 1250
@export var jump_force = 2.0
@export var mouse_sensitivity = 0.2
@export var deceleration = 15.0
@export var max_pitch = 20.0 # degrees

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = 0.0
var target_speed = 0.0
var direction = Vector3.ZERO
var force_step : bool = false

#detection
var detected_object : Array = []
var current_object  : Array = []


# Camera nodes
@onready var camera_pivot = $CameraPivot
@onready var camera = $CameraPivot/Camera3D

func _ready():
	# Hide and capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Horizontal rotation (left/right)
		rotate_y(deg_to_rad(-event.relative.x * mouse_sensitivity))
		
		# Vertical rotation (up/down) - on camera pivot
		camera_pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sensitivity))
		camera_pivot.rotation.x = clamp(
			camera_pivot.rotation.x, 
			deg_to_rad(-max_pitch), 
			deg_to_rad(max_pitch)
		)
		
	if Input.is_action_just_pressed("alt"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	# Get input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var is_sprinting = Input.is_action_pressed("sprint")
	
	# Calculate movement direction relative to character's orientation
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	#Handle action
	if Input.is_action_just_pressed("action"):
		_check_action()
	
	# Handle speed
	target_speed = move_speed
	if is_sprinting and input_dir.y < 0:  # Only sprint when moving forward
		target_speed = sprint_speed
	
	# Smooth acceleration/deceleration
	if direction != Vector3.ZERO:
		current_speed = target_speed * delta
	else:
		current_speed = 0
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	# Calculate velocity
	velocity.x = direction.x * current_speed
	velocity.z = direction.z * current_speed
	
	#if get_last_slide_collision():
		#var collision_normal = get_last_slide_collision().get_normal()
		#if collision_normal.y == clamp(collision_normal.y, 0.1, 0.9):  # Adjust threshold as needed
			#
			#velocity.y +=  0.1
			#force_step = true
			#print(velocity.y)
		#else:
			#force_step = false
	#else:
		#force_step = false
		
	
	move_and_slide()
	

func _process(delta: float) -> void:
	# Apply gravity
	
	if !is_on_floor() and !force_step:
		velocity.y -= gravity * delta

func object_checker() -> void:
	print(detected_object)
	if detected_object.is_empty():
		return
		
	if delimeter_checker(detected_object[0]):
		current_object = delimeter_checker(detected_object[0])
	else:
		detected_object.erase(detected_object[0])

func delimeter_checker(obj_name):
	if ! "||" in obj_name:
		return null
	
	var word_arr = obj_name.split("||")
	return word_arr

func _check_action() -> void:
	if current_object == []:
		return
	var node = get_tree().get_first_node_in_group(current_object[1])
	if is_instance_valid(node):
		node.init_action(current_object[0])

func _on_player_detector_area_entered(area: Area3D) -> void:
	detected_object.append(area.name)
	object_checker()

func _on_player_detector_area_exited(area: Area3D) -> void:
	detected_object.erase(area.name)
	if delimeter_checker(area.name):
		current_object = []
