extends StaticBody3D

# components
@onready var m_TopFlashLight:    Node3D = $Model/Light1
@onready var m_BottomFlashLight: Node3D = $Model/Light2
@onready var m_Base:             Node3D = $Model/Base

# states
enum IEState {S_Idle, S_MoveUp, S_MoveDown}

# variables
var m_State:        IEState = IEState.S_Idle
var m_InitialY:     float   = 0.0
var m_InitialBaseY: float   = 0.0
var m_Active:       bool    = false

# constants
const m_Velocity: float = 5.0

# signals
signal can_use_elevator(canUse, elevator)

func get_base_height() -> float:
	var mesh := m_Base.mesh as CylinderMesh

	if mesh:
		return mesh.height

	return 1.25

func set_base_height(height: float):
	var mesh := m_Base.mesh as CylinderMesh

	if mesh:
		# create a standalone copy, otherwise all the bases in each elevators will be affected
		mesh        = mesh.duplicate()
		mesh.height = height
		m_Base.mesh = mesh
###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_InitialY     = global_position.y
	m_InitialBaseY = m_Base.global_position.y

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

			if (global_position.y <= m_InitialY):
				global_position.y = m_InitialY
				m_State           = IEState.S_Idle
				return

			global_position.y -= m_Velocity * delta

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

	m_State = IEState.S_MoveUp

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

	m_State = IEState.S_Idle
