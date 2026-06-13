extends Node2D
class_name PuzzleRoom1

@onready var enemies_node: Node2D = $Enemies
@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var enemy_reset_timer: Timer = $EnemyResetTimer

var enemy_start_points: Array[Vector2] = []

func _ready():
	room_listener.player_entered.connect(enable_enemies)
	room_listener.player_exited.connect(disable_enemies)
	enemy_reset_timer.timeout.connect(reset_enemy_positions)

	for enemy in enemies_node.get_children():
		if enemy is not Enemy: continue
		enemy_start_points.append(enemy.global_position)

func enable_enemies(player: Player):
	for node in enemies_node.get_children():
		if node is not Enemy: continue
		(node as Enemy).chase_target = player
		(node as Enemy).toggle_active(true)
	enemy_reset_timer.stop()

func disable_enemies(_player: Player):
	for node in enemies_node.get_children():
		if node is not Enemy: continue
		(node as Enemy).toggle_active(false)
	enemy_reset_timer.start()

func reset_enemy_positions():
	for i in range(enemy_start_points.size()):
		enemies_node.get_child(i).global_position = enemy_start_points[i]
