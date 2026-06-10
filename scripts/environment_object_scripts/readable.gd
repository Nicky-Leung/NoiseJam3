extends Node2D

enum Type {
	LAB_REPORT,
	MESSAGES,
	EMAIL
}

# Default items (Don't touch in editor)
@export var default_electronic_sprite: Texture2D = null
@export var default_paper_sprite: Texture2D = null
@export var default_paper_SFX: AudioStream = null
@export var default_electronic_SFX: AudioStream = null

# Used items
@export var type: Type = Type.MESSAGES
@export var open_SFX: AudioStream = null
@export var in_world_sprite: Texture2D = null
@export var readable_menu: PackedScene = null
@export var is_wider_sprite: bool = false

@onready var sprite: TextureRect = $Sprite
@onready var interactable: Interactable = $Interactable
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer
@onready var menu_close_button: Button = $Menu/Close
@onready var menu: CanvasLayer = $Menu

var player_ref: Player = null

func _ready():
	if type == Type.LAB_REPORT:
		sprite.texture = default_paper_sprite if in_world_sprite == null else in_world_sprite
		audio_player.stream = default_paper_SFX if open_SFX == null else open_SFX
	else: # others are electronic
		sprite.texture = default_electronic_sprite if in_world_sprite == null else in_world_sprite
		audio_player.stream = default_electronic_SFX if open_SFX == null else open_SFX

	sprite.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL if is_wider_sprite else TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL

	interactable.interacted.connect(on_interact)
	menu_close_button.pressed.connect(on_close_pressed)
	var readable = readable_menu.instantiate()
	menu.add_child(readable)
	menu.move_child(readable, 0)
	menu.visible = false

func on_interact(player: Player):
	menu.visible = true
	player_ref = player
	player.handle_pause(true)
	HELPERS.play_audio(audio_player, 0.95, 1.05)
	get_tree().paused = true

func on_close_pressed():
	menu.visible = false
	player_ref.handle_pause(false)
	get_tree().paused = false
