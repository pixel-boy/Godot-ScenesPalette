tool
extends Button

# Button used for categories, if it does not have an icon it displays its text.

signal on_selected
signal on_edit
var selected = false setget set_selected
var category_name = "Category" setget set_category_name
var icon_path = "" setget set_icon_path
onready var parent = get_parent()


func _ready():
	connect("on_edit",parent,"_on_btn_edit_pressed")
	set("custom_styles/hover",get_stylebox("selected_focus", "ItemList"))
	set("custom_styles/normal",get_stylebox("selected_focus", "ItemList"))
	set("custom_styles/pressed",get_stylebox("DebuggerPanel", "EditorStyles"))
	set("custom_styles/focus",get_stylebox("DebuggerPanel", "EditorStyles"))
	update_font()


# Change the font size according to the length of the text
func update_font():
	if text.length() < 4:
		set("custom_fonts/font",get_font("doc_title", "EditorFonts"))
	else:
		set("custom_fonts/font",get_font("output_source", "EditorFonts"))


func set_selected(v):
	selected = v
	pressed = selected


# Opens the category edit window if double click
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if get_global_rect().has_point(event.position):
				if event.doubleclick:
					emit_signal("on_edit")


func _on_pressed(v):
	if v:
		parent.category_id = get_index()


func set_category_name(v):
	category_name = v
	hint_tooltip = category_name


func set_icon_path(v):
	icon_path = v
	if icon_path != "":
		icon = load(icon_path)
	else:
		icon = null
		text = category_name
		update_font()
