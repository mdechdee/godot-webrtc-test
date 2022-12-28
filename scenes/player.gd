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
var direction := Vector3.ZERO # actual movement direction
var facing_dir := Vector3.ZERO # Camera facing direction

func _ready():
	pass
#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	pass
#	if event is InputEventKey:
#		if event.keycode == KEY_ALT:
#			if event.pressed:
#				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#			else:
#				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#	if event is InputEventMouseMotion:
#		# rotate horizontally around player
#		%SpringArm.rotate(
#			transform.basis.y, 
#			-event.relative.x * CAMERA_ROTATE_SPEED
#			)
#		# rotate vertically around player		
#		%SpringArm.rotate(
#			%SpringArm.transform.basis.z\
#			.cross(transform.basis.y).normalized(), 
#			event.relative.y * CAMERA_ROTATE_SPEED
#		)
#		%SpringArm.rotation.x = clamp(%SpringArm.rotation.x, -PI/4, PI/4)

func _physics_process(delta):
	var xform: Transform3D = global_transform
	input_dir = Input.get_vector("move_left", "move_right", "move_backward", "move_forward")
	
	facing_dir = -Plane.PLANE_XZ.project(%SpringArm.transform.basis.z).normalized()
	var side_dir = -facing_dir.cross(Vector3.UP).normalized()
	direction = (facing_dir*input_dir.y - side_dir*input_dir.x).normalized()
		# Ground movement
	var speed = GROUND_SPEED if is_on_floor() else AIR_SPEED
	var max_speed = MAX_GROUND_SPEED if is_on_floor() else MAX_AIR_SPEED
	if direction:
		# turn model to walking direction
		xform = xform.looking_at(xform.origin + direction)
		%Person.global_transform = %Person.global_transform.interpolate_with(xform, 0.15)
		velocity.x = move_toward(velocity.x, direction.x*max_speed, speed)
		velocity.z = move_toward(velocity.z, direction.z*max_speed, speed)
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
	%SpeedLabel.text = "Velocity: (%f,%f,%f)" % [velocity.x,velocity.y,velocity.z]
