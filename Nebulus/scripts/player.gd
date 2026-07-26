extends CharacterBody3D

# components
@onready var m_Camera:     Camera3D           = $"../Camera"
@onready var m_WalkSound:  AudioStreamPlayer  = $WalkSound
@onready var m_Animations: AnimationTree      = $AnimationTree
@onready var m_Highlight:  DirectionalLight3D = $SilhouetteHighlight

# classes
var m_StateMachine: PlayerStateMachine

# portal animation parts
enum IEPortal {P_Aligning, P_RotateTo, P_Enter, P_RotateTower, P_Exit, P_RotateFrom}

# variables
var m_AngleX                =  0.0
var m_AngleY                =  PI / 2.0
var m_Offset                = -1.0
var m_LastDir               = -1.0
var m_PortalAngle           =  0.0
var m_TargetPortalAngle     =  0.0
var m_Turning               =  false
var m_CanEnterPortal        =  false
var m_MoveThroughPortal     =  false
var m_Portal                =  null
var m_TargetPortal          =  null
var m_PortalState: IEPortal = IEPortal.P_Aligning

# constants
const m_CameraRadius          = 55.0
const m_PlayerRadius          = 31.0
const m_PlayerVelocity        = 0.6 #1.2
const m_RotationVelocity      = 5.0
const m_TowerRotationVelocity = 1.8
const m_WalkVelocity          = 9.0
const m_JumpVelocity          = 40.0
const m_GravityMultiplier     = 12.5
const m_WalkStopDist          = 25.0

# get the gravity from the project settings to be synced with RigidBody nodes.
var m_Gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

###
# Gets the rotation angle between 2 angles
#@param startAngle - start angle to calculate from
#@param endAngle - end angle to calculate to
#@return the rotation angle, between -PI and PI
##
func GetRotationAngle(startAngle, endAngle) -> float:
	# calculate the rotation angle, which is the shortest signed distance from start angle to end angle
	return wrapf(endAngle - startAngle, -PI, PI)

###
# Checks if target angle was reached
#@param angle - current angle to test
#@param targetAngle - target angle to test against
#@param threshold - threshold which determines if target angle is reached
#@return true if angle reached target angle, otherwise false
##
func TargetAngleReached(angle, targetAngle, threshold = 0.01) -> bool:
	# by calculating the rotation angle between the current angle and the target one, it's possible
	# to determine if the target is reached if the rotation angle is lower than a given threshold
	return (abs(GetRotationAngle(angle, targetAngle)) < threshold)

###
# Gets the next position for the current angle when rotation between start and end angles
#@param delta - elapsed time in seconds since the previous call
#@param rotationVelocity - rotation velocity
#@param startAngle - start angle to calculate from
#@param endAngle - end angle to calculate to
#@param curAngle - current angle for which the next position should be calculated
#@return the next current angle position
##
func GetNextAngle(delta, rotationVelocity, startAngle, endAngle, curAngle) -> float:
	var rotationAngle = GetRotationAngle(startAngle, endAngle)

	# extract the rotation direction
	var direction = sign(rotationAngle)

	# calculate the distance to travel
	var distance = delta * rotationVelocity

	# calculate the curent angle next position depending on the rotation direction
	return curAngle + (distance * direction)

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
# Rotates the player while turning
#@param delta - elapsed time in seconds since the previous call
##
func RotatePlayer(delta):
	AnimatePlayer(false)
	StopWalkSound()

	# is player walking to the left or to the right?
	if (m_LastDir > 0.0):
		# rotate to the right
		m_Offset += (m_RotationVelocity * delta)

		# end reached?
		if (m_Offset >= 1.0):
			m_Offset  = 1.0
			m_Turning = false
	else:
		# rotate to the left
		m_Offset -= (m_RotationVelocity * delta)

		# end reached?
		if (m_Offset <= -1.0):
			m_Offset  = -1.0
			m_Turning =  false

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
# Moves the player until it is aligned with the portal to enter
#@param delta - elapsed time in seconds since the previous call
#@return true once the player has arrived, otherwise false
##
func MoveToPortal(delta) -> bool:
	# is player turning?
	if (m_Turning):
		AnimatePlayer(false)
		StopWalkSound()
		RotatePlayer(delta)
		MovePlayer()
		return false

	# get direction to which the player should move
	var dir = sign(GetRotationAngle(m_PortalAngle, m_AngleY + (PI / 2.0)))

	# check if the player is looking to the correct direction, turn it if not
	if (dir != m_LastDir and not TargetAngleReached(m_AngleY, m_PortalAngle + (PI / 2.0))):
		m_LastDir = dir
		m_Turning = true
		return false

	# calculate the next angle position
	m_AngleY = GetNextAngle(delta, m_PlayerVelocity, m_PortalAngle, m_AngleY + (PI / 2.0), m_AngleY)

	var playerAngle = wrapf(m_AngleY,                   -PI, PI)
	var endAngle    = wrapf(m_PortalAngle + (PI / 2.0), -PI, PI)
	var endReached  = false

	# by calculating the rotation angle between the current player position and the target, it's possible
	# to determine if the target is reached if the angle is lower than a given threshold
	if (TargetAngleReached(playerAngle, endAngle)):
		m_AngleY   = endAngle
		endReached = true

	# apply the changes
	MoveCamera()
	MovePlayer()
	AnimatePlayer(true)
	PlayWalkSound()

	return endReached

###
# Rotates the player in a such manner he faces the portal
#@param delta - elapsed time in seconds since the previous call
#@return true when rotation finished, otherwise false
##
func RotatePlayerToFacePortal(delta) -> bool:
	AnimatePlayer(false)
	StopWalkSound()

	var endReached = false

	# is player walking to the left or to the right?
	if (m_LastDir > 0.0):
		# rotate to the right
		m_Offset += (m_RotationVelocity * delta)

		# end reached?
		if (m_Offset >= 2.0):
			m_Offset   = 2.0
			endReached = true
	else:
		# because the rotation will happen counter-clockwise, need to add 360° to the offset
		if (m_Offset < 0.0):
			m_Offset = 3.0

		# rotate to the left
		m_Offset -= (m_RotationVelocity * delta)

		# end reached?
		if (m_Offset <= 2.0):
			m_Offset   = 2.0
			endReached = true

	MovePlayer()
	return endReached

###
# Moves the player toward the portal
#@param delta - elapsed time in seconds since the previous call
#@return true when move finished, otherwise false
##
func EnterPortal(delta) -> bool:
	# move the player toward the portal
	global_position.x -= delta * m_WalkVelocity * sin(m_AngleY) * cos(m_AngleX)
	global_position.z -= delta * m_WalkVelocity * cos(m_AngleY) * cos(m_AngleX)

	AnimatePlayer(true)
	PlayWalkSound()

	# final pos reached?
	return global_position.length() < m_WalkStopDist

###
# Rotates the tower between the source portal to the target one
#@param delta - elapsed time in seconds since the previous call
#@return true when rotation finished, otherwise false
##
func RotateTower(delta):
	# calculate the next angle position
	m_AngleY = GetNextAngle(delta, m_TowerRotationVelocity, m_PortalAngle, m_TargetPortalAngle, m_AngleY)

	var playerAngle = wrapf(m_AngleY,                         -PI, PI)
	var endAngle    = wrapf(m_TargetPortalAngle + (PI / 2.0), -PI, PI)
	var endReached  = false

	# by calculating the rotation angle between the current player position and the target, it's possible
	# to determine if the target is reached if the angle is lower than a given threshold
	if (TargetAngleReached(playerAngle, endAngle)):
		m_AngleY   = endAngle
		endReached = true

	# apply the changes
	MoveCamera()
	PlayWalkSound()

	return endReached

###
# Moves the player from the portal to the platform
#@param delta - elapsed time in seconds since the previous call
#@return true when move finished, otherwise false
##
func LeavePortal(delta) -> bool:
	# force the character to look at the camera
	m_Offset = 0.0

	# move the player from the portal to the platform
	global_position.x += delta * m_WalkVelocity * sin(m_AngleY) * cos(m_AngleX)
	global_position.z += delta * m_WalkVelocity * cos(m_AngleY) * cos(m_AngleX)

	AnimatePlayer(true)
	PlayWalkSound()

	# final pos reached?
	if (global_position.length() >= m_PlayerRadius):
		global_position.x = m_PlayerRadius * sin(m_AngleY) * cos(m_AngleX)
		global_position.z = m_PlayerRadius * cos(m_AngleY) * cos(m_AngleX)
		return true

	return false

###
# Rotates the player after exited the portal
#@param delta - elapsed time in seconds since the previous call
#@return true when rotation finished, otherwise false
##
func RotatePlayerAfterExitPortal(delta) -> bool:
	AnimatePlayer(false)
	StopWalkSound()

	var endReached = false

	# was player previously walking to the left or to the right?
	if (m_LastDir > 0.0):
		# rotate to the right
		m_Offset += (m_RotationVelocity * delta)

		# end reached?
		if (m_Offset >= m_LastDir):
			m_Offset   = m_LastDir
			endReached = true
	else:
		# rotate to the left
		m_Offset -= (m_RotationVelocity * delta)

		# end reached?
		if (m_Offset <= m_LastDir):
			m_Offset   = m_LastDir
			endReached = true

	MovePlayer()
	return endReached

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
	# is player walking through a portal?
	if (m_MoveThroughPortal):
		# dispatch currently running portal animation part
		match (m_PortalState):
			IEPortal.P_Aligning:
				if (MoveToPortal(delta)):
					m_PortalState = IEPortal.P_RotateTo

			IEPortal.P_RotateTo:
				if (RotatePlayerToFacePortal(delta)):
					m_PortalState = IEPortal.P_Enter

			IEPortal.P_Enter:
				if (EnterPortal(delta)):
					m_PortalState = IEPortal.P_RotateTower

			IEPortal.P_RotateTower:
				if (RotateTower(delta)):
					# locate the player beyond the portal to exit
					global_position.x = (m_WalkStopDist - 1.0) * sin(m_AngleY) * cos(m_AngleX)
					global_position.z = (m_WalkStopDist - 1.0) * cos(m_AngleY) * cos(m_AngleX)
					m_PortalState     = IEPortal.P_Exit

			IEPortal.P_Exit:
				if (LeavePortal(delta)):
					m_LastDir     = sign(GetRotationAngle(m_AngleY + (PI / 2.0), m_TargetPortalAngle))
					m_PortalState = IEPortal.P_RotateFrom

			IEPortal.P_RotateFrom:
				if (RotatePlayerAfterExitPortal(delta)):
					m_Turning           = false
					m_MoveThroughPortal = false

		return

	var inputDir = Vector2.ZERO

	# do move the player to the left or right?
	if Input.is_action_pressed("left"):
		inputDir.x = -1.0
	elif Input.is_action_pressed("right"):
		inputDir.x = 1.0

	if Input.is_action_pressed("up") && m_CanEnterPortal:
		inputDir.y          = 0.0
		m_PortalState       = IEPortal.P_Aligning
		m_MoveThroughPortal = true

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

		dir = 1.0

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
		RotatePlayer(delta)

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
# Called when the player enters or leaves the trigger zone of a portal
#@param canEnter - if true, player can enter in portal
#@param portal -  portal the player is currently facing, null if canEnter is false
#@param targetPortal - target portal on which the player should move, null if canEnter is false
##
func _on_can_enter_portal(canEnter, portal, targetPortal):
	m_CanEnterPortal = canEnter
	m_Portal         = portal
	m_TargetPortal   = targetPortal

	if (m_Portal):
		m_PortalAngle = m_Portal.global_rotation.y

	if (m_TargetPortal):
		m_TargetPortalAngle = m_TargetPortal.global_rotation.y
