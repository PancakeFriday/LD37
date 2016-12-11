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

var Grabbed_object = {
	Grabbed = false,
	Obj = "",
	Dist = 0,
	Delta = Vector2()
}

var Thrown_objects = []

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
	if(charpos.x - campos.x < get_viewport().get_mouse_pos().x*cam_scale):
		Char.dir = 1
	else:
		Char.dir = -1
	Char.get_node("Sprite").set_scale(Vector2(Char.dir,1))
		
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
	
	# Grab an object
	var crosshair_line = [Char.get_pos(), mouse_pos_trans]
	if(not Grabbed_object.Grabbed):
		var colliding_objects = []
		for v in get_node("Food").get_children():
			var Food_rect = v.get_item_rect()
			var Food_pos = v.get_pos()
			Food_rect = Rect2(Food_pos, Food_rect.size)
			
			if collides(crosshair_line, Food_rect):
				colliding_objects.push_back(v)
			else:
				v.set_modulate(Color(1,1,1,1))
	
		var closest_object = get_closest_object(colliding_objects)
		if(Input.is_mouse_button_pressed(BUTTON_LEFT) and closest_object.size() > 0):
			# Check first, if the grabbed object was thrown in the first place
			var i = 0
			for v in Thrown_objects:
				if v.Obj == closest_object[0]:
					print("yuup")
					print(Thrown_objects.size())
					Thrown_objects.remove(i)
					print(Thrown_objects.size())
				i+=1


			Grabbed_object.Grabbed = true
			Grabbed_object.Obj = closest_object[0]
			Grabbed_object.Dist = closest_object[1]
			
			var a = get_slope(crosshair_line)
			var alpha = atan(a)
			var res = Vector2()
			if( Char.dir > 0 ):
				res = Grabbed_object.Dist * Vector2(cos(alpha), sin(alpha)) + Char.get_pos();
			else:
				res = Grabbed_object.Dist * Vector2(-cos(alpha), -sin(alpha)) + Char.get_pos();
			
			Grabbed_object.Delta = res - closest_object[0].get_pos()
			Grabbed_object.Obj.set_modulate(Color(0.8,0.8,1,1))
			print(Grabbed_object.Delta)
	
	# Drop object
	if(Grabbed_object.Grabbed and Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		Grabbed_object.Grabbed = false
		Grabbed_object.Obj.set_modulate(Color(1,1,1,1))
		
		var a = get_slope(crosshair_line)
		var alpha = atan(a)
		print(sin(alpha))
		Thrown_objects.push_back({
			Obj = Grabbed_object.Obj,
			Speed = Vector2(Char.dir*Char.force*cos(alpha),Char.dir*Char.force*sin(alpha))
		})
	
	process_grabbed(crosshair_line)
	
	process_thrown(dt)

func process_thrown(dt):
	for v in Thrown_objects:
		v.Speed = Vector2(v.Speed.x, v.Speed.y + 1)
		var pos = v.Obj.get_pos()
		v.Obj.set_pos(Vector2(pos.x + v.Speed.x*dt, pos.y + v.Speed.y*dt))

func process_grabbed(line):
	if(Grabbed_object.Grabbed):
		var a = get_slope(line)
		var alpha = atan(a)
		var res = Vector2()
		res = Grabbed_object.Dist * Char.dir * Vector2(cos(alpha), sin(alpha)) + Char.get_pos() - Grabbed_object.Delta;
		Grabbed_object.Obj.set_pos(res)

func get_slope(line):
	return (line[1].y - line[0].y)/(line[1].x - line[0].x)
		
func get_closest_object(objects):
	var min_dist = 100000000
	var dist_index = -1
	var i = 0
	for v in objects:
		var dist = Char.get_pos().distance_to(v.get_pos())
		if dist < min_dist:
			min_dist = dist
			dist_index = i
		i += 1
	if(dist_index == -1):
		return []

	i = 0
	for v in objects:
		if(i != dist_index):
			v.set_modulate(Color(1,1,1,1))
		else:
			v.set_modulate(Color(1,0.8,0.8,1))
		i += 1
	return [objects[dist_index], min_dist]

# check collisions
func y(x, a, b):
	return a*x+b
		
func collides(line, rect):
	if(sign(rect.pos.x - Char.get_pos().x) != Char.dir):
		return
	# Get line into the form y = a*x + b
	# y = (y1-y0)/(x1-x0) * (x - x0) + y0
	# y = a*x - a*x0 + y0 => b = y0 - a*x0
	var a = get_slope(line)
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