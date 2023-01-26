extends Node

var mapstart = preload("res://Scenes/MainScenes/Map.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var mapstart_instance = mapstart.instantiate()
	add_child(mapstart_instance)

