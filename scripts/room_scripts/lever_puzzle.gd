extends Node2D

@onready var test: Lever = $Lever

func _ready():
    test.pulled.connect(_on_pulled)

func _on_pulled(lever: Lever):
    lever.reset_lever()