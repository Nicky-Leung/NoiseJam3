extends Node2D

@export var angel: Angel = null # for adding music/vertigo while being chased

@onready var start_room: StarterRoom = $Layout/StarterRoom
@onready var room1: PuzzleRoom1 = $Layout/PuzzleRoom1
@onready var room2 = $Layout/PuzzleRoom2
@onready var room3 = $Layout/PuzzleRoom3
@onready var hallways = $Layout/Hallways

func _ready():
    room3.diamond_collected.connect(_on_last_room_finished)
    start_room.reached_ending.connect(_back_to_menu)

func _on_last_room_finished():
    start_room.uncensor_sin()

func _back_to_menu():
    SCENE_MANAGER.change_scene(SceneManager.Scenes.MAIN_MENU)
