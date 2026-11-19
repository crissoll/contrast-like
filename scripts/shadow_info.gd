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
## - from index 0 to n-1 the vertices of the projected shadow [br]
## - from n to 2n-1 the vertices of the original mesh IF THE EXTRUSION VECTOR DIRECTION IS ZERO, [br]otherwise it returns the projected vertices shifted by the vector direction, obtaining a slab.
func update_shadow(
	mesh_transform:Transform3D,
	unique_vertices: PackedVector3Array,
	light_position: Vector3,
	light_direction: Vector3,
	max_ray_length: float
) -> void:
	shadow_body.global_position = mesh_transform.origin

	var n := unique_vertices.size()
	var projected_points := PackedVector3Array()
	projected_points.resize(n * 2)

	var space := shadow_body.get_world_3d().direct_space_state
	var dir := light_direction

	for i in n:
		var p := mesh_transform * unique_vertices[i]
		dir = (p - light_position).normalized() ## add DirectionalLight support!!!!
		projected_points[i] = _intersection_point(
			space,
			mesh_transform.origin, # correct
			p, 
			dir, # WRONG!!!!!
			max_ray_length) # correct
		
		projected_points[n + i] = _extrusion_point(
			mesh_transform.origin,
			p,
			projected_points[i])

	shadow_shape.points = projected_points


func _intersection_point(
	space: PhysicsDirectSpaceState3D,
	origin: Vector3,
	from: Vector3,
	dir: Vector3,
	max_ray_length: float
) -> Vector3:
	var to := from + dir * max_ray_length
	var query := PhysicsRayQueryParameters3D.create(
		from,
		to,
		Utils.CollisionLayers.WALLS_SHADOW_RECEIVER
	)
	var hit := space.intersect_ray(query)
	print("from:",from)
	print("to:",to)
	print("dir:",dir)
	var hit_pos: Vector3
	if hit.is_empty():
		hit_pos = to - origin
	else:
		hit_pos = hit.position - origin
	print(hit_pos)
	return hit_pos

func _extrusion_point(
	origin: Vector3,
	vertex_world: Vector3,
	shadow_point_rel: Vector3
) -> Vector3:
	var extrusion_direction := Vector3(0, 0, 0.5)
	if extrusion_direction == Vector3.ZERO:
		return vertex_world - origin
	return shadow_point_rel + extrusion_direction
