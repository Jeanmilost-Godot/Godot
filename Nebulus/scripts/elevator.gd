extends StaticBody3D

# components
@onready var m_TopFlashLight:    Node3D = $Model/Light1
@onready var m_BottomFlashLight: Node3D = $Model/Light2
@onready var m_Base:             Node3D = $Model/Base
@onready var m_IdleTimer:        Timer  = $IdleTimer

# states
enum IEState {S_Idle, S_MoveUp, S_MoveDown}

# variables
var m_State:      IEState = IEState.S_Idle
var m_StartY:     float   = 0.0
var m_EndY:       float   = 0.0
var m_StartBaseY: float   = 0.0
var m_Active:     bool    = false

# constants
const m_Velocity: float = 5.0

# signals
signal can_use_elevator(canUse, elevator)

###
# Gets the elevator base height
#@return the elevator base height
##
func get_base_height() -> float:
	var mesh := m_Base.mesh as CylinderMesh

	if mesh:
		return mesh.height

	return 1.25

###
# Sets the elevator base height
#@param height - the elevator base height
##
func set_base_height(height: float):
	var mesh := m_Base.mesh as CylinderMesh

	if mesh:
		# create a standalone copy, otherwise all the bases in each elevators will be affected
		mesh        = mesh.duplicate()
		mesh.height = height
		m_Base.mesh = mesh

###
# Uses the elevator
##
func use():
	# don't use if already running
	if (is_using()):
		return

	m_State = IEState.S_MoveUp

###
# Checks if the elevator is using
#@return true if elevator is using, otherwise false
##
func is_using() -> bool:
	return (m_State != IEState.S_Idle)

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_IdleTimer.timeout.connect(_on_idle_timer_timeout)

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	match (m_State):
		IEState.S_Idle:
			if (m_Active):
				# disable the lights
				m_TopFlashLight.light_fade_out()
				m_BottomFlashLight.light_fade_out()
				m_Active = false

		IEState.S_MoveUp:
			if (not m_Active):
				# enable the lights
				m_TopFlashLight.light_fade_in()
				m_BottomFlashLight.light_fade_in()
				m_Active = true

			if (global_position.y >= m_EndY):
				global_position.y = m_EndY
				m_State           = IEState.S_Idle

				# start the timer which allows the elevator to move down after a waiting time
				m_IdleTimer.start(5.0)
				return

			var velocity = m_Velocity * delta

			global_position.y        += velocity
			m_Base.global_position.y -= velocity / 2.0

			set_base_height(get_base_height() + velocity)

		IEState.S_MoveDown:
			if (not m_Active):
				# enable the lights
				m_TopFlashLight.light_fade_in()
				m_BottomFlashLight.light_fade_in()
				m_Active = true

			if (global_position.y <= m_StartY):
				global_position.y = m_StartY
				m_State           = IEState.S_Idle
				return

			var velocity = m_Velocity * delta

			global_position.y        -= m_Velocity * delta
			m_Base.global_position.y += velocity / 2.0

			set_base_height(get_base_height() - velocity)


###
# Called when the idle timer, which is run after elevator hits the top, triggers
##
func _on_idle_timer_timeout() -> void:
	m_State = IEState.S_MoveDown

###
# Called when a body enters in the trigger zone
#param body - body which entered in the trigger zone
##
func _on_trigger_zone_body_entered(body):
	# ignore any body but player
	if body.name != "Player":
		return

	# notify that elevator may be used
	can_use_elevator.emit(true, self)

###
# Called when a body leaves the trigger zone
#param body - body which leaved the trigger zone
##
func _on_trigger_zone_body_exited(body):
	# ignore any body but player
	if body.name != "Player":
		return

	# notify that elevator may no longer be used
	can_use_elevator.emit(false, null)
