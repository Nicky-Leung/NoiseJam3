extends Node
class_name SceneManager

enum Scenes {
    MAIN_MENU,
    IN_GAME,
    ENDING_SEQUENCE # maybe?
}

@onready var main_menu_scene = load("res://scenes/menus/main_menu.tscn") as PackedScene # placeholder
@onready var in_game_scene = load("res://scenes/main.tscn") as PackedScene # placeholder

func change_scene(scene: Scenes) -> void:
    if scene == Scenes.MAIN_MENU:
        get_tree().change_scene_to_packed(main_menu_scene)
    elif scene == Scenes.IN_GAME:
        get_tree().change_scene_to_packed(in_game_scene)
    elif scene == Scenes.ENDING_SEQUENCE:
        print("don't even know if this is necessary")