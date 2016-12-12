extends Sprite

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var start_time
var ballspeed = 200

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	randomize()
	randomize()
	randomize()
	randomize()
	randomize()
	randomize()
	start_time = rand_range(2, 4)
	get_node("Animation").set_current_animation("Idle")
	pass

func _process(dt):
	run(dt)

func run(dt):
	if start_time < 0:
		start_time = 0.8
		get_node("Ball").set_pos(Vector2(0,7))
		get_node("Ball").show()
		get_node("Animation").seek(0)
		get_node("Animation").set_current_animation("Idle")
		get_node("Animation").play()
	else:
		start_time -= dt
	
	var ballpos = get_node("Ball").get_pos()
	if(get_pos().y > 400):
		if ballpos.y < 180:
			get_node("Ball").set_pos(Vector2(0, ballpos.y + ballspeed*dt))
	else:
		if ballpos.y < 130:
			get_node("Ball").set_pos(Vector2(0, ballpos.y + ballspeed*dt))
		
	ballpos = get_node("Ball").get_pos() + get_pos()
	var charpos = get_node("../../Char").get_pos()
	var charsize = get_node("../../Char/Sprite").get_texture().get_size()
	charsize.x = charsize.x/7
	
	if(ballpos.x > charpos.x - charsize.x / 2 and ballpos.x < charpos.x + charsize.x/2):
		if(ballpos.y > charpos.y - charsize.y / 2 and ballpos.y < charpos.y + charsize.y/2):
			get_node("../../").Pl_health -= 10
			get_node("Ball").set_pos(Vector2(0,-1000))
			get_node("../../").hurt_color = 1