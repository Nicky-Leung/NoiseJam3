extends Node


@onready var enter_password_scene = load("res://scenes/in_game_menus/enter_password.tscn")
@onready var forgot_password_scene = load("res://scenes/in_game_menus/forgot_password.tscn")


@onready var current_scene: Node
@onready var ui_root: Node = $UIRoot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	change_game_state(PasswordFlow.GameState.ENTER_PASSWORD)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_game_state(state: PasswordFlow.GameState):
	 if current_scene:
		current_scene.queue_free()
	
	match state:
		PasswordFlow.GameState.ENTER_PASSWORD:
			current_scene = enter_password_scene.instantiate()
			ui_root.add_child(current_scene)
		PasswordFlow.GameState.FORGOT_PASSWORD:
			current_scene = forgot_password_scene.instantiate()
			ui_root.add_child(current_scene)
			current_scene.action_requested.connect(func(action): change_game_state(action))
