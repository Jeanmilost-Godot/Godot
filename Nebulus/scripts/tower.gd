extends Node3D

# components
@onready var m_Player: CharacterBody3D = $"../Player"

# variables
var m_Name     = ""
var m_Time     = 0
var m_Robot    = 0
var m_RowCount = 0

var m_ElevatorEndArray: Array[int] = []

# constants
const m_TabChar             = "\t"
const m_RowHeight           = 2.5
const m_PlatformAngle       = 22.5
const m_TextureRepeatOffset = 2.0

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
# Create the tower fundation (i.e. the underwater part)
##
func create_tower_fundation():
	for x in range(10):
		var towerRow = preload("res://scenes/tower_row.tscn").instantiate()
		add_child(towerRow)

		var towerPosY            = 0 - (m_RowHeight * x)
		towerRow.global_position = Vector3(0.0, towerPosY, 0.0)

		# configure the tower row texture in a such manner it repeats harmoniously in the whole tower
		configure_tower_tower_row_texture(towerRow, towerPosY)

func ParseColor(line):
	pass

func parse_data_line(dataIndex, line):
	# first data is the tower row count
	if (dataIndex == 0):
		m_RowCount = line.to_int()
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

			">":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/platform.tscn").instantiate()
				add_child(platform)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				platform.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				platform.global_rotation = Vector3(0.0, rotY, 0.0)

				index += 1

			"-":
				# create a platform and attach it to the scene
				var platform = preload("res://scenes/platform.tscn").instantiate()
				add_child(platform)

				var posY = (m_RowCount * m_RowHeight) - (m_RowHeight * dataIndex)
				platform.global_position = Vector3(0.0, posY, 0.0)

				var rotY = deg_to_rad(m_PlatformAngle * index)
				platform.global_rotation = Vector3(0.0, rotY, 0.0)

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

###
# Called when the node enters the scene tree for the first time
##
func _ready():
	m_ElevatorEndArray.resize(16)

	load_level("res://levels/tower1.txt")

###
# Called every frame at a fixed rate, which allows any processing that requires the physics values
#@param delta - elapsed time in seconds since the previous call
##
func _process(delta):
	pass
