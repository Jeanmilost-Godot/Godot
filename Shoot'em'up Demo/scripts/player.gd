extends CharacterBody3D

# children instances
@onready var m_Seagul: Node3D = $Model

# constants
const m_Speed           = 20.0
const m_FireRateTime    = 0.1
const m_GameOverTimeout = 2.0

# global variables
var m_ElapsedFireTime = 0.0
var m_GameOverTime    = 0.0
var m_GameOver        = false
var m_GameOverEmitted = false

# signals
signal game_over()

###
# Fires a projectile
##
func fire_projectile():
	# wait for fire rate time elapsed before firing a new projectile
	if (m_ElapsedFireTime < m_FireRateTime):
		return

	# create a projectile and attach it to the scene
	var projectile = preload("res://scenes/seagull_projectile.tscn").instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position    = global_position
	projectile.global_position.z -= 5.0
	projectile.fire(200.0)

	m_ElapsedFireTime = 0.0

###
# Runs the game over sequence
##
func run_game_over():
	if m_GameOver:
		return

	m_GameOver = true

	# hide the player model
	m_Seagul.hide();

	# create an explosion and attach it to the scene
	var explosion = preload("res://scenes/explosion.tscn").instantiate()
	get_tree().current_scene.add_child(explosion)

	explosion.global_position = global_position
	explosion.fire()

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	CollisionManager.do_delete.connect(_on_collision_manager_do_delete)

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _physics_process(delta):
	m_ElapsedFireTime += delta

	# is game over?
	if m_GameOver:
		m_GameOverTime += delta

		# game over timeout?
		if (!m_GameOverEmitted && m_GameOverTime >= m_GameOverTimeout):
			# signal other classes that game is over. NOTE game over signal is not emitted immediately
			# when player is hit to let the time to play the explosion sequence
			game_over.emit()
			m_GameOverEmitted = true

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
		velocity.y = direction.y * m_Speed
		velocity.z = direction.z * m_Speed
	else:
		velocity.y = move_toward(velocity.y, 0.0, m_Speed)
		velocity.z = move_toward(velocity.z, 0.0, m_Speed)

	# move the player and check for collision
	var collision = move_and_collide(velocity * delta)

	# found a collision?
	if collision:
		var collider = collision.get_collider()

		# collided something in the scene?
		if collider is CharacterBody3D or collider is StaticBody3D:
			# register collision in manager
			CollisionManager.register_collision(self, collider)

	# limit the item position into the screen
	position.x = clamp(position.x, -45.0, 45.0)
	position.y = clamp(position.y, -5.0,  25.0) 

	# fire a projectile
	if Input.is_action_pressed("fire"):
		fire_projectile()

	# cancel the game
	if Input.is_action_pressed("cancel"):
		run_game_over()

###
# Called when the collision manager notifies that the item should be deleted
#@param obj1 - first object involved in the collision, may be either the item itself or its collider
#@param obj1 - second object involved in the collision, may be either the item itself or its collider
##
func _on_collision_manager_do_delete(obj1, obj2):
	if (obj1 != self and obj2 != self):
		return

	run_game_over()
