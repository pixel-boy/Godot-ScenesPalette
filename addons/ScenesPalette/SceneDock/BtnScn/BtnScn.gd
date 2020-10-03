tool
extends PanelContainer


# Scene button, displays the name of the scene, and the scene preview if it exists (Godot automatically generates the preview when the scene is saved)


signal pressed(scene_name)
signal scene_remove(path)

onready var line = $HBoxContainer/LineEdit
var path setget set_path
var selected = false setget set_selected
var mode = "Tile" setget set_mode
var scn_name = "" setget set_scn_name


func _ready():
	self.mode = mode
	path = line.text
	$Label.set("custom_fonts/font",get_font("output_source", "EditorFonts"))
	$Label.set("custom_styles/normal",get_stylebox("Background", "EditorStyles"))
	set("custom_styles/panel",get_stylebox("DebuggerPanel", "EditorStyles"))


func on_btn_pressed():
	var scene_name = line.text
	emit_signal("pressed",scene_name)


func _input(event):
	if !is_visible_in_tree():
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if get_global_rect().has_point(event.position):
				if event.doubleclick:
					_on_BtnOpenScn_pressed()
				else:
					owner.selected_btn(self)
		elif event.button_index == BUTTON_RIGHT:
			if get_global_rect().has_point(event.position):
				if event.is_pressed():
					_on_BtnClose_pressed()


func _on_BtnOpenScn_pressed():
	owner.plugin.open_scene(line.text)


func set_texture(path,texture,userdata):
	if texture:
		$HBoxContainer/Icon.texture = texture


func set_path(v):
	path = v
	$HBoxContainer/LineEdit.text = path
	self.scn_name = path.get_file().replace("."+path.get_extension(),"")
	hint_tooltip = scn_name


func _on_BtnClose_pressed():
	emit_signal("scene_remove",path)
	queue_free()


func get_drag_data(position):
	var mydata = make_data()
	set_drag_preview(make_preview())
	owner.data = mydata
	return mydata


func make_data():
	return(path)


func make_preview():
	var tex = TextureRect.new()
	tex.texture = $HBoxContainer/Icon.texture
	return(tex)


func set_selected(v):
	selected = v
	if selected:
		set("custom_styles/panel",get_stylebox("button_pressed", "Tree"))
	else:
		set("custom_styles/panel",get_stylebox("Information3dViewport", "EditorStyles"))


func set_mode(v):
	match v:
		"Tile":
			size_flags_horizontal = SIZE_SHRINK_CENTER
			$HBoxContainer/LineEdit.visible = false
			$HBoxContainer/BtnPackedScene.visible = false
			$HBoxContainer/BtnClose.visible = false
		"List":
			size_flags_horizontal = SIZE_EXPAND_FILL
			$HBoxContainer/LineEdit.visible = true
			$HBoxContainer/BtnPackedScene.visible = true
			$HBoxContainer/BtnClose.visible = true


func set_scn_name(v):
	scn_name = v
	$Label.text = scn_name
