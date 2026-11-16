extends Node

signal shadow_triggered

@export var area: Area3D

var _is_triggered := false


func _ready() -> void:
	if area == null:
		area = get_parent() as Area3D
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not _is_triggered:
		shadow_triggered.emit()
		print("hit shadow")
		_is_triggered = true


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player") and _is_triggered:
		print("shadow exited")
		_is_triggered = false
