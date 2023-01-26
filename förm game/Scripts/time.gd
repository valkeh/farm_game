extends Node


var puppet_minute = 0
var puppet_hour = 0
var puppet_day = 0
var puppet_month = 0
var puppet_year = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").play("day_and_night")

@rpc
func _update_state(p_minute, p_hour, p_day, p_month, p_year):
	puppet_minute = p_minute
	puppet_hour = p_hour
	puppet_day = p_day
	puppet_month = p_month
	puppet_year = p_year

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Timer_timeout():
	if is_multiplayer_authority():
		Global.minute = Global.minute + 1
		print(Global.minute)
		if (Global.minute == 60):
			Global.minute = 0
			Global.hour = Global.hour + 1
		if (Global.hour == 24):
			Global.hour = 0
			Global.day = Global.day + 1
		if (Global.day == 32):
			Global.day = 1
			Global.month = Global.month + 1
		if (Global.month == 13):
			Global.month = 1
			Global.year = Global.year + 1
			
		rpc("_update_state", Global.minute, Global.hour, Global.day, Global.month, Global.year)
	else:
		Global.minute = puppet_minute
		Global.hour = puppet_hour
		Global.day = puppet_day
		Global.month = puppet_month
		Global.year = puppet_year

	get_node("AnimationPlayer").seek(Global.hour + Global.minute * 0.0165, true)
