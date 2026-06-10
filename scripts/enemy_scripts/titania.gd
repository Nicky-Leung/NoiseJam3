extends Enemy
class_name Titania

func _process(delta):
	in_light = false

func _physics_process(delta: float) -> void:
	if ai_state == State.PATROL:
		patrol(delta)
		rotation = move_toward(rotation, 0, delta * turn_rate)

	if patrol_path.progress_ratio >= 0.95:
		ai_state = State.CHASE
		chase_target = player

	if ai_state != State.CHASE: return
	if in_light: move_away_from_player(delta)
	else: chase(delta)

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
