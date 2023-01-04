class_name Player
extends CharacterBody3D

const GROUND_SPEED = 3
const AIR_SPEED = 3
const MAX_AIR_SPEED = 5
const MAX_GROUND_SPEED = 6

const JUMP_VELOCITY = 10
const MAX_AIR_VELOCITY = 8.0

const CAMERA_ROTATE_SPEED = 0.004
var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

var score := 0
var is_running := false

var input_dir := Vector2.ZERO # input direction (WASD)
@export var direction := Vector3.ZERO # actual movement direction
var facing_dir := Vector3.ZERO # Camera facing direction

@export var synced_position := Vector3.ZERO
@export var synced_direction := Vector3.ZERO
# Velocity is needed to determine animation
@export var synced_velocity := Vector3.ZERO

func _ready():
	FunctionCallTest.room_joined.connect(
		func(room_id, peer_id): 
			%PeerIdLabel.text = str(FunctionCallTest.peer_id)
			name = str(FunctionCallTest.peer_id)
			print("ROOM JOINED %d" % peer_id)
			set_multiplayer_authority(peer_id)
	)
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_ALT and event.pressed:
			if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if event is InputEventMouseMotion:
		# rotate horizontally around player
		%SpringArm.rotate(
			transform.basis.y, 
			-event.relative.x * CAMERA_ROTATE_SPEED
			)
		# rotate vertically around player		
		%SpringArm.rotate(
			%SpringArm.transform.basis.z\
			.cross(transform.basis.y).normalized(), 
			event.relative.y * CAMERA_ROTATE_SPEED
		)
		%SpringArm.rotation.x = clamp(%SpringArm.rotation.x, -PI/4, PI/4)

func _physics_process(delta):
	is_running = velocity.length() > 0.1 
	%AnimationTree.set("parameters/conditions/is_running", is_running)
	%AnimationTree.set("parameters/conditions/not_is_running", !is_running)
	# Sync position, rotation, and animation with authority
	if !is_multiplayer_authority():
		global_position = synced_position
		direction = synced_direction
		
		# Velocity is needed to determine animation
		velocity = synced_velocity
		# Sync model rotation with authority
		if direction:
			var xform: Transform3D = global_transform
			xform = xform.looking_at(xform.origin + direction)
			%Person.global_transform = %Person.global_transform.interpolate_with(xform, 0.15)
		return
	var xform: Transform3D = global_transform
	input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	
	# Determine facing, input direction according to camera view
	facing_dir = -Plane.PLANE_XZ.project(%SpringArm.transform.basis.z).normalized()
	var side_dir = -facing_dir.cross(Vector3.UP).normalized()
	direction = (facing_dir*input_dir.y - side_dir*input_dir.x).normalized()
	
	var speed = GROUND_SPEED if is_on_floor() else AIR_SPEED
	var max_speed = MAX_GROUND_SPEED if is_on_floor() else MAX_AIR_SPEED
	if direction:
		# turn model to walking direction
		xform = xform.looking_at(xform.origin + direction)
		%Person.global_transform = %Person.global_transform.interpolate_with(xform, 0.15)
		# interpolate speed
		velocity.x = move_toward(velocity.x, direction.x*max_speed, speed)
		velocity.z = move_toward(velocity.z, direction.z*max_speed, speed)
	else:
		# interpolate speed to stop
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	
	# sync properties to peers
	synced_position = global_position
	synced_direction = direction
	synced_velocity = velocity
	
	%SpeedLabel.text = "Velocity: (%.2f,%.2f,%f.2)\nDirection: (%.2f, %.2f, %.2f)" % [velocity.x,velocity.y,velocity.z, direction.x, direction.y, direction.z]
