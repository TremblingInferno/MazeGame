extends Node2D

export var speed := .25
var Map : TileMap
var map_pos :Vector2


const DIRECTIONS := {Vector2.RIGHT : "e", Vector2.UP: "n", Vector2.LEFT: "w", Vector2.DOWN: "s"}

func on_player_moved(player):
	var final_destination = $MoveStrategy.get_destination(player, Map)
	var path = Map.get_astar_path_avoiding_obstacles_and_units(Map.map_to_world(map_pos), final_destination)
	if path.size() < 2:
		return
	var next_map_pos = Map.world_to_map(path[1])
#	if get_parent().enemy_in_spot(next_map_pos):
#		return
	$Sprite.animation = DIRECTIONS[next_map_pos - map_pos]
	map_pos = next_map_pos 
	var destination = Map.map_to_world(map_pos) + Map.cell_size / 2 
	$Tween.interpolate_property(self, 'position', position, destination, speed,
								Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()

