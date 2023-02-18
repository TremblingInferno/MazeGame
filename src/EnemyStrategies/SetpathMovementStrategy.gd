extends Node


var original_pos
var mirrored_corner
var towards_original:bool = false


func _ready():
	var Main = get_parent().get_parent().Main
	original_pos = get_parent().map_pos
	mirrored_corner = Vector2(Main.west_bounds + 
								(Main.east_bounds - original_pos.x) - 1,
								(Main.height - original_pos.y) - 1)


func get_destination(player:Area2D, map:TileMap): # shared by all enemy move strategies
	var destination
	if towards_original:
		destination = original_pos
	else:
		destination = mirrored_corner
	if original_pos == get_parent().map_pos:
		towards_original = false
	elif mirrored_corner == get_parent().map_pos:
		towards_original = true
	
	return map.map_to_world(destination)
