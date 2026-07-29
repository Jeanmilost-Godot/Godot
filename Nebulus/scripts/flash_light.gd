extends Node3D

# components
@onready var m_Light:        SpotLight3D    = $Core/Light
@onready var m_CounterLight: SpotLight3D    = $Core/CounterLight
@onready var m_Core:         MeshInstance3D = $Core

# variables
var m_Enabled: bool = false

# constants
const m_LightEnergy:        float = 2.3
const m_CounterLightEnergy: float = 15.0
const m_Velocity:           float = 10.0

###
# Enables the light
#@param duration - light fade in duration
##
func light_fade_in(duration := 0.1):
	# fade in the light
	m_Light.visible = true
	m_Light.light_energy = 0.0
	var lightTween = create_tween()
	lightTween.tween_property(m_Light, "light_energy", m_LightEnergy, duration)

	# fade in the counter light
	m_CounterLight.visible = true
	m_CounterLight.light_energy = 0.0
	var counterLightTween = create_tween()
	counterLightTween.tween_property(m_CounterLight, "light_energy", m_CounterLightEnergy, duration)

	m_Enabled = true

###
# Disables the light
#@param duration - light fade out duration
##
func light_fade_out(duration := 0.1):
	# fade out the light
	var lightTween = create_tween()
	lightTween.tween_property(m_Light, "light_energy", 0.0, duration)
	lightTween.tween_callback(func(): m_Light.visible = false)

	# fade out the counter light
	var counterLightTween = create_tween()
	counterLightTween.tween_property(m_CounterLight, "light_energy", 0.0, duration)
	counterLightTween.tween_callback(func(): m_CounterLight.visible = false)

	m_Enabled = false

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_Light.visible        = false
	m_CounterLight.visible = false

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	# do nothing if not enabled
	if (not m_Enabled):
		return

	# rotate the light to apply a siren light effect
	m_Core.global_rotation.y = wrapf(m_Core.global_rotation.y + (m_Velocity * delta), -PI, PI)
