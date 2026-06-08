extends Control

@onready var start: TextureButton = $Start
@onready var options: TextureButton = $Options
@onready var credits: TextureButton = $Credits
@onready var quit: TextureButton = $Quit

func _ready():
	if start == null:
		print("ERROR: Play button not found at path: $Play")
		return
	if options == null:
		print("ERROR: Options button not found at path: $Options")
		return
	if credits == null:
		print("ERROR: Credits button not found at path: $Credits")
		return
	
	start.pressed.connect(handle_start)
	options.pressed.connect(handle_options)
	credits.pressed.connect(handle_credits)

	if OS.has_feature("web"):
		if quit:
			quit.visible = false
	else:
		if quit == null:
			print("ERROR: Quit button not found at path: $Quit")
		else:
			quit.pressed.connect(handle_quit)

func handle_start():
	SCENE_MANAGER.change_scene(SceneManager.Scenes.IN_GAME)

func handle_options():
	SCENE_MANAGER.open_sub_menu(SceneManager.SubMenus.OPTIONS)
	

func handle_credits():
	print("credits opened")

func handle_quit():
	get_tree().quit()
