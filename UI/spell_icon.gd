class_name SpellIcon
extends TextureProgressBar

@export var spell: SpellData
@onready var cooldown_text = %CooldownText

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_under = spell.icon
	texture_progress = spell.icon

func _on_cooldown_tick(timer: TimerPlus):
	value = 1 - (timer.time_left / timer.time_total)
	
	if (timer.time_left >= 3.0 or timer.time_left < 0.05):
		cooldown_text.hide()
	else:
		cooldown_text.show()
		cooldown_text.text = "%.01f" % timer.time_left
