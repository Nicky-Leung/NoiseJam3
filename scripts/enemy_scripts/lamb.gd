extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask = PHYS_LAYERS.TERRAIN + PHYS_LAYERS.PLAYER
	collision_layer = PHYS_LAYERS.ENEMY
	if collides_with_others: collision_mask += PHYS_LAYERS.ENEMY

	z_index = 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if ai_state == State.PATROL:
		patrol(delta)
		rotation = move_toward(rotation, 0, delta * turn_rate)
	if patrol_path.progress_ratio >= 0.95:
		ai_state = State.CHASE
		chase_target = player

	if in_light and ai_state == State.CHASE:
		# print ("Lamb spotted player and is now chasing!")
		# move_away_from_player(delta)
		move_away_from_player(delta)
	super(delta)



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
				print("Lamb is trying to move away from player to position: ", candidate_position)
				return move_to(delta, candidate_position)
	velocity = velocity.lerp(away_direction * base_speed, acceleration * delta)
	move_and_slide()
	turn_process(delta)
	return false



func _on_dungeon_door_animation_finished() -> void:
	ai_state = State.PATROL
	global_position = patrol_path.global_position


func _on_dungeon_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
