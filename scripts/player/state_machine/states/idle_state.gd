extends State

func enter(_previous_state: States, _data := {}) -> void:
	#future animation
	print("idle")
	pass


func physics_update(_delta: float) -> void:

	if player.try_jump():
		transition_to(States.JUMP)
	elif not player.is_on_floor():
		transition_to(States.FALL)
	elif player.has_move_input():
		transition_to(States.MOVE)
