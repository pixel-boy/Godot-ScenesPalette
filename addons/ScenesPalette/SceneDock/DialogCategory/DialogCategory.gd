tool
extends ConfirmationDialog

# Confirmation dialog used to create and edit categories, allows you to select an icon and choose a name

signal on_cancel
signal just_confirmed(data)
var icon_path = "" setget set_icon_path
var category_name = "" setget set_category_name
var not_available_name_list = []
var mode = "Create"

func _ready():
	connect("confirmed",self,"_on_accept")
	get_cancel().connect("pressed", self, "cancelled")
	$HBoxContainer2/VBoxIcon/BtnClearIcon.set_button_icon(get_icon("Remove", 'EditorIcons'))
	
	
func get_data():
	var data = {}
	data["Name"] = $HBoxContainer2/VBoxName/LineEditName.text
	data["Icon"] = icon_path
	return(data)

func cancelled():
	emit_signal("on_cancel")

func _input(event):
	if !visible:
		return
	if event is InputEventKey:
		if event.is_pressed():
			if event.scancode == KEY_ESCAPE:
				queue_free()
			if event.scancode == KEY_ENTER:
				_on_accept()


func _on_accept():
	var data = get_data()
	if check_valid_name(data["Name"]):
		emit_signal("just_confirmed",get_data())
		queue_free()


func _on_btn_icon_pressed():
	var file_dialog = EditorFileDialog.new()
	add_child(file_dialog)
	file_dialog.mode = FileDialog.MODE_OPEN_FILE
	file_dialog.add_filter("*.png")
	file_dialog.popup_centered_ratio()
	file_dialog.connect("file_selected",self,"_on_file_selected")

func _on_file_selected(path):
	self.icon_path = path

	
func set_icon_path(v):
	icon_path = v
	if icon_path != "":
		$HBoxContainer2/VBoxIcon/BtnIcon.icon = load(v)
		$HBoxContainer2/VBoxIcon/BtnIcon.text = ""
	else:
		$HBoxContainer2/VBoxIcon/BtnIcon.text = "Select icon..."
		

func set_category_name(v):
	category_name = v
	_on_text_changed(v)

func _on_text_changed(new_text):
	if $HBoxContainer2/VBoxName/LineEditName.text != new_text:
		$HBoxContainer2/VBoxName/LineEditName.text = new_text
	if new_text == "":
		$HBoxContainer2/VBoxName/LblInvalidName.text = 'Empty name field'
	else:
		$HBoxContainer2/VBoxName/LblInvalidName.text = '"'+new_text+'" Already used'
	$HBoxContainer2/VBoxName/LblInvalidName.visible = !check_valid_name(new_text)

func check_valid_name(v):
	if v == "":
		return(false)
	return(not_available_name_list.find(v.to_lower()) == -1 or mode == "Edit")


func _on_clear_icon_pressed():
	self.icon_path = ""


func _on_just_show():
	var line_edit = $HBoxContainer2/VBoxName/LineEditName
	line_edit.select(0,line_edit.text.length())
	line_edit.grab_focus()
