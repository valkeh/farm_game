extends Node2D



func save():
	var save_dict = {
		"path" : scene_file_path,
		"parent" : get_parent().get_path(),
		"pos_x" : position.x, # Vector2 is not supported by JSON
		"pos_y" : position.y,
	}
	return save_dict
