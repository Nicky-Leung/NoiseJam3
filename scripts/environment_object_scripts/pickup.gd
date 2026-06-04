extends Node2D

# Add into this when new pickables are added
enum Item {
	BATTERY,
	MEDKIT,
	TRAP
}

@export var item: Item = Item.BATTERY
@export var item_sprite: Texture2D = null

@onready var sprite: TextureRect = $Sprite
@onready var interactable: Interactable = $Interactable
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

func _ready():
	sprite.texture = item_sprite
	interactable.interacted.connect(on_interacted)

func on_interacted(player: Player):
	var was_added_to_inv = false
	if item == Item.BATTERY: was_added_to_inv = player.inventory.try_change_battery(true)
	elif item == Item.MEDKIT: was_added_to_inv = player.inventory.try_change_medkit(true)
	elif item == Item.TRAP: was_added_to_inv = player.inventory.try_change_trap(true)

	if was_added_to_inv:
		visible = false
		interactable.enable(false)
		HELPERS.play_audio(audio_player, 0.9, 1.1, 10)

		# debate if just want to hide it, or actually delete it
		var delay = create_tween()
		delay.tween_interval(audio_player.stream.get_length())
		delay.tween_callback(queue_free)
	else:
		# probably put some UI saying inventory is full, for now just print it
		print("Cannot add " + str(Item.keys()[item]) + " because inventory is full")
