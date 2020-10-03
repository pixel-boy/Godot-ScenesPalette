tool
extends Container


signal category_count_changed(category_count)
signal change_category(category)
signal new_category(data)
signal remove_category(category_name)

const spacing = 48

var columns = 2
var file_dialog = null

var category_id = 0 setget set_category_id
onready var btn_category = preload("res://addons/ScenesPalette/SceneDock/BtnCategory/BtnCategory.tscn")
onready var dialog_category = preload("res://addons/ScenesPalette/SceneDock/DialogCategory/DialogCategory.tscn")


func _ready():
	connect("category_count_changed",self,"_on_category_count_changed")


func _on_add_pressed():
	var category = create_category()
	category.connect("just_confirmed",self,"add_category")
	category.connect("on_cancel",self,"cancel_dialog")


func cancel_dialog():
	if file_dialog:
		file_dialog.queue_free()
		file_dialog = null

func create_category(category_name = "",category_icon = "",mode="Create"):
	if !file_dialog:
		file_dialog = dialog_category.instance()
		file_dialog.category_name = category_name
		file_dialog.icon_path = category_icon
		file_dialog.mode = mode
		for key in owner.my_scn_list.list:
			file_dialog.not_available_name_list.append(key.to_lower())
		var base_control = owner.plugin.get_base_control()
		base_control.add_child(file_dialog)
		file_dialog.popup_centered_ratio(0.15)
		return(file_dialog)
		file_dialog = null


func _on_remove_pressed():
	remove_category()


func load_category(my_scn_list):
	var list = my_scn_list.list
	for data in list:
		var inst = btn_category.instance()
		add_child(inst)
		set_btn_data(inst,list[data])
	emit_signal("category_count_changed",get_child_count())
	if my_scn_list.last_category != "":
		var i = 0
		for data in list:
			if my_scn_list.last_category == list[data]["Name"]:
				select_category(i)
			i+= 1
	else:
		select_category(0)



func add_category(data):
	var inst = btn_category.instance()
	add_child(inst)
	set_btn_data(inst,data)
	emit_signal("new_category",data)
	emit_signal("category_count_changed",get_child_count())
	select_category(get_child_count()-1)


func edit_category(data):
	var child = get_child(category_id)
	owner.edit_category(child.category_name,data)
	set_btn_data(child,data)


func remove_category():
	var child = get_child(category_id)
	emit_signal("remove_category",child.category_name)
	child.queue_free()
	self.category_id -= 1
	emit_signal("category_count_changed",get_child_count()-1)


func set_category_id(id):
	pass
	category_id = clamp(id,0,get_child_count()-1)
	select_category(category_id)


func set_btn_data(btn,data):
	btn.category_name = data["Name"]
	btn.icon_path = data["Icon"]


func select_category(id):
	for child in get_children():
		child.selected = child.get_index() == id
		if child.get_index() == id:
			emit_signal("change_category",child.category_name)
			


func _on_category_count_changed(v):
	var btn_remove = owner.get_node("HBox/VBox/ToolBox/BtnRemove")
	var btn_edit = owner.get_node("HBox/VBox/ToolBox/BtnEdit")
	btn_remove.disabled = v <= 1
	_on_resized()


func _on_resized():
	update_columns_width()


func _on_sort_children():
	var pos = Vector2()
	for child in get_children():
		if !child.visible:
			continue
		child.rect_position = pos*spacing
		pos.x += 1
		if pos.x > columns-1:
			pos.x = 0
			pos.y += 1


func update_columns_width():
	var columns_width = spacing
	var marge = 32
	columns = floor((rect_size.x)/columns_width)
	var category_nbr = get_child_count()
	var nbr_line = clamp(ceil((category_nbr)/columns),1,category_nbr)
	get_parent().rect_min_size.y = (nbr_line*spacing)+6


func _on_btn_edit_pressed():
	var category_name = get_child(category_id).category_name
	var old_data = owner.my_scn_list.list[category_name]
	var category = create_category(category_name,old_data["Icon"],"Edit")
	category.connect("just_confirmed",self,"edit_category")
	category.connect("on_cancel",self,"cancel_dialog")
