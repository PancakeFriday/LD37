extends Node2D

var time_start
var house_fade_in = 0

var cam_scale = 1
var cam_scale_speed = 5

var cam_final_pos = Vector2(310,60)
var cam_move_speed = 1.5

var cam_init_done = false

var Char
var CharAnim

func _ready():
	Char = get_node("Char")
	CharAnim = get_node("Char/Animation")
	CharAnim.set_current_animation("Walking")

	time_start = OS.get_unix_time()
	pass

func run(dt):
	var elapsed = OS.get_unix_time() - time_start
	
	if elapsed > 1:
		house_fade_in = min(1, house_fade_in+dt)
		get_node("House").set_opacity(1-house_fade_in)
	if elapsed > 1.5 and not cam_init_done:
		cam_scale = max(0.3, cam_scale-dt/cam_scale_speed)
		get_node("Camera").set_zoom(Vector2(cam_scale,cam_scale))
		var pos = get_node("Camera").get_offset()
		var dir = (pos - cam_final_pos).normalized()
		var move_to = pos - dir*cam_move_speed
		if pos == cam_final_pos or pos.x > cam_final_pos.x or pos.y > cam_final_pos.y:
			get_node("Camera").set_offset(cam_final_pos)
			cam_init_done = true
		else:
			get_node("Camera").set_offset(move_to)
	
	if cam_init_done:
		post_init_run(dt)
		
func post_init_run(dt):
	if(Input.is_action_pressed("move_left")):
		CharAnim.advance(-dt)
		Char.move(Vector2(-dt*60,0))
	elif(Input.is_action_pressed("move_right")):
		CharAnim.advance(dt)
		Char.move(Vector2(dt*60,0))
	else:
		pass
		#CharAnim.stop()
	pass