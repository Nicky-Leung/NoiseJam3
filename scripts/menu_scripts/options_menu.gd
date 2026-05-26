extends Control

@onready var sfx_slider: HSlider = $Background/SFX/SFXSlider
@onready var music_slider: HSlider = $Background/Music/MusicSlider
@onready var close_button: Button = $Background/Close

func _ready():
    sfx_slider.value = OPTIONS.SFX
    music_slider.value = OPTIONS.MUSIC
    sfx_slider.value_changed.connect(func(new_val: float): OPTIONS.SFX = new_val)
    music_slider.value_changed.connect(func(new_val: float): OPTIONS.MUSIC = new_val)
    close_button.pressed.connect(handle_close)

func handle_close():
    queue_free()