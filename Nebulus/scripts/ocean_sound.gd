extends AudioStreamPlayer

# exposed values on editor
@export var ListenerNode:  Node3D = null
@export var OceanYLevel:   float = 0.0  # the Y height of the ocean
@export var MaxFadeHeight: float = 50.0 # height at which ocean becomes completely silent

# variables
var m_TargetVolume: float = -80.0
var m_VolumeTween:  Tween = null

###
# Smoothly shifts the volume
#@param targetDB - target DB
##
func smooth_volume_shift(targetDB: float):
	# kill any existing volume tween before starting a new one
	if m_VolumeTween:
		m_VolumeTween.kill()

	# create a new volume tween
	m_VolumeTween = create_tween()

	# interpolate volume_db to the target over 0.1 seconds to prevent popping
	m_VolumeTween.tween_property(self, "volume_db", targetDB, 0.1)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	# start completely silent to guarantee zero popping on boot
	volume_db = -80.0
	play()

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(_delta: float):
	if (!ListenerNode):
		return

	# get the listener current height
	var listenerHeight: float = ListenerNode.global_position.y
	
	# calculate distance above the ocean
	var heightDistance: float = max(0.0, listenerHeight - OceanYLevel)
	
	# calculate a 0.0 to 1.0 volume factor
	var fadeFactor: float = 1.0 - (heightDistance / MaxFadeHeight)
	fadeFactor            = clamp(fadeFactor, 0.0, 1.0)

	# Calculate the exact volume we WANT to reach
	var calculatedDB: float = linear_to_db(fadeFactor)
	
	# only update if the target height volume has actually changed
	if abs(m_TargetVolume - calculatedDB) > 0.1:
		m_TargetVolume = calculatedDB
		smooth_volume_shift(m_TargetVolume)

	# handle pausing optimizations cleanly
	if fadeFactor <= 0.0 and playing:
		stream_paused = true
	elif fadeFactor > 0.0 and stream_paused:
		stream_paused = false
