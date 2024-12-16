extends Node3D
var json = JSON.parse_string(FileAccess.open("res://data/vanilla/provinces_data.json", FileAccess.READ).get_as_text())
@export var map_width = 5632

func get_mapdata():
	return json

func _ready():
	create_map()

func create_map():
	for provname in json.keys():
		for polygon in json[provname]:
			var vertices = []
			for vertex in polygon:
				vertices.append(Vector3(vertex[0],vertex[1],0))
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = vertices2mesh(vertices)
			add_child(mesh_instance)
		for polygon in json[provname]:
			var vertices = []
			for vertex in polygon:
				vertices.append(Vector3(vertex[0]-map_width,vertex[1],0))
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = vertices2mesh(vertices)
			add_child(mesh_instance)

func vertices2mesh(vertices):
	var mesh = ArrayMesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var first_vertex = vertices[0]
	for i in range(1, vertices.size() - 1):
		st.add_vertex(first_vertex)
		st.add_vertex(vertices[i])
		st.add_vertex(vertices[i + 1])
	#st.generate_normals()
	st.index()
	st.commit(mesh)
	return mesh

func queryprov(point: Vector2):
	for provname in json.keys():
		for polygon in json[provname]:
			if Geometry2D.is_point_in_polygon(point, polygon):
				$"../Control/DebugInfo".dbgappend("Clicked ProvinceID:","%s" % provname)
				break