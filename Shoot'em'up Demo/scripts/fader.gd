extends ColorRect

# children instances
@onready var g_GameOverMsg: RichTextLabel = $GameOverMsg

###
# Fades the whole screen from black
#@param duration - fade duration, in seconds
#@param applyOnGameOverMsg - if true, the fading effect will also be applied on game over message
##
func fade_from_black(duration: float = 1.0, applyOnGameOverMsg: bool = true):
	# vary the alpha value until reaching the min value after a given duration
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, duration)
	
	# do apply the fader on game over message?
	if applyOnGameOverMsg:
		# vary the alpha value until reaching the min value after a given duration
		var gameOverTween = create_tween()
		gameOverTween.tween_property(g_GameOverMsg, "modulate:a", 0.0, duration)

###
# Fades the whole screen to black
#@param duration - fade duration, in seconds
#@param applyOnGameOverMsg - if true, the fading effect will also be applied on game over message
##
func fade_to_black(duration: float = 1.0, applyOnGameOverMsg: bool = true):
	# vary the alpha value until reaching the max value after a given duration
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, duration)

	# do apply the fader on game over message?
	if applyOnGameOverMsg:
		# vary the alpha value until reaching the max value after a given duration
		var gameOverTween = create_tween()
		gameOverTween.tween_property(g_GameOverMsg, "modulate:a", 1.0, duration)

###
# Show or hide the game over message
#@param show - if true, game over message will be shown, hidden otherwise
##
func show_game_over_msg(show):
	if show:
		g_GameOverMsg.modulate.a = 1.0
	else:
		g_GameOverMsg.modulate.a = 0.0
