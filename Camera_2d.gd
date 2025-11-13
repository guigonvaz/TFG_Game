extends Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	top_level = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position.x = get_parent().global_position.x
	global_position.y = 120
	
