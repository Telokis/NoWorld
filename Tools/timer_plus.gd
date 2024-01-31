extends Node

signal timeout

var time_left: float
var _running = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _running:
		decrease_timer(delta)

## Used to explicitely decrease the duration left on the timer
func decrease_timer(seconds: float):
	time_left -= seconds
	if time_left <= 0:
		_running = false
		timeout.emit()

## Starts the timer with the given duration in seconds
func start(duration_seconds: float):
	time_left = duration_seconds
	_running = true

## Returns whether the timer is currently running or not
func isStopped():
	return not _running
