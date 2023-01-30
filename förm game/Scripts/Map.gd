extends Node

var player_spawn = preload("res://Scenes/SupportScenes/PlayerTemplate.tscn")
var last_world_state = 0

var world_state_buffer = []
const interpolation_offset = 250

	
func save_game():
	var savegame = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		#if node.filename.empty():
		#	print("persistent node '%s' is not an instanced scene, skipped" % node.name)
		#	continue
		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		# Call the node's save function.
		var node_data = node.call("save")
		var json_string = JSON.stringify(node_data)
		savegame.store_line(json_string)
		print(json_string)

# Note: This can be called from anywhere inside the tree. This function
# is path independent.
func load_game():
	
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var content = save_game.get_line()
		print(content)
		var json_object = JSON.new()
		json_object.parse(content)
		print(json_object.data["pos_x"])

	# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(json_object.data["path"]).instantiate()
		get_node(json_object.data["parent"]).add_child(new_object)
		new_object.position = Vector2(json_object.data["pos_x"], json_object.data["pos_y"])

	# Now we set the remaining variables.
		for i in json_object.data.keys():
			if i == "path" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, json_object.data[i])

func SpawnNewPlayer(player_id, spawn_position):
	if multiplayer.get_unique_id() == player_id:
		pass
	else:
		if not get_node("players/OtherPlayers").has_node(str(player_id)):
			var new_player = player_spawn.instantiate()
			new_player.position = spawn_position
			new_player.name = str(player_id)
			get_node("players/OtherPlayers").add_child(new_player)
			
func DespawnPlayer(player_id):
	await get_tree().create_timer(0.2).timeout
	get_node("players/OtherPlayers/" + str(player_id)).queue_free()

func _physics_process(delta):
	var render_time = GameServer.client_clock - interpolation_offset
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove_at(0)
		if world_state_buffer.size() > 2:
			var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
			for player in world_state_buffer[2].keys():
				if str(player) == "T":
					continue
				if str(player) == "Animals":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("players/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					var animation_vector = world_state_buffer[2][player]["A"]
					get_node("players/OtherPlayers/" + str(player)).MovePlayer(new_position, animation_vector)
				else:
					print("spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
			for animal in world_state_buffer[2]["Animals"].keys():
				if not world_state_buffer[1]["Animals"].has(animal):
					continue
				if get_node("mobs/Animals").has_node(str(animal)):
					var new_position = lerp(world_state_buffer[1]["Animals"][animal]["AnimalLocation"], world_state_buffer[2]["Animals"][animal]["AnimalLocation"], interpolation_factor)
					get_node("mobs/Animals/" + str(animal)).MoveAnimal(new_position)
				else:
					SpawnNewAnimal(animal, world_state_buffer[2]["Animals"][animal])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if str(player) == "Animals":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("players/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("players/OtherPlayers/" + str(player)).MovePlayer(new_position)
			
func SpawnNewAnimal(animal_id, animal_dict):

	var spawned_animal = load("res://creatures/animals/"+str(animal_dict["AnimalType"][0])+".tscn")
	if spawned_animal:
		var new_animal = spawned_animal.instantiate()
		new_animal.position = animal_dict["AnimalLocation"]
		new_animal.type = animal_dict["AnimalType"]
		new_animal.state = animal_dict["AnimalState"]
		new_animal.name = str(animal_id)
		get_node("mobs/Animals").add_child(new_animal, true)
	


func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)


