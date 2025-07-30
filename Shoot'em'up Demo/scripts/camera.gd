extends Camera3D

# children instances
@onready var g_Fader: ColorRect = $Fader

# constants
const g_ScrollEndPos = -1250

##
# Called when the node enters the scene tree for the first time
###
func _ready():
	g_Fader.show_game_over_msg(false)
	g_Fader.fade_from_black()

###
# Called every frame
#@param delta - elapsed time in seconds since the previous frame
##
func _process(delta):
	# horizontal scroll
	if position.z > g_ScrollEndPos:
		position.z += -10 * delta;
	else:
		position.z = g_ScrollEndPos

###
# Called when player game over sequence ended
##
func _on_player_game_over():
	g_Fader.fade_to_black()
