extends Node

var player_spawn = preload("res://Scenes/SupportScenes/PlayerTemplate.tscn")
var last_world_state = 0

var world_state_buffer = []
const interpolation_offset = 100

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
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[1].has(player):
					continue
				if get_node("players/OtherPlayers").has_node(str(player)):
					var new_position = lerp(world_state_buffer[1][player]["P"], world_state_buffer[2][player]["P"], interpolation_factor)
					get_node("players/OtherPlayers/" + str(player)).MovePlayer(new_position)
				else:
					print("spawning player")
					SpawnNewPlayer(player, world_state_buffer[2][player]["P"])
		elif render_time > world_state_buffer[1].T:
			var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
			for player in world_state_buffer[1].keys():
				if str(player) == "T":
					continue
				if player == multiplayer.get_unique_id():
					continue
				if not world_state_buffer[0].has(player):
					continue
				if get_node("players/OtherPlayers").has_node(str(player)):
					var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
					var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
					get_node("players/OtherPlayers/" + str(player)).MovePlayer(new_position)
			
			

func UpdateWorldState(world_state):
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)

