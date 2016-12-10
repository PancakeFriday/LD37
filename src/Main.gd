extends Node2D

var Gamestate = "MainGame"

func _ready():
	set_process(true)
	#get_node("Game").hide()
	pass

func _process(dt):
	if(Gamestate == "Title"):
		if get_node("Title").run(dt) == "done":
			Gamestate = "MainGame"
			get_node("Title").free()
			get_node("Game").show()
			
	if(Gamestate == "MainGame"):
		get_node("Game").run(dt)
	
	pass