extends Node
var dbgtxt: Dictionary = {}
var pending: Dictionary = {}
var refresh: bool = false

func _process(_delta):
	if refresh:
		for key in pending.keys():
			dbgtxt[key] = pending[key]
		pending.clear()
		var text = ""
		for key in dbgtxt.keys():
			text += key + dbgtxt[key] + "\n"
		self.text = text
		refresh = false

func dbgappend(key: String, value: String):
	pending[key] = value
	refresh = true
