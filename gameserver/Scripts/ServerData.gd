extends Node

var skill_data
var test_data = {
		"Stats": {
			"Strength": 42,
			"Vitality": 68,
			"Dexterity": 37,
			"Intelligence": 24,
			"Wisdom": 17
		}
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	var skill_data_file = FileAccess.open("res://Data/SkillData.json", FileAccess.READ)
	var content = skill_data_file.get_as_text()
	var json_object = JSON.new()
	var skill_data_json = json_object.parse(content)
	
	skill_data_file = null
	#skill_data = skill_data_json.result
