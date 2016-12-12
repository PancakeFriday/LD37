extends Node2D

var Gamestate = "Menu"
var Starttime
var Fade = 2
var Fade2 = 4

func _ready():
	set_process(true)
	#get_node("Game").hide()
	Starttime = OS.get_unix_time()
	get_node("Info_text").add_text("Oh no! The computer took your job away!\nIt appears, that he is in the one room, that controls the entire building.\nQuick, destroy the computer to save the day.\nYou will receive damage over time, as the computer leaked some gas into the system.\n\n\nControls:\n\n[A],[D]: Move left / right\n[Space]: Jump\n[LSHIFT]: Run\n[Left mouse]: Pick up furniture\n[Right mouse]: Throw furniture\n\nPress [Escape] to close this message")
	pass

func _process(dt):
	if(Gamestate == "Title"):
		if get_node("Title").run(dt) == "done":
			Gamestate = "MainGame"
			get_node("Title").free()
			get_node("Game").show()
	
	if(Gamestate == "Menu"):
		get_node("Game").run_menu(dt)
		if Input.is_action_pressed("Submit"):
			Gamestate = "Intro"
		elif Input.is_action_pressed("jump"):
			Gamestate = "Info"
			
	if(Gamestate == "Intro"):
		if get_node("Game").run_intro(dt):
			print("ok")
			Gamestate = "MainGame"
			
	if(Gamestate == "Info"):
		var elapsed = OS.get_unix_time() - Starttime
		Fade -= dt
		Fade2 -= dt
		get_node("Info").set_modulate(Color(1,1,1,-Fade/2+1))
		if Fade2 < 2:
			get_node("Info_text").add_color_override("default_color", Color(0,0,0,-Fade2/2+1))
			
		if Input.is_action_pressed("Escape"):
			get_node("Info").set_modulate(Color(1,1,1,0))
			get_node("Info_text").add_color_override("default_color", Color(0,0,0,0))
			Gamestate = "Menu"

	if(Gamestate == "MainGame"):
		get_node("Game").run(dt)
	
	pass