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

var Current_level = 0

var Levels = [
{
	Floor = 224,
	Left = 591,
	Right = 955,
	Ceiling = 105
},
{
	Floor = 380,
	Left = 342,
	Right = 1103,
	Ceiling = 249
},
{
	Floor = 581,
	Left = 105,
	Right = 1103,
	Ceiling = 413
}
]

var Grabbed_object = {
	Grabbed = false,
	Obj = "",
	Dist = 0,
	Delta = Vector2()
}

var Portal_rando = 10
var Portal_positions = [Vector2(749.322998, 110.524002), Vector2(506.362, 254.529999), Vector2(818.968018, 254.473999),
						Vector2(297.608002, 418.502014), Vector2(560.086975, 418.467987), Vector2(836.052002, 418.493988)]

var Thrown_objects = []
var Falling_objects = []

var Shake_screen_time = 0

var Comp_health = 100.0
var Pl_health = 150.0

var hurt_player = 15
var hurt_color = 0

var Game_over_wait = 5
var Winner_wait = 5

var fade_time = 2

func _ready():
	get_node("House").show()
	Char = get_node("Char")
	CharAnim = get_node("Char/Animation")
	CharAnim.set_current_animation("Walking")
	CharAnim.set_speed(Char.move_speed)
	
	Crosshair = Shader.new()

	time_start = OS.get_unix_time()
	
	# Activate portal
	for v in get_node("Portals").get_children():
		v.get_node("Animation").set_current_animation("Idle")
		v.get_node("Animation").play()
	
	set_process(true)
	
	var CouchTex = load("res://img/Couch.png")
	var FlowerTex = load("res://img/Flower.png")
	var DeskTex = load("res://img/Desk.png")
	for i in range(0,7):
		randomize()
		var SomeCouch = Sprite.new()
		SomeCouch.set_texture(CouchTex)
		SomeCouch.set_centered(false)
		var pos = Vector2()
		var index = randi()%3
		pos.x = rand_range(Levels[index].Left, Levels[index].Right - CouchTex.get_width())
		pos.y = Levels[index].Floor - CouchTex.get_height()
		SomeCouch.set_pos(pos)
		get_node("Food").add_child(SomeCouch)
	for i in range(0,5):
		randomize()
		var SomeCouch = Sprite.new()
		SomeCouch.set_texture(FlowerTex)
		SomeCouch.set_centered(false)
		var pos = Vector2()
		var index = randi()%3
		pos.x = rand_range(Levels[index].Left, Levels[index].Right - FlowerTex.get_width())
		pos.y = Levels[index].Floor - FlowerTex.get_height()
		SomeCouch.set_pos(pos)
		get_node("Food").add_child(SomeCouch)
	for i in range(0,5):
		randomize()
		var SomeCouch = Sprite.new()
		SomeCouch.set_texture(DeskTex)
		SomeCouch.set_centered(false)
		var pos = Vector2()
		var index = randi()%3
		pos.x = rand_range(Levels[index].Left, Levels[index].Right - DeskTex.get_width())
		pos.y = Levels[index].Floor - DeskTex.get_height()
		SomeCouch.set_pos(pos)
		get_node("Food").add_child(SomeCouch)
	
	get_node("Game_over").set_scale(Vector2(2.2,2.2))
	get_node("Winner").set_scale(Vector2(2.2,2.2))
	get_node("RichTextLabel").add_text("Press [ENTER] to begin\nPress [Space] for Info")
	pass

func run(dt):
	var elapsed = OS.get_unix_time() - time_start
	
	
	if elapsed > 0.2:
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
		
func run_menu(dt):
	pass
	
func run_intro(dt):
	var elapsed = OS.get_unix_time() - time_start
	fade_time = fade_time - dt
	get_node("Title").set_modulate(Color(1,1,1,max(0,fade_time/2)))
	get_node("RichTextLabel").add_color_override("default_color", Color(0,0,0,max(0,fade_time/2)))
	if fade_time <= 0:
		return true
	return false
		
func post_init_run(dt):
	randomize()
	var elapsed = OS.get_unix_time() - time_start
	if Current_level == 0:
		get_node("Camera").set_offset(Vector2(get_node("Camera").get_offset().x, 60))
	if Current_level == 1:
		get_node("Camera").set_offset(Vector2(get_node("Camera").get_offset().x, 156))
	if Current_level == 2:
		get_node("Camera").set_offset(Vector2(get_node("Camera").get_offset().x, 346))
	var campos = get_node("Camera").get_offset()
	var charpos = Char.get_pos()
	
	if(Shake_screen_time > 0):
		get_node("Camera").set_offset(campos + Vector2(randi()%6 - 3, randi()%6 - 3))
		Shake_screen_time -= dt
	campos = get_node("Camera").get_offset()
	if campos.x < 0:
		get_node("Camera").set_offset(Vector2(0, campos.y))
	campos = get_node("Camera").get_offset()
	
	if(Pl_health <= 0):
		Game_over_wait -= dt
		get_node("Game_over").show()
		if get_node("Game_over").get_pos().y < campos.y+100:
			get_node("Game_over").set_pos(get_node("Game_over").get_pos() + Vector2(0, 100*dt))
		if Game_over_wait <= 0:
			get_tree().reload_current_scene()
		return
	else:
		get_node("Game_over").set_pos(campos + Vector2(300,10))
	
	if(Comp_health <= 0):
		Winner_wait -= dt
		get_node("Winner").show()
		if get_node("Winner").get_pos().y < campos.y+100:
			get_node("Winner").set_pos(get_node("Winner").get_pos() + Vector2(0, 100*dt))
		if Winner_wait <= 0:
			get_tree().reload_current_scene()
		return
	else:
		get_node("Winner").set_pos(campos + Vector2(300,10))
		

	# Don't touch this dadadada
	mouse_pos_trans = get_viewport().get_mouse_pos()*cam_scale + get_node("Camera").get_offset()
	
	# Hurt the player
	hurt_player -= dt
	if(hurt_player <= 0):
		hurt_player = 10
		Pl_health -= 10
		hurt_color = 1
	if hurt_color > 0:
		hurt_color -= dt/1.5
	else:
		hurt_color = 0
	get_node("Hurt_screen").set_modulate(Color(1,0,0,hurt_color/3))
	
	# Health bars
	if(campos.x > 0):
		get_node("Health_Comp").show()
		get_node("Health_Pl").show()
		get_node("Health_Comp").set_pos(campos + Vector2(150,300))
		get_node("Health_Pl").set_pos(campos + Vector2(440,300))
	else:
		get_node("Health_Comp").show()
		get_node("Health_Pl").show()
		get_node("Health_Comp").set_pos(Vector2(150,300 + campos.y))
		get_node("Health_Pl").set_pos(Vector2(440,300 + campos.y))
		
	get_node("Health_Comp/Bar").set_scale(Vector2(Comp_health/100,1))
	get_node("Health_Pl/Bar").set_scale(Vector2(Pl_health/150,1))
	
	# Cannons
	for v in get_node("Canons").get_children():
		v.run(dt)
	
	# Randomize portals
	if Portal_rando < 0:
		Portal_rando = false
		var ran = randi()%6
		get_node("Portals/Portal2").set_pos(Portal_positions[ran])
		Portal_rando = 6
	
	Portal_rando -= dt
	
	if(Input.is_action_pressed("run")):
		Char.move_speed = 4
	else:
		Char.move_speed = 2.5

	# Gravity
	if(Char.get_pos().y < Levels[Current_level].Floor - Char.get_node("Sprite").get_texture().get_height()/2):
		Char.fallspeed = Char.fallspeed + Char.grav*dt
	elif(Input.is_action_pressed("jump")):
		Char.fallspeed = -4
	else:
		Char.fallspeed = 0
	
	Char.set_pos(Vector2(Char.get_pos().x, Char.get_pos().y + Char.fallspeed))
	
	var charheight = Char.get_node("Sprite").get_texture().get_height()
	if(Char.get_pos().y > Levels[Current_level].Floor - charheight/2):
		Char.set_pos(Vector2(Char.get_pos().x, Levels[Current_level].Floor - charheight/2))

	var charwidth = Char.get_node("Sprite").get_texture().get_width()/7
	if(Input.is_action_pressed("move_left")):
		CharAnim.advance(-dt)
		var move_to = Vector2(-dt*40*Char.move_speed,0)
		
		if(Char.get_pos().y > Levels[Current_level].Floor) or (Char.get_pos().x >= Levels[Current_level].Left + charwidth/2):
			Char.move(move_to)
		else:
			if(Current_level > 0):
				Current_level -= 1
				Char.set_pos(Vector2(Levels[Current_level].Right - charwidth/2, Levels[Current_level].Floor - charheight/2))
	elif(Input.is_action_pressed("move_right")):
		CharAnim.advance(dt)
		var move_to = Vector2(dt*40*Char.move_speed,0)
		
		if(Char.get_pos().x <= Levels[Current_level].Right - charwidth/2):
			Char.move(move_to)
		else:
			if(Current_level < 2):
				Current_level += 1
				Char.set_pos(Vector2(Levels[Current_level].Left + charwidth/2, Levels[Current_level].Floor - charheight/2))
	else:
		CharAnim.seek(0, true)
		
	# Flip player
	if(charpos.x - campos.x < get_viewport().get_mouse_pos().x*cam_scale):
		Char.dir = 1
	else:
		Char.dir = -1
	Char.get_node("Sprite").set_scale(Vector2(Char.dir,1))
		
	# Camera Movement
	if charpos.x < campos.x + 250:
		get_node("Camera").set_offset(Vector2(charpos.x - 250, campos.y))
	if charpos.x > campos.x + 300:
		get_node("Camera").set_offset(Vector2(charpos.x - 300, campos.y))

	Char.get_node("Crosshair").set_points(Char.get_pos(), mouse_pos_trans)
	
	# Rotate
	var portal_delta = -charpos + get_node("Portals/Portal2").get_pos()
	var alpha = atan(portal_delta.x / portal_delta.y)
	if( charpos.y < get_node("Portals/Portal2").get_pos().y):
		alpha += PI
	get_node("Char/Arrow").set_rot(alpha)
	
	# Disable crosshair
	if(Grabbed_object.Grabbed):
		get_node("Char/Crosshair").hide()
	else:
		get_node("Char/Crosshair").show()
	
	# Grab an object
	var crosshair_line = [Char.get_pos(), mouse_pos_trans]
	if(not Grabbed_object.Grabbed):
		var colliding_objects = []
		for v in get_node("Food").get_children():
			var Food_rect = v.get_item_rect()
			var Food_pos = v.get_pos()
			Food_rect = Rect2(Food_pos, Food_rect.size)
			
			if collides(crosshair_line, Food_rect) and Food_pos.distance_to(Char.get_pos()) < 180:
				colliding_objects.push_back(v)
			else:
				v.set_modulate(Color(1,1,1,1))
	
		var closest_object = get_closest_object(colliding_objects)
		if(Input.is_mouse_button_pressed(BUTTON_LEFT) and closest_object.size() > 0):
			# Check first, if the grabbed object was thrown in the first place
			var i = 0
			for v in Thrown_objects:
				if v.Obj == closest_object[0]:
					Thrown_objects.remove(i)
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
	
	# Drop object
	if(Grabbed_object.Grabbed and Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		Grabbed_object.Grabbed = false
		Grabbed_object.Obj.set_modulate(Color(1,1,1,1))
		
		var a = get_slope(crosshair_line)
		var alpha = atan(a)
		Thrown_objects.push_back({
			Obj = Grabbed_object.Obj,
			Speed = Vector2(Char.dir*Char.force*cos(alpha),Char.dir*Char.force*sin(alpha)),
			Level = Current_level
		})
		
	process_falling(dt)
	
	process_grabbed(crosshair_line)
	
	process_thrown(dt, get_node("Portals/Portal2"))

func food_in_portal(food, portal):
	var food_point = food.get_pos() + Vector2(food.get_texture().get_width()/2,0)
	var portal_rect = portal.get_item_rect()
	portal_rect.pos += portal.get_pos()
	if(food_point.x > portal_rect.pos.x and food_point.x < portal_rect.pos.x + portal_rect.size.x):
		if(food_point.y+3 > portal_rect.pos.y and food_point.y+3 < portal_rect.pos.y + portal_rect.size.y):
			return true
	return false

func process_falling(dt):
	var i = 0
	for v in Falling_objects:
		if(v.get_pos().y < 175):
			v.set_pos(Vector2(v.get_pos().x, v.get_pos().y + 100*dt))
		else:
			Comp_health -= 10
			Shake_screen_time = 0.9
			Falling_objects.remove(i)
			v.free()
		i += 1
	
func process_thrown(dt, portal):
	var i=0
	for v in Thrown_objects:
		var pos = v.Obj.get_pos()
		var move_to = Vector2(pos.x + v.Speed.x*dt, pos.y + v.Speed.y*dt)
		
		if(pos.x < Levels[v.Level].Left):
			move_to.x = Levels[v.Level].Left
			v.Speed.x = -v.Speed.x/4
		if(pos.x > Levels[v.Level].Right - v.Obj.get_texture().get_width()):
			move_to.x = Levels[v.Level].Right - v.Obj.get_texture().get_width()
			v.Speed.x = 0
		
		if(pos.y > Levels[v.Level].Floor - v.Obj.get_texture().get_height()):
			move_to.y = Levels[v.Level].Floor - v.Obj.get_texture().get_height()
			v.Speed.x = min(0, v.Speed.x - sign(v.Speed.x)*1)
			v.Speed.y = 0
		else:
			# Gravity
			v.Speed.y += 4
		
		if(move_to.y < Levels[v.Level].Ceiling):
			move_to.y = Levels[v.Level].Ceiling + 1

		v.Obj.set_pos(move_to)
		
		if(food_in_portal(v.Obj, portal)):
			Thrown_objects.remove(i)
			v.Obj.set_pos(Vector2(512 - v.Obj.get_texture().get_width()/2,110))
			Falling_objects.push_back(v.Obj)
			Portal_rando = 0
		
		i += 1

func process_grabbed(line):
	if(Grabbed_object.Grabbed):
		var a = get_slope(line)
		var alpha = atan(a)
		var res = Vector2()
		res = Grabbed_object.Dist * Char.dir * Vector2(cos(alpha), sin(alpha)) + Char.get_pos() - Grabbed_object.Delta;
		if res.y < Levels[Current_level].Ceiling:
			res.y = Levels[Current_level].Ceiling
		if res.y > Levels[Current_level].Floor - Grabbed_object.Obj.get_texture().get_height():
			res.y = Levels[Current_level].Floor - Grabbed_object.Obj.get_texture().get_height()
		if res.x < Levels[Current_level].Left:
			res.x = Levels[Current_level].Left
		if res.x > Levels[Current_level].Right - Grabbed_object.Obj.get_texture().get_width():
			res.x = Levels[Current_level].Right - Grabbed_object.Obj.get_texture().get_width()
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