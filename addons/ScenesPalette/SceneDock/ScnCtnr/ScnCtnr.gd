tool
extends Container

# panels containing the list of scenes, it is possible to drop scenes inside to add them to the list

signal change_mode(mode)

const spacing = 56

var mode = "Tile" setget set_mode
var columns = 2


func _ready():
	self.mode = mode

func set_mode(v):
	mode = v
	_on_change_mode(mode)
	match mode:
		"Tile":
			columns = 2
		"List":
			columns = 1


func _on_change_mode(v):
	mode = v
	for child in get_children():
		child.mode = v


func _on_resized():
	update_columns_width()


func update_columns_width():
	var columns_width = spacing
	var marge = 44
	if mode == "List":
		columns = 1
	else:
		columns = floor((rect_size.x-marge)/columns_width)


func _on_sort_children():
	if mode == "Tile":
		var pos = Vector2()
		for child in get_children():
			if !child.visible:
				continue
			child.rect_position = pos*spacing
			child.rect_size.x = spacing
			pos.x += 1
			if pos.x > columns:
				pos.x = 0
				pos.y += 1
	else:
		var pos = Vector2()
		for child in get_children():
			if !child.visible:
				continue
			child.rect_position = pos*spacing
			child.rect_size.x = rect_size.x
			pos.y+= 1
			print("Sort children")

func _on_filter_changed(new_text):
	var t = new_text.to_lower()
	for child in get_children():
		var n = child.scn_name.to_lower()
		var v = n.find(t) != -1
		if new_text == "":
			v = true
		child.visible = v
