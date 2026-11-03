class_name StateMachine
extends Node


signal state_changed(from: StringName, to: StringName)

@export var initial_state: State

var current: State


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.player = owner as Player
			child.transition.connect(_change_state)

	await owner.ready
	if initial_state:
		_change_state(initial_state.name)


func _change_state(new_name: StringName) -> void:
	var next := get_node_or_null(String(new_name)) as State
	if next == null:
		push_error("StateMachine: stato '%s' non trovato." % new_name)
		return
	if next == current:
		return

	var previous: StringName = current.name if current else &""
	if current:
		current.exit()
	current = next
	current.enter(previous)
	state_changed.emit(previous, new_name)


func _physics_process(delta: float) -> void:
	if current:
		current.physics_update(delta)


func _unhandled_input(event: InputEvent) -> void:
	if current:
		current.handle_input(event)
