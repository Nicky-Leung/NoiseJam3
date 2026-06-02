extends Node

enum game_states {
	PASSWORD,
	FORGOT_PASSWORD,
	CAPTCHA,
	TOS
}


@onready var enter_password_scene = load("res://scenes/in_game_menus/enter_password.tscn")
@onready var forgot_password_scene = load("res://scenes/in_game_menus/forgot_password.tscn")


@onready var current_scene: Node
@onready var ui_root: Node = $UIRoot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_game_state(game_states.PASSWORD)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_game_state(state: game_states):
	
	match state:
		game_states.PASSWORD:
			current_scene.queue_free()
			current_scene = enter_password_scene.instantiate()
			ui_root.add_child(current_scene)
		game_states.FORGOT_PASSWORD:
			current_scene.queue_free()
			current_scene = forgot_password_scene.instantiate()
			ui_root.add_child(current_scene)

		current_scene.actionrrequested.connect(func(action))
	
	