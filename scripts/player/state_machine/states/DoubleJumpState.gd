extends State

func enter(previous_state_path: String, data := {}) -> void:
	print("double jump")
	#future animation
	player.air_jump(player.strength_double_jump)


func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()
	player.apply_air_movement(dir, player.walk_speed, delta)
	player.apply_gravity(delta)
	player.rotate_visuals_towards(dir, delta)
	player.move_and_slide()

	if check_landing():
		return
	# Only matters if max_air_jumps > 1.
	if player.wants_jump() and player.can_air_jump():
		transition_to(DOUBLE_JUMP)
	elif player.velocity.y <= 0.0:
		transition_to(FALL)
