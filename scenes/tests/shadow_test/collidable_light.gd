class_name CollidableLight
extends Node3D

@export var level_container : Node3D
@export var shadow_container : Node3D
@export var max_ray_length := 1000.0

static var meshes_surfaces : Dictionary[Mesh,PackedVector3Array]
var shadows_infos : Dictionary[MeshInstance3D,MeshShadowInfo]

func add_mesh_surface(mesh:Mesh):
	if mesh in meshes_surfaces:
		return
	var seen := {}
	for s in mesh.get_surface_count():
		var verts: PackedVector3Array = mesh.surface_get_arrays(s)[Mesh.ARRAY_VERTEX]
		for vert in verts:
			seen[vert] = true
	meshes_surfaces[mesh] = PackedVector3Array(seen.keys())

func compute_mesh_shadow_info(mesh:MeshInstance3D) -> void:
	if mesh not in shadows_infos:
		add_shadow_info(mesh)
	print("mesh:",mesh.get_path(),#correct
		"\ntransform:",mesh.global_transform, #correct
		"\nlight_direction:",-global_transform.basis.z)#correct
	for p in meshes_surfaces[mesh.mesh]:#correct
		print(mesh.to_global(p))
	shadows_infos[mesh].update_shadow(
		mesh.global_transform,
		meshes_surfaces[mesh.mesh],
		global_position,
		-global_transform.basis.z,
		max_ray_length
	)

func add_shadow_info(mesh:MeshInstance3D) -> void:
	var mesh_shadow_info := MeshShadowInfo.new()
	shadow_container.add_child(mesh_shadow_info.shadow_body)
	shadows_infos[mesh] = mesh_shadow_info

@export
var transform_change_tracker: TransformChangeTracker

func _ready() -> void:
	transform_change_tracker.node_transform_changed.connect(compute_mesh_shadow_info)
	var meshes : Array[MeshInstance3D]
	meshes.assign(level_container.find_children("*","MeshInstance3D",true))
	for mesh in meshes:
		add_mesh_surface(mesh.mesh)
		transform_change_tracker.add_tracking(mesh)
		compute_mesh_shadow_info(mesh)
