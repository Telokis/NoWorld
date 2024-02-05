class_name World
extends Node3D

@export var player: Player
@export var ui: UI

func _unhandled_input(_event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

func _ready():
	player.cooldownTimerFinished.connect(ui._on_cooldown_timer_finished)
	player.cooldownTimerTicked.connect(ui._on_cooldown_timer_ticked)
