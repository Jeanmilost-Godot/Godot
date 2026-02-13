extends CharacterBody3D

# components
@onready var m_Camera:     Camera3D          = $"../Camera"
@onready var m_WalkSound:  AudioStreamPlayer = $WalkSound
@onready var m_Animations: AnimationTree     = $AnimationTree

# variables
var m_AngleX =  0.0
var m_AngleY =  PI / 2.0
var m_Offset = -1.0

# constants
const m_CameraRadius      = 65.0
const m_PlayerRadius      = 31.0
const m_PlayerVelocity    = 1.25
const m_JumpVelocity      = 50.0
const m_GravityMultiplier = 12.5

# get the gravity from the project settings to be synced with RigidBody nodes.
var m_Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

###
# Moves the camera position around the tower
##
func MoveCamera():
	var cameraPos = Vector3.ZERO
	cameraPos.x   = m_CameraRadius * sin(m_AngleY) * cos(m_AngleX)
	cameraPos.y   = position.y
	cameraPos.z   = m_CameraRadius * cos(m_AngleY) * cos(m_AngleX)

	m_Camera.position   = cameraPos
	m_Camera.rotation.y = m_AngleY

###
# Moves the player position around the tower
##
func MovePlayer():
	var playerPos = Vector3.ZERO
	playerPos.x   = m_PlayerRadius * sin(m_AngleY) * cos(m_AngleX)
	playerPos.y   = position.y
	playerPos.z   = m_PlayerRadius * cos(m_AngleY) * cos(m_AngleX)

	position   = playerPos
	rotation.y = m_AngleY + (PI / 2.0) * m_Offset;

###
# Animates the player, or stops the animation
#param walking - if true, the player is walking
##
func AnimatePlayer(walking):
	m_Animations.set("parameters/conditions/walk", true)
	m_Animations.active = walking

###
# Plays the walk sound
##
func PlayWalkSound():
	# play the walking sound
	if !m_WalkSound.is_playing():
		m_WalkSound.play();

###
# Stops the walk sound
##
func StopWalkSound():
	# stop the walking sound
	if m_WalkSound.is_playing():
		m_WalkSound.stop();

#func _ready():
	#m_Animations.active = true

func _physics_process(delta):
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var walking   = false

	if input_dir.x < 0.0:
		m_AngleY =  m_AngleY - (delta * m_PlayerVelocity)
		m_Offset = -1.0
		walking  =  true

		AnimatePlayer(true)
		PlayWalkSound()
	elif input_dir.x > 0.0:
		m_AngleY =  m_AngleY + (delta * m_PlayerVelocity)
		m_Offset =  1.0
		walking  =  true

		AnimatePlayer(true)
		PlayWalkSound()
	else:
		AnimatePlayer(false)
		StopWalkSound()

	MoveCamera()
	MovePlayer()

	# apply gravity when not on floor
	if not is_on_floor():
		velocity.y -= m_Gravity * (delta * m_GravityMultiplier)
	else:
		# handle jump
		if input_dir.y != 0.0 and walking:
			velocity.y = -input_dir.y * m_JumpVelocity
		else:
			velocity.y = 0.0

	# apply the velocity and check the collisions
	move_and_slide()
