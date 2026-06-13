extends Node2D

@export var angel: Angel = null # for adding music/vertigo while being chased

@onready var ambient_music: AudioStreamPlayer = $Musics/AmbientMusic
@onready var chase_music: AudioStreamPlayer = $Musics/ChaseMusic
@onready var start_room: StarterRoom = $Layout/StarterRoom
@onready var room1: PuzzleRoom1 = $Layout/PuzzleRoom1
@onready var room2 = $Layout/PuzzleRoom2
@onready var room3 = $Layout/PuzzleRoom3
@onready var hallways = $Layout/Hallways

func _ready():
	room3.diamond_collected.connect(_on_last_room_finished)
	start_room.reached_ending.connect(_back_to_menu)

	angel.start_chase.connect(func(): swap_music(false))
	angel.stop_chase.connect(func(): swap_music(true))
	ambient_music.volume_db = HELPERS.factor_to_db(OPTIONS.MUSIC)
	ambient_music.play()
	chase_music.volume_db = -60

func _on_last_room_finished():
	start_room.uncensor_sin()

func _back_to_menu():
	SCENE_MANAGER.change_scene(SceneManager.Scenes.MAIN_MENU)


func swap_music(to_ambient: bool):
	var tween = create_tween()

	if to_ambient:
		tween.tween_property(chase_music, "volume_db", -60, 5)
		tween.tween_callback(func():
			chase_music.stop()
			ambient_music.play()
		)
		tween.tween_property(ambient_music, "volume_db", HELPERS.factor_to_db(OPTIONS.MUSIC) - 10, 0.5)
	else:
		tween.tween_property(ambient_music, "volume_db", -60, 0.25)
		tween.tween_callback(func():
			ambient_music.stop()
			chase_music.play()
		)
		tween.tween_property(chase_music, "volume_db", HELPERS.factor_to_db(OPTIONS.MUSIC), 0.5)
	tween.play()
