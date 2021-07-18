extends KinematicBody2D

signal grounded_updated(is_grounded)

const UP = Vector2(0, -1)
const SLOPE_STOP = 64
var velocity = Vector2()
var move_speed = 6 * Globals.UNIT_SIZE
var gravity
var max_jump_velocity
var min_jump_velocity
var is_grounded
var is_jumping = false

var max_jump_height = 4.25 * Globals.UNIT_SIZE
var min_jump_height = 0.75 * Globals.UNIT_SIZE
var jump_duration = 0.5


onready var sprite = $AnimatedSprite
onready var raycasts = $Raycasts
onready var anim_player = $AnimationPlayer

func _ready():
	gravity = 2 * max_jump_height / pow(jump_duration, 2)
	max_jump_velocity = -sqrt(2 * gravity * max_jump_height)
	min_jump_velocity = -sqrt(2 * gravity * min_jump_height)
	
	Globals.player = self

func _physics_process(delta):
	pass
	
func _apply_gravity(delta):
	velocity.y += gravity * delta
	
func _apply_movement():
	if is_jumping && velocity.y >= 0:
		is_jumping = false
	velocity = move_and_slide(velocity, UP, SLOPE_STOP)
	var was_grounded = is_grounded
	is_grounded = _check_is_grounded()
	
	if was_grounded == null || is_grounded != was_grounded:
		emit_signal("grounded_updated", is_grounded)
	
func _handle_move_input():
	var move_direction = -int(Input.is_action_pressed("left")) + int(Input.is_action_pressed("right"))
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		sprite.scale.x = move_direction
	
func _get_h_weight():
	return 0.2 if is_grounded else 0.1

func _check_is_grounded():
	for raycast in raycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
	
func _assign_animation():
	var anim = "idle"
	if !is_grounded:
		anim = "jump"
	elif velocity.x != 0:
		anim = "run"
		
	if anim_player.assigned_animation != anim:
		anim_player.play(anim)
