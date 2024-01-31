extends Area3D

@export var speed = 7.5
@export var damage = 1
@export var maxTravelDistance = 10

var targetPoint: Vector3
var direction: Vector3

@onready var timer = $Timer

func _ready():
	timer.wait_time = maxTravelDistance / speed
	timer.connect("timeout", _on_timeout)
	look_at(targetPoint)
	body_entered.connect(_on_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_entered(other):
	print(other)

#func _on_screen_exited():
	#queue_free()

func _on_timeout():
	speed = 0
	queue_free()
