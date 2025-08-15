extends Node3D

# children instances
@onready var m_Sparks: GPUParticles3D = $Sparks
@onready var m_Flash:  GPUParticles3D = $Flash
@onready var m_Fire:   GPUParticles3D = $Fire
@onready var m_Smoke:  GPUParticles3D = $Smoke

##
# Called when the node enters the scene tree for the first time
###
func _ready():
	fire()

###
# Fires the explosion
##
func fire():
	m_Sparks.emitting = true
	m_Flash.emitting  = true
	m_Fire.emitting   = true
	m_Smoke.emitting  = true
