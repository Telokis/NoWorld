extends CharacterBody3D

@export_category("Physics")
@export var SPEED = 5.0
@export var JUMP_VELOCITY = 15
@export var GRAVITY_FACTOR = 1.0
## How much velocity can be altered while airborne. 0 means no movement, 1 means full movement.
@export_range(0, 1) var AIR_CONTROL_FACTOR: float = 0.5

@export_category("Controls adjustments")
@export var MOUSE_HORIZONTAL_SENSITIVITY = 0.1
@export var MOUSE_VERTICAL_SENSITIVITY = 0.1

@export_category("Camera zoom")
@export var MIN_CAMERA_ARM_DISTANCE: float = 0
@export var MAX_CAMERA_ARM_DISTANCE: float = 10
@export var CAMERA_ZOOM_INCREMENT: float = 1

@export_category("Projectiles")
@export var BasicProjectile: PackedScene = preload("res://Scenes/Projectiles/bullet.tscn")

@onready var camera = $cameraArm/Camera3D
@onready var camera_arm = $cameraArm
@onready var muzzle = $muzzle

@onready var topCameraArmPosMarker = $topCameraArmPos
@onready var bottomCameraArmPosMarker = $bottomCameraArmPos

@onready var zoomLevel: float = camera_arm.spring_length
var zoomTween : Tween

var BoxScene = preload("res://Scenes/box.tscn")

## If set to true and airborne, we can decide a direction.
var jumpHadInitialVelocity = false;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_HORIZONTAL_SENSITIVITY))
		camera_arm.rotate_x(deg_to_rad(-event.relative.y * MOUSE_VERTICAL_SENSITIVITY))
		camera_arm.rotation.x = clamp(camera_arm.rotation.x, -PI/2, PI/2)

func _process(_delta):
	if Input.is_action_just_pressed("zoom_in"):
		handleZoom(-CAMERA_ZOOM_INCREMENT)
	elif Input.is_action_just_pressed("zoom_out"):
		handleZoom(+CAMERA_ZOOM_INCREMENT)
	
	if Input.is_action_just_pressed("shoot"):
		shoot()

## Perform zoom by configuring the springArm3D
func handleZoom(zoomChange):
	if (zoomTween):
		zoomTween.kill()
		
	zoomTween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	zoomLevel = clamp(zoomLevel + zoomChange, MIN_CAMERA_ARM_DISTANCE, MAX_CAMERA_ARM_DISTANCE)
	var weight = (zoomLevel - MIN_CAMERA_ARM_DISTANCE) / (MAX_CAMERA_ARM_DISTANCE - MIN_CAMERA_ARM_DISTANCE)
	var cameraHeight = lerp(bottomCameraArmPosMarker.position, topCameraArmPosMarker.position, weight)
	
	zoomTween.tween_property(camera_arm, "spring_length", zoomLevel, 0.15)
	zoomTween.tween_property(camera_arm, "position", cameraHeight, 0.15)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * GRAVITY_FACTOR

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jumpHadInitialVelocity = velocity.x != 0 or velocity.z != 0
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	# If we're on the floor, we have perfect control, no sliding/inertia.
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0
			velocity.z = 0
	elif !jumpHadInitialVelocity and velocity.x == 0 and velocity.z == 0:
		# If jumping, we're allowed to adjust our velocity slightly
		# if we didn't have any when we started the jump.
		velocity.x = direction.x * SPEED * AIR_CONTROL_FACTOR
		velocity.z = direction.z * SPEED * AIR_CONTROL_FACTOR

	# Update physics
	move_and_slide()

func shoot():
	# To shoot, we first need to raycast from the camera to see what it is aiming at.
	# Once we have the collision point, we can then shoot to it from the player's muzzle.
	var screenCenter = get_viewport().size / 2.0
	var origin = camera.project_ray_origin(screenCenter)
	var to = origin + camera.project_ray_normal(screenCenter) * 1000.0
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(origin, to)
	var collision = space.intersect_ray(query)
	var targetPoint = to
	
	# If a collision is found, we target the intersection point
	if collision:
		targetPoint = collision.position
		
	var projectileInstance = BasicProjectile.instantiate()
	get_tree().current_scene.add_child(projectileInstance)
	projectileInstance.transform = muzzle.global_transform
	projectileInstance.direction = (targetPoint - projectileInstance.position).normalized()
