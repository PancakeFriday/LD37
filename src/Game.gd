extends Node2D

var time_start
var house_fade_in = 0

var cam_scale = 1
var cam_scale_speed = 5

var cam_final_pos = Vector2(330,60)
var cam_final_zoom = 0.4
var cam_move_speed = 2.1

var cam_init_done = false

var Char
var CharAnim

var Crosshair

var mouse_pos_trans

func _ready():
	get_node("House").show()
	Char = get_node("Char")
	CharAnim = get_node("Char/Animation")
	CharAnim.set_current_animation("Walking")
	CharAnim.set_speed(Char.move_speed)
	
	Crosshair = Shader.new()

	time_start = OS.get_unix_time()
	
	# Activate portal
	get_node("Portal/Animation").set_current_animation("Idle")
	get_node("Portal/Animation").play()
	
	set_process(true)
	
	pass

func run(dt):
	var elapsed = OS.get_unix_time() - time_start
	
	if elapsed > 1:
		house_fade_in = min(1, house_fade_in+dt)
		get_node("House").set_opacity(1-house_fade_in)
	if elapsed > 1.5 and not cam_init_done:
		cam_scale = max(cam_final_zoom, cam_scale-dt/cam_scale_speed)
		get_node("Camera").set_zoom(Vector2(cam_scale,cam_scale))
		var pos = get_node("Camera").get_offset()
		var dir = (pos - cam_final_pos).normalized()
		var move_to = pos - dir*cam_move_speed
		if pos == cam_final_pos or pos.x > cam_final_pos.x or pos.y > cam_final_pos.y:
			get_node("Camera").set_offset(cam_final_pos)
			cam_init_done = true
			get_node("House_exterior").show()
		else:
			get_node("Camera").set_offset(move_to)
	
	if cam_init_done:
		post_init_run(dt)
		
func post_init_run(dt):
	var campos = get_node("Camera").get_offset()
	var charpos = Char.get_pos()

	# Don't touch this dadadada
	mouse_pos_trans = get_viewport().get_mouse_pos()*cam_scale + get_node("Camera").get_offset()

	if(Input.is_action_pressed("move_left")):
		CharAnim.advance(-dt)
		Char.move(Vector2(-dt*40*Char.move_speed,0))
	elif(Input.is_action_pressed("move_right")):
		CharAnim.advance(dt)
		Char.move(Vector2(dt*40*Char.move_speed,0))
	else:
		CharAnim.seek(0, true)
		
	# Flip player
	if(charpos.x - campos.x + 340 < get_viewport().get_mouse_pos().x):
		Char.get_node("Sprite").set_scale(Vector2(1,1))
	else:
		Char.get_node("Sprite").set_scale(Vector2(-1,1))
		
	# Gravity
	if(Char.get_pos().y < 202):
		Char.fallspeed = Char.fallspeed + Char.grav*dt
	elif(Input.is_action_pressed("jump")):
		Char.fallspeed = -4
	else:
		Char.fallspeed = 0
	
	Char.set_pos(Vector2(Char.get_pos().x, Char.get_pos().y + Char.fallspeed))
		
	# Camera Movement
	if charpos.x < campos.x + 250:
		get_node("Camera").set_offset(Vector2(charpos.x - 250, campos.y))
	if charpos.x > campos.x + 300:
		get_node("Camera").set_offset(Vector2(charpos.x - 300, campos.y))

	Char.get_node("Crosshair").set_points(Char.get_pos(), mouse_pos_trans)
	
	#var Couch_rect = get_node("Food/Couch_1").get_item_rect()
	#var Couch_pos = get_node("Food/Couch_1").get_pos()
	#Couch_rect = Rect2(Couch_pos, Couch_rect.size)
	
	#if collides(crosshair_line, Couch_rect):
	#	get_node("Food/Couch_1").set_modulate(Color(1,0,0,1))
	#else:
	#	get_node("Food/Couch_1").set_modulate(Color(1,1,1,1))
		
	var crosshair_line = [Char.get_pos(), mouse_pos_trans]
	for v in get_node("Food").get_children():
		var Food_rect = v.get_item_rect()
		var Food_pos = v.get_pos()
		Food_rect = Rect2(Food_pos, Food_rect.size)
		
		if collides(crosshair_line, Food_rect):
			v.set_modulate(Color(1,0,0,1))
		else:
			v.set_modulate(Color(1,1,1,1))
	
# check collisions
func y(x, a, b):
	return a*x+b
		
func collides(line, rect):
	# Get line into the form y = a*x + b
	# y = (y1-y0)/(x1-x0) * (x - x0) + y0
	# y = a*x - a*x0 + y0 => b = y0 - a*x0
	var a = (line[1].y - line[0].y)/(line[1].x - line[0].x)
	var b = line[0].y - a*line[0].x
	
	# I wanna check for at least two intersections
	var num_cols = 0

	# a*x_col + b = rect.top <=> x_col = (rect.top - b)/a
	var x_col = rect.pos.x

	# Left border
	if(y(x_col, a,b) > rect.pos.y and y(x_col, a,b) < rect.pos.y + rect.size.y):
		num_cols += 1
	# Right border
	x_col = rect.pos.x + rect.size.x
	if(y(x_col, a,b) > rect.pos.y and y(x_col, a,b) < rect.pos.y + rect.size.y):
		num_cols += 1
	# Top border
	x_col = (rect.pos.y - b)/a
	if(x_col > rect.pos.x and x_col < rect.pos.x + rect.size.x):
		num_cols += 1
	# Bottom border
	x_col = (rect.pos.y + rect.size.y - b)/a
	if(x_col > rect.pos.x and x_col < rect.pos.x + rect.size.x):
		num_cols += 1
	
	# Can it be bigger than two? Hm..
	if num_cols == 2:
		return true
	elif num_cols > 2:
		print("Hmmmmmm...........")
		
	return false