extends Node
@export var mapwid = 5632
@export var maphei = 2048
var map = {}
var lookupimg = Image.load_from_file("res://data/vanilla/provinces_lookup.png")
var statejson = JSON.parse_string(FileAccess.open("res://data/vanilla/state_province.json", FileAccess.READ).get_as_text())
var lookupjs = JSON.parse_string(FileAccess.open("res://data/vanilla/lookup.json", FileAccess.READ).get_as_text())

func _ready():
	#lookup lookupimg as to detect clicked province
	for key in lookupjs.keys():
		var rgb = lookupjs[key]
		var color = Color(rgb[0] / 255, rgb[1] / 255, rgb[2] / 255, 1)
		map[color] = key

func clickmap(uv : Vector2):
	uv = uv * 10; uv.y = maphei - uv.y
	pass

func play_sound(sfx_path: String):
	var player = AudioStreamPlayer.new()
	player.stream = load(sfx_path)
	add_child(player)
	player.play()
	#player.connect("finished", player, "queue_free")
