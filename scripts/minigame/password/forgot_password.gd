extends Control

signal action_requested(action: PasswordFlow.GameState)

@onready var forgot_password: Button = %Forgot_Email

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	forgot_password.pressed.connect(func(): action_requested.emit(PasswordFlow.GameState.FORGOT_PASSWORD))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
