extends CharacterBody3D

# children instances
@onready var g_Seagull: Node3D = $seagull

# constants
const g_Speed           = 20.0
const g_FireRateTime    = 0.1
const g_GameOverTimeout = 2.0

# global variables
var g_ElapsedFireTime = 0.0
var g_GameOverTime    = 0.0
var g_GameOver        = false
var g_GameOverEmitted = false

# signals
signal game_over()

###
# Fires a projectile
##
func fire_projectile():
	# wait for fire rate time elapsed before firing a new projectile
	if (g_ElapsedFireTime < g_FireRateTime):
		return

	# create a projectile and attach it to the scene
	var projectile = preload("res://scenes/seagull_projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position    = global_position
	projectile.global_position.z -= 5.0
	projectile.fire(200.0)

	g_ElapsedFireTime = 0.0

###
# Runs the game over sequence
##
func run_game_over():
	if g_GameOver:
		return

	g_GameOver = true

	# hide the player model
	g_Seagull.hide();

	# create an explosion and attach it to the scene
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	get_tree().current_scene.add_child(explosion)

	explosion.global_position    = global_position
	explosion.fire()

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	g_ElapsedFireTime += delta

	# is game over?
	if g_GameOver:
		g_GameOverTime += delta

		# game over timeout?
		if (!g_GameOverEmitted && g_GameOverTime >= g_GameOverTimeout):
			# signal other classes that game is over
			game_over.emit()
			g_GameOverEmitted = true

		return

	var inputDir: Vector3

	# do move the player to the left or right?
	if Input.is_action_pressed("left"):
		inputDir.x = -1.0
	elif Input.is_action_pressed("right"):
		inputDir.x = 1.0

	# do move the player to the top or bottom?
	if Input.is_action_pressed("top"):
		inputDir.y = 1.0
	elif Input.is_action_pressed("bottom"):
		inputDir.y = -1.0

	# calculate the player direction
	var direction = (transform.basis * Vector3(0, inputDir.y, inputDir.x)).normalized()

	# move the player
	if direction:
		velocity.y = direction.y * g_Speed
		velocity.z = direction.z * g_Speed
	else:
		velocity.y = move_toward(velocity.y, 0, g_Speed)
		velocity.z = move_toward(velocity.z, 0, g_Speed)

	move_and_slide()

	# limit the item position into the screen
	position.x = clamp(position.x, -45, 45)
	position.y = clamp(position.y, -5,  20) 

	# fire a projectile
	if Input.is_action_pressed("fire"):
		fire_projectile()

	# cancel the game
	if Input.is_action_pressed("cancel"):
		run_game_over()
