class_name TransformNotifier
extends Node3D

## new_transform is in global space
signal transform_changed(target:Node3D)

@onready var target := get_parent_node_3d()

func _ready() -> void:
	set_notify_transform(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED and target:
		transform_changed.emit(target)
