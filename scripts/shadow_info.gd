class_name MeshShadowInfo
extends RefCounted

var shadow_body: StaticBody3D
var shadow_collision: CollisionShape3D
var shadow_shape : ConvexPolygonShape3D

func _init() -> void:
	shadow_shape = ConvexPolygonShape3D.new()
	shadow_collision = CollisionShape3D.new()
	shadow_collision.shape = shadow_shape
	shadow_body = StaticBody3D.new()
	shadow_body.collision_layer = Utils.CollisionLayers.COLLIDABLE_SHADOW
	shadow_body.add_child(shadow_collision)

##returns a PackedVector3Array containing:[br]
## - from index 0 to vertex_count-1 the vertices of the projected shadow [br]
## - from vertex_count to 2*vertex_count-1 the vertices of the original mesh IF THE EXTRUSION VECTOR DIRECTION IS ZERO, [br]otherwise it returns the projected vertices shifted by the vector direction, obtaining a slab.
func update_shadow(
	mesh_transform:Transform3D,
	unique_vertices: PackedVector3Array,
	light_position: Vector3,
	light_direction: Vector3,
	max_ray_length: float
) -> void:
	shadow_body.global_position = mesh_transform.origin

	var vertex_count := unique_vertices.size()
	var projected_points := PackedVector3Array()
	projected_points.resize(vertex_count * 2)

	var space := shadow_body.get_world_3d().direct_space_state
	var dir := light_direction

	for i in vertex_count:
		var vertex_global_pos := mesh_transform * unique_vertices[i]
		dir = (vertex_global_pos - light_position).normalized() ## add DirectionalLight support!!!!
		
		var farthest_possible_position := vertex_global_pos + dir * max_ray_length
		var hit := _get_hit_dict(space,vertex_global_pos,farthest_possible_position)
		var wall_normal := Vector3.ZERO
		
		if(hit.is_empty()):
			projected_points[i] = farthest_possible_position - mesh_transform.origin
		else:
			wall_normal = hit["normal"]
			wall_normal.y = 0
			projected_points[i] = hit.position - mesh_transform.origin
		
		projected_points[vertex_count + i] = _extrusion_point(
			mesh_transform.origin,
			vertex_global_pos,
			projected_points[i],
			wall_normal)

	shadow_shape.points = projected_points

func _get_hit_dict(
		space: PhysicsDirectSpaceState3D,
		from: Vector3,
		to : Vector3,
	) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(
		from,
		to,
		Utils.CollisionLayers.WALLS_SHADOW_RECEIVER
	)
	return space.intersect_ray(query)


func _extrusion_point(
		origin: Vector3,
		vertex_global_position: Vector3,
		vertex_shadow_global_position: Vector3,
		wall_normal: Vector3,
	) -> Vector3:
	if wall_normal == Vector3.ZERO:
		return vertex_global_position - origin
	return vertex_shadow_global_position + wall_normal
