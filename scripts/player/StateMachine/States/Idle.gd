class_name IdleState
extends State


func handle_input(_event: InputEvent) -> void:
	if player.get_move_direction():
		transition.emit("MoveState")
