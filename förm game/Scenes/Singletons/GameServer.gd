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
