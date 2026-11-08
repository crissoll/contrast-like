extends State

func enter(previous_state_path: String, data := {}) -> void:
	#future animation
	print("idle")
	pass


func physics_update(delta: float) -> void:
	var dir := player.get_move_direction()

	if player.try_jump():
		transition_to(JUMP)
	elif not player.is_on_floor():
		transition_to(FALL)
	elif player.has_move_input():
		transition_to(MOVE)
