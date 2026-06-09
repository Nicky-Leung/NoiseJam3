extends TextureButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_pressed() -> void:
	SCENE_MANAGER.change_scene(SceneManager.Scenes.MAIN_MENU)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
