extends Node

var player_state_collection = {}

var network = ENetMultiplayerPeer.new()
var ip = "83.254.157.18"
var port = 7000

var client_clock = 0
var decimal_collector : float = 0
var latency_array = []
var latency = 0
var delta_latency = 0

func _ready():
	multiplayer.connect("connected_to_server", Callable(self, "_connected_succeeded"))
	multiplayer.connect("connection_failed", Callable(self, "_connected_fail"))
	ConnectToServer()
	

func ConnectToServer():
	network.create_client(ip, port)
	multiplayer.set_multiplayer_peer(network)
	
func _physics_process(delta):
	client_clock += int(delta*1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00

func connection_fail():
	print("Failed to connect")
	
func _connected_succeeded():
	print("Successfully connected")
	FetchServerTime.rpc_id(1, Time.get_unix_time_from_system() * 1000)
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.connect("timeout", Callable(self, "DetermineLatency"))
	self.add_child(timer)
	SendWorldRequest()
	
@rpc
func FetchServerTime(client_time):
	pass
	

@rpc(any_peer)
func ReturnServerTime(server_time, client_time):
	latency = ((Time.get_unix_time_from_system() * 1000) - client_time) / 2
	client_clock = server_time + latency

@rpc
func DetermineLatency():
	DetermineLatency.rpc_id(1,Time.get_unix_time_from_system() * 1000)
	
@rpc(any_peer)
func ReturnLatency(client_time):
	latency_array.append(((Time.get_unix_time_from_system() * 1000) - client_time) / 2)
	if latency_array.size() == 9:
		var total_latency = 0
		latency_array.sort()
		var mid_point = latency_array[4]
		for i in range(latency_array.size()-1,-1,-1):
			if latency_array[i] > (2 * mid_point) and latency_array[i] > 20:
				latency_array.remove_at(i)
			else:
				total_latency += latency_array[i]
		delta_latency = (total_latency / latency_array.size()) - latency
		latency = total_latency / latency_array.size()
		print("New Latency ", latency)
		print("Delta Latency ", delta_latency)
		latency_array.clear()

func SendPlayerState(player_state):
	RecievePlayerState.rpc_id(1, player_state)

@rpc(any_peer)
func DespawnPlayer(player_id):
	get_node("../SceneHandler/Map").DespawnPlayer(player_id)

@rpc
func RecievePlayerState(player_state):
	pass

@rpc(any_peer)
func RecieveWorldState(world_state):
	get_node("../SceneHandler/Map").UpdateWorldState(world_state)
	
@rpc
func SpawnAnimal(position):
	pass
	
func SendWorldRequest():
	LoadWorldRequest.rpc_id(1)
	
@rpc
func LoadWorldRequest():
	pass
	
@rpc(any_peer)
func RecieveWorldSave(save_game):
	
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
	
	var some_array = save_game.rsplit("\n")
	var json_object = JSON.new()
	json_object.parse(JSON.stringify(save_game))
	
	for n in some_array.size():
		
		json_object.parse(some_array[n])
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
	
func SpawnOnPress(position, animal_type):
	#print("hey")
	SpawnAnimal.rpc_id(1, position, animal_type)
	

