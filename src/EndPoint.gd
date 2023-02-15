extends Node2D

signal finished


func _on_Area2D_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	position = Vector2(-1000,-1000) # just get it out of the way
	emit_signal("finished")
