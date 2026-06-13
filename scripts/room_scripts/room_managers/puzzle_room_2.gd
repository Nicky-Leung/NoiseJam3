extends Node2D

@export var enemy_list: Array[Enemy] = []

@onready var room_listener: RoomListener = $Layout/RoomListener
@onready var enemy_reset_timer: Timer = $EnemyResetTimer

func _ready():
	room_listener.player_entered.connect(enable_enemies)
	room_listener.player_exited.connect(disable_enemies)
	enemy_reset_timer.timeout.connect(reset_enemy_positions)

func enable_enemies(player: Player):
	for enemy in enemy_list:
		enemy.chase_target = player
		enemy.toggle_active(true)
	enemy_reset_timer.stop()

func disable_enemies(_player: Player):
	for enemy in enemy_list:
		enemy.toggle_active(false)
	enemy_reset_timer.start()

func reset_enemy_positions():
	for enemy in enemy_list:
		enemy.reset_rat()
