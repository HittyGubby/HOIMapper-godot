extends Camera3D

@export var sen = 0.2
@export var senmouse = 0.2
@export var zoomsen = 0.5
@export var zoomsenmouse = 1
@export var edgethres_fac = 0.05
@export var zmin = 50.0
#zmax is defined by fov
@export var maxtiltz = 200
@export var tiltsen = 4
@export var lerpacc = 0.95

var maphei = 2048
var mapwid = 5632
var vel = Vector3.ZERO
@onready var dbg = $"../Control/DebugInfo"

func _process(delta):
	#init tick
	var view = get_viewport().get_visible_rect().size
	var edgethres = view * edgethres_fac
	var mousepos = get_viewport().get_mouse_position()
	var zoomfacmouse = position.z * zoomsenmouse
	var zoomfac = position.z * zoomsen
	var fac = position.z * sen
	var facmouse = position.z * senmouse
	var x = edgethres.x-max(min(mousepos.x, view.x - mousepos.x),0)
	var y = edgethres.y-max(min(mousepos.y, view.y - mousepos.y),0)
	var proxfac = Vector2(x/edgethres.x,y/edgethres.y)

	#manipulate velocities
	if mousepos.x < edgethres.x:	vel.x += -facmouse * proxfac.x
	elif mousepos.x > view.x - edgethres.x:	vel.x += facmouse * proxfac.x
	if mousepos.y < edgethres.y:	vel.y += facmouse * proxfac.y
	elif mousepos.y > view.y - edgethres.y:	vel.y += -facmouse * proxfac.y
	#zoom vector
	var cam = get_viewport().get_camera_3d()
	var ray_origin = get_viewport().get_camera_3d().project_ray_origin(mousepos)
	var ray_direction = get_viewport().get_camera_3d().project_ray_normal(mousepos)
	var cursorpos = ray_origin + ray_direction * (-ray_origin.z / ray_direction.z)
	var zoomvec = (cursorpos - cam.position).normalized()

	#accept input
	if Input.is_action_just_pressed("ui_cancel"):get_tree().quit()
	if Input.is_action_pressed("ui_left"):vel.x = fac * proxfac.x
	if Input.is_action_pressed("ui_right"):vel.x = -fac * proxfac.x
	if Input.is_action_pressed("ui_up"):vel.y = -fac * proxfac.y
	if Input.is_action_pressed("ui_down"):vel.y = fac * proxfac.y
	if Input.is_action_pressed("ui_page_down"):vel -= zoomvec * zoomfac
	if Input.is_action_pressed("ui_page_up"):vel += zoomvec * zoomfac
	if Input.is_action_just_released("scroll_up"):vel += zoomvec * zoomfacmouse
	if Input.is_action_just_released("scroll_down"):vel -= zoomvec * zoomfacmouse
	if Input.is_action_pressed("lmb"):$"..".queryprov(Vector2(cursorpos.x,cursorpos.y))
	
	#cam tilt controller
	if position.z<maxtiltz:	cam.rotation.x = tiltsen*asin((maxtiltz-position.z)/maphei)
	#cam coord limits
	var fovrad = deg_to_rad(get_viewport().get_camera_3d().fov)
	var zmax = maphei/2.0/tan(fovrad/2.0)
	var ymax = maphei-position.z*tan(cam.rotation.x+fovrad/2.0)
	var ymin = position.z*tan(fovrad/2.0-cam.rotation.x)

	#velocity applies to pos
	var newposition = position + vel * delta
	if position.x > mapwid / 2.0:	newposition.x = newposition.x - mapwid
	elif position.x < -mapwid / 2.0:	newposition.x = newposition.x + mapwid
	newposition.y = clamp(newposition.y,ymin,ymax)
	newposition.z = clamp(newposition.z,zmin,zmax)
	position = newposition

	#lerp, expotential speed
	vel = vel * lerpacc

	#debug info
	dbg.dbgappend("FPS:","%d"%Engine.get_frames_per_second())
	dbg.dbgappend("CamPos:","(%.2f,%.2f,%.2f)"%[cam.position.x,cam.position.y,cam.position.z])
	dbg.dbgappend("CamRot:","(%.2f,%.2f,%.2f)"%[rad_to_deg(cam.rotation.x),rad_to_deg(cam.rotation.y),rad_to_deg(cam.rotation.z)])
	dbg.dbgappend("CursorPos:","(%.2f,%.2f)"%[cursorpos.x,cursorpos.y])
	dbg.dbgappend("YRange:","[%.2f,%.2f]"%[ymin,ymax])
