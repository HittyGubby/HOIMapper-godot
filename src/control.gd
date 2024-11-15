extends Node

var debug_text = ""
var persistent_debug_text = ""

func _process(delta):
	var camera_position = get_viewport().get_camera_3d().global_transform.origin
	var camera_rotation = get_viewport().get_camera_3d().global_transform.basis.get_euler()
	var fps = Engine.get_frames_per_second()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = get_viewport().get_camera_3d().project_ray_origin(mouse_pos)
	var ray_direction = get_viewport().get_camera_3d().project_ray_normal(mouse_pos)
	var cursor_xy_position = ray_origin + ray_direction * (-ray_origin.z / ray_direction.z)
	
	debug_text = ""
	debug_text += "CamPos: (%.2f, %.2f, %.2f)\n" % [camera_position.x, camera_position.y, camera_position.z]
	debug_text += "CamRot: (%.2f, %.2f, %.2f)\n" % [rad_to_deg(camera_rotation.x), rad_to_deg(camera_rotation.y), rad_to_deg(camera_rotation.z)]
	debug_text += "CursorPos: (%.2f, %.2f)\n" % [cursor_xy_position.x, cursor_xy_position.y]
	debug_text += "FPS: %d\n" % fps
	
	$".".text = debug_text + persistent_debug_text

func show_province_id(province_id: String):
	appendInfo("Clicked ProvinceID: %s\n" % province_id)

func appendInfo(info: String):
	persistent_debug_text = ""
	persistent_debug_text += info
	$".".text = debug_text + persistent_debug_text
