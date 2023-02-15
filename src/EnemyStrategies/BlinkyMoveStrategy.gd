extends Node

func get_destination(player:Area2D, map:TileMap): # shared by all enemy move strategies
	var destination = map.map_to_world(player.map_pos)
	return destination
