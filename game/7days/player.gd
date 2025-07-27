extends CharacterBody3D

@export var move_speed = 750
@export var sprint_speed = 850
@export var jump_force = 1.0
@export var mouse_sensitivity = 0.2
@export var deceleration = 15.0
@export var max_pitch = 20.0 # degrees

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_speed = 0.0
var target_speed = 0.0
var direction = Vector3.ZERO

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
	
	# Handle speed
	target_speed = move_speed
	if is_sprinting and input_dir.y < 0:  # Only sprint when moving forward
		target_speed = sprint_speed
	
	# Smooth acceleration/deceleration
	if direction != Vector3.ZERO:
		current_speed = target_speed * delta
	else:
		current_speed = 0
	
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	
	# Calculate velocity
	if direction != Vector3.ZERO:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity = Vector3.ZERO
	
	move_and_slide()
