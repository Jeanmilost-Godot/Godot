extends Node3D

# components
@onready var m_AnimPlayer: AnimationPlayer = $Model/AnimationPlayer

# variables
var m_TargetTime: float  = -1.0
var m_Playing:    bool   =  false
var m_AnimName:   String =  "Animation"

# constants
const m_SpeedScale  = 2.0
const m_OpenEndTime = 1.7

# signals
signal portal_open()
signal portal_close()

###
# Plays the animation until the target time is reached
#@param target - target time to reach
##
func PlayToTarget(target: float):
	m_TargetTime = target
	m_Playing = true

	if not m_AnimPlayer.is_playing():
		m_AnimPlayer.play(m_AnimName)

###
# Stops the animation when the target time is reached
##
func StopAtTarget():
	m_AnimPlayer.seek(m_TargetTime, true)
	m_AnimPlayer.pause()

	m_Playing    =  false
	m_TargetTime = -1.0

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	# certify that the door is closed by default
	m_AnimPlayer.play(m_AnimName)
	m_AnimPlayer.seek(0.0, true)
	m_AnimPlayer.pause()

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	# not playing animation?
	if not m_Playing:
		return

	# get current animation time
	var pos = m_AnimPlayer.current_animation_position

	# play animation
	if (pos < m_TargetTime):
		# forward (toward larger time)
		m_AnimPlayer.speed_scale = m_SpeedScale

		if pos >= m_TargetTime - 0.01:
			StopAtTarget()
	elif (pos > m_TargetTime):
		# backward (toward smaller time)
		m_AnimPlayer.speed_scale = -m_SpeedScale

		if pos <= m_TargetTime + 0.01:
			StopAtTarget()

###
# Called when a body enters in the trigger zone
#param body - body which entered in the trigger zone
##
func _on_trigger_zone_body_entered(body):
	# ignore any body but player
	if body.name != "Player":
		return

	portal_open.emit()

	# open, go toward 1.7 from current position
	PlayToTarget(m_OpenEndTime)

###
# Called when a body leaves the trigger zone
#param body - body which leaved the trigger zone
##
func _on_trigger_zone_body_exited(body):
	# ignore any body but player
	if body.name != "Player":
		return

	portal_close.emit()

	var endTime = m_AnimPlayer.current_animation_length

	# close, go toward animation end from current position
	PlayToTarget(endTime)
