tool
class_name BtnEditorIcon
extends Button

# A simple button that uses icons from the Godot editor

export var icon_name = "" setget set_icon_name


func _ready():
	self.icon_name = icon_name

 
func set_icon_name(v):
	icon_name = v
	set_icon(icon_name)
	name = "Btn"+icon_name.capitalize().replace(" ","")


func set_icon(v):
	icon_name = v
	set_button_icon(get_icon(v, 'EditorIcons'))
