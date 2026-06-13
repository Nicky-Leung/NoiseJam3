extends Node
class_name SceneManager

enum Scenes {
	MAIN_MENU,
	IN_GAME,
	ENDING_SEQUENCE, # maybe?
	GAME_OVER
}
@onready var main_menu_scene = load("res://scenes/menus/menu.tscn") as PackedScene
@onready var in_game_scene = load("res://scenes/map_scenes/level.tscn") as PackedScene # placeholder
@onready var game_over_scene = load("res://scenes/menus/game_over.tscn") as PackedScene
@onready var credits_scene = load("res://scenes/menus/credits.tscn") as PackedScene

enum SubMenus {
	PAUSE_MENU, # implement later
	OPTIONS,
	CREDITS
}
@onready var options_menu_scene = load("res://scenes/menus/options_menu.tscn") as PackedScene

func change_scene(scene: Scenes) -> void:
	if scene == Scenes.MAIN_MENU:
		get_tree().change_scene_to_packed(main_menu_scene)
	elif scene == Scenes.IN_GAME:
		get_tree().change_scene_to_packed(in_game_scene)
	elif scene == Scenes.ENDING_SEQUENCE:
		print("don't even know if this is necessary")
	elif scene == Scenes.GAME_OVER:
		get_tree().change_scene_to_packed(game_over_scene)

func open_sub_menu(menu: SubMenus):
	if menu == SubMenus.OPTIONS:
		var instance = options_menu_scene.instantiate()
		get_tree().current_scene.add_child(instance)
	elif menu == SubMenus.PAUSE_MENU:
		print("implement later")
	if menu == SubMenus.CREDITS:
		var instance = credits_scene.instantiate()
		get_tree().current_scene.add_child(instance)
