tool
extends EditorPlugin

# The plugin script, it instantiates the dock, activates and deactivates it depending on the situation, 
# and makes the link with the Godot editor and the dock

var dock = null
var filesystem_dock = get_editor_interface().get_file_system_dock()
var editor_selection = get_editor_interface().get_selection()
var active = true setget set_active 
var file_moved_history = []


func _enter_tree():
	connect("main_screen_changed",self,"_on_main_screen_changed")
	filesystem_dock.connect("files_moved",self,"_on_files_moved")
	editor_selection.connect("selection_changed",self,"_on_selection_changed")
	instanciate_dock()


func _exit_tree():
	remove_dock()


func _on_main_screen_changed(screen_name: String):
	self.active = screen_name == "2D"
	check_selected_node()


func set_active(v):
	active = v
	if !dock:
		instanciate_dock()
	dock.plugin = self
	if active:
		dock.visible = true
	else:
		dock.visible = false


func instanciate_dock():
	if !dock:
		dock = preload("res://addons/ScenesPalette/SceneDock/SceneDock.tscn").instance()
		dock.plugin = self
		add_control_to_container(CONTAINER_CANVAS_EDITOR_SIDE_RIGHT, dock)
		dock.set_preview_provider(get_editor_interface().get_resource_previewer())
		dock.load_scn_list()
		update_reference()


func remove_dock():
	if dock:
		remove_control_from_container(CONTAINER_CANVAS_EDITOR_SIDE_RIGHT,dock)
		dock.free()
		dock = null


func update_reference():
	for change in file_moved_history:
		dock.my_scn_list.update_ref(change)
	file_moved_history.clear()


func _on_files_moved(old,new):
	var dict = {
		"old":old,
		"new":new,
	}
	file_moved_history.append(dict)
	if dock:
		update_reference()
		dock.save()
		dock.load_current_category()


func _on_selection_changed():
	check_selected_node()


func check_selected_node():
	var nodes = editor_selection.get_selected_nodes()
	if nodes.size():
		if nodes[0] is TileMap:
			dock.visible = false
		else:
			dock.visible = true


func get_canvas_editor():
	var canvas = get_editor_interface().get_editor_viewport().get_child(0)
	return(canvas)


func get_root():
	return(get_tree().get_edited_scene_root())


func get_mouse_pos():
	return(get_root().get_global_mouse_position())


func open_scene(path):
	get_editor_interface().open_scene_from_path(path)


func get_system_file():
	return(get_editor_interface().get_current_path())

func get_base_control():
	return(get_editor_interface().get_base_control())
