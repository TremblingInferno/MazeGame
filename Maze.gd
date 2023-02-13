extends Node2D

export(Curve) var erase_curve


const N = 1
const E = 2
const S = 4
const W = 8

var cell_walls = {Vector2(0, -1): N, Vector2(1, 0): E, 
				  Vector2(0, 1): S, Vector2(-1, 0): W}

var tile_size = 64  # tile size (in pixels)
var width = 40  # width of map (in tiles)
var height = 24  # height of map (in tiles)

var map_seed = 675343778

# fraction of walls to remove
var erase_fraction = 0.1

# get a reference to the map for convenience
onready var Map = $TileMap

func _ready():
	randomize()
	if !map_seed:
		map_seed = randi()
	seed(map_seed)
	print("Seed: ", map_seed)
	tile_size = Map.cell_size
	
	var start_point = Vector2(-2,height/2)
	$Player.map = Map
	$Player.position = Map.map_to_world(start_point) + Vector2(32,32)
	$Player.map_pos = start_point
	make_maze(start_point)
	erase_walls()


func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n*2 in unvisited:
			list.append(cell + n*2)
	return list


func make_maze(start_point, end_point = Vector2(width, height/2)):
	var unvisited = []  # array of unvisited tiles
	var stack = []
	# fill the map with solid tiles
	Map.clear()
	for x in range(width):
		for y in range(height):
			Map.set_cellv(Vector2(x, y), N|E|S|W)
	for x in range(0, width, 2):
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
	Map.set_cellv(end_point, 5)
	create_line(end_point, Vector2(-2, 0))


func create_line(cell, dist:Vector2):
	var dir = dist.normalized()
	for i in dist.length():
		var next = cell + dir
		
		if Map.get_cellv(cell) < 0:
			Map.set_cellv(cell, 15)
		if Map.get_cellv(next) < 0:
			Map.set_cellv(next, 15)
		print(Map.get_cellv(cell))
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
	var width_size = int(width)
	create_line(Vector2(0,0), Vector2(0, height - 2))
	create_line(Vector2(width-2, 0), Vector2(0, height - 2))
	for i in width_size:
		var x = clamp((i + 2) * 2, 2, width_size/2)
		
		var y = int(rand_range(2, height/2 - 2)) * 2
		var cell = Vector2(x, y)
		# pick random neighbor
		var neighbor = cell_walls.keys()[randi() % cell_walls.size()] * 2
		if Map.get_cellv(cell) & cell_walls[neighbor.normalized()]:
			create_line(cell, neighbor)
