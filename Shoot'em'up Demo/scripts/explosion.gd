extends Node3D

# children instances
@onready var g_Sparks: GPUParticles3D = $Sparks
@onready var g_Flash:  GPUParticles3D = $Flash
@onready var g_Fire:   GPUParticles3D = $Fire
@onready var g_Smoke:  GPUParticles3D = $Smoke

##
# Called when the node enters the scene tree for the first time
###
func _ready():
	fire()

###
# Fires the explosion
##
func fire():
	g_Sparks.emitting = true
	g_Flash.emitting  = true
	g_Fire.emitting   = true
	g_Smoke.emitting  = true
