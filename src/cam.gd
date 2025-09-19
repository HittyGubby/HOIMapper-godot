extends Camera3D

@export var SENSITIVITY_KEYBOARD = 0.03
@export var SENSITIVITY_MOUSE = 0.2
@export var ZOOM_SENSITIVITY_KEYBOARD = 0.2
@export var ZOOM_SENSITIVITY_MOUSE = 1
@export var EDGE_WIDTH_RATIO = 0.05
@export var Z_MIN = 2.0 # zmax is defined by fov
@export var TILT_START_Z = 20
@export var TILT_SENSITIVITY = 4
@export var LERPING_ACCELERATION = 0.95
var MAP_HEIGHT = 204.8
var MAP_WIDTH = 563.2
var velocity = Vector3.ZERO

func _process(delta):
	#init tick
	var view = get_viewport().get_visible_rect().size
	var edgethres = view * EDGE_WIDTH_RATIO
	var mousepos = get_viewport().get_mouse_position()
	var zoomfacmouse = position.z * ZOOM_SENSITIVITY_MOUSE
	var zoomfac = position.z * ZOOM_SENSITIVITY_KEYBOARD
	var fac = position.z * SENSITIVITY_KEYBOARD
	var facmouse = position.z * SENSITIVITY_MOUSE
	var x = edgethres.x - max(min(mousepos.x, view.x - mousepos.x), 0)
	var y = edgethres.y - max(min(mousepos.y, view.y - mousepos.y), 0)
	var proxfac = Vector2(x / edgethres.x, y / edgethres.y)

	#manipulate velocities
	if mousepos.x < edgethres.x: velocity.x += -facmouse * proxfac.x
	elif mousepos.x > view.x - edgethres.x: velocity.x += facmouse * proxfac.x
	if mousepos.y < edgethres.y: velocity.y += facmouse * proxfac.y
	elif mousepos.y > view.y - edgethres.y: velocity.y += -facmouse * proxfac.y
	#zoom vector
	var cam = get_viewport().get_camera_3d()
	var rayorigin = get_viewport().get_camera_3d().project_ray_origin(mousepos)
	var raydir = get_viewport().get_camera_3d().project_ray_normal(mousepos)
	var cursorpos = rayorigin + raydir * (-rayorigin.z / raydir.z)
	var zoomvec = (cursorpos - cam.position).normalized()

	#accept input
	if Input.is_action_just_pressed("ui_cancel"): get_tree().quit()
	if Input.is_action_pressed("ui_left"): velocity.x += fac * proxfac.x
	if Input.is_action_pressed("ui_right"): velocity.x -= fac * proxfac.x
	if Input.is_action_pressed("ui_up"): velocity.y -= fac * proxfac.y
	if Input.is_action_pressed("ui_down"): velocity.y += fac * proxfac.y
	if Input.is_action_pressed("ui_page_down"): velocity -= zoomvec * zoomfac
	if Input.is_action_pressed("ui_page_up"): velocity += zoomvec * zoomfac
	if Input.is_action_just_released("scroll_up"): velocity += zoomvec * zoomfacmouse
	if Input.is_action_just_released("scroll_down"): velocity -= zoomvec * zoomfacmouse
	#if Input.is_action_pressed("lmb"):emit_signal("clickdown")
	if Input.is_action_just_released("lmb") && get_viewport().gui_get_focus_owner() == null:
		%Handlers.clickmap(Vector2(cursorpos.x, cursorpos.y))

	#cam tilt controller
	if position.z < TILT_START_Z: cam.rotation.x = TILT_SENSITIVITY * asin((TILT_START_Z - position.z) / MAP_HEIGHT)
	else: cam.rotation.x = 0
	#cam coord limits
	var fovrad = deg_to_rad(get_viewport().get_camera_3d().fov)
	var zmax = MAP_HEIGHT / 2.0 / tan(fovrad / 2.0)
	var ymax = MAP_HEIGHT - position.z * tan(cam.rotation.x + fovrad / 2.0)
	var ymin = position.z * tan(fovrad / 2.0 - cam.rotation.x)

	#velocity applies to pos
	var newpos = position + velocity * delta
	if position.x > MAP_WIDTH / 2.0: newpos.x = newpos.x - MAP_WIDTH
	elif position.x < -MAP_WIDTH / 2.0: newpos.x = newpos.x + MAP_WIDTH
	newpos.y = clamp(newpos.y, ymin, ymax)
	newpos.z = clamp(newpos.z, Z_MIN, zmax)
	position = newpos

	#lerp, expotential speed
	if velocity.length() > 0.1: velocity = velocity * LERPING_ACCELERATION
	else: velocity = Vector3.ZERO

	#debug info
	%DebugInfo.dbgappend("FPS:", "%d"%Engine.get_frames_per_second())
	%DebugInfo.dbgappend("CamPos:", "(%.2f,%.2f,%.2f)" % [cam.position.x, cam.position.y, cam.position.z])
	%DebugInfo.dbgappend("CamRot:", "(%.2f,%.2f,%.2f)" % [rad_to_deg(cam.rotation.x), rad_to_deg(cam.rotation.y), rad_to_deg(cam.rotation.z)])
	%DebugInfo.dbgappend("CursorPos:", "(%.2f,%.2f)" % [cursorpos.x, cursorpos.y])
	%DebugInfo.dbgappend("YRange:", "[%.2f,%.2f]" % [ymin, ymax])
