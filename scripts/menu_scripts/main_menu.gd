extends Control

@onready var start: Button = $Play
@onready var options: Button = $Options
@onready var credits: Button = $Credits
@onready var quit: Button = $Quit

func _ready():
	start.pressed.connect(handle_start)
	options.pressed.connect(handle_options)
	credits.pressed.connect(handle_credits)

	if OS.has_feature("web"): # quitting in browser is equivalent to crashing the game
		quit.visible = false
	else:
		quit.pressed.connect(handle_quit)

func handle_start(): # probably need to do some fade-to-game type thing instead of abrupt cut
	SCENE_MANAGER.change_scene(SceneManager.Scenes.IN_GAME)

func handle_options(): # implement options menu
	SCENE_MANAGER.open_sub_menu(SceneManager.SubMenus.OPTIONS)

func handle_credits(): # implement at the end when all the assets are sorted out
	print("credits opened")

func handle_quit():
	get_tree().quit()
