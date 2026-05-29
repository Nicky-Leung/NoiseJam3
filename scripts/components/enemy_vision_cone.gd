extends Node2D
class_name EnemyVision

signal body_in_view(player: Player)

@export var holder: Node2D = null
@export var cone_arc: float = 45
@export var cone_length: float = 200

@onready var ray_list: Array[RayCast2D] = []

func _ready():
	# Append rays to list
	for child in get_children():
		if child is RayCast2D: ray_list.append(child as RayCast2D)

	var direction = ray_list[0].target_position.rotated(deg_to_rad(cone_arc) - global_rotation).normalized()
	for ray in ray_list:
		# set physics layers
		ray.collision_mask = PHYS_LAYERS.TERRAIN + PHYS_LAYERS.PLAYER
		# position rays
		ray.target_position = direction * cone_length
		direction = direction.rotated(deg_to_rad(cone_arc * -2 / (ray_list.size() - 1)))

func _physics_process(_delta):
	for ray in ray_list:
		var collider = ray.get_collider()
		if collider is not Player: continue
		body_in_view.emit(collider as Player)
		return
