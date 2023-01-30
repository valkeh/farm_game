extends Node

var animal_id_counter = 1
var animal_spawn_points = [Vector2(0, 0)]
var open_locations = [0,1,2]
var occupied_locations = {}
var animal_list = {}

func SpawnAnimal(location, animal_type):
	print(animal_type)
	animal_list[animal_id_counter] = {"AnimalType": animal_type, "AnimalLocation": location, "AnimalState": "Idle", "time_out": 1}
	animal_id_counter += 1
