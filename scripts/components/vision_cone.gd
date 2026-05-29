extends Node2D

signal body_in_view(body: Node2D)

enum DetectType {
	ENEMY,
	PLAYER,
	BOTH
}

@export var holder: Node2D = null
@export var cone_arc: float = 45
@export var cone_length: float = 300
@export var detect_type: DetectType = DetectType.PLAYER

@onready var ray_list: Array[RayCast2D] = []

func _ready():
	# Append rays to list
	for child in get_children():
		if child is RayCast2D: ray_list.append(child as RayCast2D)

	var direction = ray_list[0].target_position.rotated(deg_to_rad(cone_arc) - global_rotation).normalized()
	for ray in ray_list:
		# set physics layers
		ray.collision_mask = PHYS_LAYERS.TERRAIN
		ray.collision_mask += PHYS_LAYERS.ENEMY if detect_type == DetectType.ENEMY || detect_type == DetectType.BOTH else 0
		ray.collision_mask += PHYS_LAYERS.PLAYER if detect_type == DetectType.PLAYER || detect_type == DetectType.BOTH else 0

		# position rays
		ray.target_position = direction * cone_length
		direction = direction.rotated(deg_to_rad(cone_arc * -2 / (ray_list.size() - 1)))

func _physics_process(_delta):
	var encountered = []
	for ray in ray_list:
		var collider = ray.get_collider()
		if collider is Enemy && !encountered.has(collider):
			print(collider)
			encountered.append(collider)
			body_in_view.emit(collider)
			collider.alert_visual(holder)
		elif collider is Player && !encountered.has(collider):
			encountered.append(collider)
			body_in_view.emit(collider)
