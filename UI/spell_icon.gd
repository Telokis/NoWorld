extends Control

@onready var progress_texture = $ProgressTexture

@export var textureImage: Texture2D

# Called when the node enters the scene tree for the first time.
func _ready():
	progress_texture.texture_under = textureImage
	progress_texture.texture_progress = textureImage


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
