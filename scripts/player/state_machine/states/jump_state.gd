extends State


func enter(_previous_state: States, _data := {}) -> void:
	print("jump")
	#future animation
	pass


func physics_update(_delta: float) -> void:

	if player.velocity.y > 0 and not player.is_jump_held():
		gravity_scale = player.jump_interrupted_gravity_multiplier
	else:
		gravity_scale = 1.0

	if check_landing():
		return
	if player.wants_jump() and player.can_air_jump():
		transition_to(States.DOUBLE_JUMP)
	elif player.velocity.y <= 0.0:
		transition_to(States.FALL)
