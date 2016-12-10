extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var origin = Vector2(0,0)
var destination = Vector2(100,100)
var color = Color(1,1,1,0)
var spacing = 7
var width = 3

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#set_process(true)
	pass

func _draw():
	# We're gonna draw sum lines biiitch
	# (0,0) -> (1,1)
	# (2,2) -> (3,3)
	# (4,4) -> (5,5)
	# (6,6) -> (7,7) 
	for i in range(0,100):
		var zero = (destination-origin).normalized()
		draw_line(zero*i*spacing, zero*(i*spacing + width), color, 1.0)
	pass
	
func set_points(t, u):
	origin = t
	destination = u
	color = Color(1,1,1,1)
	update()