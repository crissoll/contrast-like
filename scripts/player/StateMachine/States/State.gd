class_name State
extends Node

var player: Player
signal transition(new_state: StringName)

func enter(_previous: StringName) -> void:
	pass
	
func exit() -> void:
	pass


func handle_input(_event: InputEvent) -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
