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
	# on opening show the level from black screen
	m_Fader.show_game_over_msg(false)
	m_Fader.fade_from_black()

	# create the entities
	m_Entities = Entities.new()

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

	# iterate through entities
	for i  in range(m_Entities.get_count()):
		# do spawn the entity?
		if !m_Entities.is_spawned(i) && position.z <= m_Entities.get_spawn_pos(i):
			# notify that the entity was spawned, this way it will not be respawn infinitely
			m_Entities.set_spawned(i)

			# get the entity scene and add it to parent one
			var entity = m_Entities.get_scene(i).instantiate()
			get_tree().current_scene.add_child(entity)

			# set the entity start position
			entity.global_position = m_Entities.get_start_pos(i)

###
# Called when player game over sequence ended
##
func _on_player_game_over():
	m_Fader.fade_to_black()
