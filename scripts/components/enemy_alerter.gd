extends Area2D
class_name EnemyAlerter

enum Type {
	SOUND, ## Player sound
	VISUAL, ## Player flashlight
}

@export var alerter_shape: Shape2D = null
@export var player: Player = null ## Leave empty for light type
@export var type: Type = Type.SOUND

@onready var in_range_enemies: Array[Enemy] = []
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var shape: Shape2D:
	get: return hitbox.shape

func _ready():
	hitbox.shape = alerter_shape if alerter_shape != null else hitbox.shape
	body_entered.connect(on_body_entered)
	body_exited.connect(on_body_exited)

func _physics_process(_delta):
	if type == Type.SOUND: return
	for enemy in in_range_enemies:
		if in_view(enemy): enemy.alert_visual(player)
		else: enemy.alert_no_visual()

func enable(do_enable: bool):
	monitoring = do_enable
	if !do_enable:
		for enemy in in_range_enemies:
			enemy.alert_no_visual()
		in_range_enemies.clear()

func on_body_entered(body: Node2D):
	if body is not Enemy: return
	if type == Type.SOUND: body.alert_sound(player)
	else: in_range_enemies.append(body as Enemy)

func on_body_exited(body: Node2D):
	if body is not Enemy || type == Type.SOUND: return
	(body as Enemy).alert_no_visual()
	in_range_enemies.remove_at(in_range_enemies.find(body as Enemy))

func in_view(enemy: Enemy) -> bool:
	var test_point = global_position if player == null else player.global_position
	var space2d = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(test_point, enemy.global_position, PHYS_LAYERS.TERRAIN)
	return space2d.intersect_ray(query).is_empty()
