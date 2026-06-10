extends TextureButton

func _on_pressed() -> void:
	SCENE_MANAGER.change_scene(SceneManager.Scenes.MAIN_MENU)