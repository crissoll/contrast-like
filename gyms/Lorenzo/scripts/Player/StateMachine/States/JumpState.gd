extends State
var gravity_scale : float

func enter(previous_state_path: String, data := {}) -> void:
	print("jump")
	#future animation
	pass


func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()
	
	if player.velocity.y > 0:
		gravity_scale = 1.0 if player.is_jump_held() else player.jump_interrupted_gravity_multiplier
	else:
		gravity_scale = 1.0
		
	player.apply_air_movement(dir, player.walk_speed, delta)
	player.apply_gravity(delta, gravity_scale)
	player.rotate_visuals_towards(dir, delta)
	player.move_and_slide()

	if check_landing():
		return
	if player.wants_jump() and player.can_air_jump():
		transition_to(DOUBLE_JUMP)
	elif player.velocity.y <= 0.0:
		transition_to(FALL)
