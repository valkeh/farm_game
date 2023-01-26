extends Node

var n = 1
var creature = preload("res://creatures/animals/aves/doomlord.tscn")

func _ready():
	randomize()
	spawn()

func spawn():
	for i in n:
		var new_creature = creature.instantiate()
		var x = randf_range(0,10)
		var y = randf_range(0,10)
		var rand_pos = Vector2(x,y)
		new_creature.position = rand_pos
		add_child(new_creature)
