extends Camera3D

@export var sensitivity = 2
@export var edge_threshold_percentage = 0.05
@export var lerp_speed = 5.0
@export var scroll_speed = 500
@export var min_z = 100
@export var max_tilt = 30

var map_height = 2048
var fov_rad
var max_tilt_rad
var target_position
var target_z
var y_max
var y_min
var max_z = 1024

func _ready():
	fov_rad = deg_to_rad(get_viewport().get_camera_3d().fov)
	max_tilt_rad = deg_to_rad(max_tilt)
	max_z = map_height/2/float(tan(fov_rad/2))
	target_position = global_transform.origin
	target_z = position.z

func _process(delta):
	var mouse_position = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	var edge_threshold = viewport_size * edge_threshold_percentage
	var move_direction = Vector3.ZERO
	var x_proximity_factor = clamp((edge_threshold.x - min(mouse_position.x, viewport_size.x - mouse_position.x)) / edge_threshold.x, 0.0, 1.0)
	var y_proximity_factor = clamp((edge_threshold.y - min(mouse_position.y, viewport_size.y - mouse_position.y)) / edge_threshold.y, 0.0, 1.0)
	var zoom_factor = position.z * sensitivity

	if mouse_position.x < edge_threshold.x:move_direction.x -= zoom_factor * x_proximity_factor
	elif mouse_position.x > viewport_size.x - edge_threshold.x:move_direction.x += zoom_factor * x_proximity_factor
	if mouse_position.y < edge_threshold.y:move_direction.y += zoom_factor * y_proximity_factor
	elif mouse_position.y > viewport_size.y - edge_threshold.y:move_direction.y -= zoom_factor * y_proximity_factor
	if Input.is_action_pressed("ui_left"):move_direction.x -= zoom_factor
	if Input.is_action_pressed("ui_right"):move_direction.x += zoom_factor
	if Input.is_action_pressed("ui_up"):move_direction.y += zoom_factor
	if Input.is_action_pressed("ui_down"):move_direction.y -= zoom_factor
	if Input.is_action_pressed("ui_page_down") && position.z < max_z:target_z = target_z + scroll_speed * delta
	elif Input.is_action_pressed("ui_page_up") && position.z > min_z:target_z = target_z - scroll_speed * delta

	y_max = map_height/2-2*tan(fov_rad/2+max_tilt_rad*(max_z-position.z)/(max_z-min_z))
	y_min = -map_height/2-2*tan(fov_rad/2+max_tilt_rad*(max_z-position.z)/(max_z-min_z))
	#y_min = map_height/2+(position.z-max_z)*map_height/2/max_z
	rotation.x = max_tilt_rad*(max_z-position.z)/(max_z-min_z)
	
	print(y_min)

	if move_direction != Vector3.ZERO:
		if position.y >= y_min && position.y <= y_max:
			target_position += move_direction * delta
		else: 
			target_position[1] = clamp(position.y, y_min,y_max)
			target_position += move_direction * delta
	global_transform.origin = global_transform.origin.lerp(target_position, lerp_speed * delta)
	position.z = lerp(position.z, float(target_z), delta * lerp_speed)
	position.z = clamp(position.z,min_z,max_z)

func _input(event):
	if event is InputEventMouseButton:
		if position.z <= max_z && position.z >= min_z:
			target_z = position.z
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:target_z = position.z + scroll_speed
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:target_z = position.z - scroll_speed
