class_name TimerPlus
extends Node

signal finished
signal ticked(timer: TimerPlus)

var time_left: float
var time_total: float
var _running = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _running:
		decrease_timer(delta)

## Used to explicitely decrease the duration left on the timer
func decrease_timer(seconds: float):
	time_left -= seconds
	ticked.emit(self)
	if time_left <= 0.0:
		time_left = 0
		_running = false
		finished.emit()

## Starts the timer with the given duration in seconds
func start(duration_seconds: float):
	time_left = duration_seconds
	time_total = duration_seconds
	_running = true

## Returns whether the timer is currently running or not
func isStopped():
	return not _running
