@tool
extends Area3D

@export var speed = 7.5
@export var damage = 1
@export var maxTravelDistance = 10

var targetPoint: Vector3

@onready var timer = $Timer

func _ready():
	timer.wait_time = maxTravelDistance / speed
	timer.connect("timeout", _on_timeout)
	look_at(targetPoint)
	#area_entered.connect(_on_entered)

func _physics_process(delta):
	position.z -= speed * delta

#func _on_entered(other):
	#if other.is_in_group("Enemies"):
		#other.hit(get_damage())
		#
		#speed = 0
		#set_deferred("monitoring", false)
		#$Sprite2D.hide()
		#$GPUParticles2D.restart()
		#await get_tree().create_timer(1.0).timeout
		#queue_free()

#func _on_screen_exited():
	#queue_free()

func _on_timeout():
	speed = 0
	queue_free()

#func get_damage():
	#return damage
