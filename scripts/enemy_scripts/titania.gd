extends Enemy
class_name Titania

@onready var attack_ray: RayCast2D = $AttackRay
@onready var sprite: AnimatedSprite2D = $Sprite

func _ready():
	super()
	sprite.animation = "move"
	sprite.animation_finished.connect(_on_animation_finished)

func _process(delta):
	super(delta)
	if ai_state == State.PATROL || velocity.length() > 0:
		sprite.play()
	elif velocity.length() < 0 || !is_active:
		sprite.pause()

func _physics_process(delta: float) -> void:
	if !is_active: return
	if ai_state == State.PATROL:
		patrol(delta)
		rotation = move_toward(rotation, 0, delta * turn_rate)

	if patrol_path.progress_ratio >= 0.95:
		ai_state = State.CHASE
		chase_target = player

	if ai_state != State.CHASE: return
	if in_light: move_away_from_player(delta)
	else:
		chase(delta)
		try_damage_player()

func toggle_active(enable: bool) -> void:
	super(enable)
	ai_state = State.IDLE

func _on_animation_finished():
	if sprite.animation != "attack": return
	sprite.animation = "move"

func reset_patrol_path():
	var current_pos = global_position
	patrol_path.progress = 0
	global_position = current_pos

func try_damage_player():
	var collider = attack_ray.get_collider()
	if collider is not Player: return
	(collider as Player).attack(attack_damage, self)
	sprite.animation = "attack"

func move_away_from_player(delta: float) -> bool:
	if chase_target == null:
		return false
	var away_direction = global_position.direction_to(chase_target.global_position) * -1
	var distances = [80]
	var angles := [0.0, deg_to_rad(25), deg_to_rad(-25), deg_to_rad(50), deg_to_rad(-50), deg_to_rad(75), deg_to_rad(-75), deg_to_rad(100), deg_to_rad(-100)]

	for distance in distances:
		for angle in angles:
			var candidate_direction = away_direction.rotated(angle)
			var candidate_position = global_position + candidate_direction * distance

			nav_agent.target_position = candidate_position
			if nav_agent.is_target_reachable():
				return move_to(delta, candidate_position)
	velocity = velocity.lerp(away_direction * base_speed, acceleration * delta)
	move_and_slide()
	turn_process(delta)
	return false

func start_patrol_phase() -> void:
	ai_state = State.PATROL
	patrol_path.progress = 0
	global_position = patrol_path.global_position
