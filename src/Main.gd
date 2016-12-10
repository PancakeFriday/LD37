extends Node2D

var Gamestate = "Title"

func _ready():
	set_process(true)
	pass

func _process(dt):
	if(Gamestate == "Title"):
		get_node("Title").run(dt)
	
	pass