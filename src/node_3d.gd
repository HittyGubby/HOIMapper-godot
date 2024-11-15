extends Node3D
var map_data = JSON.parse_string(FileAccess.open("res://data/vanilla/provinces_data.json", FileAccess.READ).get_as_text())
@export var map_width = 5632

func _ready():
	create_map()

func create_map():
	#transform = Transform3D.FLIP_Y
	for province_name in map_data.keys():
		for polygon in map_data[province_name]:
			var vertices = []
			for vertex in polygon:
				vertices.append(Vector3(vertex[0],vertex[1],0))
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = create_mesh_from_vertices(vertices)
			add_child(mesh_instance)
		for polygon in map_data[province_name]:
			var vertices = []
			for vertex in polygon:
				vertices.append(Vector3(vertex[0]-map_width,vertex[1],0))
			var mesh_instance = MeshInstance3D.new()
			mesh_instance.mesh = create_mesh_from_vertices(vertices)
			add_child(mesh_instance)

func create_mesh_from_vertices(vertices):
	if vertices.size() < 3: return null
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
