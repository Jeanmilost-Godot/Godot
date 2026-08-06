extends Node3D

# components
@onready var flash_particles: GPUParticles3D = $FlashParticles
@onready var spark_particles: GPUParticles3D = $SparkParticles

###
# Starts the explosion effect
##
func start():
	# start both systems immediately
	flash_particles.emitting = true
	spark_particles.emitting = true
