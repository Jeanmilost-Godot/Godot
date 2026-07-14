extends CharacterBody3D

# components
@onready var m_Camera:     Camera3D           = $"../Camera"
@onready var m_WalkSound:  AudioStreamPlayer  = $WalkSound
@onready var m_Animations: AnimationTree      = $AnimationTree
@onready var m_Highlight:  DirectionalLight3D = $SilhouetteHighlight

# classes
var m_StateMachine: PlayerStateMachine

# variables
var m_AngleX       =  0.0
var m_AngleY       =  PI / 2.0
var m_Offset       = -1.0
var m_LastDir      = -1.0
var m_Turning      =  false
var m_PortalOpened =  false

# constants
const m_CameraRadius      = 55.0
const m_PlayerRadius      = 31.0
const m_PlayerVelocity    = 0.6 #1.2
const m_JumpVelocity      = 40.0
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

	m_Highlight.global_position = global_position
	m_Highlight.look_at(Vector3.ZERO, Vector3.UP)

###
# Animates the player, or stops the animation
#param walking - if true, the player is walking
##
func AnimatePlayer(walking):
	m_Animations.set("parameters/conditions/walk",  walking)
	m_Animations.set("parameters/conditions/idle", !walking)

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

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_StateMachine = PlayerStateMachine.new()

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	var inputDir = Vector2.ZERO

	# do move the player to the left or right?
	if Input.is_action_pressed("left"):
		inputDir.x = -1.0
	elif Input.is_action_pressed("right"):
		inputDir.x = 1.0

	if Input.is_action_pressed("up") && m_PortalOpened:
		inputDir.y = 0.0

	# do move the player to the top or bottom?
	if Input.is_action_pressed("jump_or_fire"):
		inputDir.y = -1.0

	var direction = (transform.basis * Vector3(inputDir.x, 0, inputDir.y)).normalized()
	var walking   = false
	var dir       = m_LastDir

	# move player around the tower
	if inputDir.x < 0.0:
		if (!m_Turning):
			m_AngleY = m_AngleY - (delta * m_PlayerVelocity)
			walking  = true

		dir = -1.0

		AnimatePlayer(true)
		PlayWalkSound()
	elif inputDir.x > 0.0:
		if (!m_Turning):
			m_AngleY = m_AngleY + (delta * m_PlayerVelocity)
			walking  = true

		dir =  1.0

		AnimatePlayer(true)
		PlayWalkSound()
	else:
		AnimatePlayer(false)
		StopWalkSound()

	# if direction changes, start to turn the player model
	if (dir != m_LastDir):
		m_LastDir = dir
		m_Turning = true

	# turn the player model to point the walking direction
	if (m_Turning):
		AnimatePlayer(false)
		StopWalkSound()

		if (m_LastDir > 0.0):
			m_Offset += (5.0 * delta)

			if (m_Offset >= 1.0):
				m_Offset  =  1.0
				m_Turning =  false
		else:
			m_Offset -= (5.0 * delta)

			if (m_Offset <= -1.0):
				m_Offset  = -1.0
				m_Turning =  false

	# apply player and camera movements
	MoveCamera()
	MovePlayer()

	# apply gravity when not on floor
	if not is_on_floor():
		velocity.y -= m_Gravity * (delta * m_GravityMultiplier)

		AnimatePlayer(false)
		StopWalkSound()
	else:
		# handle jump
		if inputDir.y != 0.0 and walking:
			velocity.y = -inputDir.y * m_JumpVelocity
		else:
			velocity.y = 0.0

	# apply the velocity and check the collisions
	move_and_slide()

###
# Called when a portal is opened and the player may enter in it
##
func _on_portal_open():
	m_PortalOpened = true;

###
# Called when a portal is closed and the player may no longer enter in it
##
func _on_portal_close():
	m_PortalOpened = false;
