extends "res://StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("run")
	add_state("jump")
	add_state("fall")
	add_state("wall_slide")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent._update_move_direction()
	parent._update_wall_direction()
	if state != states.wall_slide:
		parent._handle_movement()
	parent._apply_gravity(delta)
	if state == states.wall_slide:
		parent._cap_gravity_wall_slide()
		parent._handle_wall_slide_sticking()
	parent._apply_movement()
	
func _input(event):
	if [states.idle, states.run, states.wall_slide].has(state):
		if event.is_action_pressed("jump"):
			if state == states.wall_slide:
				parent.wall_jump()
			else:
				parent.jump()
			set_state(states.jump)
	if state == states.jump:
		if event.is_action_released("jump") && parent.velocity.y < parent.min_jump_velocity:
			parent.velocity.y = parent.min_jump_velocity
			set_state(states.jump)
	
func _get_transition(delta):
	match state:
		states.idle:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x != 0:
				return states.run
		states.run:
			if !parent.is_grounded:
				if parent.velocity.y < 0:
					return states.jump
				elif parent.velocity.y >= 0:
					return states.fall
			elif parent.velocity.x == 0:
				return states.idle
		states.jump:
			if parent.wall_direction != 0 && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.velocity.y >= 0:
				return states.fall
			elif parent.is_grounded:
				return states.idle
		states.fall:
			if parent.wall_direction != 0  && parent.wall_slide_cooldown.is_stopped():
				return states.wall_slide
			elif parent.is_grounded:
				return states.idle
			elif parent.velocity.y < 0:
				return states.jump
		states.wall_slide:
			if parent.is_grounded:
				return states.idle
			elif parent.wall_direction == 0:
				return states.fall
			#if parent.move_direction != parent.wall_direction:
				#return states.fall
			#elif parent.wall_direction == 0:
				#if parent.is_grounded:
					#if parent.velocity.x != 0:
						#return states.run
					#return states.idle
				#elif parent.velocity.y < 0:
					#return states.jump
				#else:
					#return states.fall
			#elif parent.is_grounded:
				#if parent.velocity.x != 0:
					#return states.run
				#return states.idle
	
	return null
	
func _enter_state(new_state, old_state):
	match new_state:
		states.wall_slide:
			parent.sprite.scale.x = -parent.wall_direction
	
func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			parent.wall_slide_cooldown.start()


func _on_WallSlideStickyTimer_timeout():
	if state == states.wall_slide:
		set_state(states.fall)
