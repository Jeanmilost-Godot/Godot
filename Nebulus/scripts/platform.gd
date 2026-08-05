extends StaticBody3D

# components
@onready var m_Platform:           MeshInstance3D      = $Model
@onready var m_Hologram:           MeshInstance3D      = $Hologram
@onready var m_Collider:           CollisionShape3D    = $Collider
@onready var m_HologramBreakSound: AudioStreamPlayer3D = $HologramBreakSound

# variables
var m_Velocity:       float = 0.0
var m_FadeDuration:   float = 0.2
var m_IsHologram:     bool  = false
var m_HologramBroken: bool  = false

# signals
signal do_player_swip(swip, dir)

###
# Ensures that transparency is enabled in mesh material
#@param meshInst - mesh instance for which the transparency should be enabled
#@note MeshInstance3D.transparency only has visible effect if the material's transparency mode 
#      allows it (Alpha or Alpha Scissor)
##
func ensure_transparent(meshInst: MeshInstance3D):
	var mat := meshInst.get_surface_override_material(0)

	if (!mat):
		mat = meshInst.mesh.surface_get_material(0).duplicate()
		meshInst.set_surface_override_material(0, mat)

	if (mat is BaseMaterial3D):
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

###
# Sets the platform an hologram
##
func set_hologram():
	m_Platform.visible = false
	m_Hologram.visible = true

	m_IsHologram = true

###
# Called when a body entered in the platform swip trigger zone
#param body - body which entered in the swip trigger zone
##
func _on_swip_trigger_zone_body_entered(body):
	# is an hologram, ignore
	if (m_IsHologram):
		return

	# ignore any body but player
	if body.name != "Player":
		return

	do_player_swip.emit(true, m_Velocity)

###
# Called when a body leaved the platform swip trigger zone
#param body - body which leaved the swip trigger zone
##
func _on_swip_trigger_zone_body_exited(body):
	# is an hologram, ignore
	if (m_IsHologram):
		return

	# ignore any body but player
	if body.name != "Player":
		return

	do_player_swip.emit(false, 0.0)

###
# Called when a body entered in the platform hologram trigger zone
#param body - body which entered in the hologram trigger zone
##
func _on_hologram_trigger_zone_body_entered(body):
	# not an hologram, or already broken, ignore
	if (!m_IsHologram or m_HologramBroken):
		return

	# ignore any body but player
	if body.name != "Player":
		return

	m_Hologram.visible = false

	# disable the platform collider
	m_Collider.set_deferred("disabled", true)

	if (!m_HologramBreakSound.is_playing()):
		m_HologramBreakSound.play()

	m_HologramBroken = true
