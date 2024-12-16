extends Node2D

var province_data = JSON.parse_string(FileAccess.open("res://provinces_data.json", FileAccess.READ).get_as_text())
var zoom_level = 0.2
var zoom_step = 0.02
var max_zoom = 5.0
var min_zoom = 1.0
var move_speed = 500.0
var border_threshold = 50
var target_zoom = 1.0
var moving_left = false
var moving_right = false
var moving_up = false
var moving_down = false
var target_position = Vector2.ZERO

var map_size = Vector2(5632, 2048)

func _ready():
	set_process_input(true)
	set_process(true)
	target_position = position
	target_zoom = zoom_level

func FARR2V2ARR(coords : Array) -> PackedVector2Array:
	var array : PackedVector2Array = []
	for coord in coords:
		var x = coord[0]
		var y = coord[1]# * (1.0 + (coord[1] / 1000.0))
		array.append(Vector2(x, y))
	return array

func _draw():
	for province_id in province_data:
		for shape in province_data[province_id]:
			draw_polygon(FARR2V2ARR(shape), [Color(1, 1, 1, 1)])

func _process(delta):
	position = position.lerp(target_position, 0.1)
	zoom_level = lerp(zoom_level, target_zoom, 0.1)
	scale = Vector2(zoom_level, zoom_level)

	var move_vector = Vector2()
	if moving_left:
		move_vector.x -= move_speed * delta
	elif moving_right:
		move_vector.x += move_speed * delta
	if moving_up:
		move_vector.y -= move_speed * delta
	elif moving_down:
		move_vector.y += move_speed * delta

	target_position -= move_vector

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			apply_zoom(zoom_step)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			apply_zoom(-zoom_step)
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_province = get_clicked_province(event.position)
			if clicked_province:
				print("Clicked on province:", clicked_province)
	elif event is InputEventMouseMotion:
		moving_left = event.position.x < border_threshold
		moving_right = event.position.x > get_viewport_rect().size.x - border_threshold
		moving_up = event.position.y < border_threshold
		moving_down = event.position.y > get_viewport_rect().size.y - border_threshold

func apply_zoom(step: float):
	#var old_zoom = target_zoom
	target_zoom = clamp(target_zoom + step, min_zoom, max_zoom)
	
	var viewport_center = get_viewport_rect().size / 2
	#var zoom_diff = target_zoom / old_zoom
	#var offset = (viewport_center - position) * (1 - zoom_diff)
	target_position += (viewport_center - target_position) * (1 - zoom_level / target_zoom)
	

func get_clicked_province(click_position: Vector2) -> String:
	for province_id in province_data:
		for shape in province_data[province_id]:
			var polygon = FARR2V2ARR(shape)
			if is_point_in_polygon(click_position, polygon):
				return province_id
	return ''

func is_point_in_polygon(point: Vector2, polygon: PackedVector2Array) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon)
