extends Node2D

var Text = {
	0: "One Room to rule them all, One Room to find them,",
	1: "One Room to bring them all and in the darkness bind them",
	2: "In the Land of Cubicles where the Shadows lie."
}
var TextLabels = {}
var FadeSpeed = 1
var Fades = {}

var Intro_Text = load("res://Intro_Text.tscn")
var test
var time_start

func _ready():
	time_start = OS.get_unix_time()
	
	for i in Text:
		TextLabels[i] = Intro_Text.instance()
		TextLabels[i].add_text(Text[i])
		TextLabels[i].set_pos(Vector2(60 + i*20,170+i*50))
		TextLabels[i].add_color_override("default_color", Color(1,1,1,0))
		add_child(TextLabels[i])
		
		# What we use to fade the text into
		Fades[i] = 0
		
	pass

func run(dt):
	var elapsed = OS.get_unix_time() - time_start
	for i in Text:
		if elapsed > (i+1)*2:
			set_fade(i,dt)
			
	if elapsed > 18:
		return "done"

	pass
	
func set_fade(i,dt):
	Fades[i] += FadeSpeed*dt;
	if Fades[i] > 1:
		Fades[i] = 1
	TextLabels[i].add_color_override("default_color", Color(1,1,1,Fades[i]))
	
	# move it by 30 as well
	var pos = TextLabels[i].get_pos()
	TextLabels[i].set_pos(Vector2(100 + i*20 - 30*Fades[i], pos.y))