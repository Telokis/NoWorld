class_name UI
extends CanvasLayer

@onready var spell_1 = %Spell1

func _on_cooldown_timer_finished():
	pass
	
func _on_cooldown_timer_ticked(timer: TimerPlus):
	spell_1._on_cooldown_tick(timer)
