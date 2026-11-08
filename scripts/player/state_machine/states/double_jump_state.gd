extends State

func enter(_previous_state: States, _data := {}) -> void:
	print("double jump")
	#future animation
	player.air_jump(player.strength_double_jump)


func physics_update(_delta: float) -> void:
	if check_landing():
		return
	# Only matters if max_air_jumps > 1.
	if player.wants_jump() and player.can_air_jump():
		transition_to(States.DOUBLE_JUMP)
	elif player.velocity.y <= 0.0:
		transition_to(States.FALL)
