extends Node2D

export var speed := .25
var map : TileMap
var map_pos :Vector2


func on_player_moved(player):
	var final_destination = $MoveStrategy.get_destination(player, map)
	var path = map.get_astar_path(map.map_to_world(map_pos), final_destination)
	if not path:
		return
	map_pos = map.world_to_map(path[1])
	var destination = map.map_to_world(map_pos) + map.cell_size/2
	$Tween.interpolate_property(self, 'position', position, destination, speed,
								Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	$Tween.start()
