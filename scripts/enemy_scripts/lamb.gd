extends Enemy


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_mask = PHYS_LAYERS.TERRAIN + PHYS_LAYERS.PLAYER
	collision_layer = PHYS_LAYERS.ENEMY
	if collides_with_others: collision_mask += PHYS_LAYERS.ENEMY
	nav_check_stagger = randi() % frames_per_nav_check
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
	move_and_slide() # move based on previous frame values
	turn_process(delta)

	if chase_target == null || !can_check_nav(): return false
	nav_agent.target_position = global_position + global_position.direction_to(chase_target.global_position) * -50
	move_direction = global_position.direction_to(nav_agent.get_next_path_position())

	if !nav_agent.is_target_reached():
		velocity = velocity.lerp(move_direction * base_speed, acceleration * delta)
	return nav_agent.is_target_reached() || !nav_agent.is_target_reachable()




func _on_dungeon_door_animation_finished() -> void:
	ai_state = State.PATROL
	global_position = patrol_path.global_position


func _on_dungeon_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
