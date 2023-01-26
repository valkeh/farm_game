extends "res://scripts/bird.gd"

func _on_Area2D_area_exited(area):
	if area.is_in_group("perch"):
		walking = false
		flying = true
		print("exited")
