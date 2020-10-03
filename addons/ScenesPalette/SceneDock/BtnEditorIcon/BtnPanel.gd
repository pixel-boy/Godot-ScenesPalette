tool
extends BtnEditorIcon

signal change_mode(mode)
var mode = "Tile" setget set_mode


func _ready():
	connect("pressed",self,"_on_change_mode")


func _on_change_mode():
	if mode == "Tile":
		self.mode = "List"
	else:
		self.mode = "Tile"


func set_mode(v):
	mode = v
	emit_signal("change_mode",mode)
	match mode:
		"Tile":
			set_icon("Panels2")
		"List":
			set_icon("Panels4")
