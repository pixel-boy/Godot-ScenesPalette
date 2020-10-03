tool
extends PanelContainer

# The complete dock, it is positioned to the right of the stage screen when "2D" mode is selected
# It contains all the other elements

signal drop_file(files)
var plugin = null setget set_plugin
var inst = null
var provider : EditorResourcePreview = null
var data = ""
var save_path = "user:///SceneDock/ScnList.tres"
var my_scn_list:ScnList = null
var category = "" setget set_category
var hidden = false setget set_hidden
var old_offset = -200

onready var btn_scn = preload("res://addons/ScenesPalette/SceneDock/BtnScn/BtnScn.tscn")
onready var scn_ctnr = preload("res://addons/ScenesPalette/SceneDock/ScnCtnr/ScnCtnr.tscn")
onready var lbl_info = $HBox/VBox/TabContainer/Panel/LblInfo
onready var tab_category = $HBox/VBox/TabContainer/Panel/List/TabCategory


func _ready():
	connect("drop_file",self,"on_drop_file")
	# Define the style of the different dock elements
	set("custom_styles/panel",get_stylebox("tab_fg", "TabContainer"))
	$HBox/VBox/TabContainer.set("custom_styles/panel",get_stylebox("SceneTabBG", "EditorStyles"))
	$HBox/VBox/TabContainer/Panel/List/LineFilter.right_icon = get_icon("Search", "EditorIcons")
	$HBox/VBox/TabContainer/Panel/List/LineFilter.set("custom_styles/normal",get_stylebox("Background", "EditorStyles"))
	$HBox/VBox/TabContainer/Panel/List/LineFilter.set("custom_styles/focus",get_stylebox("Background", "EditorStyles"))
	$HBox/VBox/TabContainer/Panel/List/HBox/LblCategory.set("custom_styles/normal",get_stylebox("read_only", "LineEdit"))
	$HBox/VBox/Panel/GridCategory.set("custom_styles/panel",get_stylebox("SceneTabBG", "EditorStyles"))
	$HBox/VBox/Panel.set("custom_styles/panel",get_stylebox("selected_focus", "ItemList"))
	$HBox/VBox/TabContainer/Panel/List/TabCategory.set("custom_styles/panel",StyleBoxEmpty.new())
	lbl_info.set("custom_fonts/font",get_font("doc_title", "EditorFonts"))

#
#func can_drop_data(pos,data):
#	return(true)


func _input(event):
	if !visible:
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			# Drop scene into the dock to add it to the current category
			if mouse_on_dock():
				if !event.is_pressed():
					if get_viewport().gui_is_dragging():
						data = get_viewport().gui_get_drag_data()
						emit_signal("drop_file",data)
					reset_data()
			else:
				# Drop scene into the scene view to instanciate it
				if !event.is_pressed():
					if mouse_on_scene_view():
						if valid_scn_path(data) and data != "":
							var inst = load(data).instance()
							var root = plugin.get_root()
							root.add_child(inst)
							inst.set_owner(root)
							if inst is Node2D:
								inst.set_global_position(plugin.get_mouse_pos())
							else:
								inst._set_global_position(plugin.get_mouse_pos())
								
					reset_data()


func reset_data():
	data = ""


func mouse_on_scene_view():
	return(plugin.get_canvas_editor().get_global_rect().has_point(get_global_mouse_position()))


func mouse_on_dock():
	return(get_global_rect().has_point(get_global_mouse_position()))


func set_plugin(v):
	plugin = v


func set_preview_provider(v : EditorResourcePreview):
	provider = v
	if !provider.is_connected("preview_invalidated", self, "_on_preview_invalidated"):
		provider.connect("preview_invalidated", self, "_on_preview_invalidated")


func on_drop_file(files):
	if files:
		var files_path = []
		if typeof(files) == TYPE_STRING:
			files_path.append(files)
		else:
			for file in files["files"]:
				files_path.append(file)
		for file in files_path:
			if valid_scn_path(file):
				add_scene(tab_category.get_current_tab_control(),file)


func valid_scn_path(v):
	return(v.find(".tscn") != -1)


func selected_btn(btn):
	var tab_node = $HBox/VBox/TabContainer/Panel/List/TabCategory
	for child in tab_node.get_current_tab_control().get_children():
		child.selected = child == btn


func update_preview():
	if !provider:
		return
	for tab in tab_category.get_children():
		for btn in tab.get_children():
			provider.queue_resource_preview(btn.path,btn,"set_texture",null)


func _on_preview_invalidated(path):
	if path.find(".tscn") != -1:
		update_preview()


func add_scene(ctnr,path):
	if !has_btn_scn(ctnr,path):
		var inst = btn_scn.instance()
		ctnr.add_child(inst)
		inst.path = path
		inst.set_owner(self)
		inst.mode = ctnr.mode
		inst.connect("scene_remove",self,"_on_scene_removed")
		if category != "":
			my_scn_list.add_scn(category,path)
	save()
	update_preview()

func _on_scene_removed(path):
	my_scn_list.remove_scn(category,path)
	save()


func save_scn_list():
	ResourceSaver.save(save_path,my_scn_list)


func has_btn_scn(ctnr,path):
	for btn in ctnr.get_children():
		if btn.path == path:
			return(true)
	return(false)


func load_scn_list(loading = true):
	var file = File.new()
	if file.file_exists(save_path):
		my_scn_list = ResourceLoader.load(save_path)
	else:
		my_scn_list = ScnList.new()
		save()
	if loading:
		load_category()


func load_category():
	var list = my_scn_list.list
	for key in list:
		var inst = scn_ctnr_instance()
		inst.name = key
		tab_category.add_child(inst)
		for scn in list[key]["Scenes"]:
			add_scene(inst,scn)
	$HBox/VBox/Panel/GridCategory.load_category(my_scn_list)
	update_preview()

func scn_ctnr_instance():
	var inst = scn_ctnr.instance()
	$HBox/VBox/TabContainer/Panel/List/HBox/BtnPanels4.connect("change_mode",inst,"_on_change_mode")
	$HBox/VBox/TabContainer/Panel/List/LineFilter.connect("text_changed",inst,"_on_filter_changed")
	return(inst)


func set_category(v):
	if !my_scn_list:
		load_scn_list(false)
	if v != category:
		category = v
		var tab = $HBox/VBox/TabContainer/Panel/List/TabCategory
		var tab_node = $HBox/VBox/TabContainer/Panel/List/TabCategory
		if tab.has_node(category):
			tab_node.current_tab = tab_node.get_node(category).get_index()
		$HBox/VBox/TabContainer/Panel/List/HBox/LblCategory.text = category
		my_scn_list.last_category = category
		save()


func save():
	$SaveTimer.stop()
	$SaveTimer.start()


func _on_save_timeout():
	save_scn_list()


func _on_new_category(data):
	var inst = scn_ctnr_instance()
	inst.name = data["Name"]
	tab_category.add_child(inst)
	my_scn_list.generate_category(data)


func _on_remove_category(category_name):
	tab_category.get_current_tab_control().queue_free()
	my_scn_list.remove_category(category_name)


func edit_category(old_name,data):
	tab_category.get_node(old_name).name = data["Name"]
	my_scn_list.edit_category(old_name,data)


func set_hidden(v):
	hidden = v
	update_hide()


func update_hide():
	$HBox/VBox.visible = !hidden
	$HBox/BtnShow.visible = hidden
	$HBox/VBox/ToolBox/BtnHide.visible = !hidden
	if hidden:
		if get_parent().split_offset != 0:
			old_offset = get_parent().split_offset
		get_parent().split_offset = 0
	else:
		get_parent().split_offset = old_offset


func _on_visibility_toggled(v):
	self.hidden = v


func _on_visibility_changed():
	old_offset = get_parent().split_offset
	update_hide()


func _on_BtnShow_pressed():
	self.hidden = false
	update_hide()

func _on_btn_hide_pressed():
	self.hidden = true
	update_hide()
