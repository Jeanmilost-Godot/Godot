extends Node3D

# components
@onready var m_Player: CharacterBody3D = $"../Player"

# variables
var m_Name     = ""
var m_Time     = 0
var m_Robot    = 0
var m_RowCount = 0

var m_ElevatorEndArray: Array[int]   = []
var m_StairsArray:      Array[Array] = []

# constants
const m_TabChar:                   = "\t"
const m_ColumnCount:         int   = 16
const m_RowHeight:           float = 2.5
const m_PlatformAngle:       float = 22.5
const m_TextureRepeatOffset: float = 2.0

###
# Loads and assigns the ice material to the mesh
#@param meshInst - mesh instance for which the material should be loaded and applied
##
func load_ice_material(meshInst: MeshInstance3D):
	if (!meshInst):
		return

	var mat = meshInst.get_surface_override_material(0)

	if mat == null:
		mat = meshInst.mesh.surface_get_material(0).duplicate()
		meshInst.set_surface_override_material(0, mat)

	# change albedo
	mat.albedo_texture = load("res://assets/textures/ice/ice_field_albedo.png")

	# change normal map
	mat.normal_enabled = true
	mat.normal_texture = load("res://assets/textures/ice/ice_field_normal-ogl.png")

	# change ambient occlusion
	mat.ao_enabled = true
	mat.ao_texture = load("res://assets/textures/ice/ice_field_ao.png")

	# change height / parallax
	mat.heightmap_enabled = true
	mat.heightmap_texture = load("res://assets/textures/ice/ice_field_height.png")
	mat.heightmap_scale   = 0.05

###
# Gets the material associated to the mesh
#@param meshInst - mesh instance for which the material should be get
#@return material, null if not found or on error
##
func get_material(meshInst: MeshInstance3D) -> StandardMaterial3D:
	if (!meshInst):
		return null

	var mat := meshInst.get_surface_override_material(0)

	if (!mat):
		mat = meshInst.mesh.surface_get_material(0)

	return mat

###
#Configures the tower row texture in a such manner it repeats perfectly with other rows
#@param towerRow - tower row for which the texture should be configured
#@param towerPosY - current y position of the tower row
##
func configure_tower_tower_row_texture(towerRow: Node3D, towerPosY: float):
	var towerNode:    MeshInstance3D     = towerRow.get_node("Tower")
	var towerBodyMat: StandardMaterial3D = get_material(towerNode)

	if (!towerBodyMat):
		return

	# make material unique per tower instance, otherwise every row shares (and fights over) the same
	# material resource and they'll all show the same offset/scale
	towerBodyMat = towerBodyMat.duplicate()
	towerNode.set_surface_override_material(0, towerBodyMat)

	# stretch the Y tiling so one full texture repeat spans every repeat offset
	towerBodyMat.uv1_scale.y = m_RowHeight / m_TextureRepeatOffset

	# offset in that same rescaled space, using the tower's world Y, so consecutive rows continue
	# the same repeating pattern instead of each restarting at UV 0
	towerBodyMat.uv1_offset.y = fposmod(towerPosY / m_TextureRepeatOffset, 1.0)

###
# Creates the tower fundation (i.e. the underwater part)
##
func create_tower_fundation():
	# iterate through rows to create
	for x in range(10):
		# create a row
		var towerRow = preload("res://scenes/tower_row.tscn").instantiate()
		add_child(towerRow)

		# set its position
		var towerPosY            = 0 - (m_RowHeight * x)
		towerRow.global_position = Vector3(0.0, towerPosY, 0.0)

		# configure the tower row texture in a such manner it repeats harmoniously in the whole tower
		configure_tower_tower_row_texture(towerRow, towerPosY)

###
# Enables a ramp collider which allows the platform to acts as a stair
#@param platform - platform which may acts as a stair
#@param row - current row on which the platform is
#@param col - current column on which the platform is
##
func enable_stairs(platform: Node3D, row: int, col: int):
	var nextRow = row + 1

	# can ignore the last rows, there are no platform above them
	if (nextRow >= m_RowCount):
		return

	# do enable left ramp?
	if (m_StairsArray[row + 1][((col + m_ColumnCount) - 1) % m_ColumnCount]):
		var ramp = platform.get_node("LeftRamp")

		if (ramp):
			ramp.disabled = false
		else:
			print("Load level - FAILED - Cannot find platform left ramp collider - row - " + str(row) + " - col - " + str(col))

	# do enable right ramp?
	if (m_StairsArray[row + 1][(col + 1) % m_ColumnCount]):
		var ramp = platform.get_node("RightRamp")

		if (ramp):
			ramp.disabled = false
		else:
			print("Load level - FAILED - Cannot find platform right ramp collider - row - " + str(row) + " - col - " + str(col))

###
# Finalizes the level geometry after fully loaded
##
func finalize_level_geometry():
	# get all spawned platforms via the group tag
	var platforms = get_tree().get_nodes_in_group("LevelPlatforms")

	# iterate through platforms
	for platform in platforms:
		var row = platform.get_meta("row")
		var col = platform.get_meta("col")
		
		# prevent out of bounds checks on row 0
		if row <= 0:
			continue

		# check if the ramp collider should be enabled on the platform left or right to turn it a stair
		enable_stairs(platform, row, col)

func ParseColor(line):
	pass

func parse_data_line(dataIndex, line):
	# first data is the tower row count
	if (dataIndex == 0):
		# get total row count
		m_RowCount = line.to_int()

		# resize the arrays used to read the file
		m_ElevatorEndArray.resize(m_ColumnCount)
		m_StairsArray.resize(m_RowCount)

		# for each stairs, resize the row array
		for i in m_StairsArray:
			i.resize(m_ColumnCount)

			#initialize it with default value
			for j in i:
				j = false

		return

	# add a new tower row to the scene
	var towerRow = preload("res://scenes/tower_row.tscn").instantiate()
	add_child(towerRow)

	# calculate the tower row position, remember that the file is read from top to bottom, whereas
	# the tower is built from the bottom to the top
	var towerPosY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
	towerRow.global_position = Vector3(0.0, towerPosY, 0.0)

	# configure the tower row texture in a such manner it repeats harmoniously in the whole tower
	configure_tower_tower_row_texture(towerRow, towerPosY)

	var index   = 0;
	var portal1 = null
	var portal2 = null

	# iterate through line chars
	for x in range(line.length()):
		# get next char
		var ch = line[x]

		# dispatch it
		match ch:
			# skip empty spaces and line end marker
			m_TabChar: index  = (index + 4) - (index % 4)
			" ":       index += 1
			"|":       index += 1

			"!":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/blocker.tscn").instantiate()
				add_child(platform)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				platform.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				platform.global_rotation = Vector3(0.0, rotY, 0.0)

				index += 1

			"#":
				# create a portal and attach it to the scene. NOTE the portal is always set above a
				# platform in the level files, for that reason it is located lower on the y axis
				var portal = preload("res://scenes/portal.tscn").instantiate()
				add_child(portal)

				# connect the portal signals to the player
				portal.can_enter_portal.connect(m_Player._on_can_enter_portal)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex) - m_RowHeight + 0.5
				portal.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				portal.global_rotation = Vector3(0.0, rotY, 0.0)

				# keep portals in order to associate them
				if (portal1 == null):
					portal1 = portal
				elif (portal2 == null):
					portal2 = portal
				else:
					print("Loading level - ERROR - too many portals on the same row")

				index += 1

			"v":
				# keep the last known elevator end, will be used later to define the elevator max height limit
				m_ElevatorEndArray[index] = dataIndex
				index += 1

			"^":
				# create an elevator and attach it to the scene. NOTE the elevator is always set above
				# a platform in the level files, for that reason it is located lower on the y axis
				var elevator = preload("res://scenes/elevator.tscn").instantiate()
				add_child(elevator)

				# connect the elevator signals to the player
				elevator.can_use_elevator.connect(m_Player._on_can_use_elevator)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex) - m_RowHeight + 1.5
				elevator.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				elevator.global_rotation = Vector3(0.0, rotY, 0.0)

				elevator.m_StartY     = elevator.global_position.y
				elevator.m_StartBaseY = elevator.m_Base.global_position.y

				# calculate the elevator end position
				elevator.m_EndY = (m_RowCount * m_RowHeight) - (m_RowHeight * m_ElevatorEndArray[index]) + 1.2

				index += 1

			">", "<":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/platform.tscn").instantiate()
				add_child(platform)

				var platformNode: MeshInstance3D = platform.get_node("Model")
				load_ice_material(platformNode)
				
				# tag the platform node with its level grid coordinates
				platform.set_meta("row", dataIndex)
				platform.set_meta("col", index)
				platform.add_to_group("LevelPlatforms")

				# connect the platform signals to the player
				platform.do_player_swip.connect(m_Player._on_do_player_swip)

				# set platform swipping velocity
				platform.m_Velocity = 0.01 if ch == ">" else -0.01

				# set platform position
				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				platform.global_position = Vector3(0.0, posY, 0.0)

				# set platform rotation
				var rotY = deg_to_rad(m_PlatformAngle * index)
				platform.global_rotation = Vector3(0.0, rotY, 0.0)

				# activate platform in the stairs array at row and column
				m_StairsArray[dataIndex][index] = true

				index += 1

			"-":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/platform.tscn").instantiate()
				add_child(platform)

				# tag the platform node with its level grid coordinates
				platform.set_meta("row", dataIndex)
				platform.set_meta("col", index)
				platform.add_to_group("LevelPlatforms")

				# set platform position
				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				platform.global_position = Vector3(0.0, posY, 0.0)

				# set platform rotation
				var rotY = deg_to_rad(m_PlatformAngle * index)
				platform.global_rotation = Vector3(0.0, rotY, 0.0)

				# activate platform in the stairs array at row and column
				m_StairsArray[dataIndex][index] = true

				index += 1

			"L":
				# create a lamp and attach it to the scene
				var lamp = preload("res://scenes/wall_lamp.tscn").instantiate()
				add_child(lamp)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				lamp.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				lamp.global_rotation = Vector3(0.0, rotY, 0.0)

				index += 1

			_:
				# default, unknown char, log and skip
				print("Loading level - unknown char found - " + ch)
				index += 1

	# bind portals together
	if (portal1 and portal2):
		portal1.m_ConnectedPortal = portal2
		portal2.m_ConnectedPortal = portal1
	elif (portal1 or portal2):
		print("Loading level - ERROR - only one portal on the row - cannot bind")

func parse_demo_line(demoIndex, line):
	var value = line.to_int()
	#print("Demo value:", value)

###
# Loads a tower level
#@param fileName - tower level file name
##
func load_level(fileName):
	# create the tower fundation (the underwater part)
	create_tower_fundation()

	# open the tower level file
	var file = FileAccess.open(fileName, FileAccess.READ)

	var section   = ""
	var dataIndex = 0
	var demoIndex = 0

	# iterate through file lines until the file end is reached
	while not file.eof_reached():
		# get next line
		var line = file.get_line().trim_suffix("\r")

		# detect section headers
		if line.begins_with("[") and line.ends_with("]"):
			section = line
			continue

		# process the current section
		match section:
			"[name]":  m_Name = line
			"[color]": ParseColor(line)
			"[time]":  m_Time = line.to_int()
			"[robot]": m_Robot = line.to_int()
			
			"[data]":
				parse_data_line(dataIndex, line)
				dataIndex += 1

			"[demo]":
				parse_demo_line(demoIndex, line)
				demoIndex += 1

	finalize_level_geometry()

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	load_level("res://levels/tower1.txt")

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	pass
