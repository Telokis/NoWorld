class_name HealthAtom extends Object

@export var max_health : int = 100
var health : int

## Positive variation means heal. Negative means damage
signal health_changed(variation: int, new_health: int, old_health: int)
signal health_depleted()

func _ready():
	health = max_health


func damage(amount: int):
	var clamped_health = clamp(health - amount, 0, max_health)
	health_changed.emit(-amount, clamped_health, health)

	health = clamped_health
	if (health <= 0):
		health_depleted.emit()


func heal(amount: int):
	return damage(-amount)
