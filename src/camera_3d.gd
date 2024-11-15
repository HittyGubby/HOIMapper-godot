extends Camera3D

@export var sensitivity = 2
@export var edge_threshold_percentage = 0.05
@export var lerp_speed = 5.0
@export var scroll_speed = 500
@export var zoom_speed = 500
@export var min_z = 100
@export var ocentery = 2048
@export var edge_sensitivity = 50
@export var smooth_transition_distance = 100

var map_height = 2048
var map_width = 5632
var fov_rad
var target_position
var target_z
var y_max
var y_min
var max_z = 1024
var camera
var mouse_position
var ray_origin
var ray_direction
var viewport_size
var edge_threshold
var move_direction = Vector3.ZERO
var x_proximity_factor
var y_proximity_factor
var zoom_factor
var zoom_vector
@onready var debug_gui = $"../Control/DebugInfo"
	
func _ready():
	camera = get_viewport().get_camera_3d()
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_direction = camera.project_ray_normal(mouse_position)
	viewport_size = get_viewport().get_visible_rect().size
	edge_threshold = viewport_size * edge_threshold_percentage
	x_proximity_factor = clamp((edge_threshold.x - min(mouse_position.x, viewport_size.x - mouse_position.x)) / edge_threshold.x, 0.0, 1.0)
	y_proximity_factor = clamp((edge_threshold.y - min(mouse_position.y, viewport_size.y - mouse_position.y)) / edge_threshold.y, 0.0, 1.0)
	zoom_factor = position.z * sensitivity
	zoom_vector = (Vector3(mouse_position[0],mouse_position[1],0) - global_transform.origin).normalized()
	fov_rad = deg_to_rad(get_viewport().get_camera_3d().fov)
	max_z = map_height/2/float(tan(fov_rad/2))
	target_position = global_transform.origin
	target_z = position.z

func _process(delta):
	edge_threshold = viewport_size * edge_threshold_percentage
	move_direction = Vector3.ZERO
	x_proximity_factor = clamp((edge_threshold.x - min(mouse_position.x, viewport_size.x - mouse_position.x)) / edge_threshold.x, 0.0, 1.0)
	y_proximity_factor = clamp((edge_threshold.y - min(mouse_position.y, viewport_size.y - mouse_position.y)) / edge_threshold.y, 0.0, 1.0)
	zoom_factor = position.z * sensitivity
	zoom_vector = (Vector3(mouse_position[0],mouse_position[1],0) - global_transform.origin).normalized()
	camera = get_viewport().get_camera_3d()
	mouse_position = get_viewport().get_mouse_position()
	ray_origin = camera.project_ray_origin(mouse_position)
	ray_direction = camera.project_ray_normal(mouse_position)
	viewport_size = get_viewport().get_visible_rect().size
	
	if mouse_position.x < edge_threshold.x:move_direction.x -= zoom_factor * x_proximity_factor
	elif mouse_position.x > viewport_size.x - edge_threshold.x:move_direction.x += zoom_factor * x_proximity_factor
	if mouse_position.y < edge_threshold.y:move_direction.y += zoom_factor * y_proximity_factor
	elif mouse_position.y > viewport_size.y - edge_threshold.y:move_direction.y -= zoom_factor * y_proximity_factor
	
	if Input.is_action_pressed("ui_left"):move_direction.x -= zoom_factor
	if Input.is_action_pressed("ui_right"):move_direction.x += zoom_factor
	if Input.is_action_pressed("ui_up"):move_direction.y += zoom_factor
	if Input.is_action_pressed("ui_down"):move_direction.y -= zoom_factor
	if Input.is_action_pressed("ui_page_down") && position.z < max_z:target_z = target_z + scroll_speed * delta
	if Input.is_action_pressed("ui_page_up") && position.z > min_z:target_z = target_z - scroll_speed * delta

	camera.rotation.x = asin((max_z-position.z)/ocentery)
	if position.y >= map_height/2:
		y_max = map_height/2+ocentery-sqrt(ocentery**2-(position.z-max_z)**2)
		y_min = 0
	if position.y < map_height/2:
	#	y_min = sqrt(ocentery**2-position.z**2)+ocentery-map_height/2
	#	y_max = map_height
		y_min=-9999
		y_max=9999
	if position.y >= y_min && position.y <= y_max:
		target_position += move_direction * delta
	else: 
		target_position[1] = clamp(position.y, y_min,y_max);target_position += move_direction * delta;
	debug_gui.appendInfo("YRange: [%.2f,%.2f]\n"%[y_min,y_max])
	
	if global_transform.origin.x > map_width / 2:
		target_position[0]=position.x - map_width
		global_transform.origin.x -= map_width
	elif global_transform.origin.x < -map_width / 2:
		target_position[0]=position.x + map_width
		global_transform.origin.x += map_width
	
	#target_position = Vector3(position.x,clamp(target_position.y, y_min, y_max),position.z)
	global_transform.origin = global_transform.origin.lerp(target_position, lerp_speed * delta)
	#global_transform.origin += zoom_vector * (target_z - position.z) * delta * zoom_speed
	position.z = lerp(position.z, float(target_z), delta * lerp_speed)
	position.z = clamp(position.z,min_z,max_z)

func _input(event):
	if event is InputEventMouseButton:
		if position.z <= max_z && position.z >= min_z:
			target_z = position.z
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:target_z = position.z + zoom_speed * position.z * position.z / max_z / max_z * 2
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:target_z = position.z - zoom_speed
			target_position[1] = clamp(position.y, y_min,y_max)
	#if event is InputEventMouseButton and event.pressed:
		#var space_state = get_world_3d().direct_space_state
		#var result = space_state.intersect_ray(ray_origin)
		#if result and result.collider:
			#var province_id = result.collider.get("province_id")
			#get_node("DebugInfo").show_province_id(province_id)

func edge_multiplier() -> float:
	var dist_x = min(mouse_position.x, viewport_size.x - mouse_position.x)
	var dist_y = min(mouse_position.y, viewport_size.y - mouse_position.y)
	var x_multiplier = clamp((edge_sensitivity / max(dist_x, smooth_transition_distance)),0,1)
	var y_multiplier = clamp((edge_sensitivity / max(dist_y, smooth_transition_distance)),0,1)
	return max(x_multiplier, y_multiplier)
