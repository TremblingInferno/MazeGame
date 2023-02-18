extends Node2D

export(NodePath) onready var EndGoal = get_node(EndGoal)


const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 64  # tile size (in pixels)
var width = 40  # width of map (in tiles)
var height = 24  # height of map (in tiles)

var west_bounds = 0
var east_bounds = width
var completed_rooms = 0
var start_point
var end_point

var map_seed

# fraction of walls to remove
var erase_fraction = 0.1

# get a reference to the map for convenience
onready var Map = $TileMap

export(PackedScene) var Enemy


func _ready():
	randomize()
	if !map_seed:
		map_seed = randi()
	seed(map_seed)
	print("Seed: ", map_seed)
	tile_size = Map.cell_size
	$Camera2D.offset = Map.map_to_world(Vector2(east_bounds - width/2, height/2)) - Vector2(32,0)
	set_bounds(completed_rooms)
	$Player.map = Map
	$Player.position = Map.map_to_world(start_point) + Map.cell_size/2
	$Player.map_pos = start_point
	make_maze()
	SoundManager.play_music()



func set_bounds(room_num):
	var dist = (width+2) * room_num
	west_bounds = dist 
	east_bounds = dist + width
	
	start_point = Vector2(west_bounds-2,height/2)
	end_point = Vector2(east_bounds, height/2)
	var camera_destination = Map.map_to_world(Vector2(east_bounds - width/2, height/2)) - Vector2(32,0)
	$Tween.interpolate_property($Camera2D, 'offset', 
								$Camera2D.offset, camera_destination, 1,
								Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()


func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n*2 in unvisited:
			list.append(cell + n*2)
	return list


func make_maze():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(west_bounds - 2, east_bounds + 2):
		for y in range(-2, height + 1):
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	for x in range(west_bounds, east_bounds, 2):
		for y in range(0, height, 2):
			unvisited.append(Vector2(x, y))
	var current = start_point

	unvisited.erase(current)
	# execute recursive backtracker algorithm
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current
			create_line(current, dir)
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		if completed_rooms > 0:
			if randi() % 4 == 0:
				yield(get_tree().create_timer(0.01), "timeout")
	set_end_point()
	yield(erase_walls(), "completed")
	Map.update()
	$Line2D.position = Map.cell_size/22
	$Line2D.points = Map.get_astar_path(Map.map_to_world(start_point), Map.map_to_world(end_point))
	$Enemies.spawn_enemies()


func create_line(cell, dist:Vector2):
	var dir = dist.normalized()
	for i in dist.length():
		var next = cell + dir
		
		if Map.get_cellv(cell) < 0:
			Map.set_cellv(cell, 15)
		if Map.get_cellv(next) < 0:
			Map.set_cellv(next, 15)
		var current_walls = Map.get_cellv(cell)
		var next_walls = Map.get_cellv(next)
		if current_walls & cell_walls[dir]:
			current_walls = current_walls - cell_walls[dir]
		if next_walls & cell_walls[-dir]:
			next_walls = next_walls - cell_walls[-dir]
		Map.set_cellv(cell, current_walls)
		Map.set_cellv(next, next_walls)
		cell += dir


func erase_walls():
	# randomly remove a number of the map's walls
	create_line(Vector2(west_bounds, 0), Vector2(0, height - 2))
	create_line(Vector2(east_bounds - 2, 0), Vector2(0, height - 2))
	for _i in range(int(width * height * erase_fraction)):
		var x = int(rand_range(west_bounds/2 + 2, east_bounds/2 - 2)) * 2
		var y = int(rand_range(2, height/2 - 2)) * 2
		var cell = Vector2(x, y)
		# pick random neighbor
		var neighbor = cell_walls.keys()[randi() % cell_walls.size()] * 2
		if Map.get_cellv(cell) & cell_walls[neighbor.normalized()]:
			create_line(cell, neighbor)
		if completed_rooms > 0:
			if randi() % 2 == 0:
				yield(get_tree().create_timer(0.01), "timeout")
	yield(get_tree(), "idle_frame")


func set_end_point():
	Map.set_cellv(end_point, 7)
	create_line(end_point, Vector2(-2, 0))
	EndGoal.position = Map.map_to_world(end_point) + Vector2(32,32)


func _on_End_finished():
	completed_rooms += 1
	$Enemies.remove_enemies()
	set_bounds(completed_rooms)
	SoundManager.play_level_creation()
	make_maze()

