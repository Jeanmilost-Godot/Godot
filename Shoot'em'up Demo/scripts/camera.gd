extends Camera3D

# children instances
@onready var m_Fader: ColorRect = $Fader

# variables
var m_Entities: Entities

# constants
const m_ScrollEndPos = -1250

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_Fader.show_game_over_msg(false)
	m_Fader.fade_from_black()

	m_Entities = Entities.new()

	#REM REM REM
	#var test = BezierCurve.new()
	#test._test()

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	# horizontal scroll
	if position.z > m_ScrollEndPos:
		position.z += -10 * delta;
	else:
		position.z = m_ScrollEndPos

	#REM REM REM
	if !m_Entities.get_entity(0).is_spawned() && position.z <= -20:
		var entity = preload("res://scenes/bat.tscn").instantiate()
		get_tree().current_scene.add_child(entity)

		entity.global_position    =  global_position
		entity.global_position.x  = -40.0
		entity.global_position.y  =  70.0
		entity.global_position.z -=  20.0
		#entity.global_rotation.y  = -90;
		#entity.global_scale(Vector3(7.0, 7.0, 7.0))

		m_Entities.get_entity(0).set_spawned()

###
# Called when player game over sequence ended
##
func _on_player_game_over():
	m_Fader.fade_to_black()
